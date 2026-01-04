import 'package:flutter/material.dart';

class PinDialog extends StatefulWidget {
  final bool isSetup;
  final String title;

  const PinDialog({
    super.key,
    this.isSetup = false,
    this.title = 'Enter PIN',
  });

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isSetup)
            const Text("Create a PIN to secure your notes. Don't forget it!",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'PIN',
              errorText: _errorText,
            ),
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
          ),
          if (widget.isSetup) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _confirmController,
              decoration: const InputDecoration(
                labelText: 'Confirm PIN',
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('OK'),
        ),
      ],
    );
  }

  void _submit() {
    final pin = _controller.text;

    if (pin.length < 4) {
      setState(() => _errorText = 'PIN must be at least 4 digits');
      return;
    }

    if (widget.isSetup) {
      if (pin != _confirmController.text) {
        setState(() => _errorText = 'PINs do not match');
        return;
      }
    }

    Navigator.of(context).pop(pin);
  }
}
