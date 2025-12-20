import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/murabi/murabi_dashboard.dart';
import 'screens/salik/salik_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
      ],
      child: MaterialApp(
        title: 'البرہان معمولات',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'NotoNastaliq',
          textTheme: TextTheme(
            bodyLarge: TextStyle(fontSize: 16, fontFamily: 'NotoNastaliq'),
            bodyMedium: TextStyle(fontSize: 14, fontFamily: 'NotoNastaliq'),
            headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoNastaliq',
            ),
          ),
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Not logged in
        if (!snapshot.hasData) {
          return LoginScreen();
        }

        // Logged in - show role-based dashboard
        return FutureBuilder<String>(
          future: authService.getUserRole(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (!roleSnapshot.hasData || roleSnapshot.data!.isEmpty) {
              return LoginScreen();
            }

            String role = roleSnapshot.data!;

            // Route based on role
            if (role == 'admin') {
              return AdminDashboard();
            } else if (role == 'murabi') {
              return MurabiDashboard();
            } else if (role == 'salik') {
              return SalikDashboard();
            }

            // Fallback
            return LoginScreen();
          },
        );
      },
    );
  }
}
