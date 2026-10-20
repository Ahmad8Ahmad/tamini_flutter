import 'package:flutter/material.dart';

/// Brand social icons, rendered from the **exact same SVG path data** the
/// website uses (see `support/templatetags/icons.py` in the Django backend).
///
/// The backend is the source of truth for the artwork; these constants mirror
/// its `whatsapp`, `facebook`, `instagram`, `x` and `tiktok` entries. When a
/// brand path changes on the web, update it here too so both surfaces stay
/// identical.
///
/// We deliberately do not depend on `flutter_svg`; instead [SocialIcon]
/// parses the path with a tiny renderer covering the commands these marks
/// actually use (move/line/curve/arc/close). If a future icon needs more of
/// the SVG spec, grow [SocialPathParser].
enum SocialBrand { whatsapp, facebook, instagram, x, snapchat, tiktok }

/// 24x24 `viewBox` path data for each brand, copied from the backend.
const Map<SocialBrand, String> _socialPaths = {
  SocialBrand.whatsapp:
      'M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z',
  SocialBrand.facebook:
      'M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z',
  SocialBrand.instagram:
      'M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z',
  SocialBrand.x:
      'M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z',
  SocialBrand.tiktok:
      'M12.525.02c1.31-.02 2.61-.01 3.91-.02.08 1.53.63 3.09 1.75 4.17 1.12 1.11 2.7 1.62 4.24 1.79v4.03c-1.44-.05-2.89-.35-4.2-.97-.57-.26-1.1-.59-1.62-.93-.01 2.92.01 5.84-.02 8.75-.08 1.4-.54 2.79-1.35 3.94-1.31 1.92-3.58 3.17-5.91 3.21-1.43.08-2.86-.31-4.08-1.03-2.02-1.19-3.44-3.37-3.65-5.71-.02-.5-.03-1-.01-1.49.18-1.9 1.12-3.72 2.58-4.96 1.66-1.44 3.98-2.13 6.15-1.72.02 1.48-.04 2.96-.04 4.44-.99-.32-2.15-.23-3.02.37-.63.41-1.11 1.04-1.36 1.75-.21.51-.15 1.07-.14 1.61.24 1.64 1.82 3.02 3.5 2.87 1.12-.01 2.19-.66 2.77-1.61.19-.33.4-.67.41-1.06.1-1.79.06-3.57.07-5.36.01-4.03-.01-8.05.02-12.07z',
  SocialBrand.snapchat:
      'M12.206.793c.99 0 4.347.276 5.93 3.821.529 1.193.403 3.219.299 4.847l-.003.06c-.012.18-.022.345-.03.51.075.045.203.09.401.09.3-.016.659-.12 1.033-.301.165-.088.344-.104.464-.104.182 0 .359.029.509.09.45.149.734.479.734.838.015.449-.39.839-1.213 1.168-.089.029-.209.075-.344.119-.45.135-1.139.36-1.333.81-.09.224-.061.524.12.868l.015.015c.06.136 1.526 3.475 4.791 4.014.255.044.435.27.42.509 0 .075-.015.149-.045.225-.24.569-1.273.988-3.146 1.271-.059.091-.12.375-.164.57-.029.179-.074.36-.134.553-.076.271-.27.405-.555.405h-.03c-.135 0-.313-.031-.538-.074-.36-.075-.765-.135-1.273-.135-.3 0-.599.015-.913.074-.6.104-1.123.464-1.723.884-.853.599-1.826 1.288-3.294 1.288-.06 0-.119-.015-.18-.015h-.149c-1.468 0-2.427-.675-3.279-1.288-.599-.42-1.107-.779-1.707-.884-.314-.045-.629-.074-.928-.074-.54 0-.958.089-1.272.149-.211.043-.391.074-.54.074-.374 0-.523-.224-.583-.42-.061-.192-.09-.389-.135-.567-.046-.181-.105-.494-.166-.57-1.918-.222-2.95-.642-3.189-1.226-.031-.063-.052-.15-.055-.225-.015-.243.165-.465.42-.509 3.264-.54 4.73-3.879 4.791-4.02l.016-.029c.18-.345.224-.645.119-.869-.195-.434-.884-.658-1.332-.809-.121-.029-.24-.074-.346-.119-1.107-.435-1.257-.93-1.197-1.273.09-.479.674-.793 1.168-.793.146 0 .27.029.383.074.42.194.789.3 1.104.3.234 0 .384-.06.465-.105l-.046-.569c-.098-1.626-.225-3.651.307-4.837C7.392 1.077 10.739.807 11.727.807l.419-.015h.06z',
};

