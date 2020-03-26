; updater.ahk
#NoTrayIcon
#Include %A_LineFile%\..\github.ahk
#Include %A_LineFile%\..\json.ahk
#Include %A_LineFile%\..\libcrypt.ahk
#Include %A_LineFile%\..\logger.ahk
#Include %A_LineFile%\..\package.ahk

DownloadLatestRelease(github, temp_dir) {
	; queries the API for the latest release information
	release_json := temp_dir . "\releases.json"
	UrlDownloadToFile % github.release_url, %release_json%

	github.LoadJSON(release_json)
	github.FindAssets()

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
}

; entry point
global SELF := "Project64K-Updater"
global log := new Logger()

app_dir := A_AppData . "\" . SELF
temp_dir := A_Temp . "\" . SELF

current_pkg := new Package(A_ScriptFullPath)
github := new GitHub(current_pkg.updater("Source"), current_pkg.updater("Beta", true))
