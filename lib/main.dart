import 'package:flutter/material.dart';

import 'models/transaction.dart';

import 'widgets/new_transaction.dart';
import 'widgets/transaction_list.dart';
import 'widgets/chart.dart';
import 'widgets/toggle_theme_button.dart';

void main() {
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitUp,
  // ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Quicksand',
        textTheme: ThemeData.light().textTheme.copyWith(
              displayMedium: const TextStyle(
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              labelLarge: const TextStyle(color: Colors.white),
            ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
            .copyWith(secondary: Colors.amber),
      ),
      darkTheme: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
        textTheme: ThemeData.dark().textTheme.copyWith(
              displayMedium: const TextStyle(
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              labelLarge: const TextStyle(
                color: Colors.white,
              ),
            ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.purple,
          brightness: Brightness.dark,
          cardColor: Colors.purple,
        ).copyWith(
          secondary: Colors.amber,
        ),
      ),
      themeMode: _themeMode,
      home: MyHomePage(setThemeMode: _setThemeMode),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.setThemeMode}) : super(key: key);

  final void Function(ThemeMode themeMode) setThemeMode;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _userTransactions = [
    Transaction(
      id: 't1',
      title: 'New Shoes',
      amount: 69.99,
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Transaction(
      id: 't2',
      title: 'Weekly Groceries',
      amount: 46.53,
      date: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Transaction(
      id: 't3',
      title: 'Cheese',
      amount: 22.99,
      date: DateTime.now(),
    ),
  ];
  bool _showChart = false;

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          const Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(
      String txTitle, double txAmount, DateTime chosenDate) {
    final newTx = Transaction(
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      id: DateTime.now().toString(),
    );

    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      // constraints:
      //   BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: NewTransaction(_addNewTransaction),
        );
      },
    );
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    final txListWidget = SizedBox(
      height: (mediaQuery.size.height -
              AppBar().preferredSize.height -
              mediaQuery.padding.top) *
          0.7,
      child: TransactionList(
          _userTransactions.reversed.toList(), _deleteTransaction),
    );

    var width = mediaQuery.size.width;
    if (width > 900) {
      width = 900;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Personal Expenses'),
            const SizedBox(width: 50),
            ToggleThemeButton(setThemeMode: widget.setThemeMode),
          ],
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _startAddNewTransaction(context),
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: width,
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (isLandscape)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('Show Chart'),
                      Switch(
                        activeColor: Theme.of(context).colorScheme.secondary,
                        value: _showChart,
                        onChanged: (val) {
                          setState(() {
                            _showChart = val;
                          });
                        },
                      ),
                    ],
                  ),
                if (!isLandscape)
                  SizedBox(
                    height: (mediaQuery.size.height -
                            AppBar().preferredSize.height -
                            mediaQuery.padding.top) *
                        0.3,
                    child: Chart(_recentTransactions),
                  ),
                if (!isLandscape) txListWidget,
                if (isLandscape)
                  _showChart
                      ? SizedBox(
                          height: (mediaQuery.size.height -
                                  AppBar().preferredSize.height -
                                  mediaQuery.padding.top) *
                              0.7,
                          child: Chart(_recentTransactions),
                        )
                      : txListWidget
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _startAddNewTransaction(context),
      ),
    );
  }
}
