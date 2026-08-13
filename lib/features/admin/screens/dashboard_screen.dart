import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  int _studentCount = 0;
  int _teacherCount = 0;
  int _announcementCount = 0;
  int _courseCount = 0;
  int _pendingUsersCount = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _dynamicActivities = [];

  // Infos de l'administrateur connecté
  String _adminName = 'Administrateur';
  String? _adminPhotoUrl;

  // État du système dynamique
  DateTime _lastSyncTime = DateTime.now();
  bool _isFirebaseConnected = true;

  // Abonnements pour écouter Firestore en temps réel
  StreamSubscription? _adminSubscription;
  StreamSubscription? _studentsSubscription;
  StreamSubscription? _teachersSubscription;
  StreamSubscription? _announcementsSubscription;
  StreamSubscription? _coursesSubscription;
  StreamSubscription? _recentAnnouncementsSubscription;
  StreamSubscription? _pendingUsersSubscription;

  @override
  void initState() {
    super.initState();
    _initRealtimeListeners();
  }

  @override
  void dispose() {
    // On libère les abonnements pour éviter les fuites de mémoire, mola
    _adminSubscription?.cancel();
    _studentsSubscription?.cancel();
    _teachersSubscription?.cancel();
    _announcementsSubscription?.cancel();
    _coursesSubscription?.cancel();
    _recentAnnouncementsSubscription?.cancel();
    _pendingUsersSubscription?.cancel();
    super.dispose();
  }

  // Générer la salutation dynamique en fonction de l'heure
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 18) {
      return 'Bonjour';
    } else {
      return 'Bonsoir';
    }
  }

  // Générer la date du jour dynamiquement en français
  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
    final months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    final weekdayStr = weekdays[now.weekday % 7];
    final monthStr = months[now.month - 1];
    return '$weekdayStr ${now.day} $monthStr ${now.year}';
  }

  void _initRealtimeListeners() {
    setState(() {
      _isLoading = true;
    });

    // 0. Écouter les infos de l'admin connecté
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      _adminSubscription = _firestore
          .collection('users')
          .doc(currentUser.uid)
          .snapshots()
          .listen((doc) {
        if (mounted && doc.exists) {
          setState(() {
            _adminName = doc.data()?['name'] ?? 'Administrateur';
            _adminPhotoUrl = doc.data()?['photoUrl'];
          });
        }
      }, onError: (e) => debugPrint("Erreur chargement profil admin: $e"));
    }

    // 1. Écouter les étudiants en temps réel
    _studentsSubscription = _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _studentCount = snapshot.docs.length;
          _lastSyncTime = DateTime.now();
          _isFirebaseConnected = true;
          _checkLoadingFinished();
        });
      }
    }, onError: (e) {
      debugPrint("Erreur étudiants temps réel: $e");
      if (mounted) setState(() => _isFirebaseConnected = false);
    });

    // 2. Écouter les enseignants en temps réel
    _teachersSubscription = _firestore
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _teacherCount = snapshot.docs.length;
          _lastSyncTime = DateTime.now();
          _checkLoadingFinished();
        });
      }
    }, onError: (e) => debugPrint("Erreur enseignants temps réel: $e"));

    // 3. Écouter tous les communiqués en temps réel
    _announcementsSubscription = _firestore
        .collection('announcements')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _announcementCount = snapshot.docs.length;
          _lastSyncTime = DateTime.now();
          _checkLoadingFinished();
        });
      }
    }, onError: (e) => debugPrint("Erreur communiqués temps réel: $e"));

    // 4. Écouter tous les cours en temps réel
    _coursesSubscription = _firestore
        .collection('courses')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _courseCount = snapshot.docs.length;
          _lastSyncTime = DateTime.now();
          _checkLoadingFinished();
        });
      }
    }, onError: (e) => debugPrint("Erreur cours temps réel: $e"));

    // 5. Écouter les utilisateurs en attente d'approbation (status == pending)
    _pendingUsersSubscription = _firestore
        .collection('users')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _pendingUsersCount = snapshot.docs.length;
          _lastSyncTime = DateTime.now();
          _checkLoadingFinished();
        });
      }
    }, onError: (e) => debugPrint("Erreur pending users temps réel: $e"));

    // 6. Écouter les activités récentes (les 3 derniers communiqués et utilisateurs)
    _recentAnnouncementsSubscription = _firestore
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .limit(3)
        .snapshots()
        .listen((announcementsSnapshot) async {
      List<Map<String, dynamic>> tempActivities = [];

      // Ajouter les communiqués récents
      for (var doc in announcementsSnapshot.docs) {
        final data = doc.data();
        final title = data['title'] ?? 'Nouveau communiqué';
        
        // Parsing robuste de la date pour éviter le crash mola
        DateTime? createdDateTime;
        final rawCreatedAt = data['createdAt'];
        if (rawCreatedAt is Timestamp) {
          createdDateTime = rawCreatedAt.toDate();
        } else if (rawCreatedAt is String) {
          createdDateTime = DateTime.tryParse(rawCreatedAt);
        }

        tempActivities.add({
          'icon': Icons.campaign,
          'text': 'Communiqué : $title',
          'time': createdDateTime != null ? _formatDateTime(createdDateTime) : 'Récemment',
          'color': const Color(0xFFFFB300),
        });
      }

      // Récupérer aussi rapidement les 2 derniers utilisateurs inscrits
      try {
        final recentUsers = await _firestore
            .collection('users')
            .orderBy('createdAt', descending: true)
            .limit(2)
            .get();

        for (var doc in recentUsers.docs) {
          final data = doc.data();
          final name = data['name'] ?? 'Utilisateur';
          final rawRole = data['role'] ?? 'student';
          
          // Correction de la bavure sur les rôles mola !
          String roleLabel = 'Étudiant';
          if (rawRole == 'teacher') {
            roleLabel = 'Enseignant';
          } else if (rawRole == 'admin') {
            roleLabel = 'Administrateur';
          }

          tempActivities.add({
            'icon': Icons.person_add,
            'text': 'Nouvel inscrit ($roleLabel) : $name',
            'time': 'Actif',
            'color': AppColors.secondary,
          });
        }
      } catch (e) {
        debugPrint("Erreur lors du fetch des utilisateurs récents: $e");
      }

      if (tempActivities.isEmpty) {
        tempActivities = [
          {
            'icon': Icons.upload,
            'text': 'Système prêt et synchronisé en temps réel',
            'time': 'À l\'instant',
            'color': AppColors.primary,
          }
        ];
      }

      if (mounted) {
        setState(() {
          _dynamicActivities = tempActivities;
          _checkLoadingFinished();
        });
      }
    }, onError: (e) => debugPrint("Erreur activités temps réel: $e"));
  }

  void _checkLoadingFinished() {
    if (_isLoading) {
      _isLoading = false;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else {
      return 'Il y a ${difference.inDays} jours';
    }
  }

  // Permet de forcer manuellement une re-synchro si besoin
  Future<void> _handleRefresh() async {
    _adminSubscription?.cancel();
    _studentsSubscription?.cancel();
    _teachersSubscription?.cancel();
    _announcementsSubscription?.cancel();
    _coursesSubscription?.cancel();
    _recentAnnouncementsSubscription?.cancel();
    _pendingUsersSubscription?.cancel();
    _initRealtimeListeners();
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildAppBar(context),
          Positioned.fill(
            top: 80,
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: theme.colorScheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(context),
                    const SizedBox(height: 16),
                    _buildPendingAlertBanner(context),
                    const SizedBox(height: 16),
                    _buildKPIStats(context),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    _buildSystemHealth(context),
                    const SizedBox(height: 24),
                    _buildRecentActivity(context),
                    const SizedBox(height: 120), // Espace pour la barre de navigation
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.05))),
          ),
          child: Row(
            children: [
              // Retrait du menu burger inutile mola
              Text(
                'Acadify UIECC',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: colorScheme.primary, 
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'ADMIN',
                  style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
              const Spacer(),
              // Cercle de profil cliquable et dynamique
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2), width: 2),
                    color: colorScheme.surfaceContainer,
                  ),
                  child: ClipOval(
                    child: _adminPhotoUrl != null && _adminPhotoUrl!.isNotEmpty
                        ? Image.network(
                            _adminPhotoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            color: colorScheme.onSurfaceVariant,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB300).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFB300).withValues(alpha: 0.2)),
              ),
              child: const Text(
                'Administrateur',
                style: TextStyle(color: Color(0xFFFFB300), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const Spacer(),
            Text(
              _getFormattedDate(),
              style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Salutation chaleureuse et dynamique avec le nom de l'admin
        Text(
          '${_getGreeting()}, $_adminName',
          style: AppTextStyles.headlineLarge.copyWith(color: colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Tableau de bord',
          style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildPendingAlertBanner(BuildContext context) {
    if (_pendingUsersCount == 0) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => context.push('/admin-users'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.gpp_maybe, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Validation requise',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.orange,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Il y a $_pendingUsersCount compte(s) en attente d\'approbation.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurface,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.orange, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildKPIStats(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        _buildKPICard(
          context, 
          _isLoading ? '...' : '$_studentCount', 
          'Étudiants actifs', 
          Icons.group, 
          colorScheme.secondary, 
          _isLoading ? '' : 'Live',
          () => context.push('/admin-users'), // Redirection vers la gestion des utilisateurs
        ),
        _buildKPICard(
          context, 
          _isLoading ? '...' : '$_teacherCount', 
          'Enseignants', 
          Icons.school, 
          const Color(0xFFFFB300), 
          _isLoading ? '' : 'Live',
          () => context.push('/admin-users'), // Redirection vers la gestion des utilisateurs
        ),
        _buildKPICard(
          context, 
          _isLoading ? '...' : '$_announcementCount', 
          'Communiqués', 
          Icons.campaign, 
          colorScheme.primary, 
          _isLoading ? '' : 'Live',
          () => context.push('/admin-announcements'), // Redirection vers la gestion des communiqués
        ),
        _buildKPICard(
          context, 
          _isLoading ? '...' : '$_courseCount', 
          'Cours créés', 
          Icons.folder_open, 
          const Color(0xFFFFB300), 
          _isLoading ? '' : 'Live',
          () => context.push('/admin-announcements'), // Redirection vers les cours/annonces
        ),
      ],
    );
  }

  Widget _buildKPICard(BuildContext context, String value, String label, IconData icon, Color color, String trend, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: color, size: 18),
                ),
                if (trend.isNotEmpty)
                  Text(
                    trend, 
                    style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 10)
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value, 
                        style: AppTextStyles.headlineLarge.copyWith(fontSize: 24, color: colorScheme.onSurface, fontWeight: FontWeight.bold)
                      ),
                    ),
                    Text(
                      label, 
                      style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Actions rapides', style: AppTextStyles.headlineMedium.copyWith(color: colorScheme.onSurface, fontSize: 18)),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Toutes les actions sont déjà affichées ci-dessous !')),
                );
              },
              child: Text('Tout voir', style: AppTextStyles.labelMedium.copyWith(color: const Color(0xFFFFB300))),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _buildActionItem(context, Icons.post_add, 'Nouveau communiqué', colorScheme.primary, () => context.push('/admin-compose-announcement')),
            _buildActionItem(context, Icons.person_add, 'Ajouter utilisateur', colorScheme.secondary, () => context.push('/admin-add-user')),
            _buildActionItem(context, Icons.manage_accounts, 'Gérer communiqués', const Color(0xFFFFB300), () => context.push('/admin-announcements')),
            _buildActionItem(context, Icons.group_work, 'Gérer utilisateurs', colorScheme.onSurfaceVariant, () => context.push('/admin-users')),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                label, 
                style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurface, fontSize: 12), 
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemHealth(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Formatage de la dernière synchro en temps réel
    final syncHour = "${_lastSyncTime.hour.toString().padLeft(2, '0')}:${_lastSyncTime.minute.toString().padLeft(2, '0')}:${_lastSyncTime.second.toString().padLeft(2, '0')}";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: colorScheme.secondary, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_heart, color: colorScheme.secondary, size: 20),
              const SizedBox(width: 8),
              Text('État du système', style: AppTextStyles.headlineMedium.copyWith(color: colorScheme.onSurface, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          _buildHealthRow(context, 'Firebase connection', _isFirebaseConnected ? 'Connecté' : 'Déconnecté', _isFirebaseConnected),
          _buildHealthRow(context, 'Notifications FCM', _isFirebaseConnected ? 'Opérationnel' : 'Ralenti', _isFirebaseConnected),
          _buildHealthRow(context, 'Dernière synchro', syncHour, null),
          const SizedBox(height: 12),
          Text('Storage usage (234 Mo / 1 Go)', style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurface, fontSize: 11)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.23,
              backgroundColor: colorScheme.surfaceContainer,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRow(BuildContext context, String label, String status, bool? isPositive) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 12)),
          Row(
            children: [
              if (isPositive != null)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(color: isPositive ? colorScheme.secondary : colorScheme.error, shape: BoxShape.circle),
                ),
              Text(
                status, 
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold, 
                  color: isPositive == true ? colorScheme.secondary : (isPositive == false ? colorScheme.error : colorScheme.onSurface),
                  fontSize: 12
                )
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activité récente', style: AppTextStyles.headlineMedium.copyWith(color: colorScheme.onSurface, fontSize: 18)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
          ),
          child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: _dynamicActivities.map((activity) {
                    return _buildActivityItem(
                      context, 
                      activity['icon'] as IconData, 
                      activity['text'] as String, 
                      activity['time'] as String, 
                      activity['color'] as Color
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, IconData icon, String text, String time, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface, fontSize: 13)),
                const SizedBox(height: 2),
                Text(time, style: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
