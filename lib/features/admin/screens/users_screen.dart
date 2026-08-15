import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  String _selectedFilter = 'Tous';
  int _currentNavIndex = 1; // Index par défaut pour "Users" (0: Dashboard, 1: Users, 2: Alerts)

  // Coordonnées pour le bouton d'ajout déplaçable
  double? _fabX;
  double? _fabY;

  // Contrôleur pour la recherche
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Dialogue pour modifier un utilisateur en direct-direct
  void _showEditUserDialog(BuildContext context, String docId, Map<String, dynamic> userData) {
    final nameController = TextEditingController(text: userData['name'] ?? '');
    final matriculeController = TextEditingController(text: userData['matricule'] ?? '');
    String selectedRole = userData['role'] ?? 'student';
    String selectedStatus = userData['status'] ?? 'active';

    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colorScheme.surface,
              title: Text(
                'Modifier l\'utilisateur',
                style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom complet',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: matriculeController,
                      decoration: const InputDecoration(
                        labelText: 'Matricule',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Rôle',
                        border: OutlineInputBorder(),
                      ),
                      dropdownColor: colorScheme.surface,
                      items: const [
                        DropdownMenuItem(value: 'student', child: Text('Étudiant')),
                        DropdownMenuItem(value: 'teacher', child: Text('Enseignant')),
                        DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedRole = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Statut',
                        border: OutlineInputBorder(),
                      ),
                      dropdownColor: colorScheme.surface,
                      items: const [
                        DropdownMenuItem(value: 'active', child: Text('Actif')),
                        DropdownMenuItem(value: 'inactive', child: Text('Suspendu')),
                        DropdownMenuItem(value: 'pending', child: Text('En attente')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedStatus = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Annuler', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Le nom ne peut pas être vide !')),
                      );
                      return;
                    }
                    await _firestore.collection('users').doc(docId).update({
                      'name': nameController.text.trim(),
                      'matricule': matriculeController.text.trim().toUpperCase(),
                      'role': selectedRole,
                      'status': selectedStatus,
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Utilisateur mis à jour avec succès !')),
                      );
                    }
                  },
                  child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildAnalyticsSection(context),
                  const SizedBox(height: 32),
                  _buildSearchAndFilters(context),
                  const SizedBox(height: 24),
                  _buildUserListStream(context),
                  const SizedBox(height: 240), // Plus d'espace pour éviter le masquage par la nav bar
                ],
              ),
            ),
          ),
          _buildFAB(context),
          _buildBottomNavBar(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'University Admin',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gestion des utilisateurs', style: AppTextStyles.headlineLarge),
        Text(
          'Supervisez les comptes académiques en temps réel',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        final total = docs.length;
        final students = docs.where((d) => (d.data() as Map<String, dynamic>)['role'] == 'student').length;
        final teachers = docs.where((d) => (d.data() as Map<String, dynamic>)['role'] == 'teacher').length;
        final pending = docs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'pending').length;

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _buildStatCard(context, 'Total utilisateurs', '$total', null, () {
              setState(() => _selectedFilter = 'Tous');
            }),
            _buildStatCard(context, 'Étudiants', '$students', AppColors.primary, () {
              setState(() => _selectedFilter = 'Étudiants');
            }),
            _buildStatCard(context, 'Enseignants', '$teachers', AppColors.amber, () {
              setState(() => _selectedFilter = 'Enseignants');
            }),
            _buildStatCard(context, 'En attente', '$pending', Colors.orange, () {
              setState(() => _selectedFilter = 'En attente');
            }),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color? borderColor, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: borderColor != null 
            ? Border(left: BorderSide(color: borderColor, width: 4))
            : Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.headlineMedium.copyWith(
                color: borderColor ?? AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Rechercher par nom ou matricule',
              prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.onSurfaceVariant),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Tous'),
              const SizedBox(width: 8),
              _buildFilterChip('Étudiants'),
              const SizedBox(width: 8),
              _buildFilterChip('Enseignants'),
              const SizedBox(width: 8),
              _buildFilterChip('Administrateurs'),
              const SizedBox(width: 8),
              _buildFilterChip('En attente'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isActive ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildUserListStream(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'Aucun utilisateur trouvé dans Firestore',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        // Filtrer localement selon la recherche et le filtre sélectionné
        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          final matricule = (data['matricule'] ?? '').toString().toLowerCase();
          final role = (data['role'] ?? '').toString();
          final status = (data['status'] ?? '').toString();

          final matchesSearch = name.contains(_searchQuery.toLowerCase()) ||
              matricule.contains(_searchQuery.toLowerCase());

          if (_selectedFilter == 'Tous') {
            return matchesSearch;
          } else if (_selectedFilter == 'Étudiants') {
            return matchesSearch && role == 'student';
          } else if (_selectedFilter == 'Enseignants') {
            return matchesSearch && role == 'teacher';
          } else if (_selectedFilter == 'Administrateurs') {
            return matchesSearch && role == 'admin';
          } else if (_selectedFilter == 'En attente') {
            return matchesSearch && status == 'pending';
          }
          return matchesSearch;
        }).toList();

        if (filteredDocs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'Aucun utilisateur ne correspond aux critères',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredDocs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            final name = data['name'] ?? 'Sans nom';
            final matricule = data['matricule'] ?? 'Pas de matricule';
            final role = data['role'] ?? 'student';
            final status = data['status'] ?? 'active';

            String displayRole = 'Étudiant';
            if (role == 'teacher') displayRole = 'Enseignant';
            if (role == 'admin') displayRole = 'Administrateur';

            final isActive = status == 'active';

            return _buildUserCard(
              context,
              name,
              matricule,
              displayRole,
              isActive,
              status == 'pending',
              doc.id,
              data,
            );
          },
        );
      },
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    String name,
    String id,
    String role,
    bool isActive,
    bool isPending,
    String docId,
    Map<String, dynamic> userRaw,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    Color roleColor;
    if (role == 'Étudiant') {
      roleColor = AppColors.primary; // Vert
    } else if (role == 'Enseignant') {
      roleColor = AppColors.amber; // Orange comme demandé
    } else {
      roleColor = const Color(0xFF974946); // Rouge pour Admin
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          // Le cercle de profil a été retiré ici pour un design plus épuré
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name, 
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: roleColor, // Couleur du texte selon le rôle (Vert, Orange, Rouge)
                  )
                ),
                Text(id, style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  role.toUpperCase(),
                  style: TextStyle(color: roleColor, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isPending 
                          ? Colors.orange 
                          : (isActive ? AppColors.primary : AppColors.error),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isPending ? 'En attente' : (isActive ? 'Actif' : 'Suspendu'),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
            color: colorScheme.surface,
            onSelected: (value) async {
              if (value == 'toggle_status') {
                final nextStatus = isActive ? 'inactive' : 'active';
                await _firestore.collection('users').doc(docId).update({
                  'status': nextStatus,
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Statut de $name mis à jour !')),
                  );
                }
              } else if (value == 'approve') {
                await _firestore.collection('users').doc(docId).update({
                  'status': 'active',
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Compte de $name approuvé avec succès !')),
                  );
                }
              } else if (value == 'delete') {
                await _firestore.collection('users').doc(docId).delete();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$name a été supprimé.')),
                  );
                }
              } else if (value == 'edit') {
                _showEditUserDialog(context, docId, userRaw);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: colorScheme.onSurface),
                    const SizedBox(width: 8),
                    const Text('Modifier'),
                  ],
                ),
              ),
              if (isPending)
                PopupMenuItem<String>(
                  value: 'approve',
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text('Approuver le compte'),
                    ],
                  ),
                )
              else
                PopupMenuItem<String>(
                  value: 'toggle_status',
                  child: Row(
                    children: [
                      Icon(
                        isActive ? Icons.block : Icons.check_circle_outline,
                        size: 18,
                        color: isActive ? AppColors.error : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(isActive ? 'Suspendre' : 'Activer'),
                    ],
                  ),
                ),
              PopupMenuItem<String>(
                value: 'delete',
                child: const Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Supprimer', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final defaultX = size.width - 160.0;
    final defaultY = size.height - 180.0;

    return StatefulBuilder(
      builder: (context, setFabState) {
        final x = _fabX ?? defaultX;
        final y = _fabY ?? defaultY;

        return Positioned(
          left: x,
          top: y,
          child: GestureDetector(
            onPanUpdate: (details) {
              setFabState(() {
                // Déplacement fluide sans refresh de la page entière
                _fabX = (x + details.delta.dx).clamp(10.0, size.width - 160.0);
                _fabY = (y + details.delta.dy).clamp(80.0, size.height - 150.0);
              });
            },
            child: ElevatedButton.icon(
              onPressed: () => context.push('/admin-add-user'),
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text('Ajouter', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 10,
                shadowColor: Colors.black.withValues(alpha: 0.4),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        top: false,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            border: Border(top: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.05))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(0, Icons.dashboard, 'Dashboard'),
              _buildBottomNavItem(1, Icons.group, 'Users'),
              _buildBottomNavItem(2, Icons.notifications, 'Alertes'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    final isActive = _currentNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentNavIndex = index;
        });
        if (index == 0) {
          context.go('/admin-dashboard');
        } else if (index == 2) {
          context.go('/admin-announcements');
        }
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.amber : AppColors.onSurfaceVariant,
            ),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isActive ? AppColors.amber : AppColors.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
