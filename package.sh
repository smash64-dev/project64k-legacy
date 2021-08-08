#!/bin/bash
# package.sh - create a git archive ready for release
# this should work with linux and git bash in Windows

function ini_set() {
	local file="$1"
	local section="$2"
	local key="$3"
	local value="$4"

	local delim="="
	if [[ -e "$file" ]]; then
		sed -i "/\[${section}]/,/\[/ s|^\(${key}.*${delim}\).*$|\1${value}|" "$file"
	fi
}

function package_release() {
	local release_dir="$1"
	local release_name="$2"

	echo "- Creating git archive and moving files to $(basename "${release_dir}")"
	local release_stash=''
	release_stash="$(git stash create 2>/dev/null)"
	git archive --format=zip --output="${release_dir}/${release_name}" "${release_stash:-HEAD}"

	local files=(
		'CHANGELOG.md'
	)

	for file in "${files[@]}"; do
		cp -f "${SELF_DIR}/${file}" "${release_dir}/${file}"
	done

	(cd "$release_dir" && sha1sum "$release_name" > sha1sum.txt)
}

function update_fields() {
	local version="$1"
	local date="$2"
	local owner="$3"

	local file=''
	local section=''
	local key=''
	local value=''

	local build_id='0'
	build_id="$(echo -n "${version} ${date} ${owner}" | sha1sum | awk '{print $1}')"

	# define the package version and date strings
	local fields=(
		"Cfg/tools.cfg|Meta|Author|${owner}"
		"Cfg/tools.cfg|Meta|Date|${date}"
		"Cfg/tools.cfg|Meta|Version|${version#v}"
		"Tools/updater.cfg|Package|BuildId|${build_id}"
		"Tools/updater.cfg|Package|Version|${version#v}"
		"Tools/updater/cfg/base/tools.cfg|Meta|Author|${owner}"
		"Tools/updater/cfg/base/tools.cfg|Meta|Date|${date}"
		"Tools/updater/cfg/base/tools.cfg|Meta|Version|${version#v}"
	)

	# append entires for all relevant lng files
	local locales=''
	locales="$(find . -name "*.lng" | grep -v "template.lng\|locale.lng")"

	for file in $locales; do
		section="$(grep -o "^\[[^=]\+\]" "$file" | tr -d '[]')"
		fields[${#fields[@]}]="${file}|${section}|Tools1|Version: ${version#v} (${date})"
		fields[${#fields[@]}]="${file}|${section}|Tools2|Author: ${owner}"
	done

	# change version strings in various ini files
	echo "- Updating config files to contain the correct version"
	for field in "${fields[@]}"; do
		file="$(echo "$field" | awk -F'|' '{print $1}')"
		section="$(echo "$field" | awk -F'|' '{print $2}')"
		key="$(echo "$field" | awk -F'|' '{print $3}')"
		value="$(echo "$field" | awk -F'|' '{print $4}')"

		ini_set "$file" "$section" "$key" "$value"
	done
}

function update_self() {
	local updater="$1"

	# support building on multiple platforms
	echo "- Running package-updater on self to update local configs"
	case $(uname -s) in
		[Ll]inux)	wine cmd.exe /c "$updater -s" ;;
		*)			$updater "-s" ;;
	esac

	# clear update history from user.cfg
	sed -i '1,/\[Update_History\]/!d' "Tools/user.cfg"
}

# entry point
SELF_DIR="$(git rev-parse --show-toplevel)"
SELF_NAME="$(basename -s .git "$(git config --get remote.origin.url)")"
OWNER_NAME="CEnnis91"

OUTPUT_DIR="${SELF_DIR}/Release"
OUTPUT_FILE="${SELF_NAME}.zip"
UPDATER_EXE="Tools/package-updater.exe"

cd "$SELF_DIR" || exit

# this regex is not the recommeneded regex for semver, but it will work well enough for basic
# https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
# also related https://unix.stackexchange.com/a/398160
VALID_VERSION='^v?(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*).*$'
INPUT_VERSION="$1"

while [[ ! "$INPUT_VERSION" =~ $VALID_VERSION ]]; do
	read -rp "Input a valid 'semver' version name: " INPUT_VERSION
done

mkdir -p "$OUTPUT_DIR"
update_fields "$INPUT_VERSION" "$(date +"%Y/%m/%d")" "$OWNER_NAME"
update_self "${SELF_DIR}/${UPDATER_EXE}"
package_release "$OUTPUT_DIR" "$OUTPUT_FILE"

exit 0
