import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LifeExpectancyModel(),
      child: const LifeExpectancyApp(),
    ),
  );
}

class LifeExpectancyApp extends StatelessWidget {
  const LifeExpectancyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Expectancy Calculator',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      home: const LifeExpectancyCalculator(),
    );
  }
}

class LifeExpectancyModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _prediction;
  String? _error;

  bool get isLoading => _isLoading;
  String? get prediction => _prediction;
  String? get error => _error;

  Future<void> predictLifeExpectancy(Map<String, double> data) async {
    _isLoading = true;
    _prediction = null;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://your-api-endpoint.com/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        _prediction = result['prediction'].toString();
      } else {
        throw Exception('Failed to predict life expectancy');
      }
    } catch (e) {
      _error = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class LifeExpectancyCalculator extends StatelessWidget {
  const LifeExpectancyCalculator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade200, Colors.green.shade600],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: LifeExpectancyForm(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LifeExpectancyForm extends StatefulWidget {
  const LifeExpectancyForm({Key? key}) : super(key: key);

  @override
  _LifeExpectancyFormState createState() => _LifeExpectancyFormState();
}

class _LifeExpectancyFormState extends State<LifeExpectancyForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController rdSpendController = TextEditingController();
  final TextEditingController administrationController =
      TextEditingController();
  final TextEditingController marketingSpendController =
      TextEditingController();

  @override
  void dispose() {
    rdSpendController.dispose();
    administrationController.dispose();
    marketingSpendController.dispose();
    super.dispose();
  }

  void _predictLifeExpectancy() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'rd_spend': double.parse(rdSpendController.text),
        'administration': double.parse(administrationController.text),
        'marketing_spend': double.parse(marketingSpendController.text),
      };
      Provider.of<LifeExpectancyModel>(context, listen: false)
          .predictLifeExpectancy(data);
    }
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool autofocus = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          autofocus: autofocus,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
          ],
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Life Expectancy Calculator',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          _buildInputField('R&D Spend', rdSpendController, autofocus: true),
          const SizedBox(height: 20),
          _buildInputField('Administration', administrationController),
          const SizedBox(height: 20),
          _buildInputField('Marketing Spend', marketingSpendController),
          const SizedBox(height: 30),
          Consumer<LifeExpectancyModel>(
            builder: (context, model, child) {
              return ElevatedButton(
                onPressed: model.isLoading ? null : _predictLifeExpectancy,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: model.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Predict Life Expectancy',
                          style: TextStyle(fontSize: 18)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ).animate().fade(duration: 500.ms).slide(
                  begin: const Offset(0, 0.5), curve: Curves.easeOutQuad);
            },
          ),
          const SizedBox(height: 20),
          Consumer<LifeExpectancyModel>(
            builder: (context, model, child) {
              if (model.prediction != null) {
                return Text(
                  'Predicted Life Expectancy: ${model.prediction} years',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                );
              } else if (model.error != null) {
                return Text(
                  model.error!,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                  textAlign: TextAlign.center,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
