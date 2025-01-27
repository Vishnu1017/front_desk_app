import 'package:flutter/foundation.dart';
import 'package:front_desk_app/visitor.dart';
import 'package:hive/hive.dart';

class VisitorManager extends ChangeNotifier {
  final Box<Visitor> _box = Hive.box<Visitor>('visitorBox');

  VisitorManager(Box<Visitor> box);

  List<Visitor> get visitors => _box.values.toList();

  void checkIn(Visitor visitor) {
    _box.add(visitor);
    notifyListeners();
  }

  void checkOut(Visitor visitor) {
    visitor.checkOutTime = DateTime.now();
    visitor.save();
    notifyListeners();
  }
}
