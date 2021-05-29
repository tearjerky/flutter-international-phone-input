import 'dart:async';

import 'package:international_phone_input/src/validator_response.dart';

class InputValidator_Listener{
  StreamController<Validator_Response> streamController = new StreamController();
  Stream<Validator_Response> get stream => streamController.stream;
  Sink get sink => streamController.sink;
  void dispose(){
    streamController.close();
  }

}