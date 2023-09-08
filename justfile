gpg_id := "n4vysh"

list:
    gpg --list-keys "{{ gpg_id }}"
    gpg --list-secret-keys --keyid-format=long "{{ gpg_id }}"

generate:
    ./scripts/generate.bash "{{ gpg_id }}"

store:
    ./scripts/store.bash "{{ gpg_id }}"

import:
    gpg --import \
        ~/Downloads/gpg_public_key.asc \
        ~/Downloads/gpg_private_primary_key.asc \
        ~/Downloads/gpg_private_sub_key.asc \
        ~/Downloads/gpg_revcert.asc

get-keyid *opt:
    @./scripts/get-keyid.bash "{{ gpg_id }}" "{{ opt }}"

edit-card:
    gpg --edit-card

edit-key:
    gpg --edit-key "{{ gpg_id }}"

export *opt:
    @gpg {{ opt }} --export "{{ gpg_id }}"

delete:
    ./scripts/delete.bash "{{ gpg_id }}"
