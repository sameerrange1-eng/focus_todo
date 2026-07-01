import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/focus_session_provider.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FocusSessionProvider(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Focus Session')),
        body: Consumer<FocusSessionProvider>(
          builder: (context, session, _) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: CircularProgressIndicator(
                          value: session.progress,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey.shade200,
                        ),
                      ),
                      Text(
                        _formatDuration(session.remaining),
                        style: const TextStyle(
                            fontSize: 40, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  if (session.state == FocusSessionState.idle) ...[
                    const Text('Choose a session length',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [15, 25, 45, 60].map((mins) {
                        return ChoiceChip(
                          label: Text('$mins min'),
                          selected:
                              session.totalDuration.inMinutes == mins,
                          onSelected: (_) =>
                              session.setDuration(Duration(minutes: mins)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => session.start(),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start focus session'),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'App blocking requires a one-time permission on Android.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ] else if (session.state == FocusSessionState.running) ...[
                    const Text('Stay focused!',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: session.pause,
                      icon: const Icon(Icons.pause),
                      label: const Text('Pause'),
                    ),
                  ] else if (session.state == FocusSessionState.paused) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: session.resume,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Resume'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: session.cancel,
                          icon: const Icon(Icons.stop),
                          label: const Text('End'),
                        ),
                      ],
                    ),
                  ] else if (session.state ==
                      FocusSessionState.completed) ...[
                    const Icon(Icons.celebration,
                        size: 48, color: Colors.amber),
                    const SizedBox(height: 12),
                    const Text('Session complete!',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    FilledButton(
                        onPressed: session.reset,
                        child: const Text('Start another')),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
