import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/peminjaman/screens/form_peminjaman_screen.dart';
import 'features/peminjaman/screens/riwayat_peminjaman_screen.dart';

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
      home: const LabLendHome(),
    );
  }
}

class LabLendHome extends StatefulWidget {
  const LabLendHome({super.key});

  @override
  State<LabLendHome> createState() => _LabLendHomeState();
}

class _LabLendHomeState extends State<LabLendHome> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const FormPeminjamanScreen(),
      const RiwayatPeminjamanScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box),
            label: 'Peminjaman',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}
