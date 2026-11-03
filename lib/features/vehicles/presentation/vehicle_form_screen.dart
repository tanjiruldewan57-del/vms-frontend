import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../data/mock_vehicle_repository.dart';
import '../domain/vehicle_model.dart';
import 'vehicle_provider.dart';

/// Form screen for registering a new vehicle or updating an existing vehicle.
/// Fields strictly adhere to domain specification:
/// Vehicle Number, Company, Type, Brand, Model, and Status.
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

  late final TextEditingController _vehicleNumberController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;

  String? _selectedCompany;
  VehicleType _selectedType = VehicleType.heavyTruck;
  VehicleStatus _selectedStatus = VehicleStatus.active;
  bool _initializedFromExisting = false;

  @override
  void initState() {
    super.initState();
    _vehicleNumberController = TextEditingController();
    _brandController = TextEditingController();
    _modelController = TextEditingController();
    _selectedCompany = MockVehicleRepository.companies.first;
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
      _vehicleNumberController.text = vehicle.vehicleNumber;
      _brandController.text = vehicle.brand;
      _modelController.text = vehicle.model;
      _selectedCompany = vehicle.company;
      _selectedType = vehicle.type;
      _selectedStatus = vehicle.status;
    }
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final company = _selectedCompany ?? MockVehicleRepository.companies.first;

    if (widget.isEditMode) {
      final updated = VehicleModel(
        id: widget.vehicleId!,
        vehicleNumber: _vehicleNumberController.text.trim().toUpperCase(),
        company: company,
        type: _selectedType,
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        status: _selectedStatus,
      );

      ref.read(vehicleListProvider.notifier).updateVehicle(updated);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vehicle ${updated.vehicleNumber} updated successfully.'),
          backgroundColor: AppColors.statusActive,
        ),
      );
    } else {
      final newVehicle = VehicleModel(
        id: '',
        vehicleNumber: _vehicleNumberController.text.trim().toUpperCase(),
        company: company,
        type: _selectedType,
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        status: _selectedStatus,
      );

      ref.read(vehicleListProvider.notifier).addVehicle(newVehicle);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vehicle ${newVehicle.vehicleNumber} registered successfully.',
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

              // Section 1: Asset Identification (Vehicle Number & Company)
              AppCard(
                title: 'Asset Identification',
                child: _buildResponsiveRow(
                  isDesktop: isDesktop,
                  children: [
                    _buildTextField(
                      controller: _vehicleNumberController,
                      label: 'Vehicle Number *',
                      hint: 'e.g. STK-DK-101',
                      prefixIcon: Icons.badge_outlined,
                      validator: (String? val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Vehicle number is required (e.g. STK-101).';
                        }
                        if (val.trim().length < 3) {
                          return 'Enter a valid vehicle number format.';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedCompany,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Operating Company *',
                        prefixIcon: Icon(Icons.business_rounded, size: 20),
                      ),
                      items: MockVehicleRepository.companies.map((String comp) {
                        return DropdownMenuItem<String>(
                          value: comp,
                          child: Text(
                            comp,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            _selectedCompany = value;
                          });
                        }
                      },
                      validator: (String? val) {
                        if (val == null || val.isEmpty) {
                          return 'Please select an operating company.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 2: Manufacturer & Specifications (Type, Brand, Model)
              AppCard(
                title: 'Manufacturer & Classification',
                child: Column(
                  children: [
                    _buildResponsiveRow(
                      isDesktop: isDesktop,
                      children: [
                        DropdownButtonFormField<VehicleType>(
                          value: _selectedType,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Vehicle Type *',
                          ),
                          items: VehicleType.values.map((VehicleType type) {
                            return DropdownMenuItem<VehicleType>(
                              value: type,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(type.icon, size: 18, color: AppColors.starkOrange),
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
                          controller: _brandController,
                          label: 'Brand / Manufacturer *',
                          hint: 'e.g. Volvo, Scania, Mercedes-Benz, MAN',
                          prefixIcon: Icons.directions_car_outlined,
                          validator: (String? val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Brand is required (e.g. Volvo, Scania).';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _modelController,
                      label: 'Vehicle Model *',
                      hint: 'e.g. FH16 Aero 750, Actros L 1853, TGX 26.640',
                      prefixIcon: Icons.local_shipping_outlined,
                      validator: (String? val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Model is required (e.g. FH16 750).';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 3: Operational Readiness (Status)
              AppCard(
                title: 'Operational Readiness',
                child: DropdownButtonFormField<VehicleStatus>(
                  value: _selectedStatus,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Operational Status *',
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
                  color: AppColors.starkOrangeLight,
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
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.isEditMode
              ? 'Update vehicle number, operating company, type, brand, model, and operational status.'
              : 'Enter asset metrics according to Stark Group fleet standards.',
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
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
                'Vehicle Asset Not Found',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'The vehicle with ID "${widget.vehicleId}" was not found in the Stark Group fleet registry.',
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
