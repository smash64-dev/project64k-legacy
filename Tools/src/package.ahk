; package.ahk

class Package {
    static reserved := {basedir:true, cfgtools:true, meta:true, metadata:true, project64:true, updater:true}

    ; these generally shouldn't change
    project64 := "Project64*.exe"
    cfgtools := "Cfg\tools.ini"

    basedir := ""
    metadata := {}
    updater := ""

    __New(updaterBinary) {
        this.updater := updaterBinary
        this.basedir := this.GetBaseDirectory(this.updater)

        tools_ini := this.GetFile(this.cfgtools)
        if tools_ini {
            IniRead, tools_meta, %tools_ini%, Meta

            Loop, parse, tools_meta, `n, `r
            {
                key_value := StrSplit(A_LoopField, "=")
                key := Trim(key_value[1])
                this.metadata[key] := Trim(key_value[2])
            }
        }
    }

    ; allows using directory paths or filenames as properties
    __Get(path) {
        if ! Package.reserved[path]
            return this.GetDirectory(StrReplace(path, "_", "\"))
        else
            return this.path
    }

    ; grab the base directory of the package, "Project64*.exe"
    GetBaseDirectory(updater) {
        ; FileExist works off A_WorkingDir, don't destroy that
        B_WorkingDir = %A_WorkingDir%
        SplitPath, updater,, currentDir
        
        ; we shouldn't be more than 5 subdirectories deep anyway
        Loop, 5 {
            SetWorkingDir, %currentDir%
            if FileExist(this.project64) {
                SetWorkingDir %B_WorkingDir%
                return currentDir
            }
            SplitPath, A_WorkingDir,, currentDir
        }
    }

    ; grab the full path of a directory relative to the base directory
    GetDirectory(path) {
        fullpath := this.basedir . "\" . path
        if InStr(FileExist(fullpath), "D") {
            return fullpath
        }
        return false
    }

    ; grab the full path of a file relative to the base directory
    GetFile(path) {
        fullpath := this.basedir . "\" . path
        if FileExist(fullpath) {
            return fullpath
        }
        return false
    }

    ; retrieve stored metadata about the package
    meta(key, default_value:="") {
        if this.metadata.HasKey(key) {
            return this.metadata[key]
        } else {
            return default_value
        }
    }
}