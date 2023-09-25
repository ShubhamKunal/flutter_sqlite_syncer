import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import 'package:sqlite_crud_example/datebase_helper.dart';
import 'package:sqlite_crud_example/features/internet_connectivity/internet_bloc/internet_bloc.dart';
import 'package:sqlite_crud_example/features/internet_connectivity/internet_bloc/internet_state.dart';
import 'package:sqlite_crud_example/widgets/tag.dart';
import 'package:sqlite_crud_example/widgets/text_form_field.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SQLite CRUD Example',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final tempDB = TemporaryDB();
  final permanentDB = PermanentDB();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  InternetBloc internetBloc = InternetBloc();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InternetBloc, InternetState>(
      bloc: internetBloc,
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Contact book'),
          ),
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomTextFormField(
                      controller: nameController,
                      hintText: "Name",
                      obscureText: false,
                    ),
                    const SizedBox(height: 8),
                    CustomTextFormField(
                      controller: emailController,
                      hintText: "Email",
                      obscureText: false,
                    ),
                    const SizedBox(height: 8),
                    CustomTextFormField(
                      controller: ageController,
                      hintText: "Age",
                      obscureText: false,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            _insertContact();
                          },
                          child: const Text('Add'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _queryContacts();
                            });
                          },
                          child: const Text('Show Contacts'),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: (state is InternetGainedState)
                              ? const Text(
                                  "Internet",
                                  style: TextStyle(color: Colors.green),
                                )
                              : const Text(
                                  "No Internet",
                                  style: TextStyle(color: Colors.red),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: _queryContacts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final contacts =
                          snapshot.data!.$1 as List<Map<String, dynamic>>;
                      return ListView.builder(
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          final contact = contacts[index];
                          return ListTile(
                            title: Text(contact['name']),
                            subtitle: Text(contact['email']),
                            // trailing: IconButton(
                            //   icon: const Icon(Icons.delete),
                            //   onPressed: () {
                            //     setState(() {
                            //       _deleteContact(contact['id']);
                            //     });
                            //   },
                            // ),
                            trailing: Tag(
                                text: (snapshot.data!.$2 >= index)
                                    ? "Synced"
                                    : "Unsynced"),
                            onTap: () {
                              _editContact(contact);
                            },
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _insertContact() async {
    final name = nameController.text;
    final email = emailController.text;
    final age = int.tryParse(ageController.text) ?? 0;

    if (name.isNotEmpty && email.isNotEmpty) {
      final contact = {
        'name': name,
        'email': email,
        'age': age,
      };
      final id = await tempDB.insert(contact);
      developer.log('Inserted row id: $id');
      _clearControllers();
      setState(() {
        _queryContacts();
      });
    }
  }

  Future<(List<Map<String, dynamic>>, int)> _queryContacts() async {
    final tempContacts = await tempDB.queryAll();
    final permanentContacts = await permanentDB.queryAll();
    int lengthOfPermanentContacts = permanentContacts.length - 1;
    final allContacts = permanentContacts + tempContacts;
    developer.log(allContacts.toString());
    return (allContacts, lengthOfPermanentContacts);
  }

  void _editContact(Map<String, dynamic> contact) {
    nameController.text = contact['name'];
    emailController.text = contact['email'];
    ageController.text = contact['age'].toString();
  }

  void _deleteContact(int id) async {
    await tempDB.delete(id);
    //TODO: DELETE ACCORDINGLY
    setState(() {
      _clearControllers();
      _queryContacts();
    });
  }

  void _clearControllers() {
    nameController.clear();
    emailController.clear();
    ageController.clear();
  }
}
