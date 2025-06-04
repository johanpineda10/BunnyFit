import 'package:flutter/material.dart';

class TestProgress {
  final double progressPercentage;
  final Duration estimatedTimeLeft;
  final String currentPhase;
  final bool isCompleted;

  const TestProgress({
    required this.progressPercentage,
    required this.estimatedTimeLeft,
    required this.currentPhase,
    this.isCompleted = false,
  });

  String get progressMessage {
    if (isCompleted) return '¡Test completado!';
    
    if (progressPercentage < 25) {
      return 'Comenzando el test...';
    } else if (progressPercentage < 50) {
      return 'Vas por buen camino';
    } else if (progressPercentage < 75) {
      return '¡Falta poco!';
    } else {
      return 'Ya casi terminas';
    }
  }

  String get timeLeftMessage {
    final minutes = estimatedTimeLeft.inMinutes;
    final seconds = estimatedTimeLeft.inSeconds % 60;

    if (minutes > 0) {
      return 'Quedan $minutes ${minutes == 1 ? 'minuto' : 'minutos'} y $seconds ${seconds == 1 ? 'segundo' : 'segundos'}';
    } else {
      return 'Quedan $seconds ${seconds == 1 ? 'segundo' : 'segundos'}';
    }
  }
}

class TestSupervisor {
  final String name;
  final String? role;
  final String? specialization;

  const TestSupervisor({
    required this.name,
    this.role,
    this.specialization,
  });

  String get supervisorMessage {
    final baseMessage = '¡Recuerda! Este test está siendo supervisado por $name';
    if (role != null) {
      return '$baseMessage, ${role!.toLowerCase()}';
    }
    return baseMessage;
  }
}

class TestProgressIndicator extends StatelessWidget {
  final TestProgress progress;
  final Color? progressColor;
  final Color? backgroundColor;

  const TestProgressIndicator({
    super.key,
    required this.progress,
    this.progressColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              progress.progressMessage,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress.progressPercentage * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.progressPercentage,
            backgroundColor: backgroundColor ?? Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              progressColor ?? Colors.blue,
            ),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          progress.timeLeftMessage,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        if (progress.currentPhase.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Fase actual: ${progress.currentPhase}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}

class SupervisorBanner extends StatelessWidget {
  final TestSupervisor supervisor;

  const SupervisorBanner({
    super.key,
    required this.supervisor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue[100]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person,
            color: Colors.blue[700],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              supervisor.supervisorMessage,
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 