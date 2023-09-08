#!/bin/bash

if [[ -z ${1} ]]; then
	echo "missing user id of GPG"
	exit 1
fi

id="${1}"

read -r -p 'Do you want to delete revocation certificate and private keys (Yes/no): ' confirm
echo

if [[ $confirm != Yes ]]; then
	echo 'aborted'
	exit 0
fi

fpr=$(
	gpg -q --with-colons --fingerprint "$id" |
		awk -F: '$1 == "fpr" {print $10;}' |
		head -n 1
)

rm -v "${HOME}/.gnupg/openpgp-revocs.d/${fpr}.rev"
gpg --delete-secret-keys "$id"
