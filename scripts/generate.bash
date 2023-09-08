#!/bin/bash

if [[ -z ${1} ]]; then
  echo "missing user id of GPG"
  exit 1
fi

id="${1}"

read -r -s -p 'passphrase: ' passphrase
echo

gpg() {
  echo -n "${passphrase}" |
    command gpg --no-tty --quiet --pinentry-mode loopback --passphrase-fd 0 "$@"
}

# Generate a primary key
gpg --quick-generate-key "${id}" ed25519 sign,cert 1y >/dev/null

# Generate sub keys
fpr=$(
  command gpg -q --with-colons --fingerprint "${id}" |
    awk -F: '$1 == "fpr" {print $10;}'
)

for usage in sign auth; do
  gpg --quick-add-key "${fpr}" ed25519 "${usage}" 1y
done
gpg --quick-add-key "${fpr}" cv25519 encrypt 1y
