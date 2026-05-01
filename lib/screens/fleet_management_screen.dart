import 'package:flutter/material.dart';
import '../globals.dart';
import '../theme/app_theme.dart';
import '../models/landlord_equipment.dart';
import '../models/implement.dart';

class FleetManagementScreen extends StatefulWidget {
  const FleetManagementScreen({super.key});

  @override
  State<FleetManagementScreen> createState() => _FleetManagementScreenState();
}

class _FleetManagementScreenState extends State<FleetManagementScreen> {
  late List<LandlordEquipment> equipment;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    equipment = [
      LandlordEquipment(
        id: 'E001',
        name: 'Tractor Principal',
        brand: 'John Deere',
        model: '5075E',
        year: 2020,
        power: 75.0,
        transmission: 'Manual',
        traction: '4WD',
        usageHours: 2450.0,
        isActive: true,
        condition: 'Excelente',
        dailyRate: 150.0,
        createdAt: DateTime(2020, 6, 15),
        lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 45)),
        implements: [
          Implement(
            id: 'I001',
            name: 'Rastra de 3 metros',
            type: 'rastra',
            width: 3.0,
            condition: 'bueno',
          ),
          Implement(
            id: 'I002',
            name: 'Arado reversible',
            type: 'arado',
            condition: 'excelente',
          ),
        ],
      ),
      LandlordEquipment(
        id: 'E002',
        name: 'Tractor Secundario',
        brand: 'Massey Ferguson',
        model: '4275',
        year: 2018,
        power: 85.0,
        transmission: 'Automática',
        traction: '4WD',
        usageHours: 3120.0,
        isActive: true,
        condition: 'Bueno',
        dailyRate: 180.0,
        createdAt: DateTime(2018, 3, 20),
        lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 20)),
        implements: [
          Implement(
            id: 'I003',
            name: 'Sembradora de precisión',
            type: 'sembradora',
            condition: 'excelente',
          ),
        ],
      ),
      LandlordEquipment(
        id: 'E003',
        name: 'Cosechadora',
        brand: 'CLAAS',
        model: 'Lexion 550',
        year: 2019,
        power: 290.0,
        transmission: 'Automática',
        traction: 'AWD',
        usageHours: 1850.0,
        isActive: false,
        condition: 'Requiere Mantenimiento',
        dailyRate: 280.0,
        createdAt: DateTime(2019, 5, 10),
        lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 90)),
      ),
    ];
  }

  void _toggleEquipmentAvailability(int index) {
    setState(() {
      equipment[index] = equipment[index].copyWith(
        isActive: !equipment[index].isActive,
      );
    });
  }

  void _showAddEquipmentDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddEquipmentDialog(
        onAdd: (newEquipment) {
          setState(() {
            equipment.add(newEquipment);
          });
        },
      ),
    );
  }

  void _showEquipmentDetails(LandlordEquipment eq) {
    showDialog(
      context: context,
      builder: (context) => _EquipmentDetailsDialog(
        equipment: eq,
        onUpdate: (updatedEquipment) {
          setState(() {
            final index = equipment.indexWhere((e) => e.id == eq.id);
            if (index != -1) {
              equipment[index] = updatedEquipment;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          tr('Mis Tractores', 'My Tractors'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    tr('Filtros pendiente de implementación',
                        'Filters pending implementation'),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.filter_list_outlined),
          ),
        ],
      ),
      body: equipment.isEmpty
          ? _buildEmptyState(isDark)
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  ...equipment.asMap().entries.map(
                        (entry) => _buildEquipmentCard(
                          entry.value,
                          entry.key,
                          isDark,
                        ),
                      ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEquipmentDialog,
        icon: const Icon(Icons.add_rounded),
        label: Text(tr('Agregar Tractor', 'Add Tractor')),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(isDark ? 0.15 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.agriculture_rounded,
              size: 50,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            tr('Sin tractores registrados', 'No tractors registered'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            tr('Agrega tu primer tractor para comenzar',
                'Add your first tractor to get started'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddEquipmentDialog,
            icon: const Icon(Icons.add_rounded),
            label: Text(tr('Agregar Tractor', 'Add Tractor')),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentCard(
    LandlordEquipment eq,
    int index,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => _showEquipmentDetails(eq),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF303030) : AppTheme.borderColor,
          ),
        ),
        child: Column(
          children: [
            // Imagen placeholder
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(isDark ? 0.15 : 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.agriculture_rounded,
                  size: 60,
                  color: AppTheme.primaryColor.withOpacity(0.6),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y estado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eq.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${eq.brand} ${eq.model} (${eq.year})',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: eq.isActive
                              ? Colors.green.withOpacity(isDark ? 0.2 : 0.1)
                              : Colors.orange.withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          eq.isActive
                              ? tr('Disponible', 'Available')
                              : tr('En Taller', 'In Workshop'),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: eq.isActive ? Colors.green : Colors.orange,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Especificaciones
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildSpecBadge(
                        icon: Icons.speed_rounded,
                        label: '${eq.power.toInt()} HP',
                        isDark: isDark,
                      ),
                      _buildSpecBadge(
                        icon: Icons.settings_rounded,
                        label: eq.transmission,
                        isDark: isDark,
                      ),
                      _buildSpecBadge(
                        icon: Icons.directions_car_rounded,
                        label: eq.traction,
                        isDark: isDark,
                      ),
                      _buildSpecBadge(
                        icon: Icons.schedule_rounded,
                        label: '${eq.usageHours.toInt()}h',
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Implementos y acciones
                  if (eq.implements != null && eq.implements!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('Implementos', 'Implements'),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                              ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: eq.implements!
                              .take(3)
                              .map(
                                (impl) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentColor.withOpacity(
                                      isDark ? 0.15 : 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    impl.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: AppTheme.accentColor,
                                        ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        if (eq.implements!.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              tr('+${eq.implements!.length - 3} más',
                                  '+${eq.implements!.length - 3} more'),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppTheme.accentColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _toggleEquipmentAvailability(index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text(
                                  eq.isActive
                                      ? tr('Marcado como inactivo',
                                          'Marked as inactive')
                                      : tr('Marcado como disponible',
                                          'Marked as available'),
                                ),
                              ),
                            );
                          },
                          icon: Icon(
                            eq.isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          ),
                          label: Text(
                            eq.isActive
                                ? tr('Desactivar', 'Deactivate')
                                : tr('Activar', 'Activate'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showEquipmentDetails(eq),
                          icon: const Icon(Icons.edit_rounded),
                          label: Text(tr('Editar', 'Edit')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecBadge({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class _AddEquipmentDialog extends StatefulWidget {
  final Function(LandlordEquipment) onAdd;

  const _AddEquipmentDialog({required this.onAdd});

  @override
  State<_AddEquipmentDialog> createState() => _AddEquipmentDialogState();
}

class _AddEquipmentDialogState extends State<_AddEquipmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _powerController;
  late TextEditingController _hoursController;
  late TextEditingController _dailyRateController;

  String _selectedTransmission = 'Manual';
  String _selectedTraction = '4WD';
  String _selectedCondition = 'Bueno';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _brandController = TextEditingController();
    _modelController = TextEditingController();
    _yearController = TextEditingController(text: DateTime.now().year.toString());
    _powerController = TextEditingController();
    _hoursController = TextEditingController(text: '0');
    _dailyRateController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _powerController.dispose();
    _hoursController.dispose();
    _dailyRateController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final newEquipment = LandlordEquipment(
      id: 'E${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      brand: _brandController.text,
      model: _modelController.text,
      year: int.parse(_yearController.text),
      power: double.parse(_powerController.text),
      transmission: _selectedTransmission,
      traction: _selectedTraction,
      usageHours: double.parse(_hoursController.text),
      condition: _selectedCondition,
      isActive: true,
      dailyRate: double.tryParse(_dailyRateController.text) ?? 0.0,
      createdAt: DateTime.now(),
    );

    widget.onAdd(newEquipment);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(tr('Tractor agregado exitosamente',
            'Tractor added successfully')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(tr('Agregar Nuevo Tractor', 'Add New Tractor')),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: tr('Nombre', 'Name'),
                  hintText: tr('ej. Tractor Principal', 'e.g. Main Tractor'),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? tr('Requerido', 'Required') : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _brandController,
                      decoration: InputDecoration(
                        labelText: tr('Marca', 'Brand'),
                        hintText: 'John Deere',
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true
                              ? tr('Requerido', 'Required')
                              : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _modelController,
                      decoration: InputDecoration(
                        labelText: tr('Modelo', 'Model'),
                        hintText: '5075E',
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true
                              ? tr('Requerido', 'Required')
                              : null,
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
                      decoration: InputDecoration(
                        labelText: tr('Año', 'Year'),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true
                              ? tr('Requerido', 'Required')
                              : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _powerController,
                      decoration: InputDecoration(
                        labelText: tr('Potencia (HP)', 'Power (HP)'),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) =>
                          value?.isEmpty ?? true
                              ? tr('Requerido', 'Required')
                              : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedTransmission,
                decoration: InputDecoration(
                  labelText: tr('Transmisión', 'Transmission'),
                ),
                items: ['Manual', 'Automática', 'CVT']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedTransmission = value ?? 'Manual'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedTraction,
                decoration: InputDecoration(
                  labelText: tr('Tracción', 'Traction'),
                ),
                items: ['2WD', '4WD', 'AWD']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedTraction = value ?? '4WD'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hoursController,
                decoration: InputDecoration(
                  labelText: tr('Horas de uso', 'Usage hours'),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                    value?.isEmpty ?? true
                        ? tr('Requerido', 'Required')
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dailyRateController,
                decoration: InputDecoration(
                  labelText: tr('Tarifa diaria (\$)', 'Daily rate (\$)'),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCondition,
                decoration: InputDecoration(
                  labelText: tr('Condición', 'Condition'),
                ),
                items: ['Excelente', 'Bueno', 'Regular', 'Requiere Mantenimiento']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedCondition = value ?? 'Bueno'),
              ),
              const SizedBox(height: 12),
              Text(
                tr(
                  'Nota: Las imágenes pueden agregarse desde la edición del tractor',
                  'Note: Images can be added from tractor editing',
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(tr('Cancelar', 'Cancel')),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: Text(tr('Agregar', 'Add')),
        ),
      ],
    );
  }
}

class _EquipmentDetailsDialog extends StatefulWidget {
  final LandlordEquipment equipment;
  final Function(LandlordEquipment) onUpdate;

  const _EquipmentDetailsDialog({
    required this.equipment,
    required this.onUpdate,
  });

  @override
  State<_EquipmentDetailsDialog> createState() =>
      _EquipmentDetailsDialogState();
}

class _EquipmentDetailsDialogState extends State<_EquipmentDetailsDialog> {
  late TextEditingController _dailyRateController;
  late List<Implement> _implements;
  final TextEditingController _implementNameController = TextEditingController();
  final TextEditingController _implementTypeController = TextEditingController();
  String _selectedImplementType = 'rastra';

  @override
  void initState() {
    super.initState();
    _dailyRateController =
        TextEditingController(text: widget.equipment.dailyRate?.toString() ?? '');
    _implements = [...(widget.equipment.implements ?? [])];
  }

  @override
  void dispose() {
    _dailyRateController.dispose();
    _implementNameController.dispose();
    _implementTypeController.dispose();
    super.dispose();
  }

  void _addImplement() {
    if (_implementNameController.text.isEmpty) return;

    final newImplement = Implement(
      id: 'I${DateTime.now().millisecondsSinceEpoch}',
      name: _implementNameController.text,
      type: _selectedImplementType,
    );

    setState(() {
      _implements.add(newImplement);
    });

    _implementNameController.clear();
    _implementTypeController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(tr('Implemento agregado', 'Implement added')),
      ),
    );
  }

  void _removeImplement(int index) {
    setState(() {
      _implements.removeAt(index);
    });
  }

  void _saveChanges() {
    final updatedEquipment = widget.equipment.copyWith(
      dailyRate: double.tryParse(_dailyRateController.text),
      implements: _implements,
    );

    widget.onUpdate(updatedEquipment);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(tr('Cambios guardados', 'Changes saved')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('Editar Tractor', 'Edit Tractor'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 20),
              // Tarifa diaria
              TextField(
                controller: _dailyRateController,
                decoration: InputDecoration(
                  labelText: tr('Tarifa diaria (\$)', 'Daily rate (\$)'),
                  prefixText: '\$ ',
                  border: const OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 20),
              // Gestión de implementos
              Text(
                tr('Implementos (Opcional)', 'Implements (Optional)'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              // Lista de implementos actuales
              if (_implements.isNotEmpty)
                Column(
                  children: [
                    ..._implements.asMap().entries.map((entry) {
                      final impl = entry.value;
                      final idx = entry.key;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(
                            isDark ? 0.1 : 0.05,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppTheme.accentColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    impl.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    impl.type,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  _removeImplement(idx),
                              icon: const Icon(Icons.delete_outline_rounded),
                              color: Colors.red,
                              iconSize: 20,
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                  ],
                ),
              // Formulario para agregar implemento
              Text(
                tr('Agregar nuevo implemento', 'Add new implement'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _implementNameController,
                decoration: InputDecoration(
                  labelText: tr('Nombre', 'Name'),
                  hintText: tr('ej. Rastra de 3m', 'e.g. 3m harrow'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedImplementType,
                decoration: InputDecoration(
                  labelText: tr('Tipo', 'Type'),
                  border: const OutlineInputBorder(),
                ),
                items: ['rastra', 'arado', 'sembradora', 'otro']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedImplementType = value ?? 'rastra'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addImplement,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(tr('Agregar Implemento', 'Add Implement')),
                ),
              ),
              const SizedBox(height: 24),
              // Botones finales
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(tr('Cancelar', 'Cancel')),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    child: Text(tr('Guardar', 'Save')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
