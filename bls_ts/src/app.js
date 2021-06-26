import bls from 'bls-wasm';

await bls.init(bls.BN254);

const secretKey = new bls.SecretKey();
secretKey.setByCSPRNG();
console.log(`Secret: ${secretKey.serializeToHexStr()}`);

const publicKey = secretKey.getPublicKey();
console.log(`Public: ${publicKey.serializeToHexStr()}`);

const message = 'abc123';
const signature = secretKey.sign(message);
console.log(`Signature: ${signature.serializeToHexStr()}`);

console.log(`Result: ${publicKey.verify(signature, message)}`)