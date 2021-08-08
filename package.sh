#!/bin/bash
# package.sh - create a git archive ready for release
# this should work with linux and git bash in Windows

# function from https://github.com/kvz/bash3boilerplate/blob/master/src/ini_val.sh
#
# The MIT License (MIT)
# Copyright (c) 2013 Kevin van Zonneveld and contributors
# You are not obligated to bundle the LICENSE file with your b3bp projects as long
# as you leave these references intact in the header comments of your source files.
function ini_val() {
	local file="${1:-}"
	local sectionkey="${2:-}"
	local val="${3:-}"
	local comment="${4:-}"
	local delim="="
	local comment_delim=";"
	local section=""
	local key=""
	local current=""
	# add default section
	local section_default="default"

	if [[ ! -f "${file}" ]]; then
		# touch file if not exists
		touch "${file}"
	fi

	# Split on . for section. However, section is optional
	IFS='.' read -r section key <<< "${sectionkey}"
	if [[ ! "${key}" ]]; then
		key="${section}"
		# default section if not given
		section="${section_default}"
	fi

	current=$(sed -En "/^\[/{h;d;};G;s/^${key}([[:blank:]]*)${delim}(.*)\n\[${section}\]$/\2/p" "${file}"|awk '{$1=$1};1')

	if ! grep -q "\[${section}\]" "${file}"; then
		# create section if not exists (empty line to seperate new section)
		echo	>> "${file}"
		echo "[${section}]" >> "${file}"
	fi

	if [[ ! "${val}" ]]; then
		# get a value
		echo "${current}"
	else
		# set a value
		if [[ ! "${current}" ]]; then
			# doesn't exist yet, add
			if [[ ! "${section}" ]]; then
				# if no section is given, propagate the default section
				section=${section_default}
			fi
			# add to section
			if [[ ! "${comment}" ]]; then
				# add new key/value without comment
				RET="/\\[${section}\\]/a\\
${key}${delim}${val}"
			else
				# add new key/value with preceeding comment
				RET="/\\[${section}\\]/a\\
${comment_delim}[${key}] ${comment}\\
${key}${delim}${val}"
			fi
			sed -i.bak -e "${RET}" "${file}"
			# this .bak dance is done for BSD/GNU portability: http://stackoverflow.com/a/22084103/151666
			rm -f "${file}.bak"
		else
			# replace existing (modified to replace only keys in given section)
			sed -i.bak -e "/^\[${section}\]/,/^\[.*\]/ s|^\(${key}[ \t]*${delim}[ \t]*\).*$|\1${val}|" "${file}"
			# this .bak dance is done for BSD/GNU portability: http://stackoverflow.com/a/22084103/151666
			rm -f "${file}.bak"
		fi
	fi
}

function package_release() {
	local release_dir="$1"
	local release_name="$2"

	echo "- Creating git archive and moving files to $(basename "$release_dir")"
	git archive --format=zip --output="${release_dir}/${release_name}" HEAD

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

	local file=''
	local section=''
	local key=''
	local value=''

	# define the package version and date strings
	local version_entries=(
		"Cfg/tools.cfg|Meta|Date|${date}"
		"Cfg/tools.cfg|Meta|Version|${version#v}"
		"Tools/updater.cfg|Package|Version|${version#v}"
		"Tools/updater/cfg/base/tools.cfg|Meta|Date|${date}"
		"Tools/updater/cfg/base/tools.cfg|Meta|Version|${version#v}"
	)

	# append entires for all relevant lng files
	local locale_files=''
	locale_files="$(find . -name "*.lng" | grep -v "template.lng\|locale.lng")"
	value="Version: ${version#v} (${date})"

	for file in $locale_files; do
		section="$(grep -o "^\[[^=]\+\]" "$file" | tr -d '[]')"
		version_entries[${#version_entries[@]}]="${file}|${section}|Tools1|${value}"
	done

	# change version strings in various ini files
	echo "- Updating config files to contain the correct version"
	for entry in "${version_entries[@]}"; do
		file="$(echo "$entry" | awk -F'|' '{print $1}')"
		section="$(echo "$entry" | awk -F'|' '{print $2}')"
		key="$(echo "$entry" | awk -F'|' '{print $3}')"
		value="$(echo "$entry" | awk -F'|' '{print $4}')"

		ini_val "$file" "${section}.${key}" "${value}"
	done

	# clear update history from user.cfg
	sed '1,/\[Update_History\]/!d' "Tools/user.cfg"
}

function update_self() {
	local updater="$1"

	# support building on multiple platforms
	echo "- Running package-updater on self to update local configs"
	case $(uname -s) in
		[Ll]inux)	wine cmd.exe /c "$updater -s" ;;
		*)			$updater "-s" ;;
	esac
}

# entry point
SELF_DIR="$(git rev-parse --show-toplevel)"
SELF_NAME="$(basename -s .git "$(git config --get remote.origin.url)")"

OUTPUT_DIR="${SELF_DIR}/Release"
OUTPUT_FILE="${SELF_NAME}.zip"
UPDATER_EXE="Tools/package-updater.exe"

cd "$SELF_DIR" || exit

# this regex is not the recommeneded regex for semver, but it will work well enough for basic
# https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
VALID_VERSION='^v?(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*).*$'
INPUT_VERSION="$1"

while [[ ! "$INPUT_VERSION" =~ $VALID_VERSION ]]; do
	read -rp "Input a valid 'semver' version name: " INPUT_VERSION
done

mkdir -p "$OUTPUT_DIR"
update_fields "$INPUT_VERSION" "$(date +"%Y/%m/%d")"
update_self "${SELF_DIR}/${UPDATER_EXE}"
package_release "$OUTPUT_DIR" "$OUTPUT_FILE"

exit 0
