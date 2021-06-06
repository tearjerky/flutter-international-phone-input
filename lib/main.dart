import 'package:flutter/material.dart';
import 'package:international_phone_input/international_phone_input.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class ValueA {
  String code, dialCode, number, internationalize;

  ValueA({this.code, this.dialCode, this.number, this.internationalize});
}

class _MyHomePageState extends State<MyHomePage> {
  String phoneNumber;
  String phoneIsoCode;
  bool visible = false;
  String confirmedNumber = '';

  final ValueNotifier<ValueA> _counter = ValueNotifier<ValueA>(
      ValueA(code: 'US', dialCode: '+1', number: '', internationalize: ''));

  void onPhoneNumberChange(
      String number, String internationalizedPhoneNumber, String isoCode,String dial) {
    print(number);
    setState(() {
      phoneNumber = number;
      phoneIsoCode = isoCode;
    });
  }
  TextEditingController controller = new TextEditingController();

  onValidPhoneNumber(
      String number, String internationalizedPhoneNumber, String isoCode) {
    setState(() {
      visible = true;
      confirmedNumber = internationalizedPhoneNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('International Phone Input Example'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Spacer(flex: 1),
            SizedBox(height: 20),
           InternationalPhoneInputController(
             initialSelection: "+1",
              decoration:
              InputDecoration.collapsed(hintText: '(123) 123-1234'),
              onPhoneNumberChange: onPhoneNumberChange,
              enabledCountries: ['+233', '+1'],
               removeDuplicates: ["CA"],
              showCountryCodes: true,
              showCountryFlags: true,

             controller: controller,
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.black,
            ),
            SizedBox(height: 50),
            InternationalPhoneInputText(
              onValidPhoneNumber: onValidPhoneNumber,
            ),
            Visibility(
              child: Text(confirmedNumber),
              visible: visible,
            ),
            Spacer(flex: 2)
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
