import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart' hide Algorithm;

final _iv = IV.fromUtf8("0102030405060708");
final _presetKey = Key.fromUtf8("0CoJUm6Qyw8W8jud");
const _base62 =
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
const _publicKey =
    "-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDgtQn2JZ34ZC28NWYpAUd98iZ37BUrX/aKzmFbt7clFSs6sXqHauqKWqdtLkF2KexO40H1YTX8z2lSgBBOAxLsvaklV8k4cBFK9snQXE9/DDaFt6Rr7iVZMldczhC0JNgTz+SHXT6CBHuX3e9SdB1Ua44oncaTWz7OBGLbCiK45wIDAQAB\n-----END PUBLIC KEY-----";
final _eapiKey = Key.fromUtf8("e82ckenh8dichen8");
final _linuxapiKey = Key.fromUtf8("rFgB&fsadsasadsadash#%2?^eDg:Q");

class NestedCryptoUtils {
  NestedCryptoUtils();
  Encrypted rsaEncrypt(buffer, key) {
    var encrypted = Encrypter(RSAExt(publicKey: key));
    var data = encrypted.encryptBytes(buffer);
    return data;
  }

  Encrypted aesEncrypt(buffer, key, iv) {
    var encrypted = Encrypter(AES(key, mode: AESMode.cbc));
    var data = encrypted.encrypt(buffer, iv: _iv);
    return data;
  }

  String decrypt(String data) {
    var encrypted = Encrypter(AES(_eapiKey, mode: AESMode.ecb));
    var json = encrypted.decrypt64(data);

    return json;
  }

  Map<String, dynamic> weapi(Map oldData) {
    String text = json.encode(oldData);
    // 生成随机密钥
    var secretKey = Encrypted.fromSecureRandom(16)
        .bytes
        .map((n) => _base62[(n % 62)])
        .toList()
        .join();
    Encrypted first = aesEncrypt(text, _presetKey, _iv);
    Encrypted second = aesEncrypt(first.base64, Key.fromUtf8(secretKey), _iv);

    Map<String, dynamic> data = {};
    data["params"] = second.base64;

    Encrypted third = rsaEncrypt(
      secretKey.codeUnits.reversed.toList(),
      RSAKeyParser().parse(_publicKey),
    );
    data["encSecKey"] = third.base16;
    return data;
  }

  String eapi(String url, String text) {
    String message = "nobody${url}use${text}md5forencrypt";
    var digest = md5.convert(message.codeUnits);
    var data = "$url-36cd479b6b5-$text-36cd479b6b5-$digest";
    Map<String, String> json = {};

    var encrypted = Encrypter(AES(_eapiKey, mode: AESMode.ecb));
    var result = encrypted.encrypt(data);

    json["params"] = result.base16.toUpperCase();
    return jsonEncode(json);
  }

  String linuxapi(String text) {
    var encrypted = Encrypter(AES(_linuxapiKey, mode: AESMode.ecb));
    var result = encrypted.encrypt(text);

    Map<String, String> json = {};
    json["params"] = result.base16.toUpperCase();
    return jsonEncode(json);
  }
}

class NoPaddingEncoding extends PKCS1Encoding {
  NoPaddingEncoding(this._engine) : super(_engine);

  final AsymmetricBlockCipher _engine;

  late int _keyLength;
  late bool _forEncryption;

  @override
  void init(bool forEncryption, CipherParameters params) {
    super.init(forEncryption, params);
    _forEncryption = forEncryption;
    if (params is AsymmetricKeyParameter<RSAAsymmetricKey>) {
      _keyLength = (params.key.modulus?.bitLength ?? 0 + 7) ~/ 8;
    }
  }

  @override
  int get inputBlockSize {
    return _keyLength;
  }

  @override
  int get outputBlockSize {
    return _keyLength;
  }

  @override
  int processBlock(
      Uint8List inp, int inpOff, int len, Uint8List out, int outOff) {
    if (_forEncryption) {
      return _encodeBlock(inp, inpOff, len, out, outOff);
    } else {
      return _decodeBlock(inp, inpOff, len, out, outOff);
    }
  }

  int _encodeBlock(
      Uint8List inp, int inpOff, int inpLen, Uint8List out, int outOff) {
    if (inpLen > inputBlockSize) {
      throw ArgumentError("Input data too large");
    }

    var block = Uint8List(inputBlockSize);
    var padLength = (block.length - inpLen);

    block.fillRange(0, padLength, 0x00);

    block.setRange(padLength, block.length, inp.sublist(inpOff));

    return _engine.processBlock(block, 0, block.length, out, outOff);
  }

  int _decodeBlock(
      Uint8List inp, int inpOff, int inpLen, Uint8List out, int outOff) {
    var block = Uint8List(outputBlockSize);
    var len = _engine.processBlock(inp, inpOff, inpLen, block, 0);
    block = block.sublist(0, len);

    if (block.length < outputBlockSize) {
      throw ArgumentError("Block truncated");
    }

    return block.length;
  }
}

abstract class AbstractRSAExt {
  final RSAPublicKey? publicKey;
  final RSAPrivateKey? privateKey;

  PublicKeyParameter<RSAPublicKey>? get _publicKeyParams =>
      publicKey != null ? PublicKeyParameter(publicKey!) : null;

  PrivateKeyParameter<RSAPrivateKey>? get _privateKeyParams =>
      privateKey != null ? PrivateKeyParameter(privateKey!) : null;
  final AsymmetricBlockCipher _cipher;

  AbstractRSAExt({
    required this.publicKey,
    required this.privateKey,
  }) : _cipher = NoPaddingEncoding(RSAEngine());
}

class RSAExt extends AbstractRSAExt implements Algorithm {
  RSAExt({super.publicKey, super.privateKey});

  @override
  Encrypted encrypt(Uint8List bytes, {IV? iv, Uint8List? associatedData}) {
    if (publicKey == null) {
      throw StateError('Can\'t encrypt without a public key, null given.');
    }

    _cipher
      ..reset()
      ..init(true, _publicKeyParams!);

    return Encrypted(_cipher.process(bytes));
  }

  @override
  Uint8List decrypt(Encrypted encrypted, {IV? iv, Uint8List? associatedData}) {
    if (privateKey == null) {
      throw StateError('Can\'t decrypt without a private key, null given.');
    }

    _cipher
      ..reset()
      ..init(false, _privateKeyParams!);

    return _cipher.process(encrypted.bytes);
  }
}
