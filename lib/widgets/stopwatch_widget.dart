import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class LapTime {
  final int lapNumber;
  final Duration lapDuration;
  final Duration totalDuration;

  const LapTime({
    required this.lapNumber,
    required this.lapDuration,
    required this.totalDuration,
  });
}

class StopwatchWidget extends StatefulWidget {
  final Function(List<LapTime> laps, Duration totalTime)? onComplete;

  const StopwatchWidget({
    Key? key,
    this.onComplete,
  }) : super(key: key);

  @override
  State<StopwatchWidget> createState() => _StopwatchWidgetState();
}

class _StopwatchWidgetState extends State<StopwatchWidget> with SingleTickerProviderStateMixin {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  Duration _lastLapElapsed = Duration.zero;
  List<LapTime> _laps = [];
  bool _isRunning = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (!_isRunning) {
      _timer = Timer.periodic(const Duration(milliseconds: 10), _onTick);
      _isRunning = true;
      _animationController.repeat();
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _isRunning = false;
    _animationController.stop();
    if (widget.onComplete != null) {
      widget.onComplete!(_laps, _elapsed);
    }
  }

  void _onTick(Timer timer) {
    setState(() {
      _elapsed += const Duration(milliseconds: 10);
    });
  }

  void _lap() {
    if (_isRunning) {
      final lapDuration = _elapsed - _lastLapElapsed;
      setState(() {
        _laps = [
          ..._laps,
          LapTime(
            lapNumber: _laps.length + 1,
            lapDuration: lapDuration,
            totalDuration: _elapsed,
          ),
        ];
        _lastLapElapsed = _elapsed;
      });
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _elapsed = Duration.zero;
      _lastLapElapsed = Duration.zero;
      _laps = [];
      _isRunning = false;
    });
    _animationController.reset();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final hundredths = twoDigits(duration.inMilliseconds.remainder(1000) ~/ 10);
    return "$minutes:$seconds.$hundredths";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatDuration(_elapsed),
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w300,
            fontFamily: 'monospace',
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          width: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              RotationTransition(
                turns: _animationController,
                child: CustomPaint(
                  size: const Size(200, 200),
                  painter: StopwatchDialPainter(),
                ),
              ),
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[800]!, width: 2),
                ),
                child: Center(
                  child: Text(
                    _isRunning ? 'Stop' : 'Start',
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isRunning ? _stopTimer : _startTimer,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_laps.isNotEmpty) ...[
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Lap',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Lap time',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Total',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _laps.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final lap = _laps[_laps.length - 1 - index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Lap ${lap.lapNumber}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '+${_formatDuration(lap.lapDuration)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                _formatDuration(lap.totalDuration),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _isRunning ? _lap : _reset,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                minimumSize: const Size(120, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(_isRunning ? 'Lap' : 'Reset'),
            ),
          ],
        ),
      ],
    );
  }
}

class StopwatchDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = Colors.grey[600]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Dibuja las marcas del dial
    for (var i = 0; i < 60; i++) {
      final angle = i * (2 * 3.14159 / 60);
      final isLongMark = i % 5 == 0;
      final markLength = isLongMark ? 15.0 : 8.0;
      final startRadius = radius - markLength;
      final startPoint = Offset(
        center.dx + startRadius * cos(angle),
        center.dy + startRadius * sin(angle),
      );
      final endPoint = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 