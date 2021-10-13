#!/bin/bash

export GOOGLE_APPLICATION_CREDENTIALS=/tmp/credentials.json
jq -r '.source.GOOGLE_APPLICATION_CREDENTIALS //empty' < $payload > $GOOGLE_APPLICATION_CREDENTIALS
url=$(jq -r '.source.url //empty' < $payload)
package=$(jq -r '.source.package //empty' < $payload)
scope=$(jq -r '.source.scope //empty' < $payload)
debug=$(jq -r '.source.debug //"false"' < $payload)

[ "$debug" = "true" ] && set -x

[ -z "$(<$GOOGLE_APPLICATION_CREDENTIALS)" ] && (>&2 echo "source.$GOOGLE_APPLICATION_CREDENTIALS is not configured") && exit 1
[ -z "$url" ] && (>&2 echo "source.url is not configured") && exit 1
[ -z "$package" ] && (>&2 echo "source.package is not configured") && exit 1

url_without_protocol="$(echo $url | sed 's/.*https://')"
case "$url" in
@*)
  scope="$(echo $url | cut -d: -f1)"
  ;;
*)
  [ -z "$scope" ] && (&>2 echo "source.scope is neither defined nor part of the source.url") && exit 1
  ;;
esac

cat <<EOF > ~/.npmrc
@${scope}:registry=https:${url_without_protocol}
${url_without_protocol}:_password=""
${url_without_protocol}:username=oauth2accesstoken
${url_without_protocol}:email=not.valid@email.com
${url_without_protocol}:always-auth=true
EOF
npx google-artifactregistry-auth </dev/null
