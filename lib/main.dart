import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/peminjaman/screens/form_peminjaman_screen.dart';

void main() {
  runApp(const ProviderScope(child: LabLendApp()));
}

class LabLendApp extends StatelessWidget {
  const LabLendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LabLend',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const FormPeminjamanScreen(),
    );
  }
}
