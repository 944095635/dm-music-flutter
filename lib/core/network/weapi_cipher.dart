import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// 网易云 weapi 参数加密。
///
/// weapi 要求把明文参数转成 `params` / `encSecKey` 两个表单字段：
/// params 是参数 JSON 经两次 AES-CBC（固定密钥 + 随机密钥）后的 base64，
/// encSecKey 是随机密钥反转字节后经 RSA NO_PADDING 加密的十六进制串。
/// 随机密钥每次不同，故同一参数每次加密结果都不同。
///
/// 只用 pointycastle 实现，不依赖已归档的 encrypt 包。公钥是协议固定常量，
/// 直接展开为 modulus / exponent，省去 PEM 解析。
abstract final class WeapiCipher {
  static const String _iv = '0102030405060708';
  static const String _presetKey = '0CoJUm6Qyw8W8jud';
  static const String _base62 =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  // 网易云 web 端固定 1024 位 RSA 公钥（指数 65537），由 PEM 展开而来。
  static final BigInt _modulus = BigInt.parse(
    '157794750267131502212476817800345498121872783333389747424011531025366277535262539913701806290766479189477533597854989606803194253978660329941980786072432806427833685472618792592200595694346872951301770580765135349259590167490536138082469680638514416594216629258349130257685001248172188325316586707301643237607',
  );
  static const int _exponent = 65537;

  /// 把明文参数加密成 weapi 请求所需的表单字段。
  static Map<String, String> encrypt(Map<String, dynamic> parameters) {
    final text = jsonEncode(parameters);
    final secretKey = _randomSecretKey();
    // 第一次用固定密钥，第二次用随机密钥；两次都复用同一个 IV。
    final first = _aesCbcBase64(text, _presetKey);
    final params = _aesCbcBase64(first, secretKey);
    final encSecKey = _rsaNoPadding(secretKey);
    return {'params': params, 'encSecKey': encSecKey};
  }

  /// 生成 16 位 [0-9a-zA-Z] 随机密钥。
  static String _randomSecretKey() {
    final random = Random.secure();
    return List.generate(
      16,
      (_) => _base62[random.nextInt(_base62.length)],
    ).join();
  }

  /// AES-CBC + PKCS7 填充，输出 base64。密钥与 IV 都是 16 字节。
  static String _aesCbcBase64(String text, String key) {
    final cipher =
        PaddedBlockCipherImpl(
          PKCS7Padding(),
          CBCBlockCipher(AESEngine()),
        )..init(
          true,
          PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
            ParametersWithIV<CipherParameters>(
              KeyParameter(Uint8List.fromList(key.codeUnits)),
              Uint8List.fromList(_iv.codeUnits),
            ),
            null,
          ),
        );
    final input = Uint8List.fromList(utf8.encode(text));
    return base64Encode(cipher.process(input));
  }

  /// 随机密钥按协议反转字节序后做 RSA NO_PADDING 加密，输出小写十六进制。
  static String _rsaNoPadding(String secretKey) {
    // RSAEngine 本身就是无填充的原始 RSA；手动把明文左补齐到块长度。
    final rsa = RSAEngine()
      ..init(
        true,
        PublicKeyParameter<RSAPublicKey>(
          RSAPublicKey(_modulus, BigInt.from(_exponent)),
        ),
      );
    final blockSize = rsa.inputBlockSize;
    final input = Uint8List(blockSize);
    final reversed = secretKey.codeUnits.reversed.toList();
    input.setRange(blockSize - reversed.length, blockSize, reversed);
    final bytes = rsa.process(input);
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
