// @dart=2.9

import 'package:get/get_navigation/src/root/internacionalization.dart';

import 'Languages/ar.dart';
import 'Languages/en.dart';

class translation extends Translations{
  //for translation
  @override
  // TODO: implement keys
  Map<String, Map<String, String>> get keys => {
    'en':  en,
    'ar' : ar
  };

}