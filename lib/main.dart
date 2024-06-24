import 'package:flutter/material.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';

import 'tc.dart';
import 'package:tccore_plugin/TCDebug.dart';

late TC tc;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  tc = TC(
      siteId: 7244,
      privacyId: 6,
      sourceKey: "bed1ecf4-ca9e-4f63-9a4c-62cd303e3634");

  TCDebug().setDebugLevel(TCLogLevel.TCLogLevel_Verbose);
  TCDebug().setNotificationLog(true);

  runApp(MaterialApp(
    title: 'Navigation Basics',
    initialRoute: '/',
    routes: {
      '/': (context) => const FirstRoute(),
      '/second': (context) => const SecondRoute(),
    },
    navigatorObservers: [tc.getTCObserver(), NavigationHistoryObserver()],
  ));
}

class FirstRoute extends StatelessWidget {
  const FirstRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Route'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Open route'),
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/second',
              arguments: ScreenArguments(
                'Extract Arguments Screen',
                'This message is extracted in the build method.',
              ),
            );
          },
        ),
      ),
    );
  }
}

// You can pass any object to the arguments parameter.
// In this example, create a class that contains both
// a customizable title and message.
class ScreenArguments extends TCArguments {
  final String title;
  final String message;

  ScreenArguments(this.title, this.message);

  @override
  Map<String, dynamic> to_tc() {
    return {"title": title, "message": message};
  }
}

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Route : ${args.message}'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
