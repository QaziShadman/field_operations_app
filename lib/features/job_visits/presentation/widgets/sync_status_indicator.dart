import 'package:field_operations_app/features/job_visits/domain/enums/sync_status.dart';
import 'package:material_ui/material_ui.dart';

class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({required this.status, super.key});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (icon, label, color) = switch (status) {
      SyncStatus.synced => (Icons.cloud_done_outlined, 'Synced', Colors.blue),
      SyncStatus.pending => (
        Icons.cloud_upload_outlined,
        'Pending sync',
        Colors.amber,
      ),
      SyncStatus.syncing => (Icons.sync, 'Syncing', Colors.blueAccent),
      SyncStatus.failed => (
        Icons.cloud_off_outlined,
        'Sync failed',
        Colors.red,
      ),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
