// The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.

import "dart:async";
import "dart:math";
import "dart:convert";

import 'package:buzzing/utils/loogger_util.dart';
import 'package:buzzing/page/screenshot/screenshot_view.dart';
import 'package:buzzing/utils/config/config.dart';
import 'package:buzzing/page/error_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
//import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';
//import 'ffi/ffi_cpp.dart' if (dart.library.html) 'ffi_web.dart';
import 'package:buzzing/utils/env/config_wrapper.dart';
import 'package:buzzing/utils/env/env_config.dart';
import 'package:buzzing/page/screenshot/event_widget.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:desktop_lifecycle/desktop_lifecycle.dart';
import 'package:window_manager/window_manager.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'webview.dart';
import 'vc.dart';

Future<Null> main(List<String> args) async {
  if (args.firstOrNull == 'multi_window') {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
    LD("statr new window: ${args}");
    await windowManager.waitUntilReadyToShow();

    //final windowId = int.parse(args[1]);
    final argument =
        (args[2].isEmpty ? const {} : jsonDecode(args[2]))
            as Map<String, dynamic>;

    final windowController = await WindowController.fromCurrentEngine();
    var app = argument['app'] ?? "";
    switch (app) {
      case "VcWindow":
        {
          startVcWindow(windowController, argument, args[1]);
        }
        break;
      case "WebviewWindow":
        {
          final channel = WindowMethodChannel("WebviewWindow");
          runApp(
            WebviewWindow(
              windowController: windowController,
              args: argument,
              channel: channel,
            ),
          );
        }
        break;
      default:
        runApp(
          _ExampleSubWindow(windowController: windowController, args: argument),
        );
        break;
    }
    return;
  }
  BindingBase.debugZoneErrorsAreFatal = true;

  FlutterError.onError = (FlutterErrorDetails details) async {
    if (kDebugMode || kProfileMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack!);
    }
  };
  runZonedGuarded(
    () {
      final channel = WindowMethodChannel(
        "Main",
        mode: ChannelMode.unidirectional,
      );
      //debugPaintSizeEnabled = true;
      Config.init(() => runApp(ProviderScope(child: BuzzingApp(channel: channel))));
    },
    (Object error, StackTrace stackTrace) {
      LD("Error from outside framework");
      LD("Error: $error");
      LD("StackTrace: $stackTrace");
    },
  );
}

void run() {}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

void runInterval(void Function() callback) =>
    Timer.periodic(const Duration(milliseconds: 1000), (timer) => callback());

class _MyHomePageState extends State<MyHomePage> {
  // These futures belong to the state and are only initialized once,
  // in the initState method.
  late Future<String> greeting;

  @override
  void initState() {
    super.initState();
    runInterval(updateText);
  }

  Future<void> updateText() async {
    final name = Random().nextInt(1000).toString();
    final text = await "123";
    if (mounted) {
      setState(() {
        greeting = Future.value(text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("You're running on"),
            // To render the results of a Future, a FutureBuilder is used which
            // turns a Future into an AsyncSnapshot, which can be used to
            // extract the error state, the loading state and the data if
            // available.
            //
            // Here, the generic type that the FutureBuilder manages is
            // explicitly named, because if omitted the snapshot will have the
            // type of AsyncSnapshot<Object?>.
            FutureBuilder<List<dynamic>>(
              // We await two unrelated futures here, so the type has to be
              // List<dynamic>.
              future: Future.wait([greeting]),
              builder: (context, snap) {
                final style = Theme.of(context).textTheme.headlineMedium;
                if (snap.error != null) {
                  // An error has been encountered, so give an appropriate response and
                  // pass the error details to an unobstructive tooltip.
                  LD(snap.error.toString());
                  return Tooltip(
                    message: snap.error.toString(),
                    child: Text('Unknown OS', style: style),
                  );
                }

                // Guard return here, the data is not ready yet.
                final data = snap.data;
                if (data == null) return const CircularProgressIndicator();

                // Finally, retrieve the data expected in the same order provided
                // to the FutureBuilder.future.
                final String text = data[0];
                return Text('$text ', style: style);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:buzzing/ffi/rust/ffi/flutter.dart';
import 'package:buzzing/ffi/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
        body: Center(
          child: Text(
              'Action: Call Rust `greet("Tom")`\nResult: `${greet(name: "Tom")}`'),
        ),
      ),
    );
  }
}
*/
/*
// 窗口入口处理
void handleWindowMethodCall(MethodCall call, int windowId) async {
  switch (call.method) {
    case 'initialize':
      final arguments = call.arguments as Map<String, dynamic>;
      if (arguments['type'] == 'screenshot') {
        // 接收图像数据并显示截图界面
        final window = DesktopMultiWindow.getWindow(windowId);
        window.setMethodCallHandler((call, windowId) async {
          if (call.method == 'data') {
            final data = call.arguments as Uint8List;
            runApp(MaterialApp(
              home: ScreenshotOverlay(imageData: data),
            ));
          }
        });
      }
      break;
    default:
      break;
  }
}
  */

class _ExampleSubWindow extends StatelessWidget {
  const _ExampleSubWindow({
    Key? key,
    required this.windowController,
    required this.args,
  }) : super(key: key);

  final WindowController windowController;
  final Map? args;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: ScreenshotOverlay(),
      ),
    );
  }
}
