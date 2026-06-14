import 'package:flutter/material.dart';
import 'package:working_time/screens/new_log.dart';

class Layout extends StatefulWidget {
  final NewLog edited;
  const Layout(this.edited,{super.key, });

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Edit your registry.')),
        //titleSpacing: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 0),
        child: widget.edited,
      ),
    );
  }
}