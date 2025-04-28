import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/event.dart';

enum EventModalType {
  checkIn,
  register,
}

class EventDetailsModal extends StatefulWidget {
  final Event event;
  final String? checkInError;
  final bool isCheckingIn;
  final Function() onCheckIn;
  final Function()? onRegister;
  final Function()? onUnregister;
  final bool isRegistered;
  final EventModalType modalType;

  const EventDetailsModal({
    super.key,
    required this.event,
    required this.checkInError,
    required this.isCheckingIn,
    required this.onCheckIn,
    this.onRegister,
    this.onUnregister,
    this.isRegistered = false,
    this.modalType = EventModalType.checkIn,
  });

  @override
  State<EventDetailsModal> createState() => _EventDetailsModalState();
}

class _EventDetailsModalState extends State<EventDetailsModal> {
  String _formatErrorMessage(String error) {
    if (error.contains('already checked in')) {
      return 'You have already checked in to this event';
    } else if (error.contains('Invalid QR code')) {
      return 'Invalid QR code. Please scan a valid event check-in code';
    } else if (error.contains('Event not found')) {
      return 'Event not found. Please check your QR code and try again';
    } else if (error.contains('500')) {
      return 'Unable to check in. Please try again later';
    } else {
      return 'An error occurred. Please try again';
    }
  }

  Widget _buildActionButton() {
    final colorScheme = Theme.of(context).colorScheme;
    if (widget.modalType == EventModalType.checkIn) {
      return ElevatedButton(
        onPressed: widget.isCheckingIn
            ? null
            : () {
                if (widget.checkInError != null &&
                    widget.checkInError!.contains('already checked in')) {
                  Navigator.pop(context);
                  return;
                }
                widget.onCheckIn();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: widget.isCheckingIn
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                widget.checkInError != null &&
                        widget.checkInError!.contains('already checked in')
                    ? 'Close'
                    : widget.checkInError != null
                        ? 'Try Again'
                        : 'Check In',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed:
                  widget.isRegistered ? widget.onUnregister : widget.onRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isRegistered
                    ? colorScheme.error
                    : colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                widget.isRegistered ? 'Unregister' : 'Register',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.checkInError == null) ...[
              Text(
                widget.event.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.event.location,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.event.formattedDate,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.event.formattedTimeRange,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.event.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              if (widget.event.fulfillableItems.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Fulfillable Experiences',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...widget.event.fulfillableItems
                    .map(
                      (item) => Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 6),
                        color: colorScheme.surface,
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                                child: Container(
                                  width: 12,
                                  decoration: BoxDecoration(
                                    color:
                                        item.status.toLowerCase() == 'complete'
                                            ? colorScheme.primary
                                            : item.status.toLowerCase() ==
                                                    'incomplete'
                                                ? colorScheme.error
                                                : colorScheme.tertiary,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(9),
                                      bottomLeft: Radius.circular(9),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  item.name,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              item.experience!.description,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        '${item.experience?.points ?? 0} pts',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ],
            if (widget.checkInError != null) ...[
              const SizedBox(height: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.accentColor,
                    size: 64,
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      _formatErrorMessage(widget.checkInError!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: _buildActionButton(),
            ),
          ],
        ),
      ),
    );
  }
}
