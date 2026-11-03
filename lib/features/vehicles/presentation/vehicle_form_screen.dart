import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../domain/vehicle_model.dart';
import 'vehicle_provider.dart';

/// Form screen for registering a new vehicle or updating an existing vehicle.
/// All input fields, dropdowns, and buttons are protected against flex overflow.
class VehicleFormScreen extends ConsumerStatefulWidget {
  final String? vehicleId;

  const VehicleFormScreen({
    super.key,
    this.vehicleId,
  });

  bool get isEditMode => vehicleId != null && vehicleId!.isNotEmpty;

  @override
  ConsumerState<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends ConsumerState<VehicleFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _licensePlateController;
  late final TextEditingController _vinController;
  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _mileageController;
  late final TextEditingController _fuelTypeController;
  late final TextEditingController _driverController;
  late final TextEditingController _notesController;

  VehicleType _selectedType = VehicleType.sedan;
  VehicleStatus _selectedStatus = VehicleStatus.active;
  bool _initializedFromExisting = false;

  @override
  void initState() {
    super.initState();
    _licensePlateController = TextEditingController();
    _vinController = TextEditingController();
    _makeController = TextEditingController();
    _modelController = TextEditingController();
    _yearController = TextEditingController(text: DateTime.now().year.toString());
    _mileageController = TextEditingController(text: '0');
    _fuelTypeController = TextEditingController(text: 'Gasoline');
    _driverController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.isEditMode && !_initializedFromExisting) {
      _loadExistingVehicleData();
      _initializedFromExisting = true;
    }
  }

  void _loadExistingVehicleData() {
    final vehicles = ref.read(vehicleListProvider);
    final vehicle = vehicles.cast<VehicleModel?>().firstWhere(
          (v) => v?.id == widget.vehicleId,
          orElse: () => null,
        );

    if (vehicle != null) {
      _licensePlateController.text = vehicle.licensePlate;
      _vinController.text = vehicle.vin;
      _makeController.text = vehicle.make;
      _modelController.text = vehicle.model;
      _yearController.text = vehicle.year.toString();
      _mileageController.text = vehicle.mileage.toString();
      _fuelTypeController.text = vehicle.fuelType;
      _driverController.text = vehicle.assignedDriver ?? '';
      _notesController.text = vehicle.notes ?? '';
      _selectedType = vehicle.type;
      _selectedStatus = vehicle.status;
    }
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _vinController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _fuelTypeController.dispose();
    _driverController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final year = int.tryParse(_yearController.text.trim()) ?? DateTime.now().year;
    final mileage = int.tryParse(_mileageController.text.trim()) ?? 0;
    final assignedDriver = _driverController.text.trim().isEmpty
        ? null
        : _driverController.text.trim();
    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    if (widget.isEditMode) {
      final updated = VehicleModel(
        id: widget.vehicleId!,
        licensePlate: _licensePlateController.text.trim().toUpperCase(),
        vin: _vinController.text.trim().toUpperCase(),
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: year,
        type: _selectedType,
        status: _selectedStatus,
        mileage: mileage,
        fuelType: _fuelTypeController.text.trim(),
        assignedDriver: assignedDriver,
        notes: notes,
        lastServicedDate: DateTime.now(),
      );

      ref.read(vehicleListProvider.notifier).updateVehicle(updated);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vehicle ${updated.licensePlate} updated successfully.'),
          backgroundColor: AppColors.statusActive,
        ),
      );
    } else {
      final newVehicle = VehicleModel(
        id: '',
        licensePlate: _licensePlateController.text.trim().toUpperCase(),
        vin: _vinController.text.trim().toUpperCase(),
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: year,
        type: _selectedType,
        status: _selectedStatus,
        mileage: mileage,
        fuelType: _fuelTypeController.text.trim(),
        assignedDriver: assignedDriver,
        notes: notes,
        lastServicedDate: DateTime.now(),
      );

      ref.read(vehicleListProvider.notifier).addVehicle(newVehicle);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vehicle ${newVehicle.licensePlate} registered successfully.',
          ),
          backgroundColor: AppColors.statusActive,
        ),
      );
    }

    context.go(AppConstants.routeVehicles);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    // If edit mode but vehicle was not found in provider
    if (widget.isEditMode) {
      final exists = ref.watch(vehicleListProvider).any((v) => v.id == widget.vehicleId);
      if (!exists) {
        return _buildNotFoundState(context);
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumb & Page Header
              _buildHeader(context, theme),
              const SizedBox(height: 24),

              // Section 1: Vehicle Identification
              AppCard(
                title: 'Vehicle Identification',
                child: Column(
                  children: [
                    _buildResponsiveRow(
                      isDesktop: isDesktop,
                      children: [
                        _buildTextField(
                          controller: _licensePlateController,
                          label: 'License Plate *',
                          hint: 'e.g. TX-789-VMS',
                          prefixIcon: Icons.badge_outlined,
                          validator: (String? val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'License plate is required.';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          controller: _vinController,
                          label: 'VIN (Vehicle Identification Number) *',
                          hint: '17-character VIN',
                          prefixIcon: Icons.tag_rounded,
                          validator: (String? val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'VIN is required.';
                            }
                            if (val.trim().length < 11) {
                              return 'VIN must be at least 11 characters.';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildResponsiveRow(
                      isDesktop: isDesktop,
                      children: [
                        _buildTextField(
                          controller: _makeController,
                          label: 'Make *',
                          hint: 'e.g. Ford, Toyota, Tesla',
                          prefixIcon: Icons.directions_car_outlined,
                          validator: (String? val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Make is required.';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          controller: _modelController,
                          label: 'Model *',
                          hint: 'e.g. F-150, Camry, Model Y',
                          prefixIcon: Icons.drive_eta_outlined,
                          validator: (String? val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Model is required.';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          controller: _yearController,
                          label: 'Model Year *',
                          hint: 'e.g. 2024',
                          prefixIcon: Icons.calendar_today_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (String? val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Year is required.';
                            }
                            final y = int.tryParse(val.trim());
                            if (y == null || y < 1980 || y > DateTime.now().year + 2) {
                              return 'Enter a valid model year (1980 - ${DateTime.now().year + 2}).';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 2: Technical Specifications & Fuel
              AppCard(
                title: 'Technical Specifications & Fuel',
                child: _buildResponsiveRow(
                  isDesktop: isDesktop,
                  children: [
                    DropdownButtonFormField<VehicleType>(
                      value: _selectedType,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Classification *',
                      ),
                      items: VehicleType.values.map((VehicleType type) {
                        return DropdownMenuItem<VehicleType>(
                          value: type,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(type.icon, size: 18, color: AppColors.primaryLight),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  type.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (VehicleType? value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                        }
                      },
                    ),
                    _buildTextField(
                      controller: _fuelTypeController,
                      label: 'Fuel / Powertrain *',
                      hint: 'Electric, Hybrid, Gasoline, Diesel',
                      prefixIcon: Icons.local_gas_station_outlined,
                      validator: (String? val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Fuel type is required.';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: _mileageController,
                      label: 'Current Odometer (Miles) *',
                      hint: 'e.g. 15000',
                      prefixIcon: Icons.speed_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (String? val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Mileage is required.';
                        }
                        final m = int.tryParse(val.trim());
                        if (m == null || m < 0) {
                          return 'Enter non-negative mileage.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 3: Operational Assignment & Status
              AppCard(
                title: 'Operational Status & Assignment',
                child: Column(
                  children: [
                    _buildResponsiveRow(
                      isDesktop: isDesktop,
                      children: [
                        DropdownButtonFormField<VehicleStatus>(
                          value: _selectedStatus,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Operational Status *',
                          ),
                          items: VehicleStatus.values.map((VehicleStatus status) {
                            return DropdownMenuItem<VehicleStatus>(
                              value: status,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: status.foregroundColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      status.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (VehicleStatus? value) {
                            if (value != null) {
                              setState(() {
                                _selectedStatus = value;
                              });
                            }
                          },
                        ),
                        _buildTextField(
                          controller: _driverController,
                          label: 'Assigned Driver (Optional)',
                          hint: 'e.g. John Doe',
                          prefixIcon: Icons.person_outline_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Operational Notes & Logs',
                        hintText: 'Enter maintenance history, special routes, or service annotations...',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Bottom Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => context.go(AppConstants.routeVehicles),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: FilledButton.icon(
                      icon: Icon(
                        widget.isEditMode ? Icons.check_circle_rounded : Icons.save_rounded,
                        size: 18,
                      ),
                      label: Text(
                        widget.isEditMode ? 'Update Vehicle' : 'Register Vehicle',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      onPressed: _handleSave,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () => context.go(AppConstants.routeVehicles),
              borderRadius: BorderRadius.circular(4),
              child: const Text(
                'Fleet',
                style: TextStyle(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const Text(' / ', style: TextStyle(color: Colors.grey, fontSize: 13)),
            Flexible(
              child: Text(
                widget.isEditMode ? 'Edit Vehicle' : 'New Registration',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          widget.isEditMode
              ? 'Edit Vehicle Specifications'
              : 'Register New Fleet Asset',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.isEditMode
              ? 'Update operational statuses, mileage records, and driver assignment.'
              : 'Enter initial vehicle metrics, identification data, and categorization.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveRow({
    required bool isDesktop,
    required List<Widget> children,
  }) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 16),
            Expanded(child: children[i]),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          children[i],
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
      ),
      validator: validator,
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AppCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.statusOutOfService,
              ),
              const SizedBox(height: 16),
              const Text(
                'Vehicle Not Found',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'The vehicle with ID "${widget.vehicleId}" was not found in the fleet registry.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.go(AppConstants.routeVehicles),
                child: const Text('Back to Fleet Inventory'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
