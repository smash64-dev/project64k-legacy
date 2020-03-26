; github.ahk
#Include %A_LineFile%\..\logger.ahk
#Include %A_LineFile%\..\json.ahk

class GitHub {
    static ghlog := {}
    
    checksum_type := "SHA"
    github_api := "https://api.github.com"
    json_payload := ""
    latest_build_id := 1
    wants_beta := false

    ; we will probably access these directly
    checksum_url := ""
    latest_build := {}
    package_url := ""
    release_url := ""

    __New(source_repo, wants_beta) {
        ghlog := new Logger("github.ahk")
        this.log := ghlog

        all_releases := this.github_api . "/repos/" . source_repo . "/releases"
        latest_release := all_releases . "/latest"
        this.wants_beta := wants_beta

        ; if no beta, then just pull the latest release
        this.release_url := wants_beta ? all_releases : latest_release
        this.log.info(Format("release_url: {1} (beta: {2})", this.release_url, this.wants_beta))
    }

    ; returns the array id of the latest build from the JSON data
    FindLatestBuildId() {
        build_list := {}
        build_tags := ""

        loop {
            tag_name := this.json_payload[A_Index].tag_name
            build_list[tag_name] := A_Index
            build_tags := build_tags . "`n" . tag_name
        } until !this.json_payload[A_Index].id

        Sort build_tags, CLR
        builds_array := StrSplit(build_tags, "`n")
        latest_id := builds_array[1]

        return build_list[latest_id]
    }

    ; find the checksum and package assets in the latest build
    FindAssets() {
        assets := this.latest_build.assets
        found_checksum := false
        found_package := false

        loop {
            asset_name := assets[A_Index].name 

            if InStr(asset_name, "md5sum") {
                found_checksum := true
                this.checksum_type := "MD5"
                this.checksum_url := assets[A_Index].browser_download_url
            }

            if InStr(asset_name, "sha1sum") {
                found_checksum := true
                this.checksum_type := "SHA"
                this.checksum_url := assets[A_Index].browser_download_url
            }

            if InStr(asset_name, "zip") {
                found_package := true
                this.package_url := assets[A_Index].browser_download_url
            }
        } until !assets[A_Index].id

        return found_checksum & found_package
    }

    ; load the API results into a JSON object
    LoadJSON(json_file) {
        if FileExist(json_file) {
            FileRead, json_str, %json_file%

            if json_str {
                if this.wants_beta {
                    this.json_payload := JSON.Load(json_str)
                    this.latest_build_id := this.FindLatestBuildId()
                } else {
                    ; wrap the single release into an array to work better in other functions
                    this.json_payload := JSON.Load("[" . json_str . "]")
                    this.latest_build_id := 1
                }

                this.latest_build := this.json_payload[this.latest_build_id]
            } else {
                this.log.err(Format("Could not read json file '{1}'", json_file))
                return false
            }
        } else {
            this.log.err(Format("Unable to find json file '{1}'", json_file))
            return false
        }

        return true
    }
}
