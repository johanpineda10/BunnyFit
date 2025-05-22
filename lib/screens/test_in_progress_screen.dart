import 'package:flutter/material.dart';
import '../models/test_detail.dart';
import '../models/test_user_type.dart';
import '../models/test_progress.dart';
import '../widgets/stopwatch_widget.dart';
import 'test_feedback_screen.dart';

class TestInProgressScreen extends StatefulWidget {
  final TestDetail test;
  final TestExecutionConfig config;

  const TestInProgressScreen({
    super.key,
    required this.test,
    required this.config,
  });

  @override
  State<TestInProgressScreen> createState() => _TestInProgressScreenState();
}

class _TestInProgressScreenState extends State<TestInProgressScreen> {
  // Color azul constante para la aplicación
  static const Color appBlueColor = Color(0xFF2196F3);

  List<LapTime> _currentLaps = [];
  Duration _currentTime = Duration.zero;
  bool _isGPSActive = false;
  late TestProgress _testProgress;
  final TestSupervisor _supervisor = const TestSupervisor(
    name: 'Juan Pérez',
    role: 'Entrenador Personal',
  );

  @override
  void initState() {
    super.initState();
    _initializeGPS();
    _initializeProgress();
  }

  Future<void> _initializeGPS() async {
    if (widget.config.gpsEnabled) {
      // TODO: Implementar la inicialización real del GPS
      setState(() {
        _isGPSActive = true;
      });
    }
  }

  void _initializeProgress() {
    _testProgress = TestProgress(
      progressPercentage: 0.0,
      estimatedTimeLeft: const Duration(minutes: 5),
      currentPhase: 'Preparación',
      isCompleted: false,
    );
  }

  void _onTestComplete(List<LapTime> laps, Duration totalTime) {
    setState(() {
      _currentLaps = laps;
      _currentTime = totalTime;
    });
  }

  void _showResults() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TestResultsModal(
        laps: _currentLaps,
        totalTime: _currentTime,
        test: widget.test,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.test.nombre),
        backgroundColor: appBlueColor,
        foregroundColor: Colors.white,
        actions: [
          if (widget.config.gpsEnabled)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                _isGPSActive ? Icons.location_on : Icons.location_off,
                color: _isGPSActive ? Colors.green : Colors.red,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (widget.config.gpsEnabled && !_isGPSActive)
              Container(
                color: Colors.red[100],
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'GPS desactivado. Actívalo para medir distancias.',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Barra de progreso o banner del supervisor
                      if (widget.config.gpsEnabled) ...[
                        TestProgressIndicator(
                          progress: _testProgress,
                          progressColor: appBlueColor,
                        ),
                        const SizedBox(height: 32),
                      ] else ...[
                        SupervisorBanner(supervisor: _supervisor),
                        const SizedBox(height: 32),
                      ],
                      // Instrucciones del test
                      Text(
                        'Instrucciones',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.test.pasos.join('\n\n'),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 32),
                      // Cronómetro
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: StopwatchWidget(
                          onComplete: _onTestComplete,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Precauciones
                      Text(
                        'Precauciones',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.test.precauciones.join('\n\n'),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 32),
                      if (widget.config.gpsEnabled) ...[
                        _buildGPSDataSection(),
                        const SizedBox(height: 24),
                      ],
                      _buildManualDataSection(),
                    ],
                  ),
                ),
              ),
            ),
            // Botón Finalizar Test
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showResults,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appBlueColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Finalizar Test',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGPSDataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datos GPS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDataRow('Distancia', '0.00 km'),
            const SizedBox(height: 8),
            _buildDataRow('Velocidad', '0.0 km/h'),
            const SizedBox(height: 8),
            _buildDataRow('Altitud', '0.0 m'),
          ],
        ),
      ),
    );
  }

  Widget _buildManualDataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Datos Manuales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!widget.config.gpsEnabled)
                  const Text(
                    '(Requerido)',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Distancia (km)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              enabled: !widget.config.gpsEnabled,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Observaciones',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class TestResultsModal extends StatefulWidget {
  final List<LapTime> laps;
  final Duration totalTime;
  final TestDetail test;

  const TestResultsModal({
    Key? key,
    required this.laps,
    required this.totalTime,
    required this.test,
  }) : super(key: key);

  @override
  State<TestResultsModal> createState() => _TestResultsModalState();
}

class _TestResultsModalState extends State<TestResultsModal> {
  final _formKey = GlobalKey<FormState>();
  String? _notas;

  void _navigateToFeedback(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TestFeedbackScreen(
            test: widget.test,
            laps: widget.laps,
            totalTime: widget.totalTime,
            notes: _notas,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resultados del Test',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tiempo total: ${_formatDuration(widget.totalTime)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Número de vueltas: ${widget.laps.length}',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          if (widget.laps.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Tiempos por vuelta:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            for (var lap in widget.laps)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Vuelta ${lap.lapNumber}: ${_formatDuration(lap.lapDuration)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
          ],
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notas adicionales',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Ingresa cualquier observación relevante',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) => _notas = value,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _navigateToFeedback(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar Resultados'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final hundredths = twoDigits(duration.inMilliseconds.remainder(1000) ~/ 10);
    return "$minutes:$seconds.$hundredths";
  }
} 