import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forest/screens/home_screen.dart';
import 'package:forest/services/navigation_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Stream<List<NotificationModel>> _streamMyNotifications(String uid) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => NotificationModel.fromMap(d.data())).toList(),
        );
  }

  Future<void> _markAsRead(NotificationModel n) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(n.id)
          .update({'isRead': true});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    Future<void> _smartPop() async {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        NavigationHelper.pushReplacementFade(context, const HomeScreen());
      }
    }

    return Scaffold(
      backgroundColor: AppConstants.primaryBlack,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: _smartPop,
          icon: Icon(
            CupertinoIcons.chevron_left,
            color: AppConstants.white,
            size: 24,
          ),
        ),
      ),
      body:
          user == null
              ? Center(
                child: Text(
                  'Veuillez vous connecter',
                  style: GoogleFonts.poppins(color: AppConstants.textGrey),
                ),
              )
              : StreamBuilder<List<NotificationModel>>(
                stream: _streamMyNotifications(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppConstants.primaryGreen,
                      ),
                    );
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        "Aucune notification pour l'instant",
                        style: GoogleFonts.poppins(
                          color: AppConstants.textGrey,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final n = items[i];
                      return InkWell(
                        onTap: () async {
                          if (!n.isRead) await _markAsRead(n);
                          // Deep-link potentiel vers l’écran métier selon le title/message
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppConstants.lightGrey,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  n.isRead
                                      ? AppConstants.darkGrey
                                      : AppConstants.primaryGreen,
                              width: n.isRead ? 1 : 1.5,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                n.isRead
                                    ? CupertinoIcons.bell
                                    : CupertinoIcons.bell_fill,
                                color:
                                    n.isRead
                                        ? AppConstants.textGrey
                                        : AppConstants.primaryGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.title,
                                      style: GoogleFonts.poppins(
                                        color: AppConstants.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      n.message,
                                      style: GoogleFonts.poppins(
                                        color: AppConstants.textGrey,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      n.createdAt
                                          .toLocal()
                                          .toString()
                                          .substring(0, 16),
                                      style: GoogleFonts.poppins(
                                        color: AppConstants.textGrey,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
