import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/app_theme.dart';
import '../services/service_locator.dart';
import '../models/event.dart';

/// Implementation of Mobile Scanner example with simple configuration
class EventCheckInPage extends StatefulWidget {
  /// Constructor for simple Mobile Scanner example
  const EventCheckInPage({super.key});

  @override
  State<EventCheckInPage> createState() => _EventCheckInPageState();
}

class _EventCheckInPageState extends State<EventCheckInPage> {
  Barcode? _barcode;
  bool _isLoading = false;
  String? _errorMessage;
  Event? _event;
  String? _lastProcessedCode;
  String? _lastRawBarcode;
  bool _isCheckingIn = false;
  String? _checkInError;

  String? _extractToken(String? url) {
    if (url == null) return null;

    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isEmpty) return null;

      // Get the last segment of the path
      final token = pathSegments.last;
      return token;
    } catch (e) {
      return null;
    }
  }

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

  void _handleCheckIn() async {
    if (_event == null || _barcode == null) return;

    setState(() {
      _isCheckingIn = true;
      _checkInError = null;
    });

    try {
      final checkInCode = _extractToken(_barcode!.displayValue);
      if (checkInCode == null) {
        throw Exception('Invalid QR code');
      }

      await ServiceLocator().event.checkIn(_event!.id, checkInCode);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully checked in!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _checkInError = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingIn = false;
        });
      }
    }
  }

  void _showEventDetails(BuildContext context) {
    if (_event == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_checkInError == null) ...[
                Text(
                  _event!.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _event!.location,
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
                      _event!.formattedDate,
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
                      _event!.formattedTimeRange,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _event!.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
              if (_checkInError != null) ...[
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
                        _formatErrorMessage(_checkInError!),
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
                child: ElevatedButton(
                  onPressed: _isCheckingIn
                      ? null
                      : () async {
                          if (_checkInError != null &&
                              _checkInError!.contains('already checked in')) {
                            Navigator.pop(context);
                            return;
                          }

                          setModalState(() {
                            _isCheckingIn = true;
                            _checkInError = null;
                          });

                          try {
                            final checkInCode =
                                _extractToken(_barcode!.displayValue);
                            if (checkInCode == null) {
                              throw Exception('Invalid QR code');
                            }

                            await ServiceLocator()
                                .event
                                .checkIn(_event!.id, checkInCode);
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Successfully checked in!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            setModalState(() {
                              _checkInError = e.toString();
                            });
                          } finally {
                            setModalState(() {
                              _isCheckingIn = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isCheckingIn
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _checkInError != null &&
                                  _checkInError!.contains('already checked in')
                              ? 'Close'
                              : _checkInError != null
                                  ? 'Try Again'
                                  : 'Check In',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBarcode(BarcodeCapture barcodes) async {
    if (mounted) {
      final newBarcode = barcodes.barcodes.firstOrNull;

      // Skip if this is the same barcode we just processed
      if (newBarcode?.displayValue == _lastRawBarcode) {
        return;
      }

      setState(() {
        _barcode = newBarcode;
        _errorMessage = null;
        _event = null;
        _checkInError = null;
        if (_barcode != null) {
          _isLoading = true;
        }
      });

      if (_barcode != null) {
        try {
          final checkInCode = _extractToken(_barcode!.displayValue);
          if (checkInCode == null) {
            throw EventNotFoundException('Invalid QR code format');
          }

          // Skip if this is the same code that caused an error
          if (checkInCode == _lastProcessedCode && _errorMessage != null) {
            setState(() {
              _isLoading = false;
            });
            return;
          }

          _lastProcessedCode = checkInCode;
          _lastRawBarcode = _barcode!.displayValue;

          final eventData =
              await ServiceLocator().event.lookupEvent(checkInCode);
          if (mounted) {
            setState(() {
              _event = eventData;
              _isLoading = false;
            });
            _showEventDetails(context);
          }
        } on EventNotFoundException catch (e) {
          if (mounted) {
            setState(() {
              _errorMessage = e.toString();
              _isLoading = false;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _errorMessage = 'Could not find event';
              _isLoading = false;
            });
          }
        }
      }
    }
  }

  Widget _buildBarcode(Barcode? value) {
    if (value == null) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          Icon(
            Icons.qr_code_scanner,
            size: 40,
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            'Position QR code within frame',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    if (_errorMessage != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          const Icon(
            Icons.error_outline,
            size: 40,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (_isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'Processing check-in...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            MobileScanner(
              onDetect: _handleBarcode,
            ),
            // Header card
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Event Check-In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Scan frame overlay
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            // Bottom gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 100.0),
                  child: Center(
                    child: _buildBarcode(_barcode),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
