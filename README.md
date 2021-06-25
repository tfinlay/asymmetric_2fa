# Asymmetric 2-Factor Authentication

My partially thought-through and likely severely flawed implementation of a 2FA time-based code generation scheme that uses an asymmetric encryption scheme to prevent failure of the system in the event of 2FA supplier's security breach.

Somewhat inspired by [this WIRED story][wired_story].

[wired_story]: https://www.wired.com/story/the-full-story-of-the-stunning-rsa-hack-can-finally-be-told

## More details

The planned general flow is this:

1. Setup
    1. Client generates a keypair, sending the private key to the user and the public key to the server.
2. Verification - The client can provide a verification message to the server by:
    1. Signing the hash of the current epoch (floored to the nearest 30 seconds) using their private key.
    2. Converting the result into a number of digits via the Truncate algorithm described in [RFC4226][rfc4226], section 5.3.
    3. This result is sent to the server.
    4. Server verifies the signature of client using their public key, and the same value for current epoch.

[rfc4226]: https://www.ietf.org/rfc/rfc4226.txt
[rfc6238]: https://datatracker.ietf.org/doc/html/rfc6238