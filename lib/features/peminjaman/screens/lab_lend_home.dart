import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_notifier.dart';
import 'form_peminjaman_screen.dart';
import 'riwayat_peminjaman_screen.dart';

const Color _primary = Color(0xFF2563EB);
const Color _background = Color(0xFFF6F8FC);
const Color _textDark = Color(0xFF172554);
const Color _textMuted = Color(0xFF64748B);
const Color _border = Color(0xFFE8EDF5);

class LabLendHome extends ConsumerStatefulWidget {
  const LabLendHome({super.key});

  @override
  ConsumerState<LabLendHome> createState() => _LabLendHomeState();
}

class _LabLendHomeState extends ConsumerState<LabLendHome> {
  int _selectedIndex = 0;

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
  }

  final List<Widget> _screens = const [
    FormPeminjamanScreen(),
    RiwayatPeminjamanScreen(),
  ];

  final List<_NavigationItem> _navigationItems = const [
    _NavigationItem(
      label: 'Peminjaman',
      subtitle: 'Ajukan peminjaman alat',
      icon: Icons.add_box_outlined,
      selectedIcon: Icons.add_box_rounded,
    ),
    _NavigationItem(
      label: 'Riwayat',
      subtitle: 'Kelola peminjaman',
      icon: Icons.history_rounded,
      selectedIcon: Icons.history_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        return Scaffold(
          backgroundColor: _background,
          body: SafeArea(
            child: Row(
              children: [
                if (isDesktop) _buildSidebar(),
                Expanded(
                  child: Column(
                    children: [
                      _buildTopBar(isDesktop),
                      Expanded(
                        child: IndexedStack(
                          index: _selectedIndex,
                          children: _screens,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: isDesktop ? null : _buildMobileNavigation(),
        );
      },
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 255,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: _border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 20, 32),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LabLend',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                        letterSpacing: -0.6,
                      ),
                    ),
                    Text(
                      'LAB INVENTORY SYSTEM',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: _textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 16, 12),
            child: Text(
              'MENU UTAMA',
              style: TextStyle(
                color: _textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ...List.generate(
            _navigationItems.length,
            (index) => _buildNavigationTile(index),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.science_outlined, color: _primary, size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LabLend System',
                          style: TextStyle(
                            color: _textDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Laboratory Management',
                          style: TextStyle(color: _textMuted, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(int index) {
    final item = _navigationItems[index];
    final selected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Material(
        color: selected ? const Color(0xFFEFF4FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: () => setState(() => _selectedIndex = index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  selected ? item.selectedIcon : item.icon,
                  color: selected ? _primary : _textMuted,
                  size: 21,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: selected ? _primary : _textMuted,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (selected)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: _primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDesktop) {
    return Container(
      height: 76,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedIndex == 0
                      ? 'Pengajuan Peminjaman'
                      : 'Riwayat Peminjaman',
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Laboratory Inventory Management',
                  style: TextStyle(color: _textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(11),
            ),
            child: IconButton(
              tooltip: 'Logout',
              onPressed: _logout,
              icon: const Icon(
                Icons.logout_rounded,
                color: _textMuted,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileNavigation() {
    return NavigationBar(
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFEFF4FF),
      elevation: 0,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.add_box_outlined),
          selectedIcon: Icon(Icons.add_box_rounded, color: _primary),
          label: 'Peminjaman',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_rounded),
          selectedIcon: Icon(Icons.history_rounded, color: _primary),
          label: 'Riwayat',
        ),
      ],
    );
  }
}

class _NavigationItem {
  final String label;
  final String subtitle;
  final IconData icon;
  final IconData selectedIcon;

  const _NavigationItem({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selectedIcon,
  });
}
