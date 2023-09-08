#!/bin/bash

if [[ -z ${1} ]]; then
	echo "missing user id of GPG"
	exit 1
fi

if [[ -z ${2} ]]; then
	echo "missing key type of GPG"
	exit 1
fi

id="${1}"
type="${2}"

if [[ $type == pub ]]; then
	gpg --fingerprint --with-colons "$id" |
		awk -F: '$1 == "fpr" {print $10}' |
		head -n 1
fi

if [[ $type =~ ^(sign|encrypt)$ ]]; then
	cap=''
	[[ $type == 'sign' ]] && cap=s
	[[ $type == 'encrypt' ]] && cap=e
	gpg --fingerprint --with-colons "$id" |
		awk -F: -v cap="$cap" '$1 == "sub" && $12 == cap {print $5}'
fi
