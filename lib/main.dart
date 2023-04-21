import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final txt = TextEditingController();
  final formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TODO'),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('tododata').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No Todo.'),
              );
            }
            return ListView(
              children: snapshot.data!.docs.map((datas) {
                return Card(
                  child: ListTile(
                    title: Text(datas['data'].toString()),
                    subtitle: Text(datas['date'].toString()),
                    trailing: IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Delete Todo'),
                                content: Text(datas['data'].toString()),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('tododata')
                                          .where('data',
                                              isEqualTo: datas['data'])
                                          .get()
                                          .then((value) => value
                                              .docs.first.reference
                                              .delete());
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Todo deleted successfully...'),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Delete'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cencel'),
                                  ),
                                ],
                              );
                            });
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Add Todo'),
                  content: Form(
                    key: formkey,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Enter',
                      ),
                      controller: txt,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Enter the field';
                        }
                        return null;
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        if (formkey.currentState!.validate()) {
                          FirebaseFirestore.instance
                              .collection('tododata')
                              .add({
                            'data': txt.text,
                            'date': DateTime.now().toString().substring(0, 19)
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Todo added successfully...'),
                            ),
                          );
                          txt.clear();
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add'),
                    ),
                    TextButton(
                      onPressed: () {
                        txt.clear();
                        Navigator.pop(context);
                      },
                      child: const Text('Cencel'),
                    ),
                  ],
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
