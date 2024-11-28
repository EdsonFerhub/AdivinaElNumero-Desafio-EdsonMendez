import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(AdivinaNumero());

class AdivinaNumero extends StatelessWidget {
  const AdivinaNumero({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int numeroSecreto = 0;
  int rango = 10;
  int intentos = 5;
  int totalIntentos = 5;
  String nivelDificultad = "Fácil";
  List<int> mayorQue = [];
  List<int> menorQue = [];
  List<Map<String, dynamic>> historial = [];
  double valorDeSlider = 0.0;

  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    generarNumeroSecreto();
  }

  void generarNumeroSecreto() {
    numeroSecreto = Random().nextInt(rango) + 1;
  }

  void cambiarDificultad(double valor) {
    setState(() {
      valorDeSlider = valor;
      if (valorDeSlider == 0) {
        rango = 10;
        intentos = totalIntentos = 5;
        nivelDificultad = "Fácil";
      } else if (valorDeSlider == 1) {
        rango = 20;
        intentos = totalIntentos = 8;
        nivelDificultad = "Medio";
      } else if (valorDeSlider == 2) {
        rango = 100;
        intentos = totalIntentos = 15;
        nivelDificultad = "Difícil";
      } else if (valorDeSlider == 3) {
        rango = 1000;
        intentos = totalIntentos = 25;
        nivelDificultad = "Extremo";
      }
      reiniciarJuego();
    });
  }

  void validarAdivinanza(String entrada) {
    final int? numero = int.tryParse(entrada);
    if (numero == null || numero < 1 || numero > rango) {
      
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Dato Invalido. Ingresa un número entre 1 y $rango.")));
      return;
    }

    setState(() {
      if (numero == numeroSecreto) {
        historial.add({"numero": numero, "correcto": true});
        reiniciarJuego();
      } else if (numero > numeroSecreto) {
        menorQue.add(numero);
      } else {
        mayorQue.add(numero);
      }
      intentos--;
      if (intentos == 0) {
        historial.add({"numero": numeroSecreto, "correcto": false});
        reiniciarJuego();
      }
    });
  }

  void reiniciarJuego() {
    setState(() {
      mayorQue.clear();
      menorQue.clear();
      generarNumeroSecreto();
      intentos = totalIntentos;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adivina el Número"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Ingresa tu número",
                      border: OutlineInputBorder(),
                      hintText: "####"
                    ),
                    onSubmitted: (value) {
                      validarAdivinanza(value);
                      _inputController.clear();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  "Intentos:\n $intentos",
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Columna("Mayor que", mayorQue),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Columna("Menor que", menorQue),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ColumnaHistorial("Historial", historial),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Dificultad: $nivelDificultad",
              style: const TextStyle(fontSize: 18),
            ),
            Slider(
              value: valorDeSlider,
              min: 0,
              max: 3,
              divisions: 3,
              onChanged: cambiarDificultad,
            ),
          ],
        ),
      ),
    );
  }

  Widget Columna(String title, List<int> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Text("${items[index]}");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ColumnaHistorial(
      String title, List<Map<String, dynamic>> historial) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: historial.length,
                itemBuilder: (context, index) {
                  final item = historial[index];
                  return Text(
                    "${item['numero']}",
                    style: TextStyle(
                      color: item['correcto'] ? Colors.green : Colors.red,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
