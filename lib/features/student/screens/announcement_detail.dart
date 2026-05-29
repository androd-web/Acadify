import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AnnouncementDetail extends StatelessWidget {
  const AnnouncementDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                  _buildTag(),
                  const SizedBox(height: 24),
                  Text(
                    'Report des examens du semestre 2',
                    style: AppTextStyles.headlineLarge.copyWith(color: AppColors.onSurface, fontSize: 32),
                  ),
                  const SizedBox(height: 24),
                  _buildAuthorInfo(),
                  const SizedBox(height: 32),
                  _buildArticleBody(),
                  const SizedBox(height: 48),
                  _buildAttachmentSection(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
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
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                onPressed: () => context.pop(),
              ),
              const Spacer(),
              Text(
                'Communiqué',
                style: AppTextStyles.headlineMedium.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.bookmark_border, color: AppColors.onSurfaceVariant),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.share, color: AppColors.onSurfaceVariant),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error, size: 16, color: AppColors.error),
          const SizedBox(width: 4),
          Text(
            'URGENT',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorInfo() {
    return Container(
      padding: const EdgeInsets.only(bottom: 24),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(Icons.account_balance, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Administration', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text('Publié le 24 Octobre 2023', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chers étudiants, membres du corps professoral et personnel administratif de l\'Académie,',
          style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
        ),
        const SizedBox(height: 24),
        Text(
          'Suite aux récentes délibérations du conseil académique et en considération des circonstances exceptionnelles ayant impacté le calendrier pédagogique, nous vous informons d\'une modification majeure concernant l\'organisation des évaluations finales.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant, height: 1.6),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer.withValues(alpha: 0.4),
            borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
            border: const Border(left: BorderSide(color: AppColors.primaryContainer, width: 4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info, color: AppColors.primaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'L\'ensemble des épreuves écrites et orales prévues initialement pour la période du 1er au 15 Novembre 2023 sont officiellement reportées. La nouvelle session d\'examens se tiendra du 20 Novembre au 5 Décembre 2023.',
                  style: AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, height: 1.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Ce délai supplémentaire vise à garantir à tous les étudiants des conditions de préparation optimales. Les modalités de déroulement, la répartition des salles et les jurys d\'examen restent inchangés pour le moment. Nous vous invitons à consulter régulièrement la plateforme pour toute mise à jour éventuelle des plannings individuels.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant, height: 1.6),
        ),
        const SizedBox(height: 24),
        Text(
          'Nous comptons sur votre compréhension et votre habituel sens des responsabilités. Le secrétariat des études demeure à votre entière disposition pour toute clarification nécessaire.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PIÈCE JOINTE', style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: AppColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.picture_as_pdf, color: AppColors.error),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Planning_Examens_S2_v2.pdf', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    Text('Document PDF • 1.2 MB', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Télécharger'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
