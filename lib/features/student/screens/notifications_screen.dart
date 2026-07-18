import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box _userBox = Hive.box('userBox');
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final String? uid = _userBox.get('uid');
    if (uid == null) return;

    try {
      // Pour la démo Phase 1, on liste les communiqués récents comme notifications
      // Dans une phase 2, on créerait une collection 'notifications' dédiée
      final snapshot = await _firestore
          .collection('announcements')
          .where('status', isEqualTo: 'published')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      if (mounted) {
        setState(() {
          _notifications = snapshot.docs.map((doc) => {
            'id': doc.id,
            ...doc.data(),
            'type': doc.data()['category'] == 'urgent' ? 'alert' : 'info',
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Notifications', style: theme.textTheme.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {},
            tooltip: 'Tout marquer comme lu',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      return _buildNotificationItem(context, notif);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          const Text('Aucune notification pour le moment.'),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, Map<String, dynamic> notif) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isUrgent = notif['category'] == 'urgent';
    final DateTime date = (notif['createdAt'] as Timestamp).toDate();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUrgent ? Colors.red.withValues(alpha: 0.05) : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isUrgent ? Colors.red.withValues(alpha: 0.1) : colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isUrgent ? Colors.red : colorScheme.primary).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUrgent ? Icons.warning_amber_rounded : Icons.campaign_outlined,
              color: isUrgent ? Colors.red : colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notif['title'] ?? 'Sans titre', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  notif['body'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 8),
                Text(
                  '${date.day}/${date.month} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
