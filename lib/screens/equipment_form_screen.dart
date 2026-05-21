import 'dart:io';

import 'package:flutter/material.dart';
import '../globals.dart';
import '../theme/app_theme.dart';
import '../models/landlord_equipment.dart';
import '../models/implement.dart';
import '../utils/platform_image_picker.dart';

/// Pantalla completa para agregar o editar un tractor (evita diálogos anidados en Windows).
class EquipmentFormScreen extends StatefulWidget {
  final LandlordEquipment? equipment;

  const EquipmentFormScreen({super.key, this.equipment});

  bool get isEditing => equipment != null;

  @override
  State<EquipmentFormScreen> createState() => _EquipmentFormScreenState();
}

class _EquipmentFormScreenState extends State<EquipmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _powerController;
  late final TextEditingController _hoursController;
  late final TextEditingController _hourlyRateController;
  final TextEditingController _implementNameController = TextEditingController();

  String? _imagePath;
  bool _pickingImage = false;
  String _selectedTransmission = 'Manual';
  String _selectedTraction = '4WD';
  String _selectedCondition = 'Bueno';
  String _selectedImplementType = 'rastra';
  List<Implement> _implements = [];

  @override
  void initState() {
    super.initState();
    final eq = widget.equipment;
    _nameController = TextEditingController(text: eq?.name ?? '');
    _brandController = TextEditingController(text: eq?.brand ?? '');
    _modelController = TextEditingController(text: eq?.model ?? '');
    _yearController = TextEditingController(
      text: eq?.year.toString() ?? DateTime.now().year.toString(),
    );
    _powerController = TextEditingController(text: eq?.power.toString() ?? '');
    _hoursController = TextEditingController(
      text: eq?.usageHours.toString() ?? '0',
    );
    _hourlyRateController = TextEditingController(
      text: eq?.hourlyRate?.toString() ?? '',
    );
    if (eq != null) {
      _selectedTransmission = eq.transmission;
      _selectedTraction = eq.traction;
      _selectedCondition = eq.condition ?? 'Bueno';
      _implements = [...(eq.implements ?? [])];
      if (eq.imageUrls != null && eq.imageUrls!.isNotEmpty) {
        _imagePath = eq.imageUrls!.first;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _powerController.dispose();
    _hoursController.dispose();
    _hourlyRateController.dispose();
    _implementNameController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    if (_pickingImage) return;
    setState(() => _pickingImage = true);

    final path = await PlatformImagePicker.pickFromGallery();

    if (!mounted) return;
    setState(() {
      _pickingImage = false;
      if (path != null) _imagePath = path;
    });
  }

  void _addImplement() {
    if (_implementNameController.text.trim().isEmpty) return;
    setState(() {
      _implements.add(
        Implement(
          id: 'I${DateTime.now().millisecondsSinceEpoch}',
          name: _implementNameController.text.trim(),
          type: _selectedImplementType,
        ),
      );
    });
    _implementNameController.clear();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final result = widget.isEditing
        ? widget.equipment!.copyWith(
            name: _nameController.text.trim(),
            brand: _brandController.text.trim(),
            model: _modelController.text.trim(),
            year: int.parse(_yearController.text),
            power: double.parse(_powerController.text),
            transmission: _selectedTransmission,
            traction: _selectedTraction,
            usageHours: double.parse(_hoursController.text),
            condition: _selectedCondition,
            hourlyRate: double.tryParse(_hourlyRateController.text),
            imageUrls: _imagePath != null ? [_imagePath!] : widget.equipment!.imageUrls,
            implements: _implements,
          )
        : LandlordEquipment(
            id: 'E${DateTime.now().millisecondsSinceEpoch}',
            name: _nameController.text.trim(),
            brand: _brandController.text.trim(),
            model: _modelController.text.trim(),
            year: int.parse(_yearController.text),
            power: double.parse(_powerController.text),
            transmission: _selectedTransmission,
            traction: _selectedTraction,
            usageHours: double.parse(_hoursController.text),
            condition: _selectedCondition,
            isActive: true,
            hourlyRate: double.tryParse(_hourlyRateController.text) ?? 0.0,
            imageUrls: _imagePath != null ? [_imagePath!] : null,
            implements: _implements.isEmpty ? null : _implements,
            createdAt: DateTime.now(),
          );

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? tr('Editar Tractor', 'Edit Tractor')
              : tr('Agregar Nuevo Tractor', 'Add New Tractor'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _imageSection(isDark),
            const SizedBox(height: 20),
            if (!widget.isEditing) ...[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: tr('Nombre', 'Name'),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? tr('Requerido', 'Required') : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _brandController,
                      decoration: InputDecoration(labelText: tr('Marca', 'Brand')),
                      validator: (v) =>
                          v == null || v.isEmpty ? tr('Requerido', 'Required') : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _modelController,
                      decoration: InputDecoration(labelText: tr('Modelo', 'Model')),
                      validator: (v) =>
                          v == null || v.isEmpty ? tr('Requerido', 'Required') : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      decoration: InputDecoration(labelText: tr('Año', 'Year')),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? tr('Requerido', 'Required') : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _powerController,
                      decoration: InputDecoration(
                        labelText: tr('Potencia (HP)', 'Power (HP)'),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) =>
                          v == null || v.isEmpty ? tr('Requerido', 'Required') : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedTransmission,
                decoration: InputDecoration(
                  labelText: tr('Transmisión', 'Transmission'),
                ),
                items: ['Manual', 'Automática', 'CVT']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedTransmission = v ?? 'Manual'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedTraction,
                decoration: InputDecoration(labelText: tr('Tracción', 'Traction')),
                items: ['2WD', '4WD', 'AWD']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedTraction = v ?? '4WD'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hoursController,
                decoration: InputDecoration(
                  labelText: tr('Horas de uso', 'Usage hours'),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) =>
                    v == null || v.isEmpty ? tr('Requerido', 'Required') : null,
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _hourlyRateController,
              decoration: InputDecoration(
                labelText: tr('Tarifa por hora (\$)', 'Hourly rate (\$)'),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) =>
                  v == null || v.isEmpty ? tr('Requerido', 'Required') : null,
            ),
            if (!widget.isEditing) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedCondition,
                decoration: InputDecoration(labelText: tr('Condición', 'Condition')),
                items: ['Excelente', 'Bueno', 'Regular', 'Requiere Mantenimiento']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCondition = v ?? 'Bueno'),
              ),
            ],
            if (widget.isEditing) ...[
              const SizedBox(height: 24),
              _implementsSection(isDark),
            ],
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(tr('Cancelar', 'Cancel')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(
                      widget.isEditing ? tr('Guardar', 'Save') : tr('Agregar', 'Add'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageSection(bool isDark) {
    final hasImage =
        _imagePath != null && _imagePath!.isNotEmpty && File(_imagePath!).existsSync();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('Imagen del tractor', 'Tractor image'),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          alignment: Alignment.center,
          child: _pickingImage
              ? const CircularProgressIndicator()
              : hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_imagePath!),
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.agriculture_rounded,
                      size: 56,
                      color: AppTheme.primaryColor.withValues(alpha: 0.5),
                    ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickingImage ? null : _selectImage,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(
              hasImage
                  ? tr('Cambiar imagen', 'Change image')
                  : tr('Seleccionar imagen', 'Select image'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _implementsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('Implementos (Opcional)', 'Implements (Optional)'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        ..._implements.asMap().entries.map((entry) {
          final impl = entry.value;
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(impl.name),
            subtitle: Text(impl.type),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => setState(() => _implements.removeAt(entry.key)),
            ),
          );
        }),
        TextField(
          controller: _implementNameController,
          decoration: InputDecoration(
            labelText: tr('Nombre del implemento', 'Implement name'),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedImplementType,
          decoration: InputDecoration(labelText: tr('Tipo', 'Type')),
          items: ['rastra', 'arado', 'sembradora', 'otro']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => _selectedImplementType = v ?? 'rastra'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addImplement,
          icon: const Icon(Icons.add),
          label: Text(tr('Agregar implemento', 'Add implement')),
        ),
      ],
    );
  }
}
