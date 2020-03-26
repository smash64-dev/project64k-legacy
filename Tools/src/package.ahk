; package.ahk
#Include %A_LineFile%\..\logger.ahk
#Include %A_LineFile%\..\json.ahk

class Package {
    static cfg_list := ["Cfg\tools.ini", "Config\tools.ini"]
    static exe_list := ["project64*.exe"]
    static log := {}
    static reserved := {base_directory:true, config_tools_ini:true, exe_list:true, updater_binary:true}

    base_directory := ""
    config_tools_ini := ""
    updater_binary := ""

    ; we will probably access these directly
    config_data := {}
    config_func := {}
    config_json := ""

    __New(updater_binary) {
        log := new Logger("package.ahk")
        this.log := log

        this.updater_binary := updater_binary
        this.base_directory := this.GetBaseDirectory(this.updater_binary)

        for index, config in Package.cfg_list {
            file := this.GetFile(config)

            if file {
                this.config_tools_ini := file
                break
            }
        }

        ; store our basic information into the config data
        this.config_data["Package"] := {"BaseDir": this.base_directory, "Config": this.config_tools_ini, "Updater": this.updater_binary}

        if this.config_tools_ini {
            ; read through the entire config and turn it into an object
            IniRead, tools_sections, % this.config_tools_ini

            loop, parse, tools_sections, `n, `r
            {
                tools_section := A_LoopField
                this.config_func[tools_section] := true
                this.config_data[tools_section] := {}
                IniRead, section_keys, % this.config_tools_ini, %tools_section%

                loop, parse, section_keys, `n, `r
                {
                    section_key := StrSplit(A_LoopField, "=")
                    key := Trim(section_key[1])
                    value := Trim(section_key[2])

                    this.config_data[tools_section][key] := value
                }
            }
        }

        this.config_json := JSON.Dump(this.config_data)
        this.log.info(Format("config_json: '{1}'", this.config_json))
    }

    ; allows pull from different section of the config easier
    __Call(method, ByRef arg, args*) {
        if this.config_func[method]
            return this.GetSectionValue(method, arg, args*)
    }

    ; allows using directory paths or filenames as properties
    __Get(path) {
        if ! Package.reserved[path]
            return this.GetDirectory(StrReplace(path, "_", "\"))
        else
            return this.path
    }

    ; grab the base directory of the package, "project64_exe*.exe"
    GetBaseDirectory(updater) {
        ; FileExist works off A_WorkingDir, don't destroy that
        B_WorkingDir = %A_WorkingDir%
        SplitPath, updater,, current_dir
        
        ; we shouldn't be more than 5 subdirectories deep anyway
        loop, 5 {
            SetWorkingDir, %current_dir%

            for index, exe in Package.exe_list {
                if FileExist(exe) {
                    SetWorkingDir %B_WorkingDir%
                    return current_dir
                }
            }

            SplitPath, A_WorkingDir,, current_dir
        }

        this.log.err("Unable to find base directory")
    }

    ; grab the full path of a directory relative to the base directory
    GetDirectory(path) {
        fullpath := this.base_directory . "\" . path
        if InStr(FileExist(fullpath), "D") {
            return fullpath
        }

        this.log.warn(Format("Directory '{1}' does not exist", fullpath))
        return false
    }

    ; grab the full path of a file relative to the base directory
    GetFile(path) {
        fullpath := this.base_directory . "\" . path
        if FileExist(fullpath) {
            return fullpath
        }

        this.log.warn(Format("File '{1}' does not exist", fullpath))
        return false
    }

    ; grab values from the config, with an optional default 
    GetSectionValue(sec, key, default_value := "") {
        if this.config_data[sec].HasKey(key)
            return this.config_data[sec][key]
        else
            return default_value
    }
}
