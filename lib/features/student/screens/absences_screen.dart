import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/absence_model.dart';

class AbsencesScreen extends StatefulWidget {
  const AbsencesScreen({super.key});

  @override
  State<AbsencesScreen> createState() => _AbsencesScreenState();
}

class _AbsencesScreenState extends State<AbsencesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box _userBox = Hive.box('userBox');
  
  bool _isLoading = true;
  List<AbsenceModel> _absences = [];
  int _maxAbsences = 5; // Valeur par défaut

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final String? uid = _userBox.get('uid');
    if (uid == null) return;

    try {
      // 1. Lire le seuil de configuration
      final configDoc = await _firestore.collection('config').doc('absenceThreshold').get();
      if (configDoc.exists) {
        _maxAbsences = configDoc.get('maxAbsences') ?? 5;
      }

      // 2. Lire les absences de l'étudiant
      final snapshot = await _firestore
          .collection('absences')
          .doc(uid)
          .collection('subjects')
          .get();

      if (mounted) {
        setState(() {
          _absences = snapshot.docs.map((doc) => AbsenceModel.fromMap(doc.data(), doc.id)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching absences: $e');
      if (mounted) setState(() => _isLoading = false);
    }
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
            top: 100,
            child: RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    _buildSummaryCard(context),
                    const SizedBox(height: 32),
                    _buildSectionHeader(context, 'Détails par matière'),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_absences.isEmpty)
                      _buildEmptyState(context)
                    else
                      ..._absences.map((abs) => _buildAbsenceItem(context, abs)),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    int total = _absences.fold(0, (previousValue, item) => previousValue + item.total);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TOTAL ABSENCES', style: AppTextStyles.labelMedium.copyWith(color: colorScheme.onSurfaceVariant, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Text('$total Heures', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colorScheme.primary)),
              ],
            ),
          ),
          Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildAbsenceItem(BuildContext context, AbsenceModel abs) {
    final colorScheme = Theme.of(context).colorScheme;
    final double ratio = abs.total / _maxAbsences;
    final color = ratio >= 0.8 ? Colors.red : (ratio >= 0.5 ? Colors.orange : Colors.green);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(abs.subjectName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              Text('${abs.total} / $_maxAbsences', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: colorScheme.onSurface.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              ratio >= 1.0 ? 'SEUIL DÉPASSÉ' : '${_maxAbsences - abs.total} restantes',
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(Icons.verified_user_outlined, size: 64, color: Colors.green.withValues(alpha: 0.2)),
        const SizedBox(height: 16),
        const Text('Félicitations ! Aucune absence enregistrée.', textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.headlineMedium),
      ],
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
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Text('Mes Absences', style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          ),
        ),
      ),
    );
  }
}
