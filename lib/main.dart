import 'package:flutter/material.dart';

import 'app.dart';
import 'services/firebase/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = FlutterError.presentError;

  await FirebaseBootstrap.ensureInitialized();
  runApp(const FloraMindApp());
}
