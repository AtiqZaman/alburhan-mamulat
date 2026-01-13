import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/level_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/murabi/murabi_dashboard.dart';
import 'screens/salik/salik_dashboard.dart';
import 'screens/salik/salik_daily_update_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print('✓ Firebase initialized successfully');
  } catch (e) {
    print('✗ Firebase initialization error: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
        Provider(create: (_) => LevelService()),
      ],
      child: MaterialApp(
        title: 'Alburhan Mamulat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          fontFamily: 'NotoNastaliq',
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          fontFamily: 'NotoNastaliq',
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: SplashScreen(),
        routes: {
          '/auth_wrapper': (context) => AuthWrapper(),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/admin_dashboard': (context) => AdminDashboard(),
          '/murabi_dashboard': (context) => MurabiDashboard(),
          '/salik_dashboard': (context) => SalikDashboard(),
          '/salik_daily_update': (context) => SalikDailyUpdateScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        // Not logged in
        if (!snapshot.hasData) {
          print('AuthWrapper: User not logged in, showing login');
          return LoginScreen();
        }

        // Logged in - get role
        print('AuthWrapper: User logged in, fetching role');
        return FutureBuilder<String>(
          future: authService.getUserRole(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingScreen();
            }

            if (roleSnapshot.hasError) {
              print('⚠ Error fetching role: ${roleSnapshot.error}');
              return _buildErrorScreen(roleSnapshot.error.toString());
            }

            final role = roleSnapshot.data ?? '';

            print('AuthWrapper: User role = "$role"');

            // Route based on role
            if (role == 'admin') {
              return AdminDashboard();
            } else if (role == 'murabi') {
              return MurabiDashboard();
            } else if (role == 'salik') {
              return SalikDashboard();
            } else if (role.isEmpty) {
              print('No role found for user');
              return LoginScreen();
            } else {
              print('Unknown role: $role');
              return _buildErrorScreen('نامعلوم کردار: $role\nبراہ کرم لاگ آؤٹ کریں اور دوبارہ لاگ ان کریں');
            }
          },
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A3A5C),
              Color(0xFF2D5A8C),
              Color(0xFF3D6B9E),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                'براہ کرم انتظار کریں...',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'NotoNastaliq',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A3A5C),
              Color(0xFF2D5A8C),
              Color(0xFF3D6B9E),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 60),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  error,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'NotoNastaliq',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
