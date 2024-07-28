import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfitForm(),
    );
  }
}

class ProfitForm extends StatefulWidget {
  @override
  _ProfitFormState createState() => _ProfitFormState();
}

class _ProfitFormState extends State<ProfitForm> {
  final _formKey = GlobalKey<FormState>();

  final _rdSpendController = TextEditingController();
  final _administrationController = TextEditingController();
  final _marketingSpendController = TextEditingController();

  Future<void> _submitData() async {
    final url = 'http://127.0.0.1:8000/predict';

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'rd_spend': double.parse(_rdSpendController.text),
        'administration': double.parse(_administrationController.text),
        'marketing_spend': double.parse(_marketingSpendController.text),
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final prediction = responseData['prediction'];

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Prediction'),
          content: Text('The predicted profit is \$${prediction}'),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    } else {
      throw Exception('Failed to load prediction');
    }
  }

  @override
  void dispose() {
    _rdSpendController.dispose();
    _administrationController.dispose();
    _marketingSpendController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profit Prediction'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade200, Colors.green.shade800],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _rdSpendController,
                      decoration: InputDecoration(
                        labelText: 'R&D Spend',
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter R&D Spend';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _administrationController,
                      decoration: InputDecoration(
                        labelText: 'Administration',
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Administration';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _marketingSpendController,
                      decoration: InputDecoration(
                        labelText: 'Marketing Spend',
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Marketing Spend';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _submitData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        surfaceTintColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      child: Text('Predict', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
