import 'dart:io';

import 'package:field_operations_app/core/di/injector.dart';
import 'package:field_operations_app/core/utils/services/local_auth/local_auth_service.dart';
import 'package:field_operations_app/features/job_visits/domain/entities/job_visit.dart'
    as entity;
import 'package:field_operations_app/features/job_visits/domain/enums/job_visit_status.dart';
import 'package:field_operations_app/features/job_visits/presentation/bloc/job_visit_bloc.dart';
import 'package:field_operations_app/features/job_visits/presentation/pages/job_visit_form_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

class JobVisitDetailPage extends StatefulWidget {
  const JobVisitDetailPage({required this.visitId, super.key});

  final String visitId;

  @override
  State<JobVisitDetailPage> createState() => _JobVisitDetailPageState();
}

class _JobVisitDetailPageState extends State<JobVisitDetailPage> {
  final _localAuthServices = getIt<LocalAuthServices>();
  bool _photoUnlocked = false;
  bool _isAuthenticatingPhoto = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<JobVisitBloc, JobVisitState>(
      builder: (context, state) {
        final visit = _findVisit(state);
        if (visit == null) {
          return const Scaffold(
            body: Center(child: Text('Visit no longer exists.')),
          );
        }
        return _buildPage(context, theme, visit);
      },
    );
  }

  entity.JobVisit? _findVisit(JobVisitState state) {
    if (state is! JobVisitLoaded) {
      return null;
    }
    // for (final visit in state.visits) {
    //   if (visit.id == widget.visitId) {
    //     return visit;
    //   }
    // }
    for (final visit in state.visits) {
      if (visit.visit.id == widget.visitId) {
        return visit.visit;
      }
    }
    return null;
  }

  Widget _buildPage(
    BuildContext context,
    ThemeData theme,
    entity.JobVisit visit,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Visit'),
        actions: [
          IconButton(
            tooltip: 'Edit visit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editVisit(context, visit),
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
              if (visit.photoPath == null)
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
                )
              else
                GestureDetector(
                  onTap: _photoUnlocked ? null : _unlockPhoto,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: _photoUnlocked
                          ? Image.file(
                              File(visit.photoPath!),
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lock_outline,
                                      size: 40,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Photo locked',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isAuthenticatingPhoto
                                          ? 'Waiting for authentication...'
                                          : 'Tap to authenticate and view',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _editVisit(BuildContext context, entity.JobVisit visit) async {
    final result = await Navigator.of(context).push<JobVisitFormData>(
      MaterialPageRoute(builder: (_) => JobVisitFormPage(visit: visit)),
    );

    if (!context.mounted || result == null) return;

    final updatedVisit = entity.JobVisit(
      id: visit.id,
      timestamp: result.timestamp,
      latitude: result.latitude,
      longitude: result.longitude,
      status: result.status,
      photoPath: result.photoPath,
    );

    context.read<JobVisitBloc>().add(JobVisitUpdated(updatedVisit));
  }

  Future<void> _unlockPhoto() async {
    if (_isAuthenticatingPhoto || _photoUnlocked) {
      return;
    }

    setState(() {
      _isAuthenticatingPhoto = true;
    });

    final authenticated = await _localAuthServices.authenticateForPhoto();

    if (!mounted) return;

    setState(() {
      _isAuthenticatingPhoto = false;

      if (authenticated) {
        _photoUnlocked = true;
      }
    });

    if (!authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication failed. The photo remains locked.'),
        ),
      );
    }
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
  final JobVisitStatus status;
  final double latitude;
  final double longitude;
  final String? photoPath;
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.visit});

  final entity.JobVisit visit;

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

  final JobVisitStatus status;

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
        _statusLabel(status),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _statusLabel(JobVisitStatus status) {
    return switch (status) {
      JobVisitStatus.enRoute => 'En Route',
      JobVisitStatus.onSite => 'On Site',
      JobVisitStatus.completed => 'Completed',
      JobVisitStatus.blocked => 'Blocked',
    };
  }
}
