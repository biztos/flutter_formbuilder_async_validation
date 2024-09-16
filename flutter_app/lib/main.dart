import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FormBuilder Async',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'FormBuilder Async'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const SafeArea(
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'The URL will be validated asynchronously.',
              ),
              DemoForm(),
            ],
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class DemoForm extends StatefulWidget {
  const DemoForm({super.key});

  @override
  DemoFormState createState() {
    return DemoFormState();
  }
}

class DemoFormState extends State<DemoForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  final _urlController = TextEditingController(text: 'https://pub.dev/');

  bool _isValidating = false;
  bool _lastUrlSuccess = false;

  Future<String> _checkUrl(String input) async {
    final url = Uri.parse(input);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return 'SUCCESS';
    } else {
      final code = response.statusCode;
      final reason = response.reasonPhrase!;
      return '$code $reason';
    }
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isValidating
          ? null
          : () async {
              if (_isValidating) {
                // The form should be locked here, but Flutter so...
                debugPrint("WTF already checking!");
                return;
              }
              if (_formKey.currentState?.saveAndValidate() ?? true) {
                // IMPORTANT! Must set the var in setState to trigger rebuild.
                setState(() {
                  _lastUrlSuccess = false;
                  _isValidating = true;
                });
                try {
                  final res = await _checkUrl(_urlController.text);
                  if (res == "SUCCESS") {
                    _lastUrlSuccess = true;
                  } else {
                    _formKey.currentState?.fields['url']?.invalidate(res);
                  }
                } catch (e) {
                  _formKey.currentState?.fields['url']?.invalidate('Error: $e');
                }

                setState(() {
                  _isValidating = false;
                });
              }
            },
      child: Text(_isValidating ? "Validating..." : "Validate"),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return FormBuilder(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(38.0),
            child: FormBuilderTextField(
              key: const Key('url'),
              name: 'url',
              enabled: !_isValidating,
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'URL'),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.url(),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildSubmitButton(),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _lastUrlSuccess ? const Text('Success!') : const Text('---'),
          ),
        ],
      ),
    );
  }
}
