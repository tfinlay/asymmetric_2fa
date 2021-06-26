import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateKeypair() {
  final _sGen = Random.secure();
  final secureRandom = FortunaRandom();
  secureRandom.seed(KeyParameter(
      Uint8List.fromList(List.generate(32, (_) => _sGen.nextInt(255)))
  ));

  final generator = RSAKeyGenerator()
  ..init(ParametersWithRandom(
      RSAKeyGeneratorParameters(
          BigInt.parse('65537'),
          2048,
          64
      ),
      secureRandom
  ));
  final pair = generator.generateKeyPair();

  final myPublic = pair.publicKey as RSAPublicKey;
  final myPrivate = pair.privateKey as RSAPrivateKey;

  return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
}

int createTimestamp() {
  return DateTime.now().millisecondsSinceEpoch ~/ 30000;
}

Uint8List createTimestampData(int timestamp) {
  final bytes = Uint8List.fromList(timestamp.toRadixString(16).codeUnits);
  return bytes;
}

Uint8List signTimestamp(RSAPrivateKey privateKey, int timestamp) {
  final signer = RSASigner(SHA1Digest(), '123456');  // 123456 is the identifier used when getting the DER encoding
  signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));

  final signature = signer.generateSignature(createTimestampData(timestamp));

  return signature.bytes;
}

bool verifyTimestamp(RSAPublicKey publicKey, Uint8List expectedTimestamp, Uint8List receivedTimestamp) {
  final signature = RSASignature(receivedTimestamp);
  final verifier = RSASigner(SHA1Digest(), '123456');

  verifier.init(false, PublicKeyParameter<RSAPublicKey>(publicKey));  // false for signature verification mode

  try {
    return verifier.verifySignature(expectedTimestamp, signature);
  } on ArgumentError {
    return false;  // for Pointy Castle 1.0.2 when signature has been modified
  }
}

void main(List<String> arguments) {
  final keypair = generateKeypair();
  final public = keypair.publicKey;
  final private = keypair.privateKey;

  final currentTimestamp = createTimestamp();
  final currentTimestampData = createTimestampData(currentTimestamp);
  final signedTimestamp = signTimestamp(private, currentTimestamp);
  final isVerified = verifyTimestamp(public, currentTimestampData, signedTimestamp);

  print('Timestamp: $currentTimestamp ($currentTimestampData)');
  print('Signed Timestamp: $signedTimestamp');
  print('\tb64: ${base64.encode(signedTimestamp)}');
  print('is verified? $isVerified');
}
