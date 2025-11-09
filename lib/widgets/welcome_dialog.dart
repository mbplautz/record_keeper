import 'package:flutter/material.dart';

class WelcomeDialog extends StatefulWidget {
  final VoidCallback onShowTour;
  final VoidCallback onClose;
  final void Function (bool) onCheckChanged;

  const WelcomeDialog({
    super.key,
    required this.onShowTour,
    required this.onClose,
    required this.onCheckChanged,
  });

  @override
  State<WelcomeDialog> createState() => _WelcomeDialogState();

}

class _WelcomeDialogState extends State<WelcomeDialog> {
  bool _showWelcome = true;

  Future<void> _handleClose({bool startTour = false}) async {
    Navigator.of(context).pop();
    if (startTour) {
      widget.onShowTour();
    } else {
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome to Record Keeper, the no nonsense vinyl record cataloging app. '
                  'No account sign up or internet connection is required to use this app. '
                  'Just start adding to your collection, and then search and sort your collection as you please. '
                  '\n\nIf this is your first time using Record Keeper, you can take a quick tour of the basics of how '
                  'to use this app to catalog your vinyl record collection.',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Show Welcome Dialog on Startup'),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _showWelcome,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _showWelcome = value);
                    widget.onCheckChanged(value);
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleClose(startTour: true),
                    child: const Text('Begin Tour'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _handleClose(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
