import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Generated App',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196f3),
        accentColor: const Color(0xFF2196f3),
        canvasColor: const Color(0xFFfafafa),
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _despesasController = TextEditingController();
  final _despesasValorController = TextEditingController();
  final _proventosController = TextEditingController();
  final _proventosValorController = TextEditingController();

  final String _despesasJson = "despesas";
  final String _proventosJson = "proventos";

  List _despesasList = [];
  List _proventosList = [];

  String _saldo = '';

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override
  void initState() {
    super.initState();
    _getInfos();
  }

  void _getInfos() {
    double _somaDespesas = 0.0;
    double _somaProventos = 0.0;

    _readData(_despesasJson).then((data) {
      setState(() {
        _despesasList = json.decode(data);

        for (var i = 0; i < _despesasList.length; i++) {
          _somaDespesas =
              _somaDespesas + double.parse(_despesasList[i]["valor"]);
        }
        //print (_somaDespesas);
      });
      _readData(_proventosJson).then((data) {
        setState(() {
          _proventosList = json.decode(data);

          for (var i = 0; i < _proventosList.length; i++) {
            _somaProventos =
                _somaProventos + double.parse(_proventosList[i]["valor"]);
          }
          //print (_somaProventos);
          _saldo = (_somaProventos - _somaDespesas).toString();
          //print (_saldo );
        });
      });
    });
  }

  void _addDespesas() {
    setState(() {
      Map<String, dynamic> newDespesas = Map();
      newDespesas["title"] = _despesasController.text;
      _despesasController.text = "";
      newDespesas["valor"] = _despesasValorController.text;
      _despesasValorController.text = "";
      newDespesas["ok"] = false;
      _despesasList.add(newDespesas);

      _saveData(_despesasList, _despesasJson);
      _getInfos();
    });
  }

  void _addProventos() {
    setState(() {
      Map<String, dynamic> newProventos = Map();
      newProventos["title"] = _proventosController.text;
      _proventosController.text = "";
      newProventos["valor"] = _proventosValorController.text;
      _proventosValorController.text = "";
      _proventosList.add(newProventos);

      _saveData(_proventosList, _proventosJson);
      _getInfos();
    });
  }

  Future<File> _getFile(String auxJsonType) async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/${auxJsonType}.json");
  }

  Future<File> _saveData(List auxList, String auxJsonType) async {
    String data = json.encode(auxList);
    final file = await _getFile(auxJsonType);
    return file.writeAsString(data);
  }

  Future<String> _readData(String auxJsonType) async {
    try {
      final file = await _getFile(auxJsonType);
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  Widget buildItemDespesas(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text("${_despesasList[index]["title"]}"),
        subtitle: Text("R\$ ${_despesasList[index]["valor"]}"),
        value: _despesasList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(
            _despesasList[index]["ok"] ? Icons.check : Icons.payment,
            color: Colors.white,
          ),
          backgroundColor: Colors.redAccent,
        ),
        onChanged: (c) {
          setState(() {
            _despesasList[index]["ok"] = c;
            _saveData(_despesasList, _despesasJson);
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_despesasList[index]);
          _lastRemovedPos = index;
          _despesasList.removeAt(index);

          _saveData(_despesasList, _despesasJson);
          _getInfos();

          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _despesasList.insert(_lastRemovedPos, _lastRemoved);
                    _saveData(_despesasList, _despesasJson);
                    _getInfos();
                  });
                }),
            duration: Duration(seconds: 2),
          );

          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Widget buildItemProventos(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: ListTile(
        title: Text("${_proventosList[index]["title"]}"),
        subtitle: Text("R\$ ${_proventosList[index]["valor"]}"),
        leading: Icon(
          Icons.monetization_on,
          size: 45.0,
          color: Colors.green,
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_proventosList[index]);
          _lastRemovedPos = index;
          _proventosList.removeAt(index);

          _saveData(_proventosList, _proventosJson);
          _getInfos();

          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _proventosList.insert(_lastRemovedPos, _lastRemoved);
                    _saveData(_proventosList, _proventosJson);
                    _getInfos();
                  });
                }),
            duration: Duration(seconds: 2),
          );

          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  void _resetDespesas() {
    _readData(_despesasJson).then((data) {
      setState(() {
        _despesasList = json.decode(data);

        for (var i = 0; i < _despesasList.length; i++) {
          _despesasList[i]["ok"] = false;
        }

        _saveData(_despesasList, _despesasJson);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('CheckList Mensal'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetDespesas,
          )
        ],
      ),
      body: new Column(

          //mainAxisAlignment: MainAxisAlignment.start,
          //mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            new Container(
              height: 55.0,
              child:
                  // despesas
                  new Row(children: <Widget>[
                new Expanded(
                  child: new Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: new TextField(
                      controller: _despesasController,
                      style: new TextStyle(
                          fontSize: 20.0,
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.w400,
                          fontFamily: "Roboto"),
                      decoration: InputDecoration(
                        labelText: 'Despesas',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                new Expanded(
                  child: new Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: new TextField(
                      controller: _despesasValorController,
                      style: new TextStyle(
                          fontSize: 20.0,
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.w400,
                          fontFamily: "Roboto"),
                      decoration: InputDecoration(
                        labelText: 'Valor',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                new Container(
                    child: new Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: new RaisedButton(
                            key: null,
                            onPressed: _addDespesas,
                            color: const Color(0xFFe0e0e0),
                            child: new Text(
                              "Adicionar",
                              style: new TextStyle(
                                  fontSize: 12.0,
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Roboto"),
                            ))))
              ]),
            ),

            new Container(
              //height: 500.0,
              child: new Expanded(
                child: ListView.builder(

                    padding: EdgeInsets.only(top: 10.0),
                    itemCount: _despesasList.length,
                    itemBuilder: buildItemDespesas),
              ),
            ),

            new Divider(),

            new Container(
              height: 55.0,
              child:
                  // proventos
                  new Row(children: <Widget>[
                new Expanded(
                  child: new Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: new TextField(
                      controller: _proventosController,
                      style: new TextStyle(
                          fontSize: 20.0,
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.w400,
                          fontFamily: "Roboto"),
                      decoration: InputDecoration(
                        labelText: 'Proventos',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                new Expanded(
                  child: new Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: new TextField(
                      controller: _proventosValorController,
                      style: new TextStyle(
                          fontSize: 20.0,
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.w400,
                          fontFamily: "Roboto"),
                      decoration: InputDecoration(
                        labelText: 'Valor',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                new Container(
                    child: new Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: new RaisedButton(
                            key: null,
                            onPressed: _addProventos,
                            color: const Color(0xFFe0e0e0),
                            child: new Text(
                              "Adicionar",
                              style: new TextStyle(
                                  fontSize: 12.0,
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Roboto"),
                            ))))
              ]),
            ),

            new Expanded(
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: _proventosList.length,
                  itemBuilder: buildItemProventos),
            ),

            new Divider(),

            // saldo
            new Padding(
              padding: const EdgeInsets.all(24.0),
              child: new Text(
                "Saldo: R\$ ${_saldo}",
                style: new TextStyle(
                    fontSize: 20.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.bold,
                    fontFamily: "Roboto"),
              ),
            ),
          ]),
    );
  }
}
