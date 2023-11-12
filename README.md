# gpg-keys

My personal setup guide for [GPG][gpg-link] and Security Key.
After setup the following [ECC][ecc-link] keys
and revocation certificate will be created.

| Key     | Algorithm       | Capability     |
| :------ | :-------------- | :------------- |
| primary | EdDSA - ed25519 | Sign + Certify |
| sub     | EdDSA - ed25519 | Sign           |
| sub     | EdDSA - ed25519 | Authentication |
| sub     | ECDH - cv25519  | Encrypt        |

Expiration date of keys is 1 year.
Public key deployed following location.

- <https://keys.openpgp.org>
- <https://keybase.io/n4vysh>
- <https://github.com/n4vysh.gpg>

[gpg-link]: https://wiki.gnupg.org/Index
[ecc-link]: https://wiki.gnupg.org/ECC

## Requirement

- [devbox][devbox-link] ~> 0.8
- [rtx][rtx-link]
- Security Key ([YubiKey 5][yubikey-5-link])

Run `./scripts/init.sh` to install tools with devbox and rtx.

[devbox-link]: https://www.jetpack.io/devbox/
[rtx-link]: https://github.com/jdx/rtx
[yubikey-5-link]: https://www.yubico.com/products/yubikey-5-overview/

## Usage

Generate primary key, sub keys, and revocation certificate with `just generate`.
List generated keys with `just list`.
`sec` means primary key.
`ssb` means sub key.

### Add email address to GPG key

Add new uid for email address and revoke old uid.

```bash
just edit-key
```

```txt
gpg> adduid
...
gpg> uid 2 # select 2
...
gpg> trust
...
Please decide how far you trust this user to correctly verify other users' keys
(by looking at passports, checking fingerprints from different sources, etc.)

  1 = I don't know or won't say
  2 = I do NOT trust
  3 = I trust marginally
  4 = I trust fully
  5 = I trust ultimately
  m = back to the main menu

Your decision? 5
Do you really want to set this key to ultimate trust? (y/N) y
...
gpg> uid 2 # deselect 2
...
gpg> uid 1 # select 1
...
gpg> revuid
Really revoke this user ID? (y/N) y
Please select the reason for the revocation:
  0 = No reason specified
  4 = User ID is no longer valid
  Q = Cancel
(Probably you want to select 4 here)
Your decision? 0
Enter an optional description; end it with an empty line:
>
Reason for revocation: No reason specified
(No description given)
Is this okay? (y/N) y
...
gpg> save
```

### Store keys and revocation certificate

Store primary key, sub key, and revocation certificate to 1Password vault.

```bash
just store
```

### Set PIN and Reset Code of security key

First, enable [The KDF (Key Derived Format) function][kdf-link]
to store hash instead of plain text when entering th PIN.
Next, set User PIN, Admin PIN, and Reset Code.
The default values of [PIN][default-pin-link] are following.

| Default User PIN | Default Admin PIN |
| :--------------- | :---------------- |
| `123456`         | `12345678`        |

[default-pin-link]: https://support.yubico.com/hc/en-us/articles/360013790259-Using-Your-YubiKey-with-OpenPGP

Finally, Store new values of PIN and Reset Code to 1Password vault manually.

```bash
just edit-card
```

```txt
gpg/card> admin
gpg/card> list
...
KDF setting ......: off
...
gpg/card> kdf-setup
gpg/card> list
...
KDF setting ......: on
...
gpg/card> passwd

1 - change PIN
2 - unblock PIN
3 - change Admin PIN
4 - set the Reset Code
Q - quit

Your selection? 1
PIN changed.
...
Your selection? 3
PIN changed.
...
Your selection? 4
Reset Code set.
...
Your selection? q
gpg/card> quit
```

[kdf-link]: https://developers.yubico.com/PGP/YubiKey_5.2.3_Enhancements_to_OpenPGP_3.4.html

Change PIN retry counter from 3 to 5.

```bash
ykman openpgp access set-retries 5 5 5
```

```txt
Enter Admin PIN:
Set PIN retry counters to: 5 5 5? [y/N]: y
```

### Register GPG public key to server

Register GPG public key to server and set URL to security key.

```bash
just export | curl -T - https://keys.openpgp.org
just edit-card
```

```txt
gpg/card> admin
Admin commands are allowed

gpg/card> url
```

### Move GPG sub keys to security key

Move keys to security key.
**Quit without save** to setup secondary key.

```bash
just edit-key
```

```txt
gpg> key 1 # select 1
...
gpg> keytocard
...
Please select where to store the key:
(1) Signature key
(3) Authentication key
Your selection? 1
...
gpg> key 1 # deselect 1
...
gpg> key 2 # select 2
...
gpg> keytocard
...
Please select where to store the key:
(3) Authentication key
Your selection? 3
...
gpg> key 2 # deselect 2
...
gpg> key 3 # select 3
...
gpg> keytocard
...
Please select where to store the key:
(2) Encryption key
Your selection? 2
...
gpg> quit
Save changes? (y/N) N
Quit without saving? (y/N) y
```

### Setup secondary security key

Repeat procedure to setup another security key.
If occurred following error when run keytocard command,
try after delete and import keys.

```txt
gpg: KEYTOCARD failed: Unusable secret key
```

### Set GPG signing key in Git

```bash
git config --global user.signingkey $(just get-keyid sign)
```

### Register GPG public key to GitHub

```bash
gh gpg-key add <(just export --armor)
```

### Register GPG public key to [Keybase][keybase-link]

```bash
keybase login
keybase pgp select
```

[keybase-link]: https://keybase.io/

### Cleanup

**After setup and unplug security key**, remove the revocation certificate
and secret keys from the GPG keyring.

```bash
just delete
```

### Use security key in multiple hosts

```bash
gpg --edit-card
```

```txt
gpg/card> fetch
...
gpg/card> quit
```

```bash
gpg --edit-key n4vysh
```

```txt
gpg> trust
Your decision? 5
Do you really want to set this key to ultimate trust? (y/N) y
gpg> quit
```

```bash
just list
```

If `sec#` and `ssb>` displayed, it is success.
`#` means that the machine doesn't exists the secret key,
but has a reference to it.
`>` means that the key referenced from a smartcard.

### Extend the expiration date

```bash
just edit-key
```

```txt
gpg> list
gpg> key # primary key
gpg> expire
...
Key is valid for? (0) 1y
...
Is this correct? (y/N) y
...
gpg> key 1
gpg> key 2
gpg> key 3
gpg> expire
Are you sure you want to change the expiration time for multiple subkeys? (y/N) y
...
Key is valid for? (0) 1y
...
Is this correct? (y/N) y
...
gpg> save
```

Store 1Password vault after extend the expiration date.

```bash
just store
```

### Import from backup

Download keys and revocation certificate from 1Password Vault and run following.

```bash
just import
```

### Reset GPG keys in security key

If PIN retry counter reached 0 and can't unblock Admin PIN, follow [support page][support-page-link].

[support-page-link]: https://support.yubico.com/hc/en-us/articles/360013761339-Resetting-the-OpenPGP-Applet-on-the-YubiKey

## License

This project distributed under the [Unlicense][unlicense-link].
See the [UNLICENSE](./UNLICENSE) file for details.

[unlicense-link]: https://choosealicense.com/licenses/unlicense/
