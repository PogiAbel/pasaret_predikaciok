import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

List<String> getNames() {
  List<String> names = [
    'Földvári Tibor',
    'Szepesy László',
    'Horváth Géza',
    'Czakó Zoltán',
    'Szepessy László',
    'Pétery-Schmidt Zsolt',
    'Cseri Kálmán',
    'Takaró János',
    'Somogyi László',
    'Cs. Nagy János',
    'Sípos Ete Álmos',
    'Varga Róbert',
    'Földvári TIbor',
    'Csere Mátyás',
    'Csákány Tamás',
    'Joó Sándor (Cs.K.)'
  ];
  return names;
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  if (!File('$path/history.json').existsSync()) {
    File('$path/history.json').createSync();
  }
  return File('$path/history.json');
}

void addHistory(Map<String, dynamic> record) async {
  Map<String, dynamic> data = Map.from(record);

  // data.remove('content');
  File file = await _localFile;
  String content = await file.readAsString();
  List<dynamic> history = [];
  if (content != '') history = json.decode(content);
  for (var element in history) {
    if (element['name'] == data['name'] &&
        element['date'] == data['date'] &&
        element['title'] == data['title']) {
      history.remove(element);
      break;
    }
  }
  history.add(data);
  await file.writeAsString(json.encode(history));
}

Future<List<dynamic>> getHistory() async {
  File file = await _localFile;
  String content = await file.readAsString();
  List<dynamic> history = [];
  if (content != '') history = json.decode(content);
  final reversed = history.reversed;
  return reversed.toList();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pasaréti Ref. Gyülekezeti prédikációk',
      theme: ThemeData(
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Pasaréti Ref. Gyülekezeti prédikációk'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int counter = 0;
  List<dynamic> data = [
    {'name': 'no'}
  ];
  List<bool> checked = List.filled(16, true);
  List<String> names = getNames();

  Future<List<dynamic>> loadJson(List<bool> filter) async {
    String content =
        await DefaultAssetBundle.of(context).loadString("assets/data.json");
    List<dynamic> data = json.decode(content);
    List<String> names = getNames();
    List<dynamic> filtered = [];
    List<String> filteredNames = [];
    for (int i = 0; i < filter.length; i++) {
      if (filter[i]) {
        filteredNames.add(names[i]);
      }
    }
    for (int i = 0; i < data.length; i++) {
      if (filteredNames.contains(data[i]['name'])) {
        filtered.add(data[i]);
      }
    }

    return filtered;
  }

  _MyHomePageState() {
    loadJson(checked).then((val) => setState(() {
          data = val;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem(
                  child: TextButton(
                onPressed: () => setState(() {}),
                child: Row(
                  children: [
                    const Text(
                      'Alkalmaz',
                      style: TextStyle(fontSize: 20),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          checked = List.filled(15, false);
                        });
                      },
                      child: const Text(
                        'Egyik se',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          checked = List.filled(15, true);
                        });
                      },
                      child: const Text(
                        'Összes',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              )),
              for (int i = 0; i < names.length; i++)
                PopupMenuItem(
                  onTap: () => setState(() {}),
                  child: Row(
                    children: [
                      Text(names[i]),
                      StatefulBuilder(
                        builder: (context, setState) => Checkbox(
                            value: checked[i],
                            onChanged: (value) {
                              setState(() {
                                checked[i] = value!;
                              });
                            }),
                      ),
                    ],
                  ),
                ),
            ];
          })
        ],
      ),
      drawer: const NavigationDrawerWidget(),
      body: FutureBuilder(
        future: loadJson(checked),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    setState(() {
                      addHistory(snapshot.data![index]);
                    });
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ReadPreach(snapshot.data![index]),
                      ),
                    );
                  },
                  title: //Row(
                      //   children: [
                      //     Text(
                      //       snapshot.data![index]['date'],
                      //       style: TextStyle(color: Colors.lightBlue),
                      //     ),
                      //     Text(snapshot.data![index]['name']),
                      //     Text(snapshot.data![index]['title']),
                      //   ],
                      // )

                      Text(
                    snapshot.data![index]['date'] +
                        ' ' +
                        snapshot.data![index]['name'] +
                        ' ' +
                        snapshot.data![index]['title'],
                  ),
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class ReadPreach extends StatefulWidget {
  final Map<String, dynamic> data;
  const ReadPreach(this.data, {super.key});

  @override
  State<ReadPreach> createState() => _ReadPreachState();
}

class _ReadPreachState extends State<ReadPreach> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data['date'] +
            ' ' +
            widget.data['name'] +
            ' ' +
            widget.data['title']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(widget.data['content'],
              style: const TextStyle(fontSize: 20, height: 1.5)),
        ),
      ),
    );
  }
}

class NavigationDrawerWidget extends StatelessWidget {
  const NavigationDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder(
        future: getHistory(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: Column(children: [
                const SizedBox(
                  height: 60,
                ),
                const Text(
                  'Előzmények',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
                const SizedBox(
                  height: 20,
                ),
                for (var x in snapshot.data!)
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ReadPreach(x),
                        ),
                      );
                    },
                    title: Text(x['date'] + ' ' + x['name'] + ' ' + x['title']),
                  ),
              ]),
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