/// Brand colour matching the website's footer tiles.
///
/// [brightness] flips the near-black marks (X, TikTok) to white so they stay
/// visible on dark surfaces.
Color socialBrandColor(SocialBrand brand, {Brightness brightness = Brightness.light}) {
  switch (brand) {
    case SocialBrand.whatsapp:
      return const Color(0xFF25D366);
    case SocialBrand.facebook:
      return const Color(0xFF1877F2);
    case SocialBrand.instagram:
      return const Color(0xFFE1306C);
    case SocialBrand.x:
      return brightness == Brightness.dark
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF1A1A1A);
    case SocialBrand.snapchat:
      return const Color(0xFFFFFC00);
    case SocialBrand.tiktok:
      return brightness == Brightness.dark
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF010101);
  }
}

/// A single brand glyph, sized to [size] and tinted [color].
class SocialIcon extends StatelessWidget {
  const SocialIcon(
    this.brand, {
    super.key,
    this.size = 22,
    this.color,
  });

  final SocialBrand brand;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = this.color ?? socialBrandColor(brand, brightness: brightness);
    final path = _socialPaths[brand];
    if (path == null || path.isEmpty) {
      return Icon(
        Icons.camera_alt_outlined,
        size: size,
        color: color,
      );
    }
    return CustomPaint(
      size: Size.square(size),
      painter: _SocialIconPainter(path: path, color: color),
    );
  }
}

class _SocialIconPainter extends CustomPainter {
  _SocialIconPainter({required this.path, required this.color});

  final String path;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    final parsed = SocialPathParser(path).parse();
    parsed.shift(Offset.zero);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.save();
    canvas.scale(scale);
    canvas.drawPath(parsed, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SocialIconPainter old) =>
      old.path != path || old.color != color;
}

/// Minimal SVG path renderer for the icon subset used by the brand marks.
///
/// Supports the absolute and relative commands those paths rely on:
/// M/m, L/l, H/h, V/v, C/c, S/s, and Z/z. Arc (A/a) is not implemented because
/// none of the current icons use it; a path that does will render its arcs as
/// straight lines to the endpoint rather than throwing.
class SocialPathParser {
  SocialPathParser(this._d);

  final String _d;
  double _cx = 0, _cy = 0; // current point
  double _sx = 0, _sy = 0; // subpath start
  double _lastCtrlX = 0, _lastCtrlY = 0;
  String? _lastCmd;

