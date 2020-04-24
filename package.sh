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

function commit_changes() {
    local version="$1"
    local message="Automated: Create release package '${version}'"

    echo "- Committing changes and creating '${version}' tag"
    git commit -am "$message"
    git tag -a "$version" -m "$version"
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

function prompt_version() {
    # this regex is not the recommeneded regex for semver, but it will work well enough for basic
    # https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
    local valid_version='^v?(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*).*$'

    local prompt_version=""
    while [[ ! "$prompt_version" =~ $valid_version ]]; do
        read -rp "Input a valid 'semver' version name: " prompt_version
    done

    local version_entries=(
        'Cfg/tools.ini|Meta|Version'
        'Tools/updater.cfg|Package|Version'
    )

    local file=''
    local section=''
    local key=''

    # change version strings in various ini files
    for entry in "${version_entries[@]}"; do
        file="$(echo "$entry" | awk -F'|' '{print $1}')"
        section="$(echo "$entry" | awk -F'|' '{print $2}')"
        key="$(echo "$entry" | awk -F'|' '{print $3}')"

        ini_val "$file" "${section}.${key}" "${prompt_version#v}"
    done

    echo "$prompt_version"
}

function update_self() {
    local updater="$1"

    echo "- Running package-updater on self to update local configs"
    $updater "$updater"
}

# entry point
SELF_DIR="$(git rev-parse --show-toplevel)"
SELF_NAME="$(basename -s .git "$(git config --get remote.origin.url)")"

OUTPUT_DIR="${SELF_DIR}/Release"
OUTPUT_FILE="${SELF_NAME}.zip"
UPDATER_EXE="Tools/package-updater.exe"

cd "$SELF_DIR" || exit

mkdir -p "$OUTPUT_DIR"
VERSION="$(prompt_version)"

# TODO: make a self-updating mode that avoids notifications
update_self "${SELF_DIR}/${UPDATER_EXE}"
commit_changes "$VERSION"
package_release "$OUTPUT_DIR" "$OUTPUT_FILE"

exit 0
