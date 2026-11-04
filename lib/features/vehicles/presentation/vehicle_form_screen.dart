import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../data/vehicle_repository.dart';
import '../domain/vehicle_model.dart';
import 'vehicle_provider.dart';

/// Form screen for registering a new vehicle or updating an existing vehicle via Spring Boot API.
/// Fields strictly adhere to backend API DTOs:
/// Vehicle Number, Company, Type, Brand, Model, and Status.
class VehicleFormScreen extends ConsumerStatefulWidget {
  final String? vehicleId;

  const VehicleFormScreen({
    super.key,
    this.vehicleId,
  });

  bool get isEditMode => vehicleId != null && vehicleId!.isNotEmpty;
  int? get parsedId => int.tryParse(vehicleId ?? '');

  @override
  ConsumerState<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends ConsumerState<VehicleFormScreen> {
  static const List<String> defaultCompanies = <String>[
    'Stark Denmark Logistics',
    'Stark Building Materials UK',
    'Stark Deutschland GmbH',
    'Stark Suomi Distribution',
    'Stark Distribution Nordics',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _vehicleNumberController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;

  String? _selectedCompany;
  String _selectedType = VehicleTypeHelper.defaultTypes.first;
  VehicleStatus _selectedStatus = VehicleStatus.available;
  bool _initializedFromExisting = false;
  bool _isLoadingVehicle = false;
  bool _loadFailed = false;
  bool _isSaving = false;
  String? _serverErrorMessage;

  @override
  void initState() {
    super.initState();
    _vehicleNumberController = TextEditingController();
    _brandController = TextEditingController();
    _modelController = TextEditingController();
    _selectedCompany = defaultCompanies.first;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.isEditMode && !_initializedFromExisting) {
      _initializedFromExisting = true;
      _loadExistingVehicleData();
    }
  }

  Future<void> _loadExistingVehicleData() async {
    final targetId = widget.parsedId;
    if (targetId == null) {
      setState(() {
        _loadFailed = true;
      });
      return;
    }

    // 1. Try to populate from in-memory state if available
    final vehicles = ref.read(vehicleListProvider).vehicles;
    final vehicle = vehicles.cast<VehicleModel?>().firstWhere(
          (VehicleModel? v) => v?.id == targetId,
          orElse: () => null,
        );

    if (vehicle != null) {
      _populateForm(vehicle);
      return;
    }

    // 2. Fallback to fetching live from Spring Boot backend
    setState(() {
      _isLoadingVehicle = true;
      _loadFailed = false;
    });

    try {
      final fetched = await ref.read(vehicleRepositoryProvider).fetchVehicleById(targetId);
      if (mounted) {
        _populateForm(fetched);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadFailed = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingVehicle = false;
        });
      }
    }
  }

  void _populateForm(VehicleModel vehicle) {
    _vehicleNumberController.text = vehicle.vehicleNumber;
    _brandController.text = vehicle.brand;
    _modelController.text = vehicle.model;
    _selectedCompany = vehicle.company;
    _selectedType = vehicle.type;
    _selectedStatus = vehicle.status;
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _serverErrorMessage = null;
    });

    final company = _selectedCompany ?? defaultCompanies.first;

    try {
      if (widget.isEditMode) {
        final targetId = widget.parsedId;
        if (targetId == null) {
          throw const ApiException(message: 'Invalid vehicle ID format.');
        }

        final updated = VehicleModel(
          id: targetId,
          vehicleNumber: _vehicleNumberController.text.trim().toUpperCase(),
          company: company,
          type: _selectedType,
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          status: _selectedStatus,
        );

        await ref.read(vehicleListProvider.notifier).updateVehicle(targetId, updated);
        await ref.read(vehicleListProvider.notifier).loadVehicles();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vehicle ${updated.vehicleNumber} updated in Spring Boot database.'),
            backgroundColor: AppColors.statusActive,
          ),
        );
      } else {
        final newVehicle = VehicleModel(
          vehicleNumber: _vehicleNumberController.text.trim().toUpperCase(),
          company: company,
          type: _selectedType,
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          status: _selectedStatus,
        );

        final created = await ref.read(vehicleListProvider.notifier).createVehicle(newVehicle);
        await ref.read(vehicleListProvider.notifier).loadVehicles();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Vehicle ${created.vehicleNumber} successfully saved to Spring Boot backend.',
            ),
            backgroundColor: AppColors.statusActive,
          ),
        );
      }

      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppConstants.routeVehicles);
      }
    } on ApiException catch (e) {
      final friendlyMessage = (e.statusCode == 409 ||
              e.message.toLowerCase().contains('already exists') ||
              e.message.toLowerCase().contains('duplicate') ||
              e.message.toLowerCase().contains('conflict'))
          ? 'Vehicle number already exists in the fleet'
          : e.message;

      setState(() {
        _isSaving = false;
        _serverErrorMessage = friendlyMessage;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendlyMessage),
          backgroundColor: AppColors.statusOutOfService,
        ),
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
        _serverErrorMessage = 'An unexpected error occurred while saving the vehicle: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Operation failed: $e'),
          backgroundColor: AppColors.statusOutOfService,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    // If edit mode and loading vehicle details
    if (widget.isEditMode) {
      if (_isLoadingVehicle) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: AppColors.starkOrange,
            ),
          ),
        );
      }
      if (_loadFailed) {
        return _buildNotFoundState(context);
      }
    }

    final liveCompanies = ref.watch(availableCompaniesProvider);
    final companies = <String>{...defaultCompanies, ...liveCompanies}.toList()..sort();

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

              // Server Error Alert Box (if duplicate number or API validation fails)
              if (_serverErrorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.statusOutOfService.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.statusOutOfService),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.statusOutOfService, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _serverErrorMessage!,
                          style: const TextStyle(
                            color: AppColors.statusOutOfService,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

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
                        if (val.trim().length < 2 || val.trim().length > 50) {
                          return 'Vehicle number must be between 2 and 50 characters.';
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
                      items: companies.map((String comp) {
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
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Vehicle Type *',
                          ),
                          items: VehicleTypeHelper.defaultTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    VehicleTypeHelper.getIcon(type),
                                    size: 18,
                                    color: AppColors.starkOrange,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      type,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) {
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
                            if (val.trim().length > 50) {
                              return 'Brand cannot exceed 50 characters.';
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
                        if (val.trim().length > 50) {
                          return 'Model cannot exceed 50 characters.';
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
              const SizedBox(height: 32),

              // Bottom Actions Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppConstants.routeVehicles);
                            }
                          },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.starkOrange,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save_rounded, size: 18),
                    label: Text(
                      _isSaving
                          ? 'Persisting to Database...'
                          : (widget.isEditMode ? 'Update Vehicle Asset' : 'Register Vehicle'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onPressed: _isSaving ? null : _handleSave,
                  ),
                ],
              ),
              const SizedBox(height: 48),
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
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppConstants.routeVehicles);
                }
              },
              borderRadius: BorderRadius.circular(4),
              child: const Text(
                'Fleet Inventory',
                style: TextStyle(
                  color: AppColors.starkOrange,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.darkTextMuted),
            Text(
              widget.isEditMode ? 'Edit Vehicle' : 'Register Asset',
              style: const TextStyle(
                color: AppColors.darkTextMuted,
                fontSize: 13,
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
              ? 'Updates will be persisted to Spring Boot REST endpoint PUT /api/v1/vehicles/${widget.vehicleId}.'
              : 'Submits new vehicle payload to Spring Boot REST endpoint POST /api/v1/vehicles.',
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
                'The vehicle with ID "${widget.vehicleId}" was not found in the fleet registry.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppConstants.routeVehicles);
                  }
                },
                child: const Text('Back to Fleet Inventory'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
