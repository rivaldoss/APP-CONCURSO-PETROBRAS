import 'package:flutter/material.dart';

import 'app.dart';
import 'services/auth_service.dart';
import 'services/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseBootstrap.tryInitialize();
  await AuthService().trySignInAnonymously();

  runApp(const App());
}
