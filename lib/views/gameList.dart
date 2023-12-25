import 'package:battleships/views/gamePage.dart';
import 'package:battleships/views/gameview.dart';
import 'package:battleships/views/login.dart';
import 'package:flutter/material.dart';
import 'package:battleships/utils/http_service.dart';

// Other imports
enum AIOption { perfect, random, oneShot }

class GameListPage extends StatefulWidget {
  const GameListPage({super.key});

  @override
  _GameListPageState createState() => _GameListPageState();
}

class _GameListPageState extends State<GameListPage> {
  HttpService httpService = HttpService();

  bool _showCompletedGames = false;
  List<Map<String, dynamic>> games = [];
  List<Map<String, dynamic>> allGames = [];

  @override
  void initState() {
    super.initState();
    _fetchGames();
  }

  void _fetchGames() async {
    try {
      var fetchedGames = await httpService.getAllGames();
      setState(() {
        allGames = fetchedGames;
        games = allGames; // Initially display all games
        _showCompletedGames = false;
      });
    } catch (e) {
      // Handle exceptions, e.g., show an error message
    }
  }

  void _toggleShowCompleted() {
    setState(() {
      _showCompletedGames = !_showCompletedGames;

      if (_showCompletedGames) {
        // Filter to show only completed games
        games = allGames
            .where((game) => game['status'] == 1 || game['status'] == 2)
            .toList();
      } else {
        // Show all games
        games = allGames;
      }
    });
  }

  void _startGame({bool withAI = false}) async {
    String selection = '';
    AIOption? selectedAI = AIOption.random;
    if (withAI == true) {
      selectedAI = await showDialog<AIOption>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Choose AI Type'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, AIOption.random);
                },
                child: const Text('Random AI'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, AIOption.perfect);
                },
                child: const Text('Perfect AI'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, AIOption.oneShot);
                },
                child: const Text('One Shot AI'),
              ),
            ],
          );
        },
      );
      if (selectedAI == AIOption.random) {
        selection = 'random';
      } else if (selectedAI == AIOption.perfect) {
        selection = 'perfect';
      } else if (selectedAI == AIOption.oneShot) {
        selection = 'oneship';
      }
    }
    // Logic for starting a game with a human opponent
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => GameSetupPage(selectedAI: selection)),
    );
  }

  String _determineTurnStatus(Map<String, dynamic> game) {
    if (game["status"] == 3) {
      // If the game is actively being played
      return game["turn"] == game["position"] ? "Your Turn" : "Opponent's Turn";
    }
    return _getStatusText(game["status"]);
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Matchmaking';
      case 1:
        return 'Player 1 Won';
      case 2:
        return 'Player 2 Won';
      case 3:
        return 'Game Active';
      default:
        return 'Unknown Status';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Games'),
        // other AppBar properties...
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchGames, // Call the fetch games method
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.brown),
              child: Text('Game Options',
                  style: TextStyle(
                    color: Colors.white,
                  )),
            ),
            ListTile(
              title: const Text('Play with Human'),
              onTap: () => _startGame(withAI: false),
            ),
            ListTile(
              title: const Text('Play with AI'),
              onTap: () => _startGame(withAI: true),
            ),
            SwitchListTile(
              title: const Text('View Completed Games'),
              value: _showCompletedGames,
              onChanged: (bool value) {
                _toggleShowCompleted();
              },
            ),
            ListTile(
              title: const Text('Sign Out'),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          String status = '';
          status = _determineTurnStatus(game);

          return Dismissible(
            key: Key(game['id'].toString()),
            onDismissed: (direction) {},
            background: Container(color: Colors.red),
            child: ListTile(
              tileColor: Colors.deepOrange[100],
              title: Text(
                  '#${game['id']}    ${game['player1']} VS ${game['player2']}            $status'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => GameViewPage(gameId: game['id']),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () =>
            _startGame(withAI: false), // Start a game with a human opponent
      ),
    );
  }
}
