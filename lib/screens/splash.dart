import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 140, right: 100),
            child: Image.asset('assets/logo.png'),
          ),
          const SizedBox(height: 80),
          SizedBox(
            height: 50,
            width: 50,
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation(
                theme.colorScheme.onPrimary.withOpacity(0.4),
              ),
              strokeWidth: 5,
            ),
          ),
        ],
      )),
    );
  }
}
