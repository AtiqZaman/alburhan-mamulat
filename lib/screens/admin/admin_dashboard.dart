// ============================================================
// FILE: lib/screens/admin/admin_dashboard.dart
// COPY THIS CODE INTO: lib/screens/admin/admin_dashboard.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('ایڈمن ڈیش بورڈ'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Text('ایڈمن ڈیش بورڈ - جلد آ رہی ہے'),
      ),
    );
  }
}
