import 'package:material_ui/material_ui.dart';

class JobVisitFormPage extends StatefulWidget {
  const JobVisitFormPage({this.visit, super.key});

  /// Null means create mode.
  /// Non-null means edit mode.
  final JobVisitFormData? visit;

  bool get isEditing => visit != null;

  @override
  State<JobVisitFormPage> createState() => _JobVisitFormPageState();
}

class _JobVisitFormPageState extends State<JobVisitFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  late DateTime _selectedDateTime;
  late String _selectedStatus;
  late String? _selectedPhoto;

  final _statuses = const ['En Route', 'On Site', 'Completed', 'Blocked'];

  @override
  void initState() {
    super.initState();

    final visit = widget.visit;

    _selectedDateTime = visit?.timestamp ?? DateTime.now();

    _selectedStatus = visit?.status ?? 'En Route';

    _selectedPhoto = visit?.photoPath;

    _latitudeController = TextEditingController(
      text: visit?.latitude.toString() ?? '',
    );

    _longitudeController = TextEditingController(
      text: visit?.longitude.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Job Visit' : 'New Job Visit'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildDateTimeSection(),
            const SizedBox(height: 24),
            _buildStatusSection(),
            const SizedBox(height: 24),
            _buildLocationSection(),
            const SizedBox(height: 24),
            _buildPhotoSection(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return _FormSection(
      title: 'Visit time',
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text('Date'),
            subtitle: Text(_formatDate(_selectedDateTime)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _selectDate,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time_outlined),
            title: const Text('Time'),
            subtitle: Text(_formatTime(_selectedDateTime)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _selectTime,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return _FormSection(
      title: 'Status',
      child: DropdownButtonFormField<String>(
        initialValue: _selectedStatus,
        decoration: const InputDecoration(
          labelText: 'Visit status',
          prefixIcon: Icon(Icons.flag_outlined),
          border: OutlineInputBorder(),
        ),
        items: _statuses
            .map(
              (status) => DropdownMenuItem(value: status, child: Text(status)),
            )
            .toList(),
        onChanged: (value) {
          if (value == null) return;

          setState(() {
            _selectedStatus = value;
          });
        },
      ),
    );
  }

  Widget _buildLocationSection() {
    return _FormSection(
      title: 'Location',
      child: Column(
        children: [
          TextFormField(
            controller: _latitudeController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Latitude',
              hintText: '23.8103',
              prefixIcon: Icon(Icons.north_outlined),
              border: OutlineInputBorder(),
            ),
            validator: _validateCoordinate,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _longitudeController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Longitude',
              hintText: '90.4125',
              prefixIcon: Icon(Icons.east_outlined),
              border: OutlineInputBorder(),
            ),
            validator: _validateCoordinate,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return _FormSection(
      title: 'Photo attachment',
      child: InkWell(
        onTap: _pickPhoto,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Icons.add_a_photo_outlined,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 10),
              Text('Add photo', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Optional',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    //TODO
    // Photo picker will be connected here.
  }

  Widget _buildSaveButton() {
    return FilledButton.icon(
      onPressed: _save,
      icon: const Icon(Icons.save_outlined),
      label: Text(widget.isEditing ? 'Save Changes' : 'Create Visit'),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
    );
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selected == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        selected.year,
        selected.month,
        selected.day,
        _selectedDateTime.hour,
        _selectedDateTime.minute,
      );
    });
  }

  Future<void> _selectTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (selected == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        _selectedDateTime.year,
        _selectedDateTime.month,
        _selectedDateTime.day,
        selected.hour,
        selected.minute,
      );
    });
  }

  String? _validateCoordinate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    final coordinate = double.tryParse(value.trim());

    if (coordinate == null) {
      return 'Enter a valid number';
    }

    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = JobVisitFormData(
      id: widget.visit?.id ?? '',
      timestamp: _selectedDateTime,
      status: _selectedStatus,
      latitude: double.parse(_latitudeController.text.trim()),
      longitude: double.parse(_longitudeController.text.trim()),
      photoPath: _selectedPhoto,
    );

    Navigator.of(context).pop(result);
  }

  String _formatDate(DateTime value) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[value.month - 1]} '
        '${value.day}, ${value.year}';
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
}

class JobVisitFormData {
  const JobVisitFormData({
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

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
