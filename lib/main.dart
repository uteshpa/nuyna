import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuyna/core/di/service_locator.dart';
import 'package:nuyna/data/datasources/storage_datasource.dart';
import 'package:nuyna/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  
  // Clear any leftover cache from previous sessions
  await getIt<StorageDataSource>().clearTemporaryCache();
  
  runApp(const ProviderScope(child: NuynaApp()));
}

class NuynaApp extends ConsumerStatefulWidget {
  const NuynaApp({super.key});

  @override
  ConsumerState<NuynaApp> createState() => _NuynaAppState();
}

class _NuynaAppState extends ConsumerState<NuynaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Clear cache when app is paused or detached
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.detached) {
      getIt<StorageDataSource>().clearTemporaryCache();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'nuyna - Creator\'s Privacy Toolkit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
