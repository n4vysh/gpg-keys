#!/bin/bash

if [[ -z ${1} ]]; then
	echo "missing user id of GPG"
	exit 1
fi

id="${1}"

read -r -s -p 'Enter the passphrase for GPG private key: ' passphrase
echo

gpg() {
	echo -n "$passphrase" |
		command gpg \
			--options gpg.conf \
			--pinentry-mode loopback \
			--passphrase-fd 0 \
			"$@"
}

fpr=$(
	gpg -q --with-colons --fingerprint "$id" |
		awk -F: '$1 == "fpr" {print $10;}' |
		head -n 1
)

eval "$(op signin)"

title='GPG keys'
vault=Development
date="$(date +'%Y/%m/%d %H:%M:%S')"
if ! (op item list --vault "$vault" |
	grep "$title"); then
	op item create \
		--vault "$vault" \
		--category 'Secure Note' \
		--title "$title" \
		"$date.gpg_public_key\.asc[file]"=<(just export --armor) \
		"$date.gpg_private_primary_key\.asc[file]"=<(gpg --armor --export-secret-keys "$id") \
		"$date.gpg_private_sub_key\.asc[file]"=<(gpg --armor --export-secret-subkeys "$id") \
		"$date.gpg_revcert\.asc[file]"=<(cat "$HOME/.gnupg/openpgp-revocs.d/$fpr.rev")
else
	op item edit \
		--vault "$vault" \
		"$title" \
		"$date.gpg_public_key\.asc[file]"=<(just export --armor) \
		"$date.gpg_private_primary_key\.asc[file]"=<(gpg --armor --export-secret-keys "$id") \
		"$date.gpg_private_sub_key\.asc[file]"=<(gpg --armor --export-secret-subkeys "$id") \
		"$date.gpg_revcert\.asc[file]"=<(cat "$HOME/.gnupg/openpgp-revocs.d/$fpr.rev")
fi
