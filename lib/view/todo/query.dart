import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:todo_app/view/todo/todoCard.dart';

import '../../utils/const.dart';

final TextEditingController controller = TextEditingController();
String deleteTaskMutation(result, index) {
  return """mutation {
              deleteTask(id: ${result.data["Tasks"][index]['id']}) {
                id
              }
          }""";
}

String toggleIsCompletedMutation(result, index) {
  return """ mutation {
    updateTask(id: ${result.data["Tasks"][index]['id']}, isCompleted: ${!result.data["Tasks"][index]['isCompleted']}) {
      isCompleted
    }
  }""";
}

String fetchQuery() {
  return """query {
               Tasks {
                  id
                  isCompleted
                  task
                  }} """;
}

void initMethod(context) {
  client = GraphQLProvider.of(context).value;
}

class QueryPage extends StatefulWidget {
   QueryPage({@required this.identify});

   String identify;
  @override
  State<QueryPage> createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => initMethod(context));
    return Query(
      options: QueryOptions(
        document: gql(fetchQuery()),
      ),
      builder: (
        QueryResult result, {
        refetch,
        FetchMore fetchMore,
      }) {
        if (result.hasException) {
          return Text(result.exception.toString());
        }
        if (widget.identify == 'add' && result.data != null) {
          refetch();
          widget.identify = 'normal';
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              if (result.isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              if (result.data != null)
                Center(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: dataLength(result),
                    itemBuilder: (BuildContext context, int index) {
                      return TodoCard(
                        key: UniqueKey(),
                        task: result.data['Tasks'][index]['task'],
                        isCompleted: result.data['Tasks'][index]['isCompleted'],
                        delete: () async {
                          await client.mutate(
                            MutationOptions(
                                document:
                                    gql(deleteTaskMutation(result, index)),
                                onCompleted: (dynamic resultData) async {
                                  refetch();
                                }),
                          );
                        },
                        toggleIsCompleted: () async {
                          await client.mutate(
                            MutationOptions(
                                document: gql(
                                    toggleIsCompletedMutation(result, index)),
                                onCompleted: (dynamic resultData) {
                                  refetch();
                                }),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  dataLength(dynamic result) {
    var length = 0;
    result.data['Tasks'].forEach((item) {
      length++;
    });
    return length;
  }
}


