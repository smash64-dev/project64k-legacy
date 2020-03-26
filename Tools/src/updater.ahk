; updater.ahk
#NoTrayIcon
#Include %A_LineFile%\..\github.ahk
#Include %A_LineFile%\..\json.ahk
#Include %A_LineFile%\..\libcrypt.ahk
#Include %A_LineFile%\..\logger.ahk
#Include %A_LineFile%\..\package.ahk
#Include %A_LineFile%\..\zip.ahk

BackupPackage(package, save_dir) {
	FormatTime, now,, yyyy-MM-dd-HHmmss
	source := package.updater("Source")
	repo := StrSplit(source, "/")
	version := package.meta("Version")

	backup_zip := Format("{1}\backup-{2}-v{3}-{4}.zip", save_dir, repo[2], version, now)
	Zip(package.base_directory, backup_zip)
}

; download and verify the latest release from github
DownloadLatestRelease(github, temp_dir) {
	; queries the API for the latest release information
	release_json := temp_dir . "\releases.json"
	UrlDownloadToFile % github.release_url, %release_json%

	; find the urls we need to download with
	found_release := github.LoadJSON(release_json)
	if found_release {
		found_assets := github.FindAssets()
	} else {
		log.err(Format("Unable to find proper release data in '{1}'", release_json))
		return false
	}

	; download the proper assets
	if found_assets {
		; download the checksum file to validate our package
		SplitPath % github.checksum_url, checksum_filename
		checksum_path := temp_dir . "\" . checksum_filename
		UrlDownloadToFile % github.checksum_url, %checksum_path%
		log.info(Format("Downloaded '{1}' to '{2}' (Result: {3})", github.checksum_url, checksum_path, ErrorLevel))

		; download the full package
		SplitPath % github.package_url, package_filename
		package_path := temp_dir . "\" . package_filename
		UrlDownloadToFile % github.package_url, %package_path%
		log.info(Format("Downloaded '{1}' to '{2}' (Result: {3})", github.package_url, package_path, ErrorLevel))
	} else {
		log.err(Format("Unable to find appropriate assets to download from '{1}'", release_json))
		return false
	}

	; verify the package downloaded correctly
	if (FileExist(checksum_path) and FileExist(package_path)) {
		package_checksum := LC_FileSHA(package_path)

		FileRead, valid_contents, %checksum_path%
		valid_array := StrSplit(valid_contents, " ")
		log.info(Format("Checksum comparison '{1}' vs '{2}'", package_checksum, valid_array[1]))

		if (package_checksum == valid_array[1]) {
			log.info("Checksums match!")
			return true
		} else {
			log.warn("Checksums mismatch!")
			return false
		}
	} else {
		log.err(Format("Unable to find all downloaded assets '{1}' and '{2}'", checksum_path, package_path))
		return false
	}

	return false
}

; entry point
global self := "project64k-updater"
global log := new Logger("updater.ahk")

app_dir := A_AppData . "\" . self
temp_dir := A_Temp . "\" . self

current_pkg := new Package(A_ScriptFullPath)
github := new GitHub(current_pkg.updater("Source"), current_pkg.updater("Beta", true))

download := DownloadLatestRelease(github, temp_dir)

if download {
	BackupPackage(current_pkg, app_dir)
}