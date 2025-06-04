import 'package:flutter/material.dart';

class CountdownTimerWidget extends StatefulWidget {
  final int durationInMinutes;
  final VoidCallback onTimerComplete;

  const CountdownTimerWidget({
    Key? key,
    required this.durationInMinutes,
    required this.onTimerComplete,
  }) : super(key: key);

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Duration _duration;
  late Duration _remainingTime;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _duration = Duration(minutes: widget.durationInMinutes);
    _remainingTime = _duration;

    _controller = AnimationController(
      vsync: this,
      duration: _duration,
    );

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _remainingTime = _duration * (1 - _animation.value);
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onTimerComplete();
        }
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _controller.stop();
      } else {
        _controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remainingTime.inMinutes;
    final seconds = _remainingTime.inSeconds % 60;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Círculo de progreso
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: _animation.value,
                strokeWidth: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isPaused ? Colors.orange : Colors.blue,
                ),
              ),
              // Tiempo restante
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$minutes:${seconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isPaused ? 'Pausado' : 'En progreso',
                    style: TextStyle(
                      fontSize: 16,
                      color: _isPaused ? Colors.orange : Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Botón de pausa/reanudar
        ElevatedButton.icon(
          onPressed: _togglePause,
          icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
          label: Text(_isPaused ? 'Reanudar' : 'Pausar'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ],
    );
  }
} 