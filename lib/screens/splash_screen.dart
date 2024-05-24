import 'package:flutter/material.dart';
import 'package:pragma_todo/screens/todo_page.dart';

class SplashScreen extends StatefulWidget {
    const SplashScreen({super.key});

    @override
    _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
    double _progressValue = 0.0;

    @override
    void initState() {
        super.initState();
        _simulateLoading();
    }

    Future<void> _simulateLoading() async {
        const int totalSteps = 3;
        const int totalDurationSeconds = 10;
        const Duration stepDuration = Duration(seconds: totalDurationSeconds ~/ totalSteps);

        // Simulate loading progress
        for (int step = 1; step <= totalSteps; step++) {
            setState(() {
                _progressValue = step / totalSteps; // Update progress value for the current step
            });
            await Future.delayed(stepDuration); // Wait for the step duration
        }

        // After loading, navigate to the ToDoPage
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ToDoPage()),
        );
    }


// Get progress message based on progress value
    String _getProgressMessage(double progress) {
        if (progress < 0.3) {
            return 'Getting your tasks...';
        } else if (progress < 0.6) {
            return 'Almost done...';
        } else {
            return 'You are all set!';
        }
    }


    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        CircularProgressIndicator(
                            value: _progressValue,
                        ),
                        const SizedBox(height: 20),
                        Text(
                            _getProgressMessage(_progressValue),
                            style: const TextStyle(fontSize: 16),
                        ),
                    ],
                ),
            ),
        );
    }
}
