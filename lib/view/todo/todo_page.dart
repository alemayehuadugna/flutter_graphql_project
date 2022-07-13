import 'package:flutter/material.dart';

import 'query.dart';




class TodoPage extends StatefulWidget {

  const TodoPage({@required this.identify});

  final String identify;

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {

  @override
  Widget build(BuildContext context) {

    return QueryPage(identify: widget.identify);
  
  }
}