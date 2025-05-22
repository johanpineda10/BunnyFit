import 'package:flutter/material.dart';
import '../models/test_detail.dart';
import '../models/test_fisico.dart';
import '../widgets/stopwatch_widget.dart';
import '../models/test_user_type.dart';

class TestFeedbackScreen extends StatelessWidget {
  final TestDetail test;
  final List<LapTime> laps;
  final Duration totalTime;
  final String? notes;
  final TestExecutionConfig? config;

  const TestFeedbackScreen({
    super.key,
    required this.test,
    required this.laps,
    required this.totalTime,
    this.notes,
    this.config,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final hundredths = twoDigits(duration.inMilliseconds.remainder(1000) ~/ 10);
    return "$minutes:$seconds.$hundredths";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Retroalimentación'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen del Test
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test.nombre,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Tiempo Total', _formatDuration(totalTime)),
                _buildInfoRow('Vueltas Completadas', laps.length.toString()),
                if (notes?.isNotEmpty ?? false)
                  _buildInfoRow('Notas', notes!),
              ],
            ),
            const SizedBox(height: 32),

            // Resultados Detallados
            _buildSection(
              context: context,
              title: 'Resultados Detallados',
              icon: Icons.analytics,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: laps.length,
                itemBuilder: (context, index) {
                  final lap = laps[index];
                  return ListTile(
                    title: Text('Vuelta ${lap.lapNumber}'),
                    trailing: Text(_formatDuration(lap.lapDuration)),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Gráficos de Rendimiento
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.show_chart, color: const Color(0xFF2196F3)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Gráficos de Rendimiento',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Gráficos de rendimiento\n(Próximamente)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Análisis y Recomendaciones
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.insights, color: const Color(0xFF2196F3)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Análisis y Recomendaciones',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildAnalysisItem(
                  'Rendimiento General',
                  'El análisis de rendimiento estará disponible próximamente.',
                ),
                const SizedBox(height: 16),
                _buildAnalysisItem(
                  'Áreas de Mejora',
                  'Las recomendaciones personalizadas estarán disponibles próximamente.',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Fórmulas (si están disponibles)
            if (test.formulas != null && test.formulas!.isNotEmpty) ...[
              _buildSection(
                context: context,
                title: 'Fórmulas',
                icon: Icons.functions,
                child: Column(
                  children: test.formulas!.map((formula) => _buildFormulaItem(formula)).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Ejercicios Recomendados
            _buildSection(
              context: context,
              title: 'Ejercicios Recomendados',
              icon: Icons.fitness_center,
              child: Column(
                children: [
                  _buildExercisePlaceholder(
                    'Ejercicios de Fortalecimiento',
                    'Lista de ejercicios específicos próximamente',
                  ),
                  _buildExercisePlaceholder(
                    'Ejercicios de Técnica',
                    'Lista de ejercicios técnicos próximamente',
                  ),
                  _buildExercisePlaceholder(
                    'Ejercicios Complementarios',
                    'Lista de ejercicios complementarios próximamente',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tiempo de Recuperación
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.refresh, color: const Color(0xFF2196F3)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tiempo de Recuperación Recomendado',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRecoveryTimeSection(),
              ],
            ),
            const SizedBox(height: 32),

            // Logros y Medallas
            _buildSection(
              context: context,
              title: 'Logros y Medallas',
              icon: Icons.emoji_events,
              child: _buildAchievementsSection(),
            ),
            const SizedBox(height: 24),

            // Ajustes del Test
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tune, color: const Color(0xFF2196F3)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ajustes del Test',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTestAdjustmentsSection(context),
              ],
            ),

            // Comentarios del Supervisor
            if (config?.userType == TestUserType.other) ...[
              const SizedBox(height: 32),
              _buildSection(
                context: context,
                title: 'Comentarios del Supervisor',
                icon: Icons.rate_review,
                child: _buildSupervisorCommentsSection(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF2196F3)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildExercisePlaceholder(String title, String description) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.fitness_center,
          color: Color(0xFF2196F3),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        description,
        style: const TextStyle(
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildFormulaItem(Formula formula) {
    return ExpansionTile(
      title: Text(
        formula.nombre,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formula.descripcion,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  formula.formula,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Variables:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ...formula.variables.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(entry.value),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecoveryTimeSection() {
    // TODO: Implementar lógica para calcular tiempo de recuperación basado en:
    // - Tipo de test
    // - Intensidad
    // - Duración
    // - Nivel del usuario
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.timer,
              color: Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '24 horas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Recomendaciones:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        _buildRecoveryTip(
          icon: Icons.water_drop,
          text: 'Mantén una buena hidratación',
        ),
        _buildRecoveryTip(
          icon: Icons.hotel,
          text: 'Asegura un descanso adecuado',
        ),
        _buildRecoveryTip(
          icon: Icons.restaurant,
          text: 'Sigue una alimentación balanceada',
        ),
      ],
    );
  }

  Widget _buildRecoveryTip({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    // TODO: Implementar lógica para otorgar logros basados en:
    // - Mejora del rendimiento
    // - Consistencia
    // - Hitos alcanzados
    // - Récords personales
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildAchievementBadge(
          icon: Icons.speed,
          label: 'Velocista',
          description: 'Superaste tu mejor tiempo',
          isLocked: false,
        ),
        _buildAchievementBadge(
          icon: Icons.trending_up,
          label: 'Progreso',
          description: 'Mejora constante',
          isLocked: false,
        ),
        _buildAchievementBadge(
          icon: Icons.star,
          label: 'Elite',
          description: 'Top 10% en este test',
          isLocked: true,
        ),
      ],
    );
  }

  Widget _buildAchievementBadge({
    required IconData icon,
    required String label,
    required String description,
    required bool isLocked,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey[100] : Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLocked ? Colors.grey[300]! : Colors.blue[200]!,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 32,
            color: isLocked ? Colors.grey : Colors.blue[700],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isLocked ? Colors.grey[600] : Colors.blue[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 10,
              color: isLocked ? Colors.grey[500] : Colors.blue[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTestAdjustmentsSection(BuildContext context) {
    // TODO: Implementar lógica para ajustar:
    // - Dificultad
    // - Objetivos
    // - Variaciones del test
    // - Personalización
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Quieres aumentar la dificultad del test la próxima vez?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        _buildAdjustmentOption(
          icon: Icons.fitness_center,
          title: 'Aumentar intensidad',
          subtitle: 'Incrementa la carga o velocidad',
          onTap: () {
            // TODO: Implementar ajuste de intensidad
          },
        ),
        _buildAdjustmentOption(
          icon: Icons.timer,
          title: 'Modificar duración',
          subtitle: 'Ajusta el tiempo o las repeticiones',
          onTap: () {
            // TODO: Implementar ajuste de duración
          },
        ),
        _buildAdjustmentOption(
          icon: Icons.compare_arrows,
          title: 'Cambiar distancia',
          subtitle: 'Modifica el recorrido o el espacio',
          onTap: () {
            // TODO: Implementar ajuste de distancia
          },
        ),
      ],
    );
  }

  Widget _buildAdjustmentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.blue[700], size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupervisorCommentsSection() {
    // TODO: Implementar lógica para:
    // - Guardar comentarios del supervisor
    // - Historial de supervisiones
    // - Recomendaciones específicas
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Añade tus observaciones sobre el rendimiento y técnica del participante...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            _buildQuickComment('Buena técnica'),
            _buildQuickComment('Necesita mejorar postura'),
            _buildQuickComment('Ritmo constante'),
            _buildQuickComment('Fatiga temprana'),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickComment(String text) {
    return InkWell(
      onTap: () {
        // TODO: Implementar la lógica para añadir comentario rápido
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[800],
          ),
        ),
      ),
    );
  }
} 