import 'package:battleships/utils/http_service.dart';
import 'package:battleships/views/gameList.dart';
import 'package:flutter/material.dart';

class GameSetupPage extends StatefulWidget {
  String selectedAI = '';
  GameSetupPage({super.key, required this.selectedAI});
  @override
  _GameSetupPageState createState() => _GameSetupPageState();
}

class _GameSetupPageState extends State<GameSetupPage> {
  List<String> selectedPositions = [];
  HttpService httpService = HttpService();

  void togglePosition(String position) {
    setState(() {
      if (selectedPositions.contains(position)) {
        selectedPositions.remove(position);
      } else if (selectedPositions.length < 5) {
        selectedPositions.add(position);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Place Your Ships')),
      body: Column(
        children: [
          Expanded(
            child: buildGrid(),
          ),
          ElevatedButton(
            onPressed: selectedPositions.length == 5
                ? () => submitShips(widget.selectedAI)
                : null,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget buildGrid() {
    // Set the size of the grid
    double gridWidth = 700.0; // Width of the grid
    double gridHeight = 700.0; // Height of the grid

    return SizedBox(
      width: gridWidth,
      height: gridHeight,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 1, // Maintain the aspect ratio of the grid cells
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: 25, // 5x5 grid
        itemBuilder: (context, index) {
          String position = getPositionFromIndex(index);
          bool isSelected = selectedPositions.contains(position);

          return InkWell(
            onTap: () => togglePosition(position),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: isSelected ? Colors.blue : Colors.white,
              ),
              child: Center(child: Text(position)),
            ),
          );
        },
      ),
    );
  }

  String getPositionFromIndex(int index) {
    String row = String.fromCharCode('A'.codeUnitAt(0) + (index / 5).floor());
    String column = (1 + index % 5).toString();
    return '$row$column';
  }

  void submitShips(String selectedAI) async {
    Map<String, dynamic> response =
        await httpService.putGame(selectedPositions, widget.selectedAI);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GameListPage()),
    );
  }
}
