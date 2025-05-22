import 'package:flutter/material.dart';

class NumberSelectionModal extends StatefulWidget {
  final String title;
  final String unit;
  final double minValue;
  final double maxValue;
  final double step;
  final double? initialValue;
  final Function(double) onSelected;

  const NumberSelectionModal({
    super.key,
    required this.title,
    required this.unit,
    required this.minValue,
    required this.maxValue,
    required this.step,
    this.initialValue,
    required this.onSelected,
  });

  @override
  State<NumberSelectionModal> createState() => _NumberSelectionModalState();
}

class _NumberSelectionModalState extends State<NumberSelectionModal> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue ?? widget.minValue;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${_currentValue.toStringAsFixed(1)} ${widget.unit}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Slider(
              value: _currentValue,
              min: widget.minValue,
              max: widget.maxValue,
              divisions: ((widget.maxValue - widget.minValue) / widget.step).round(),
              label: _currentValue.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _currentValue = value;
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onSelected(_currentValue);
                    Navigator.pop(context);
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 