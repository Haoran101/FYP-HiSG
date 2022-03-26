import 'package:flutter/material.dart';

class MoneyConverter extends StatefulWidget {
  const MoneyConverter({ Key? key }) : super(key: key);

  @override
  State<MoneyConverter> createState() => _MoneyConverterState();
}

class _MoneyConverterState extends State<MoneyConverter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Currency Converter"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        //TODO: MONEY CONVERTER
      ),
    );
  }
}