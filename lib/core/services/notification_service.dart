
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _notifications {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please login to view notifications.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications');
  }

  // Get real-time notifications
  Stream<QuerySnapshot<Map<String, dynamic>>> getNotifications() {
    return _notifications
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Mark one notification as read
  Future<void> markAsRead(String notificationId) async {
    await _notifications.doc(notificationId).update({
      'isRead': true,
      'readAt': Timestamp.now(),
    });
  }

  // Mark all unread notifications as read
  Future<void> markAllAsRead() async {
    final snapshot = await _notifications
        .where('isRead', isEqualTo: false)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();

    for (final document in snapshot.docs) {
      batch.update(document.reference, {
        'isRead': true,
        'readAt': Timestamp.now(),
      });
    }

    await batch.commit();
  }

  // Get unread notification count
  Stream<int> getUnreadCount() {
    return _notifications
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
