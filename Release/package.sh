#!/bin/bash
# package.sh - this should work with git bash in Windows

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

function update_checksums() {
    local tools_ini="$1"
    local prefix="${2:-Watch_}"

    local watches=""
    watches="$(grep -o "^\[${prefix}.*\]" "$tools_ini" | tr -d '[]')"

    local name=""
    local path=""
    local checksum=""
    local action=""
    local default=""

    for section in $watches; do
        name="$(ini_val "$tools_ini" "${section}.Name")"
        path="$(ini_val "$tools_ini" "${section}.Path")"
        action="$(ini_val "$tools_ini" "${section}.Action")"

        echo "- Updating checksum for ${name} (${path})"
        case "$action" in
            # only add if it doesn't already exist
            [Cc]reate)
                if [[ -f "$path" ]]; then
                    checksum="$(sha1sum "$path" | awk '{print $1}' | xargs)"
                    ini_val "$tools_ini" "${section}.Checksum" "$checksum"
                else
                    ini_val "$tools_ini" "${section}.Checksum" "0"
                fi
                ;;

            # we don't need to do this (unused)
            [Rr]ead)
                echo "- Unknown action for ${name} (${path})"
                exit 1
                ;;
            
            # the file should be updated, but may have been modified by the user
            [Uu]pdate)
                # without xargs, sha1sum | awk is adding a weird backslash on Windows
                if [[ -f "$path" ]]; then
                    checksum="$(sha1sum "$path" | awk '{print $1}' | xargs)"
                    ini_val "$tools_ini" "${section}.Checksum" "$checksum"
                else
                    ini_val "$tools_ini" "${section}.Checksum" "0"
                fi
                ;;

            # remove a file we've removed from the package
            [Dd]elete)
                if [[ -e "$path" ]]; then
                    echo "- The file/directory for still exists (${path})"
                    exit 1
                else
                    ini_val "$tools_ini" "${section}.Checksum" "0"
                fi
                ;;

            *)
                echo "- Unknown action for ${name} (${path})"
                exit 1
                ;;
        esac
    done
}

# entry point
ROOT_DIR="$(git rev-parse --show-toplevel)"
OUTPUT_FILE="project64k-legacy.zip"

# update metadata in some config files
cd "$ROOT_DIR" || exit
echo "Creating package, please wait..."
update_checksums "Tools/updater.cfg"

# package project and save checksum
git archive --format=zip --output="Release/${OUTPUT_FILE}" HEAD
cd "Release/" || exit
sha1sum "${OUTPUT_FILE}" > sha1sum.txt

exit 0
