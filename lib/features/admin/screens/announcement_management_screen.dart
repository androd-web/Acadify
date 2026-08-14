import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AdminAnnouncementManagement extends StatefulWidget {
  const AdminAnnouncementManagement({super.key});

  @override
  State<AdminAnnouncementManagement> createState() => _AdminAnnouncementManagementState();
}

class _AdminAnnouncementManagementState extends State<AdminAnnouncementManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _activeFilter = 'Tous';
  String _searchQuery = '';
  final List<String> _filters = ['Tous', 'Urgent', 'Information', 'Général', 'Archivés'];
  final TextEditingController _searchController = TextEditingController();

  // Coordonnées pour rendre le bouton d'ajout déplaçable
  double? _fabX;
  double? _fabY;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                  _buildSearchBar(context),
                  const SizedBox(height: 24),
                  _buildFilters(context),
                  const SizedBox(height: 24),
                  _buildDynamicAnnouncementList(context),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer.withValues(alpha: 0.8),
            border: Border(bottom: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.05))),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Communiqués',
                    style: AppTextStyles.headlineMedium.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('announcements').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      final total = snapshot.data!.docs.length;
                      final archived = snapshot.data!.docs.where((d) {
                        final data = d.data() as Map<String, dynamic>;
                        return data['status'] == 'archived';
                      }).length;
                      final active = total - archived;
                      return Text(
                        '$active publiés · $archived archivés',
                        style: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                      );
                    },
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.amber),
                onPressed: () {
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
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
          hintText: 'Rechercher un communiqué...',
          prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
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
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isActive = _activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _activeFilter = filter),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.amber : colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                  border: isActive ? null : Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
                ),
                child: Text(
                  filter,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isActive ? Colors.black : colorScheme.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDynamicAnnouncementList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('announcements').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'Aucun communiqué trouvé, mola.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        // Filtrage local
        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final title = (data['title'] ?? '').toString().toLowerCase();
          final category = (data['category'] ?? 'info').toString().toLowerCase();
          final status = (data['status'] ?? 'published').toString().toLowerCase();

          final matchesSearch = title.contains(_searchQuery.toLowerCase());

          if (!matchesSearch) return false;

          if (_activeFilter == 'Tous') {
            return status != 'archived';
          } else if (_activeFilter == 'Urgent') {
            return category == 'urgent' && status != 'archived';
          } else if (_activeFilter == 'Information') {
            return category == 'info' && status != 'archived';
          } else if (_activeFilter == 'Général') {
            return category == 'general' && status != 'archived';
          } else if (_activeFilter == 'Archivés') {
            return status == 'archived';
          }
          return true;
        }).toList();

        if (filteredDocs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'Aucun communiqué ne correspond à ce filtre.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredDocs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            final docId = doc.id;

            final title = data['title'] ?? 'Sans titre';
            final category = data['category'] ?? 'info';
            final targetGroup = data['targetGroup'] ?? 'all';
            final status = data['status'] ?? 'published';

            // Parsing robuste de la date pour éviter le crash mola
            DateTime? createdDateTime;
            final rawCreatedAt = data['createdAt'];
            if (rawCreatedAt is Timestamp) {
              createdDateTime = rawCreatedAt.toDate();
            } else if (rawCreatedAt is String) {
              createdDateTime = DateTime.tryParse(rawCreatedAt);
            }

            String displayType = 'Information';
            Color categoryColor = AppColors.secondary;
            IconData categoryIcon = Icons.info;

            if (category == 'urgent') {
              displayType = 'Urgent';
              categoryColor = Theme.of(context).colorScheme.error;
              categoryIcon = Icons.campaign;
            } else if (category == 'general') {
              displayType = 'Général';
              categoryColor = AppColors.amber;
              categoryIcon = Icons.public;
            }

            String timeStr = 'Récemment';
            if (createdDateTime != null) {
              timeStr = '${createdDateTime.day}/${createdDateTime.month} à ${createdDateTime.hour}:${createdDateTime.minute.toString().padLeft(2, '0')}';
            }

            return _buildAnnouncementCard(
              context: context,
              docId: docId,
              color: categoryColor,
              type: displayType,
              icon: categoryIcon,
              time: timeStr,
              title: title,
              tags: [targetGroup == 'all' ? 'Tous' : targetGroup.toUpperCase()],
              status: status == 'archived' ? 'ARCHIVÉ' : 'PUBLIÉ',
              isArchived: status == 'archived',
            );
          },
        );
      },
    );
  }

  Widget _buildAnnouncementCard({
    required BuildContext context,
    required String docId,
    required Color color,
    required IconData icon,
    required String type,
    required String time,
    required String title,
    required List<String> tags,
    required String status,
    required bool isArchived,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 4, height: 60, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: color, size: 16),
                        const SizedBox(width: 4),
                        Text(type.toUpperCase(), style: AppTextStyles.labelSmall.copyWith(color: color, letterSpacing: 1, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text(time, style: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ...tags.map((tag) => Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
                          ),
                          child: Text(tag, style: AppTextStyles.labelSmall.copyWith(fontSize: 10, color: colorScheme.onSurfaceVariant)),
                        )),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isArchived 
                            ? colorScheme.onSurface.withValues(alpha: 0.1)
                            : colorScheme.primaryContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6, 
                            height: 6, 
                            decoration: BoxDecoration(
                              color: isArchived ? colorScheme.onSurfaceVariant : colorScheme.primary, 
                              shape: BoxShape.circle
                            )
                          ),
                          const SizedBox(width: 4),
                          Text(
                            status, 
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 10, 
                              color: isArchived ? colorScheme.onSurfaceVariant : colorScheme.primary, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 18),
                      color: colorScheme.surface,
                      onSelected: (value) async {
                        if (value == 'archive') {
                          await _firestore.collection('announcements').doc(docId).update({
                            'status': isArchived ? 'published' : 'archived',
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isArchived ? 'Communiqué republié !' : 'Communiqué archivé !')),
                            );
                          }
                        } else if (value == 'delete') {
                          await _firestore.collection('announcements').doc(docId).delete();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Communiqué supprimé avec succès !')),
                            );
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'archive',
                          child: Row(
                            children: [
                              Icon(isArchived ? Icons.unarchive : Icons.archive, size: 18),
                              const SizedBox(width: 8),
                              Text(isArchived ? 'Désarchiver' : 'Archiver'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Position par défaut : en bas à droite
    final defaultX = screenWidth - 160.0;
    final defaultY = screenHeight - 160.0;

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
                // On calcule la nouvelle position de manière fluide sans refresh de la page entière
                _fabX = (x + details.delta.dx).clamp(10.0, screenWidth - 160.0);
                _fabY = (y + details.delta.dy).clamp(80.0, screenHeight - 150.0);
              });
            },
            child: FloatingActionButton.extended(
              onPressed: () => context.push('/admin-compose-announcement'),
              backgroundColor: AppColors.amber,
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text('NOUVEAU', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
            color: colorScheme.surfaceContainerLow,
            border: Border(top: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.05))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(context, Icons.grid_view, 'Dashboard', false, () => context.go('/admin-dashboard')),
              _buildBottomNavItem(context, Icons.group, 'Users', false, () => context.go('/admin-users')),
              _buildBottomNavItem(context, Icons.notifications_active, 'Alerts', true, () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(BuildContext context, IconData icon, String label, bool isActive, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: isActive
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.amber, size: 24),
                  const SizedBox(width: 8),
                  Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.amber, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: colorScheme.onSurfaceVariant, size: 24),
                const SizedBox(height: 4),
                Text(label, style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
    );
  }
}
