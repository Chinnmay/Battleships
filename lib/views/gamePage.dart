import 'package:battleships/model/gameData.dart';
import 'package:battleships/utils/http_service.dart';
import 'package:battleships/views/gameList.dart';
import 'package:flutter/material.dart';

class GameViewPage extends StatefulWidget {
  final int gameId;

  const GameViewPage({super.key, required this.gameId});

  @override
  _GameViewPageState createState() => _GameViewPageState();
}

class _GameViewPageState extends State<GameViewPage> {
  GameData? gameData;
  HttpService httpService = HttpService();
  List<String> selectedPositions = [];

  @override
  void initState() {
    super.initState();
    fetchGameData();
  }

  void checkGameOver() {
    if (gameData!.ships.isEmpty || gameData!.sunk.length == 5) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Game Over'),
            content: Text(
                'All ships of ${gameData!.ships.isEmpty ? gameData!.player1 : gameData!.player2} are sunk!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog first
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const GameListPage()),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void fetchGameData() async {
    print("in fetch game data");
    Map<String, dynamic> fetchedData =
        await httpService.fetchGameDataFromApi(widget.gameId);
    setState(() {
      gameData = GameData.fromJson(fetchedData);
      checkGameOver();
    });
  }

  void playShot(String position) {
    setState(() {
      selectedPositions.add(position);
    });
  }

  void submitShots() async {
    List<bool> response =
        await httpService.playShot(widget.gameId, selectedPositions);

    // Update the gameData based on the response
    setState(() {
      if (response[0] == true) {
        gameData!.sunk.add(selectedPositions[selectedPositions.length - 1]);
        fetchGameData();
      } else {
        gameData!.shots.add(selectedPositions[selectedPositions.length - 1]);
        fetchGameData();
      }
      checkGameOver();

      selectedPositions.clear(); // Clear the selected positions
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Game ID: ${widget.gameId}')),
      body: gameData == null ? const CircularProgressIndicator() : buildGameGrid(),
      floatingActionButton: selectedPositions.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: submitShots,
              child: const Icon(Icons.check),
            ),
    );
  }

  Widget getGridIcon(String position) {
    List<Widget> icons = [];

    if (gameData!.sunk.contains(position)) {
      icons.add(
          const Icon(Icons.local_fire_department_outlined, color: Colors.red));
    }

    if (gameData!.ships.contains(position)) {
      icons.add(const Icon(Icons.directions_boat_filled_outlined,
          color: Colors.black));
    }

    if (gameData!.shots.contains(position)) {
      icons.add(Icon(Icons.cancel, color: Colors.brown[600]));
    }

    if (gameData!.wrecks.contains(position)) {
      icons.add(Icon(Icons.bubble_chart_outlined, color: Colors.blue[800]));
    }

    if (icons.isEmpty) {
      return const SizedBox();
    }

    if (icons.length == 1) {
      return icons.first;
    }

    return icons.isEmpty
        ? const SizedBox()
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: icons,
          );
  }

  Widget buildGameGrid() {
    return SizedBox(
      width: 700,
      height: 700,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 1,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: 25, // 5x5 grid
        itemBuilder: (context, index) {
          String position = getPositionFromIndex(index);
          bool isSelected = selectedPositions.contains(position);
          return GestureDetector(
            onTap: isSelected ? null : () => playShot(position),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: Center(child: getGridIcon(position)),
            ),
          );
        },
      ),
    );
  }

  String getPositionFromIndex(int index) {
    int row = index ~/ 5;
    int col = index % 5;
    String rowLabel =
        String.fromCharCode('A'.codeUnitAt(0) + row); // Converts 0-4 to A-E
    String colLabel = (col + 1).toString(); // Converts 0-4 to 1-5
    return '$rowLabel$colLabel';
  }

  Color getCellColor(String position) {
    if (gameData!.ships.contains(position)) {
      return const Color.fromRGBO(76, 175, 80, 1); // Color for ship position
    } else if (gameData!.wrecks.contains(position)) {
      return Colors.red; // Color for wreck position
    } else if (gameData!.shots.contains(position)) {
      return Colors.yellow; // Color for shot position
    } else if (gameData!.sunk.contains(position)) {
      return Colors.blue; // Color for sunk position
    }
    return Colors.white; // Default color for empty cell
  }
}
