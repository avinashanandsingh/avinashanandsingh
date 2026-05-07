import 'package:app/services/aura.dart';
import 'package:app/services/branding.dart';
import 'package:app/services/common.dart';
import 'package:app/services/course.dart';
import 'package:app/services/identity.dart';
import 'package:app/services/order.dart';
import 'package:app/services/page.dart';
import 'package:app/services/sacredvibe.dart';
import 'package:app/services/setting.dart';
import 'package:app/services/short.dart';
import 'package:app/services/storage.dart';
import 'package:app/services/user.dart';

class Service {
  static final aura = Aura();
  static final common = Common();
  static final identity = Identity();
  static final user = User();
  static final course = Course();
  static final branding = Branding();
  static final page = Page();
  static final short = Short();
  static final sacredvibe = Sacredvibe();
  static final setting = Setting();
  static final store = Storage();
  static final order = Order();
}
