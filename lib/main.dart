import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VmsApp());
}

class VmsApp extends StatelessWidget {
  const VmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle Management System',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7),
          brightness: Brightness.dark,
          surface: const Color(0xFF0F172A),
        ),
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
      ),
      home: const VmsWorkspaceScaffold(),
    );
  }
}

class VmsWorkspaceScaffold extends StatelessWidget {
  const VmsWorkspaceScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vehicle Management System',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32.0),
          constraints: const BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Workspace Initialized',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'vms-frontend (Flutter Web)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Frontend shell is primed and strictly decoupled from vms-backend. '
                'Application feature implementations will be placed under lib/features/.',
                style: TextStyle(color: Color(0xFF94A3B8), height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

