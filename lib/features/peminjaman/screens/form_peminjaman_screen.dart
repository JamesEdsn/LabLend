import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/peminjaman_notifier.dart';
import '../providers/riwayat_peminjaman_notifier.dart';

const Color _primary = Color(0xFF2563EB);
const Color _dark = Color(0xFF172554);
const Color _muted = Color(0xFF64748B);
const Color _border = Color(0xFFE2E8F0);
const Color _background = Color(0xFFF6F8FC);

class FormPeminjamanScreen extends ConsumerStatefulWidget {
  const FormPeminjamanScreen({super.key});

  @override
  ConsumerState<FormPeminjamanScreen> createState() =>
      _FormPeminjamanScreenState();
}

bool isValidTanggalKembali(String tanggal) {
  final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  if (!regex.hasMatch(tanggal)) return false;

  final parsedDate = DateTime.tryParse(tanggal);

  if (parsedDate == null) return false;

  return parsedDate.year.toString().padLeft(4, '0') ==
          tanggal.substring(0, 4) &&
      parsedDate.month.toString().padLeft(2, '0') == tanggal.substring(5, 7) &&
      parsedDate.day.toString().padLeft(2, '0') == tanggal.substring(8, 10);
}

class _FormPeminjamanScreenState extends ConsumerState<FormPeminjamanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _tanggalController = TextEditingController();

  String? selectedAlat;

  @override
  void dispose() {
    _jumlahController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(peminjamanProvider);

    Widget content;

    if (state.status == PeminjamanStatus.loading) {
      content = const Center(child: CircularProgressIndicator(color: _primary));
    } else if (state.status == PeminjamanStatus.error) {
      content = _buildErrorState(state);
    } else if (state.status == PeminjamanStatus.empty) {
      content = _buildEmptyState();
    } else {
      content = _buildForm(state);
    }

    return Scaffold(
      backgroundColor: _background,
      body: Material(color: _background, child: content),
    );
  }

  Widget _buildPageContainer(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 600 ? 18.0 : 36.0;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 28,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: child,
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm(PeminjamanState state) {
    return _buildPageContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(),
          const SizedBox(height: 26),
          _buildInformationCard(),
          const SizedBox(height: 20),
          _buildFormCard(state),
          const SizedBox(height: 18),
          _buildFooterNote(),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4FF),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.assignment_add, color: _primary, size: 25),
        ),
        const SizedBox(height: 18),
        const Text(
          'Form Peminjaman Alat',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _dark,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Isi formulir berikut untuk mengajukan peminjaman '
          'peralatan laboratorium.',
          style: TextStyle(fontSize: 14, height: 1.6, color: _muted),
        ),
      ],
    );
  }

  Widget _buildInformationCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: _primary, size: 21),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Peminjaman',
                  style: TextStyle(
                    color: _dark,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Pastikan alat, jumlah, dan tanggal pengembalian '
                  'sudah sesuai sebelum mengirim pengajuan.',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(PeminjamanState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172554).withValues(alpha: 0.035),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Peminjaman',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _dark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Lengkapi semua informasi di bawah ini.',
              style: TextStyle(fontSize: 13, color: _muted),
            ),
            const SizedBox(height: 26),

            _buildFieldLabel('Pilih Alat'),
            const SizedBox(height: 9),

            DropdownButtonFormField<String>(
              initialValue: selectedAlat,
              isExpanded: true,
              menuMaxHeight: 280,
              borderRadius: BorderRadius.circular(12),
              dropdownColor: Colors.white,
              elevation: 6,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _muted,
              ),
              decoration: _inputDecoration(
                hint: 'Pilih peralatan yang ingin dipinjam',
                icon: Icons.inventory_2_outlined,
              ),
              items: state.alat.map((alat) {
                return DropdownMenuItem<String>(
                  value: alat,
                  child: Text(
                    alat,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _dark,
                    ),
                  ),
                );
              }).toList(),
              onChanged: state.isSubmitting
                  ? null
                  : (value) {
                      setState(() {
                        selectedAlat = value;
                      });
                    },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Silakan pilih alat';
                }
                return null;
              },
            ),

            const SizedBox(height: 23),

            TextFormField(
              controller: _jumlahController,
              enabled: !state.isSubmitting,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                hint: 'Masukkan jumlah alat',
                icon: Icons.numbers_rounded,
              ).copyWith(labelText: 'Jumlah'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah tidak boleh kosong';
                }

                final jumlah = int.tryParse(value);

                if (jumlah == null || jumlah <= 0) {
                  return 'Jumlah harus lebih dari 0';
                }

                return null;
              },
            ),

            const SizedBox(height: 23),

            TextFormField(
              controller: _tanggalController,
              enabled: !state.isSubmitting,
              decoration: _inputDecoration(
                hint: 'Contoh: 2026-11-15',
                icon: Icons.calendar_month_outlined,
              ).copyWith(labelText: 'Tanggal Kembali (YYYY-MM-DD)'),
              validator: (value) {
                final tanggal = value?.trim() ?? '';

                if (tanggal.isEmpty) {
                  return 'Tanggal kembali tidak boleh kosong';
                }

                if (!isValidTanggalKembali(tanggal)) {
                  return 'Gunakan format YYYY-MM-DD (contoh: 2026-11-15)';
                }

                return null;
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 51,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF93B4F5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                onPressed: state.isSubmitting ? null : _submitPeminjaman,
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.3,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 17),
                          SizedBox(width: 9),
                          Text(
                            'Submit Peminjaman',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _dark,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: _muted,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(icon, color: _muted, size: 19),
      filled: true,
      fillColor: const Color(0xFFFAFBFD),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget _buildFooterNote() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.verified_user_outlined, color: _muted, size: 15),
        SizedBox(width: 7),
        Flexible(
          child: Text(
            'Pastikan data peminjaman yang kamu masukkan sudah benar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: _muted),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(PeminjamanState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStateIcon(
              Icons.cloud_off_outlined,
              const Color(0xFFFEF2F2),
              Colors.redAccent,
            ),
            const SizedBox(height: 20),
            const Text(
              'Gagal Memuat Peralatan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? 'Terjadi kesalahan.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 14),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(peminjamanProvider.notifier).fetchAlat();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStateIcon(
              Icons.inventory_2_outlined,
              const Color(0xFFEFF4FF),
              _primary,
            ),
            const SizedBox(height: 20),
            const Text(
              'Stok Alat Sedang Kosong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _dark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Belum ada peralatan yang tersedia untuk dipinjam.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateIcon(IconData icon, Color background, Color foreground) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Icon(icon, size: 34, color: foreground),
    );
  }

  Future<void> _submitPeminjaman() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final notifier = ref.read(peminjamanProvider.notifier);

    final success = await notifier.submitPeminjaman(
      alat: selectedAlat!,
      jumlah: int.parse(_jumlahController.text),
      tanggalKembali: _tanggalController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: success
            ? const Color(0xFF15803D)
            : const Color(0xFFDC2626),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          success
              ? 'Peminjaman berhasil diajukan!'
              : 'Peminjaman gagal diajukan.',
        ),
      ),
    );

    if (success) {
      ref.invalidate(riwayatPeminjamanProvider);

      _jumlahController.clear();
      _tanggalController.clear();

      setState(() {
        selectedAlat = null;
      });
    }
  }
}
