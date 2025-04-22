import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/service_locator.dart';
import '../models/flight_plan.dart';
import '../models/semester.dart';
import '../models/flight_plan_item.dart';
import '../widgets/flight_plan_item_card.dart';
import '../widgets/list_loader.dart';

class FlightPlanPage extends StatefulWidget {
  FlightPlanPage({super.key});

  @override
  State<FlightPlanPage> createState() => _FlightPlanPageState();
}

class _FlightPlanPageState extends State<FlightPlanPage> {
  List<FlightPlan> _flightPlans = [];
  Semester? _selectedSemester;
  bool _isLoadingFlightPlans = true;

  FlightPlan? get _selectedFlightPlan {
    if (_selectedSemester == null) return null;
    return _flightPlans.firstWhere(
      (plan) => plan.semester.id == _selectedSemester!.id,
      orElse: () => _flightPlans.first,
    );
  }

  List<FlightPlanItem> get _sortedFlightPlanItems {
    if (_selectedFlightPlan == null) return [];

    // First, sort by status priority
    final statusPriority = {'pending': 0, 'incomplete': 1, 'complete': 2};

    return List.from(_selectedFlightPlan!.flightPlanItems)
      ..sort((a, b) {
        // First sort by status
        final statusCompare = (statusPriority[a.status.toLowerCase()] ?? 0)
            .compareTo(statusPriority[b.status.toLowerCase()] ?? 0);
        if (statusCompare != 0) return statusCompare;

        // If status is the same, sort by due date
        return a.dueDate.compareTo(b.dueDate);
      });
  }

  double get _completionPercentage {
    if (_selectedFlightPlan == null ||
        _selectedFlightPlan!.flightPlanItems.isEmpty) {
      return 0.0;
    }

    final completedItems = _selectedFlightPlan!.flightPlanItems
        .where((item) => item.status.toLowerCase() == 'complete')
        .length;

    return completedItems / _selectedFlightPlan!.flightPlanItems.length;
  }

  String get _completionText {
    final percentage = (_completionPercentage * 100).round();
    return '$percentage%';
  }

  bool get _isLoading => _isLoadingFlightPlans;

  @override
  void initState() {
    super.initState();
    _fetchFlightPlans();
  }

  Future<void> _fetchFlightPlans() async {
    if (!mounted) return;

    try {
      final flightPlans = await ServiceLocator().flightPlan.getFlightPlans();
      if (!mounted) return;

      setState(() {
        _flightPlans = flightPlans;
        if (_flightPlans.isNotEmpty) {
          _selectedSemester = _flightPlans.first.semester;
        }
        _isLoadingFlightPlans = false;
      });
    } catch (e) {
      print(e);
      if (!mounted) return;

      setState(() {
        _isLoadingFlightPlans = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching flight plans: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    double height = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(6, height + 4, 6, 6),
            child: Card(
              color: colorScheme.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Flight Plan',
                          style: textTheme.titleLarge,
                        ),
                        if (!_isLoadingFlightPlans)
                          Row(
                            children: [
                              DropdownButton<Semester>(
                                value: _selectedSemester,
                                hint: Text(
                                  'Select Semester',
                                  style: textTheme.bodyMedium,
                                ),
                                dropdownColor: colorScheme.surface,
                                style: textTheme.bodyMedium,
                                underline: Container(
                                  height: 0,
                                  color: colorScheme.primary,
                                ),
                                items: _flightPlans.map((plan) {
                                  return DropdownMenuItem<Semester>(
                                    value: plan.semester,
                                    child: Text(plan.semesterDisplayName),
                                  );
                                }).toList(),
                                onChanged: (Semester? newValue) {
                                  setState(() {
                                    _selectedSemester = newValue;
                                  });
                                },
                              ),
                            ],
                          )
                        else
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: [
                        Text(
                          _completionText,
                          style: textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: _completionPercentage,
                            backgroundColor: colorScheme.background,
                            borderRadius: BorderRadius.circular(10),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const ListLoader()
                : _selectedFlightPlan == null
                    ? const Center(child: Text('No flight plan selected'))
                    : Scrollbar(
                        thumbVisibility: true,
                        thickness: 6,
                        radius: const Radius.circular(10),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          itemCount: _sortedFlightPlanItems.length,
                          itemBuilder: (context, index) {
                            final item = _sortedFlightPlanItems[index];
                            return FlightPlanItemCard(item: item);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
