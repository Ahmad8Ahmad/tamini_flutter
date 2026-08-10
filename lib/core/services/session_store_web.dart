import 'package:web/web.dart' as web;

bool getFlag(String key) => web.window.sessionStorage.getItem(key) != null;

void setFlag(String key) {
  web.window.sessionStorage.setItem(key, '1');
}
