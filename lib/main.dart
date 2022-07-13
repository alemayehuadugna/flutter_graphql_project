

// String get host {
// // https://github.com/flutter/flutter/issues/36126#issuecomment-596215587
//   if (UniversalPlatform.isAndroid) {
//     return '10.0.2.2';
//   } else {
//     return '127.0.0.1';
//   }
// }


import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:todo_app/utils/const.dart';
import 'package:todo_app/view/client/graphql_view.dart';
import 'package:todo_app/view/todo/query.dart';
import 'package:todo_app/view/todo/todo_page.dart';

String addTaskMutation(task) {
  return """mutation {
              addTask(isCompleted: false, task: "$task") {
                id
              }
            }""";
}

final graphqlEndpoint = 'http://localhost:3000/graphql';

void initMethod(context) {
  client = GraphQLProvider.of(context).value;
}
var identify = 'normal';

void main() async {
  await initHiveForFlutter();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClientProvider(
      uri: graphqlEndpoint,
      child: MaterialApp(
        title: 'Graphql Todo List',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Graphql Todo List'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => initMethod(context));
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          heroTag: "Tag",
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context1) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                  title: Text("Add task"),
                  content: Form(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(
                          autofocus: true,
                          controller: controller,
                          decoration: InputDecoration(labelText: "Task"),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                await client.mutate(
                                  MutationOptions(
                                      document:
                                          gql(addTaskMutation(controller.text)),
                                      onCompleted: (dynamic resultData) async {
                                        Navigator.pop(context);
                                        controller.text = '';
                                        setState(() {
                                          identify = 'add';
                                          QueryPage(identify: identify);
                                        });
                                      }),
                                );
                              },
                              child: Text(
                                "Add",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: Icon(Icons.add),
        ),
        appBar: AppBar(
          centerTitle: true,
          title: Text("To-Do"),
        ),
        body: TodoPage(identify: identify));

  }
}
