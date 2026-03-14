import 'package:flutter/material.dart';
import '../features/game/views/warning_screen.dart';
import '../features/game/views/game_screen.dart';
import '../features/game/views/win_screen.dart';
import 'theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campo Minado',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const WarningScreen(),
        '/game': (context) => const GameScreen(),
        '/win': (context) => const WinScreen(),
      },
    );
  }
}
