import 'package:flutter/foundation.dart';

class ProfileRefreshProvider extends ChangeNotifier {
  int version = 0;
  void refresh() {
    version++;
    notifyListeners();
  }
}