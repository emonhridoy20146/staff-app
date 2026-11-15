import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// PBKDF2-HMAC-SHA256 PIN hashing with a per-device salt. The PIN never
/// leaves the device (04-architecture §7).
class PinHasher {
  const PinHasher({this.iterations = 60000});
  final int iterations;

  String newSalt() {
    final r = Random.secure();
    return base64Encode(List<int>.generate(16, (_) => r.nextInt(256)));
  }

  String hash(String pin, String salt) => base64Encode(_pbkdf2(utf8.encode(pin), base64Decode(salt), iterations, 32));

  bool verify(String pin, String salt, String expected) {
    final a = utf8.encode(hash(pin, salt));
    final b = utf8.encode(expected);
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  static Uint8List _pbkdf2(List<int> password, List<int> salt, int iterations, int length) {
    final hmac = Hmac(sha256, password);
    final out = BytesBuilder();
    var block = 1;
    while (out.length < length) {
      final s = [...salt, (block >> 24) & 0xff, (block >> 16) & 0xff, (block >> 8) & 0xff, block & 0xff];
      var u = hmac.convert(s).bytes;
      final t = List<int>.from(u);
      for (var i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        for (var j = 0; j < t.length; j++) {
          t[j] ^= u[j];
        }
      }
      out.add(t);
      block++;
    }
    return Uint8List.fromList(out.takeBytes().sublist(0, length));
  }
}

/// Rejects trivially guessable PINs (1111, 1234, 0000 …).
bool isWeakPin(String pin) {
  if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) return true;
  if (pin.split('').toSet().length == 1) return true;
  const seqs = '0123456789';
  const rev = '9876543210';
  return seqs.contains(pin) || rev.contains(pin);
}
