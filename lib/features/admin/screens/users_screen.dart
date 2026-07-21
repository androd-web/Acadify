import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  // Liste dynamique des utilisateurs
  final List<Map<String, dynamic>> _users = [
    {
      'initials': 'KM',
      'name': 'Kofi Mensah',
      'matricule': 'MAT-2024-001',
      'role': 'Étudiant',
      'isActive': true,
    },
    {
      'initials': 'AD',
      'name': 'Amina Diallo',
      'matricule': 'PROF-2022-042',
      'role': 'Enseignant',
      'isActive': true,
    },
    {
      'initials': 'SO',
      'name': 'Samuel Okoro',
      'matricule': 'ADM-2019-005',
      'role': 'Administrateur',
      'isActive': true,
    },
    {
      'initials': 'JB',
      'name': 'Jean Bakari',
      'matricule': 'MAT-2023-118',
      'role': 'Étudiant',
      'isActive': false,
    },
    {
      'initials': 'FT',
      'name': 'Fanta Traoré',
      'matricule': 'MAT-2024-089',
      'role': 'Étudiant',
      'isActive': true,
    },
    {
      'initials': 'PN',
      'name': 'Paul Ngueme',
      'matricule': 'PROF-2021-011',
      'role': 'Enseignant',
      'isActive': false,
    },
  ];

  String _searchQuery = '';
  String _selectedFilter = 'Tous';
  int _currentNavIndex = 2; // Index par défaut pour "Users"

  // Contrôleur pour la recherche
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtrer les utilisateurs selon la recherche et le filtre sélectionné
  List<Map<String, dynamic>> get _filteredUsers {
    return _users.where((user) {
      final matchesSearch = user['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user['matricule'].toLowerCase().contains(_searchQuery.toLowerCase());

      if (_selectedFilter == 'Tous') {
        return matchesSearch;
      } else if (_selectedFilter == 'Étudiants') {
        return matchesSearch && user['role'] == 'Étudiant';
      } else if (_selectedFilter == 'Enseignants') {
        return matchesSearch && user['role'] == 'Enseignant';
      } else if (_selectedFilter == 'Administrateurs') {
        return matchesSearch && user['role'] == 'Administrateur';
      }
      return matchesSearch;
    }).toList();
  }

  // Calculer les statistiques dynamiquement
  int get _totalUsers => _users.length;
  int get _totalStudents => _users.where((u) => u['role'] == 'Étudiant').length;
  int get _totalTeachers => _users.where((u) => u['role'] == 'Enseignant').length;
  int get _totalSuspended => _users.where((u) => !u['isActive']).length;

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
                  _buildAnalyticsGrid(context),
                  const SizedBox(height: 32),
                  _buildSearchAndFilters(context),
                  const SizedBox(height: 24),
                  _buildUserList(context),
                  const SizedBox(height: 120),
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
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: AppColors.primary),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Menu latéral cliqué !')),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                'University Admin',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profil administrateur cliqué !')),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
                    image: const DecorationImage(
                      image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCdt98Rj3-eCBzf_xmlbfVm02ODF0sIbpv6ac1go-sE4Valvc_tSrrJ_SDVRuS9vCFy_arck1ja4I3AJc_w1-Umu9AraBKIaJ1hnEygKfBZukxenOrP_XvOS-ube41m8a9hkbIxlIhvGztDYl9jbrwvPs-Nwuey-k3iE9R3yVOAPMnRzGGYmq49JVawqNknIUhknCsa9TPsvM7Kvs36YfaO9022LHI0FX5OYBWXF0mWa9mdPyjAnU8YYNIMoLqw64Oxc3rIEDZLVmKh'),
                      fit: BoxFit.cover,
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gestion des utilisateurs', style: AppTextStyles.headlineLarge),
        Text(
          'Supervisez les comptes académiques',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildAnalyticsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard(context, 'Total utilisateurs', '$_totalUsers', null, () {
          setState(() => _selectedFilter = 'Tous');
        }),
        _buildStatCard(context, 'Étudiants', '$_totalStudents', AppColors.primary, () {
          setState(() => _selectedFilter = 'Étudiants');
        }),
        _buildStatCard(context, 'Enseignants', '$_totalTeachers', AppColors.secondaryContainer, () {
          setState(() => _selectedFilter = 'Enseignants');
        }),
        _buildStatCard(context, 'Suspendus', '$_totalSuspended', AppColors.error, () {
          // Filtre spécial ou simple notification
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Il y a $_totalSuspended compte(s) suspendu(s) actuellement.')),
          );
        }),
      ],
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

  Widget _buildUserList(BuildContext context) {
    final filtered = _filteredUsers;
    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            'Aucun utilisateur trouvé',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = filtered[index];
        return _buildUserCard(
          context,
          user['initials'],
          user['name'],
          user['matricule'],
          user['role'],
          user['isActive'],
          user,
        );
      },
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    String initials,
    String name,
    String id,
    String role,
    bool isActive,
    Map<String, dynamic> userRaw,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    Color roleColor;
    if (role == 'Étudiant') {
      roleColor = AppColors.primary;
    } else if (role == 'Enseignant') {
      roleColor = AppColors.secondaryContainer;
    } else {
      roleColor = const Color(0xFF974946);
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: roleColor.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(color: roleColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
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
                      color: isActive ? AppColors.primary : AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isActive ? 'Actif' : 'Suspendu',
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
            onSelected: (value) {
              if (value == 'toggle_status') {
                setState(() {
                  userRaw['isActive'] = !userRaw['isActive'];
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Statut de ${userRaw['name']} mis à jour : ${userRaw['isActive'] ? "Actif" : "Suspendu"}',
                    ),
                  ),
                );
              } else if (value == 'delete') {
                setState(() {
                  _users.remove(userRaw);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${userRaw['name']} a été supprimé.')),
                );
              } else if (value == 'edit') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Modification de ${userRaw['name']} (Bientôt disponible)')),
                );
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
                    const SizedBox(width: 8),
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
    return Positioned(
      bottom: 100,
      right: 20,
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
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
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
            _buildBottomNavItem(1, Icons.notifications, 'Alertes'),
            _buildBottomNavItem(2, Icons.group, 'Users'),
            _buildBottomNavItem(3, Icons.analytics, 'Stats'),
            _buildBottomNavItem(4, Icons.account_circle, 'Profil'),
          ],
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigation vers $label')),
        );
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
