
import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/CurrencyConverter/fetchrates.dart';

class SgdToAny extends StatefulWidget {
  final rates;
  final Map currencies;
  const SgdToAny({Key? key, @required this.rates, required this.currencies})
      : super(key: key);

  @override
  _SgdToAnyState createState() => _SgdToAnyState();
}

class _SgdToAnyState extends State<SgdToAny> {
  TextEditingController sgdController = TextEditingController();
  String dropdownValue = 'USD';
  String answer = '';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
          // width: w / 3,
          padding: EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SGD to Any Currency',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                SizedBox(height: 20),

                //TextFields for Entering SGD
                TextFormField(
                  key: ValueKey('sgd'),
                  controller: sgdController,
                  decoration: InputDecoration(hintText: 'Enter amount of Singapore Dollar (SGD)'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    //Future Builder for getting all currencies for dropdown list
                    Expanded(
                      child: DropdownButton<String>(
                        value: dropdownValue,
                        icon: const Icon(Icons.arrow_drop_down_rounded),
                        iconSize: 24,
                        elevation: 16,
                        isExpanded: true,
                        underline: Container(
                          height: 2,
                          color: Colors.grey.shade400,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                        },
                        items: widget.currencies.entries
                            .toSet()
                            .toList()
                            .map<DropdownMenuItem<String>>((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value + " (" + entry.key + ")"),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),

                    //Convert Button
                    Container(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            answer = sgdController.text +
                                ' SGD = ' +
                                convertany(widget.rates, sgdController.text,
                            "SGD", dropdownValue) +
                                ' ' +
                                dropdownValue;
                          });
                        },
                        child: Text('Convert'),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).primaryColor)),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),

                //Final Output
                SizedBox(height: 10),
                Container(child: Text(answer))
              ])),
    );
  }
}
