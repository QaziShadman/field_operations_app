import 'dart:io';

import 'package:material_ui/material_ui.dart';

class JobVisitDetailPage extends StatelessWidget {
  const JobVisitDetailPage({required this.visit, super.key});

  final JobVisitDetailData visit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Visit'),
        actions: [
          IconButton(
            tooltip: 'Edit visit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderCard(visit: visit),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Visit information',
            children: [
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Date',
                value: _formatDate(visit.timestamp),
              ),
              _InfoRow(
                icon: Icons.access_time_outlined,
                label: 'Time',
                value: _formatTime(visit.timestamp),
              ),
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value:
                    '${visit.latitude.toStringAsFixed(6)}, '
                    '${visit.longitude.toStringAsFixed(6)}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Photo',
            children: [
              if (visit.photoPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(visit.photoPath!), fit: BoxFit.cover),
                )
              else
                Row(
                  children: [
                    Icon(
                      Icons.photo_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'No photo attached',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    return '${_monthName(value.month)} ${value.day}, ${value.year}';
  }

  String _formatTime(DateTime value) {
    final hour = value.hour == 0
        ? 12
        : value.hour > 12
        ? value.hour - 12
        : value.hour;

    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }
}

class JobVisitDetailData {
  const JobVisitDetailData({
    required this.id,
    required this.timestamp,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.photoPath,
  });

  final String id;
  final DateTime timestamp;
  final String status;
  final double latitude;
  final double longitude;
  final String? photoPath;
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.visit});

  final JobVisitDetailData visit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Job Visit',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusBadge(status: visit.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${visit.id}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
