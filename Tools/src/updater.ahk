; updater.ahk
#NoTrayIcon
#Include %A_LineFile%\..\json.ahk
#Include %A_LineFile%\..\libcrypt.ahk
#Include %A_LineFile%\..\package.ahk

github_api := "https://api.github.com"
self := "project64-updater"

tempdir := A_Temp . "\" . self
current := new Package(A_ScriptFullPath)
is_beta := current.meta("Beta", true)
releases_url := github_api . "/repos/" . current.meta("Source") . "/releases"
latest_url := releases_url . "/latest"
releases_json := tempdir . "\releases.json"

; download releases information from github API
; if the user is not on beta, just grab the latest release
if is_beta
	UrlDownloadToFile, %releases_url%, %releases_json%
else
	UrlDownloadToFile, %latest_url%, %releases_json%

file := "C:\Windows\notepad.exe"
OutputDebug % "File = " . LC_FileSHA(file)

FileRead, json_str, %releases_json%
json_parsed := JSON.Load(json_str)

OutputDebug % "==========="
OutputDebug % json_str 
OutputDebug % "-----------"
OutputDebug % "Version: " . json_parsed[1].tag_name
OutputDebug % "Build Name: " . json_parsed[1].name
OutputDebug % "Uploader: " . json_parsed[1].author.login
OutputDebug % "Beta Build: " . json_parsed[1].prerelease
OutputDebug % "Download Name: " . json_parsed[1].assets[1].name
OutputDebug % "Download Url: " . json_parsed[1].assets[1].browser_download_url
OutputDebug % "Downloads: " . json_parsed[1].assets[1].download_count
OutputDebug % "About Build: " . json_parsed[1].body


OutputDebug % "==========="

exit

json_str =
(
{
	"str": "Hello World",
	"num": 12345,
	"float": 123.5,
	"true": true,
	"false": false,
	"null": null,
	"array": [
		"Auto",
		"Hot",
		"key"
	],
	"object": {
		"A": "Auto",
		"H": "Hot",
		"K": "key"
	}
}
)

parsed := JSON.Load(json_str)

parsed_out := Format("
(Join`r`n
String: {}
Number: {}
Float:  {}
true:   {}
false:  {}
null:   {}
array:  [{}, {}, {}]
object: {{}A:""{}"", H:""{}"", K:""{}""{}}
)"
, parsed.str, parsed.num, parsed.float, parsed.true, parsed.false, parsed.null
, parsed.array[1], parsed.array[2], parsed.array[3]
, parsed.object.A, parsed.object.H, parsed.object.K)

stringified := JSON.Dump(parsed,, 4)
stringified := StrReplace(stringified, "`n", "`r`n") ; for display purposes only

ListVars
WinWaitActive ahk_class AutoHotkey
ControlSetText Edit1, [PARSED]`r`n%json_parsed%`r`n`r`n[STRINGIFIED]`r`n%stringified%
WinWaitClose
return