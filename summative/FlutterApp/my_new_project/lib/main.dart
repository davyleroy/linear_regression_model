import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  runApp(LifeExpectancyApp());
}

class LifeExpectancyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Expectancy Calculator',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: GoogleFonts.poppins().fontFamily,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: LifeExpectancyCalculator(),
    );
  }
}

class LifeExpectancyCalculator extends StatefulWidget {
  @override
  _LifeExpectancyCalculatorState createState() =>
      _LifeExpectancyCalculatorState();
}

class _LifeExpectancyCalculatorState extends State<LifeExpectancyCalculator> {
  final _formKey = GlobalKey<FormState>();
  String selectedCountry = 'USA';
  final TextEditingController bmiController = TextEditingController();
  final TextEditingController incomeCompositionController =
      TextEditingController();

  final List<String> countries = ['USA', 'Canada', 'UK', 'Australia', 'Japan'];

  bool _isLoading = false;

  @override
  void dispose() {
    bmiController.dispose();
    incomeCompositionController.dispose();
    super.dispose();
  }

  Future<void> _predictLifeExpectancy() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('https://your-api-endpoint.com/predict'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'country': selectedCountry,
            'bmi': double.parse(bmiController.text),
            'income_composition':
                double.parse(incomeCompositionController.text),
          }),
        );

        if (response.statusCode == 200) {
          final result = json.decode(response.body);
          _showPredictionResult(result['prediction']);
        } else {
          throw Exception('Failed to predict life expectancy');
        }
      } catch (e) {
        _showErrorDialog('An error occurred: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showPredictionResult(dynamic result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Predicted Life Expectancy',
              style: TextStyle(color: Colors.teal)),
          content: Text('The predicted life expectancy is: $result years',
              style: TextStyle(fontSize: 18)),
          actions: <Widget>[
            TextButton(
              child: Text('Close', style: TextStyle(color: Colors.teal)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ).animate().scale(duration: 300.ms, curve: Curves.easeOutQuad);
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Life Expectancy Calculator',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ... (rest of the UI code remains the same)
                ElevatedButton(
                  onPressed: _isLoading ? null : _predictLifeExpectancy,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Predict Life Expectancy',
                            style: TextStyle(fontSize: 18)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                )
                    .animate()
                    .fade(duration: 500.ms)
                    .slide(begin: Offset(0, 0.5), curve: Curves.easeOutQuad),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
