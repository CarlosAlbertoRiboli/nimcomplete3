import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(NimGameApp());
}

class NimGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jogo NIM',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NimGameScreen(),
    );
  }
}

class NimGameScreen extends StatefulWidget {
  @override
  _NimGameScreenState createState() => _NimGameScreenState();
}

class _NimGameScreenState extends State<NimGameScreen> {
  int sticks = 7; // Número inicial de palitos
  String winner = '';
  String playerName = 'Jogador 1'; // Nome do jogador para o placar
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    fetchScores(); // Buscar o placar ao iniciar o jogo
  }

  Future<void> fetchScores() async {
    try {
      final url = Uri.parse('https://carlinhoslouco.pythonanywhere.com/scores');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final scores = jsonDecode(response.body);
        print('Placar atual: $scores');
      } else {
        print('Erro ao buscar o placar: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao conectar com a API: $e');
    }
  }

  Future<void> postWin(String playerName) async {
    try {
      final url = Uri.parse('https://carlinhoslouco.pythonanywhere.com/scores');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'player_name': playerName}),
      );

      if (response.statusCode == 200) {
        print('Vitória registrada com sucesso!');
      } else {
        print('Erro ao registrar vitória: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao conectar com a API: $e');
    }
  }

  void removeSticks(int count) {
    if (isGameOver) return;

    setState(() {
      sticks -= count;
      if (sticks <= 0) {
        isGameOver = true;
        winner = playerName;
        postWin(playerName); // Enviar a vitória para o servidor
      } else {
        // Simulação da jogada do computador
        int computerMove = (sticks % 4 == 0) ? 1 : sticks % 4;
        sticks -= computerMove;
        if (sticks <= 0) {
          isGameOver = true;
          winner = 'Computador';
        }
      }
    });
  }

  void resetGame() {
    setState(() {
      sticks = 7; // Resetar para 7 palitos
      isGameOver = false;
      winner = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jogo NIM'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Palitos restantes: $sticks',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            if (!isGameOver)
              Wrap(
                spacing: 10,
                children: List.generate(
                  3,
                  (index) => ElevatedButton(
                    onPressed: () => removeSticks(index + 1),
                    child: Text('Remover ${index + 1}'),
                  ),
                ),
              ),
            if (isGameOver)
              Column(
                children: [
                  Text(
                    'Fim de jogo! Vencedor: $winner',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: resetGame,
                    child: Text('Reiniciar'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
