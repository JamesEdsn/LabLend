import 'package:flutter/material.dart';

import '../models/peminjaman_model.dart';

const Color _primary = Color(0xFF356AE6);
const Color _navy = Color(0xFF172B4D);
const Color _muted = Color(0xFF718096);
const Color _border = Color(0xFFE2E8F0);
const Color _background = Color(0xFFF8FAFC);

class EditPeminjamanDialog extends StatefulWidget {
  final Peminjaman record;

  const EditPeminjamanDialog({super.key, required this.record});

  @override
  State<EditPeminjamanDialog> createState() => _EditPeminjamanDialogState();
}

class _EditPeminjamanDialogState extends State<EditPeminjamanDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _alatController;
  late final TextEditingController _jumlahController;
  late final TextEditingController _tanggalController;

  @override
  void initState() {
    super.initState();

    _alatController = TextEditingController(text: widget.record.alat);

    _jumlahController = TextEditingController(
      text: widget.record.jumlah.toString(),
    );

    _tanggalController = TextEditingController(
      text: widget.record.tanggalKembali,
    );
  }

  @override
  void dispose() {
    _alatController.dispose();
    _jumlahController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: _border),
      ),

      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),

      title: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.edit_outlined, color: _primary, size: 22),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Text(
              'Edit Peminjaman',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _navy,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),

      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),

      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Perbarui informasi peminjaman alat di bawah ini.',
                  style: TextStyle(fontSize: 13, height: 1.5, color: _muted),
                ),

                const SizedBox(height: 22),

                _buildFieldLabel('Nama Alat'),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _alatController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _navy,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: _buildInputDecoration(
                    hint: 'Masukkan nama alat',
                    icon: Icons.inventory_2_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama alat wajib diisi';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                _buildFieldLabel('Jumlah'),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _jumlahController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _navy,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: _buildInputDecoration(
                    hint: 'Masukkan jumlah alat',
                    icon: Icons.numbers_rounded,
                  ),
                  validator: (value) {
                    final jumlah = int.tryParse(value ?? '');

                    if (jumlah == null || jumlah <= 0) {
                      return 'Jumlah harus lebih dari 0';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                _buildFieldLabel('Tanggal Kembali'),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _tanggalController,
                  keyboardType: TextInputType.datetime,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _navy,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: _buildInputDecoration(
                    hint: 'YYYY-MM-DD',
                    icon: Icons.calendar_month_outlined,
                  ),
                  validator: (value) {
                    final tanggal = value?.trim() ?? '';

                    if (tanggal.isEmpty) {
                      return 'Tanggal kembali wajib diisi';
                    }

                    if (!isValidTanggalKembali(tanggal)) {
                      return 'Gunakan format YYYY-MM-DD';
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 22),

      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: _navy,
            side: const BorderSide(color: _border),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
          child: const Text(
            'Batal',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        ElevatedButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Simpan'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _navy,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9AA8BC)),
      prefixIcon: Icon(icon, size: 19, color: _muted),
      filled: true,
      fillColor: _background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final updatedRecord = widget.record.copyWith(
      alat: _alatController.text.trim(),
      jumlah: int.parse(_jumlahController.text),
      tanggalKembali: _tanggalController.text.trim(),
    );

    Navigator.pop(context, updatedRecord);
  }
}