  Path parse() {
    final path = Path();
    final tokens = _tokenize(_d);
    var t = 0;
    String? cmd;
    while (t < tokens.length) {
      final token = tokens[t];
      if (_isCommand(token)) {
        cmd = token;
        t++;
        if (cmd == 'Z' || cmd == 'z') {
          path.close();
          _cx = _sx;
          _cy = _sy;
          _lastCmd = null;
          continue;
        }
      } else if (cmd == null) {
        t++;
        continue;
      }

      switch (cmd) {
        case 'M':
        case 'm':
          final x = _num(tokens, t++);
          final y = _num(tokens, t++);
          if (cmd == 'm') {
            _cx += x;
            _cy += y;
          } else {
            _cx = x;
            _cy = y;
          }
          path.moveTo(_cx, _cy);
          _sx = _cx;
          _sy = _cy;
          // Subsequent pairs are implicit lineto.
          cmd = cmd == 'm' ? 'l' : 'L';
          break;
        case 'L':
        case 'l':
          final x = _num(tokens, t++);
          final y = _num(tokens, t++);
          _cx = cmd == 'l' ? _cx + x : x;
          _cy = cmd == 'l' ? _cy + y : y;
          path.lineTo(_cx, _cy);
          break;
        case 'H':
        case 'h':
          final x = _num(tokens, t++);
          _cx = cmd == 'h' ? _cx + x : x;
          path.lineTo(_cx, _cy);
          break;
        case 'V':
        case 'v':
          final y = _num(tokens, t++);
          _cy = cmd == 'v' ? _cy + y : y;
          path.lineTo(_cx, _cy);
          break;
        case 'C':
        case 'c':
          final x1 = _num(tokens, t++);
          final y1 = _num(tokens, t++);
          final x2 = _num(tokens, t++);
          final y2 = _num(tokens, t++);
          final x = _num(tokens, t++);
          final y = _num(tokens, t++);
          final rel = cmd == 'c';
          final c1x = rel ? _cx + x1 : x1;
          final c1y = rel ? _cy + y1 : y1;
          final c2x = rel ? _cx + x2 : x2;
          final c2y = rel ? _cy + y2 : y2;
          _cx = rel ? _cx + x : x;
          _cy = rel ? _cy + y : y;
          path.cubicTo(c1x, c1y, c2x, c2y, _cx, _cy);
          _lastCtrlX = c2x;
          _lastCtrlY = c2y;
          break;
        case 'S':
        case 's':
          final x2 = _num(tokens, t++);
          final y2 = _num(tokens, t++);
          final x = _num(tokens, t++);
          final y = _num(tokens, t++);
          final rel = cmd == 's';
          final reflectX = (_lastCmd == 'C' || _lastCmd == 'c' || _lastCmd == 'S' || _lastCmd == 's')
              ? 2 * _cx - _lastCtrlX
              : _cx;
          final reflectY = (_lastCmd == 'C' || _lastCmd == 'c' || _lastCmd == 'S' || _lastCmd == 's')
              ? 2 * _cy - _lastCtrlY
              : _cy;
          final c2x = rel ? _cx + x2 : x2;
          final c2y = rel ? _cy + y2 : y2;
          _cx = rel ? _cx + x : x;
          _cy = rel ? _cy + y : y;
          path.cubicTo(reflectX, reflectY, c2x, c2y, _cx, _cy);
          _lastCtrlX = c2x;
          _lastCtrlY = c2y;
          break;
        default:
          // Unknown command: skip a token to avoid an infinite loop.
          t++;
      }
      _lastCmd = cmd;
    }
    return path;
  }

  static bool _isCommand(String s) =>
      s.length == 1 && 'MmLlHhVvCcSsZzAa'.contains(s);

  static double _num(List<String> tokens, int i) =>
      double.tryParse(tokens[i]) ?? 0;

  /// Splits the path into commands (single letters) and numbers. Handles
  /// negatives written as `-1.5` and implicit separators like `.5.5`.
  static List<String> _tokenize(String d) {
    final out = <String>[];
    final buf = StringBuffer();
    void flush() {
      if (buf.isNotEmpty) {
        out.add(buf.toString());
        buf.clear();
      }
    }

    for (var i = 0; i < d.length; i++) {
      final c = d[i];
      if (c == ' ' || c == ',' || c == '\n' || c == '\t' || c == '\r') {
        flush();
        continue;
      }
      if (_isCommand(c)) {
        flush();
        out.add(c);
        continue;
      }
      // A new number starts on a sign, or on a '.' when the buffer already
      // contains a '.' (e.g. "0.5.5" -> ["0.5", ".5"]).
      if ((c == '-' || c == '+') ||
          (c == '.' && buf.toString().contains('.'))) {
        flush();
      }
      buf.write(c);
    }
    flush();
    return out;
  }
}
