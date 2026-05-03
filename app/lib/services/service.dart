import 'package:app/services/branding.dart';
import 'package:app/services/course.dart';
import 'package:app/services/identity.dart';
import 'package:app/services/page.dart';
import 'package:app/services/sacredvibe.dart';
import 'package:app/services/setting.dart';
import 'package:app/services/short.dart';
import 'package:app/services/user.dart';

class Service {
  static final identity = Identity();
  static final user = User();
  static final course = Course();
  static final branding = Branding();
  static final page = Page();
  static final short = Short();
  static final sacredvibe = Sacredvibe();
  static final setting = Setting();
}
