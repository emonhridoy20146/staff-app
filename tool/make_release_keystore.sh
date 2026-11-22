#!/usr/bin/env bash
# One-time: make the staff app's release signing key and the text to paste into the four GitHub secrets.
# Run it on YOUR machine (not in CI, not in a shared session). Nothing here is committed: *.jks and *.b64 are git-ignored.
# Usage: tool/make_release_keystore.sh [output-folder]   (default: ~/staff-app-signing)
set -euo pipefail

out="${1:-$HOME/staff-app-signing}"
alias_name="staff"

if [ -e "$out/staff-release.jks" ]; then
  echo "$out/staff-release.jks already exists. Not overwriting a signing key." >&2
  exit 1
fi
mkdir -p "$out"
chmod 700 "$out"

# keytool asks for the password (twice) and your details. A PKCS12 key uses ONE password for the store and the key.
keytool -genkeypair -v -keystore "$out/staff-release.jks" -alias "$alias_name" \
  -keyalg RSA -keysize 2048 -validity 10000

# One line of text, the same on Linux and macOS.
base64 < "$out/staff-release.jks" | tr -d '\n' > "$out/staff-release.b64"
chmod 600 "$out/staff-release.jks" "$out/staff-release.b64"

cat <<TXT

Done. In $out:
  staff-release.jks   the key itself. Back it up with the password somewhere safe. If it is lost, no phone can be
                      updated again (only uninstall + install). Never commit it, never share it.
  staff-release.b64   the same key as one line of text, for the first GitHub secret.

Now in GitHub: staff-app > Settings > Secrets and variables > Actions > New repository secret, four times:
  STAFF_KEYSTORE_B64        the whole content of staff-release.b64
  STAFF_KEYSTORE_PASSWORD   the password you just typed
  STAFF_KEY_ALIAS           $alias_name
  STAFF_KEY_PASSWORD        the same password again

Then delete staff-release.b64 (the secret holds it now), and run CI again on main.
TXT
