#!/bin/bash
set -ex

BASE=$(dirname $0)
TMP=$BASE/tmp
KP=henri

mkdir -p "$TMP"

create_authority() {
    local kp="$1"
    mkdir -p $BASE/authorities
    pushd $BASE/authorities
    openssl req -nodes -x509 -sha256 -newkey rsa:4096 \
        -keyout "$kp.key" \
        -out "$kp.crt" \
        -days 365 \
        -subj "/C=UK/ST=Zuid Holland/L=Rotterdam/O=Sparkling Network/OU=IT Dept/CN=$kp Sign Key"
    # openssl x509 -in "$kp.crt" -out "$kp.pub"
    openssl x509 -in "$kp.crt" -pubkey -out "$kp.pub"
    popd
}

sign_artifact() {
    local authority="$1"
    local artifact="$2"
    openssl dgst -sha256 -sign authorities/$authority.key -out $artifact.sha256 $artifact
}

verify_artifact() {
    local authority="$1"
    local artifact="$2"
    openssl dgst -sha256 -verify authorities/$authority.pub -signature $artifact.sha256 $artifact
}

ex_artifact() {
    echo hello > artifact.txt
    sign_artifact a artifact.txt
    verify_artifact a artifact.txt
}

split_payload() {
    local signed_payload="$1"
    local tmp=$(mktemp -d)
    local payload=$tmp/payload

    cat $signed_payload | \
        awk -- "
        BEGIN {file=\"${payload}\"}
        /^=== SIGNATURE ([^ ]+) *\$/ {file=\"${tmp}/\"\$3\".sig\"; next; next}
        /.*/ {print > file}
        "

    echo "$tmp"
}

validated_payload() {
    local signed_payload="$1"
    shift
    local authorities="$@"
    local tmp="$(split_payload $signed_payload)"

    for authority in $authorities; do
        echo "authority: $authority"
        openssl dgst -sha256 \
            -verify authorities/$authority.pub \
            -signature $tmp/$authority \
            $tmp/payload
    done

    #rm -rf "$tmp"
}

sign_payload() {
    local payload="$1"
    shift
    local authorities="$@"
    local tmp="$(split_payload $payload)"
    ls -F $tmp

    # generate new .sig files
    for authority in $authorities; do
        openssl dgst -sha256 \
            -sign authorities/$authority.key \
            -out $tmp/$authority.raw \
            $tmp/payload
        base64 < $tmp/$authority.raw > $tmp/$authority.sig
        rm $tmp/$authority.raw
    done

    # assemble the new file
    local new_payload="$tmp/new"
    cp $tmp/payload $new_payload
    for signature in $tmp/*.sig; do
        local authority=$(basename $signature | sed 's/\.sig$//')
        echo "=== SIGNATURE $authority"
        cat $signature
    done >> $new_payload
    mv $payload $payload.bak
    mv $new_payload $payload
}

ex_parsing() {
    cat > $TMP/signed-payload <<EOS
the payload
=== SIGNATURE a
signature by a
=== SIGNATURE b
signature by b
EOS
    validated_payload $TMP/signed-payload
}

eval "$@"
