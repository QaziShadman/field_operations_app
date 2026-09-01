import 'package:field_operations_app/features/job_visits/presentation/widgets/job_visit_list_tile.dart';
import 'package:material_ui/material_ui.dart';

class JobVisitListPage extends StatefulWidget {
  const JobVisitListPage({super.key});

  @override
  State<JobVisitListPage> createState() => _JobVisitListPageState();
}

class _JobVisitListPageState extends State<JobVisitListPage> {
  _VisitSort _sort = _VisitSort.newest;

  final List<_MockJobVisit> _visits = [
    _MockJobVisit(
      id: 'visit-1',
      timestamp: DateTime(2026, 8, 30, 10, 30),
      status: 'Completed',
      latitude: 23.8103,
      longitude: 90.4125,
    ),
    _MockJobVisit(
      id: 'visit-2',
      timestamp: DateTime(2026, 8, 30, 9, 15),
      status: 'On Site',
      latitude: 23.8200,
      longitude: 90.4200,
    ),
    _MockJobVisit(
      id: 'visit-3',
      timestamp: DateTime(2026, 8, 29, 14, 0),
      status: 'En Route',
      latitude: 23.8300,
      longitude: 90.4300,
    ),
  ];

  List<_MockJobVisit> get _sortedVisits {
    final visits = [..._visits];
    switch (_sort) {
      case _VisitSort.newest:
        visits.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;

      case _VisitSort.oldest:
        visits.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;

      case _VisitSort.status:
        visits.sort(
          (a, b) => a.status.toLowerCase().compareTo(b.status.toLowerCase()),
        );
        break;
    }
    return visits;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visits = _sortedVisits;

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
      body: visits.isEmpty
          ? _EmptyState(onCreateVisit: _createVisit)
          : CustomScrollView(
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
                    itemCount: visits.length,
                    itemBuilder: (context, index) {
                      final visit = visits[index];
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
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createVisit,
        icon: const Icon(Icons.add),
        label: const Text('New Visit'),
      ),
    );
  }

  void _openVisit(_MockJobVisit visit) {
    // Detail page will be implemented next.
  }
  void _createVisit() {
    // Create page will be implemented next.
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

class _MockJobVisit {
  _MockJobVisit({
    required this.id,
    required this.timestamp,
    required this.status,
    required this.latitude,
    required this.longitude,
  });
  final String id;
  final DateTime timestamp;
  final String status;
  final double latitude;
  final double longitude;
}
