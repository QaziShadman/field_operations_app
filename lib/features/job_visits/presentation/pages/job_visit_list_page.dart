import 'package:field_operations_app/core/di/injector.dart';
import 'package:field_operations_app/features/job_visits/domain/entities/job_visit.dart'
    as entity;
import 'package:field_operations_app/features/job_visits/presentation/bloc/job_visit_bloc.dart';
import 'package:field_operations_app/features/job_visits/presentation/pages/job_visit_detail_page.dart';
import 'package:field_operations_app/features/job_visits/presentation/pages/job_visit_form_page.dart';
import 'package:field_operations_app/features/job_visits/presentation/widgets/job_visit_list_tile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

class JobVisitListPage extends StatefulWidget {
  const JobVisitListPage({super.key});

  @override
  State<JobVisitListPage> createState() => _JobVisitListPageState();
}

class _JobVisitListPageState extends State<JobVisitListPage> {
  _VisitSort _sort = _VisitSort.newest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<JobVisitBloc, JobVisitState>(
      builder: (context, state) {
        final showFab = state is JobVisitLoaded && state.visits.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Job Visits'),
            actions: [
              PopupMenuButton<_VisitSort>(
                tooltip: 'Sort visits',
                icon: const Icon(Icons.sort),
                initialValue: _sort,
                onSelected: (value) {
                  setState(() {
                    _sort = value;
                  });
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _VisitSort.newest,
                    child: Row(
                      children: [
                        Icon(Icons.arrow_downward),
                        SizedBox(width: 12),
                        Text('Newest first'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _VisitSort.oldest,
                    child: Row(
                      children: [
                        Icon(Icons.arrow_upward),
                        SizedBox(width: 12),
                        Text('Oldest first'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _VisitSort.status,
                    child: Row(
                      children: [
                        Icon(Icons.sort_by_alpha),
                        SizedBox(width: 12),
                        Text('Status'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: switch (state) {
            JobVisitInitial() || JobVisitLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            JobVisitLoaded(:final visits) => _buildLoaded(
              context,
              theme,
              visits,
            ),
            JobVisitFailure(:final message) => _buildError(context, message),
          },
          floatingActionButton: showFab
              ? FloatingActionButton.extended(
                  onPressed: _createVisit,
                  icon: const Icon(Icons.add),
                  label: const Text('New Visit'),
                )
              : null,
        );
      },
    );
  }

  List<entity.JobVisit> _sortVisits(List<entity.JobVisit> visits) {
    final sortedVisits = [...visits];

    switch (_sort) {
      case _VisitSort.newest:
        sortedVisits.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;

      case _VisitSort.oldest:
        sortedVisits.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;

      case _VisitSort.status:
        sortedVisits.sort((a, b) => a.status.name.compareTo(b.status.name));
        break;
    }

    return sortedVisits;
  }

  Widget _buildLoaded(
    BuildContext context,
    ThemeData theme,
    List<entity.JobVisit> visits,
  ) {
    final sortedVisits = _sortVisits(visits);

    if (sortedVisits.isEmpty) {
      return _EmptyState(onCreateVisit: _createVisit);
    }
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your visits',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${visits.length} visits',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          sliver: SliverList.separated(
            itemCount: sortedVisits.length,
            itemBuilder: (context, index) {
              final visit = sortedVisits[index];
              return JobVisitListTile(
                timestamp: visit.timestamp,
                status: visit.status,
                latitude: visit.latitude,
                longitude: visit.longitude,
                onTap: () => _openVisit(visit),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(height: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                context.read<JobVisitBloc>().add(const JobVisitStarted());
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  void _openVisit(entity.JobVisit visit) {
    final bloc = getIt<JobVisitBloc>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: JobVisitDetailPage(visitId: visit.id),
        ),
      ),
    );
  }

  Future<void> _createVisit() async {
    final result = await Navigator.of(context).push<JobVisitFormData>(
      MaterialPageRoute(builder: (_) => const JobVisitFormPage()),
    );
    if (!mounted || result == null) return;
    final visit = entity.JobVisit(
      id: _generateVisitId(),
      timestamp: result.timestamp,
      latitude: result.latitude,
      longitude: result.longitude,
      status: result.status,
      photoPath: result.photoPath,
    );
    context.read<JobVisitBloc>().add(JobVisitCreated(visit));
  }

  String _generateVisitId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreateVisit});
  final VoidCallback onCreateVisit;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('No job visits yet', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Create your first visit to get started.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreateVisit,
              icon: const Icon(Icons.add),
              label: const Text('Create Visit'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _VisitSort { newest, oldest, status }
