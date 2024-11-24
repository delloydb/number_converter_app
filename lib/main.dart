import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const NumberConverterApp());
}

class NumberConverterApp extends StatelessWidget {
  const NumberConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Converter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NumberConverterPage(),
    );
  }
}

class NumberConverterPage extends StatefulWidget {
  const NumberConverterPage({super.key});

  @override
  State<NumberConverterPage> createState() => _NumberConverterPageState();
}

class _NumberConverterPageState extends State<NumberConverterPage> {
  final TextEditingController _binaryController = TextEditingController();
  final TextEditingController _decimalController = TextEditingController();
  final TextEditingController _hexController = TextEditingController();
  final TextEditingController _octalController = TextEditingController();

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _isValidNumber(String input, int radix) {
    try {
      if (input.isEmpty) {
        return false;
      }
      if (input.contains('.')) {
        final List<String> parts = input.split('.');
        return parts.length == 2 &&
            int.tryParse(parts[0], radix: radix) != null &&
            parts[1].runes.every((int char) => int.tryParse(String.fromCharCode(char), radix: radix) != null);
      } else {
        return int.tryParse(input, radix: radix) != null;
      }
    } catch (e) {
      return false;
    }
  }

  void _convert(String input, int fromBase, int toBase, TextEditingController controller) {
    try {
      if (!_isValidNumber(input, fromBase)) {
        throw const FormatException();
      }
      final double decimal = _convertToDecimal(input, fromBase);
      final String result = _convertFloatingPoint(decimal, toBase);
      controller.text = result;
    } catch (e) {
      _showError('Invalid Input');
    }
  }

  double _convertToDecimal(String input, int base) {
    if (!input.contains('.')) {
      return double.parse(int.parse(input, radix: base).toString());
    }
    final List<String> parts = input.split('.');
    final int intPart = int.parse(parts[0], radix: base);
    double fracPart = 0.0;
    for (int i = 0; i < parts[1].length; i++) {
      fracPart += int.parse(parts[1][i], radix: base) / pow(base, i + 1);
    }
    return intPart + fracPart;
  }

  String _convertFloatingPoint(double decimal, int toBase) {
    final int intPart = decimal.floor();
    final double fracPart = decimal - intPart;

    // Convert integer part
    String result = intPart.toRadixString(toBase).toUpperCase();

    // Convert fractional part (if exists)
    if (fracPart > 0) {
      result += '.';
      double frac = fracPart;
      for (int i = 0; i < 10; i++) {
        frac *= toBase;
        final int digit = frac.floor();
        result += digit.toRadixString(toBase).toUpperCase();
        frac -= digit;
        if (frac == 0) {
          break;
        }
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Number Converter')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildInputField('Decimal', _decimalController),
              _buildConversionButtons(
                _decimalController,
                <int, TextEditingController>{2: _binaryController, 16: _hexController, 8: _octalController},
                10,
              ),
              const SizedBox(height: 16),

              _buildInputField('Binary', _binaryController),
              _buildConversionButtons(
                _binaryController,
                <int, TextEditingController>{10: _decimalController, 16: _hexController, 8: _octalController},
                2,
              ),
              const SizedBox(height: 16),

              _buildInputField('Hexadecimal', _hexController),
              _buildConversionButtons(
                _hexController,
                <int, TextEditingController>{10: _decimalController, 2: _binaryController, 8: _octalController},
                16,
              ),
              const SizedBox(height: 16),

              _buildInputField('Octal', _octalController),
              _buildConversionButtons(
                _octalController,
                <int, TextEditingController>{10: _decimalController, 2: _binaryController, 16: _hexController},
                8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => controller.clear(),
        ),
      ),
    );
  }

Widget _buildConversionButtons(
  TextEditingController fromController,
  Map<int, TextEditingController> toControllers,
  int fromBase,
) {
  return Wrap(
    spacing: 8.0, // Add spacing between buttons
    runSpacing: 8.0, // Add spacing between rows
    children: toControllers.entries.map((MapEntry<int, TextEditingController> entry) {
      final int toBase = entry.key;
      final TextEditingController toController = entry.value;
      return ElevatedButton(
        onPressed: () => _convert(fromController.text, fromBase, toBase, toController),
        child: Text('To ${_getBaseName(toBase)}'),
      );
    }).toList(),
  );
}


  String _getBaseName(int base) {
    switch (base) {
      case 2:
        return 'Binary';
      case 10:
        return 'Decimal';
      case 16:
        return 'Hexadecimal';
      case 8:
        return 'Octal';
      default:
        return '';
    }
  }
}
