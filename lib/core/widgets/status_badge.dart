import 'package:flutter/material.dart';
import '../../features/vehicles/domain/vehicle_model.dart';

/// Pill badge representing a vehicle's operational status.
/// Hardened with Flexible and TextOverflow.ellipsis against overflow.
class StatusBadge extends StatelessWidget {
  final VehicleStatus status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8.0 : 12.0,
        vertical: compact ? 4.0 : 6.0,
      ),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: status.foregroundColor.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 6.0 : 8.0,
            height: compact ? 6.0 : 8.0,
            decoration: BoxDecoration(
              color: status.foregroundColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: compact ? 6.0 : 8.0),
          Flexible(
            child: Text(
              status.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: status.foregroundColor,
                fontSize: compact ? 11.0 : 12.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
