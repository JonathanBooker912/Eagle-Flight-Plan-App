import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/service_locator.dart';
import '../models/event.dart';
import '../widgets/check_in_success_modal.dart';
import '../widgets/event_details_modal.dart';
import '../widgets/barcode_scanner_overlay.dart';

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

  void _showSuccessModal(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.onSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isDismissible: false,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      builder: (context) => CheckInSuccessModal(event: _event!),
    );
  }

  void _showEventDetails(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_event == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.onSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isDismissible: false,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => EventDetailsModal(
          event: _event!,
          checkInError: _checkInError,
          isCheckingIn: _isCheckingIn,
          onCheckIn: () async {
            setModalState(() {
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
                _showSuccessModal(context);
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
            BarcodeScannerOverlay(
              barcode: _barcode,
              errorMessage: _errorMessage,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
