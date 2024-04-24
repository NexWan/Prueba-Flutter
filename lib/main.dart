import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purpleAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}


/*
* From what I could understand this shit works as a Singleton in some apps
* (Basically it handles the global variables for your app I thin)
*/
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  // ↓ Add the code below.
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

/*I think this is kinda like the main container, like a Scene in javafx or something like that
* Apparently making it a "StatefulWidget" makes it so you can have some features of the state
* properties in your class?*/
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  /*This is what I mean, apparently with a Stateless widget you can't modify the
  * states of your app, but you can get access to them declaring it like an object*/
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoriteWords();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    /*I'm not a huge fan of this shit, fortunately android studio makes it look pretty.
    * Even tho it looks like shit there we have some kind of "Widget state" where you can control
    * which view is being shown through the NavigationRail type, it's pretty cool*/
    return Builder(
      builder: (context) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: false,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

/*This is like a component in angular, here you do some shit with it's own view
* It's literally a view object in a MVC*/
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/*This is just so you don't have huge stuff and you can have like your own component
* of some element (like a text in this case)
* */
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onBackground,
    );
    return Card(
      color: theme.colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(pair.asLowerCase, style: style),
      ),
    );
  }
}

/*Another class. Another view
* This is in order to handle the favorite words of the state class, it's cool and shi*/
class FavoriteWords extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, //This is to center your column to the vertical (idk if it affects horizontal too)
        children: [
          const MsgBlock(),
          SizedBox(height: 10,), //This is some kind of margin on y (and I guess you can do it on x too).
          for(var msg in favorites)
            Text(msg.asLowerCase)
        ],
      ),
    );
  }

}

/*The same, this is just to style a bit*/
class MsgBlock extends StatelessWidget {
  const MsgBlock({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.background,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text('Messages:', style: theme.textTheme.displayMedium,),
        )
    );
  }
}
