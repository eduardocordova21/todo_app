import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/models/item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static var items = <Item>[];

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var textController = TextEditingController();

  void addItem() {
    if (textController.text.isEmpty) return;

    setState(() {
      HomePage.items.add(Item(textController.text, false));
      textController.clear();
      saveItem();
    });
  }

  void removeItem(int index) {
    setState(() {
      HomePage.items.removeAt(index);
    });
    saveItem();
  }

  Future loadItems() async {
    var preferences = await SharedPreferences.getInstance();
    var data = preferences.getString("data");

    if (data != null) {
      Iterable decoded = jsonDecode(data);

      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();

      setState(() {
        HomePage.items = result;
      });
    }
  }

  saveItem() async {
    var preferences = await SharedPreferences.getInstance();
    await preferences.setString("data", jsonEncode(HomePage.items));
  }

  _HomePageState() {
    loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: textController,
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
          decoration: const InputDecoration(
            labelText: "Nova tarefa",
            labelStyle: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: ListView.builder(
          itemCount: HomePage.items.length,
          itemBuilder: (BuildContext context, int index) {
            final item = HomePage.items[index];

            return Dismissible(
              key: Key(item.title),
              background: Container(
                color: Colors.red.withOpacity(0.2),
                child: const Text("Excluir"),
              ),
              onDismissed: (direction) {
                removeItem(index);
              },
              child: CheckboxListTile(
                title: Text(item.title),
                value: item.done,
                onChanged: (value) {
                  setState(() {
                    item.done = value!;
                    saveItem();
                  });
                },
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: addItem,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
