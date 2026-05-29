import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PdfViewerScreen extends StatelessWidget {
  const PdfViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101412),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainer,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Cours_Algorithmique_S1.pdf',
          style: AppTextStyles.headlineMedium.copyWith(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildSimulatedPdfPage(),
                const SizedBox(height: 120),
              ],
            ),
          ),
          _buildOfflineBadge(),
          _buildPageIndicator(),
          _buildBottomNavBar(),
        ],
      ),
    );
  }

  Widget _buildSimulatedPdfPage() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Université Internationale', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
              Text('2023-2024', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
            ],
          ),
          const Divider(height: 32),
          const Text(
            'Chapitre 3: Structures de Données Avancées',
            style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Text(
            'Dans ce chapitre, nous aborderons les structures de données complexes essentielles pour l\'optimisation des algorithmes. La maîtrise de ces concepts est fondamentale pour le développement logiciel performant.',
            style: TextStyle(color: Color(0xFF333333), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          const Text(
            '3.1 Arbres Binaires de Recherche (ABR)',
            style: TextStyle(color: Color(0xFF0B6E4F), fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Un arbre binaire de recherche est une structure de données arborescente où chaque nœud possède au maximum deux enfants. Pour tout nœud, les valeurs du sous-arbre gauche sont inférieures, et celles du sous-arbre droit sont supérieures.',
            style: TextStyle(color: Color(0xFF333333), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Text(
              'struct Noeud {\n    int valeur;\n    Noeud* gauche;\n    Noeud* droite;\n};',
              style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: Color(0xFF444444)),
            ),
          ),
          const SizedBox(height: 40),
          Center(child: Text('Page 3', style: TextStyle(color: Colors.grey[500], fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildOfflineBadge() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_done, color: AppColors.primary, size: 14),
            const SizedBox(width: 4),
            Text('Offline', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHighest.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Text('Page 3 sur 42', style: AppTextStyles.labelSmall),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.first_page, color: AppColors.onSurfaceVariant), onPressed: () {}),
            IconButton(icon: const Icon(Icons.search, color: AppColors.onSurfaceVariant), onPressed: () {}),
            IconButton(icon: const Icon(Icons.bookmark_outline, color: AppColors.onSurfaceVariant), onPressed: () {}),
            IconButton(icon: const Icon(Icons.last_page, color: AppColors.onSurfaceVariant), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
