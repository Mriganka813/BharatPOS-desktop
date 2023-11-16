//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shopos/src/blocs/Kot/KotCubit.dart';
import 'package:shopos/src/provider/billing.dart';
import 'package:shopos/src/services/LocalDatabase.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:sqflite/sqflite.dart';
//import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  locator.registerLazySingleton(() => GlobalServices());
  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //sqfliteFfiInit();
  //databaseFactory = databaseFactoryFfi;

  /// TODO uncomment this line
  // await const Utils().checkUpdates();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => Billing(),
    )
  ], child: BlocProvider(
    create: (_) => KotCubit(),
    child: const MyApp())));
}
