; logger.ahk

class Logger {
    ; helps build methods like log.crit() and log.warn()
    static loglevels := {crit:"C", err:"E", warn:"W", info:"I", verb:"V"}
    tag := ""

    __New(tag:="") {
        this.tag := tag ? tag : A_ScriptName
    }

    ; allows calling different log levels from the object
    __Call(method, ByRef arg, args*) {
        if Logger.loglevels[method]
            return this.logger(Logger.loglevels[method], arg, args*)
    }

    ; log message to DebugView (https://docs.microsoft.com/en-us/sysinternals/downloads/debugview)
    logger(level, message := "") {
        ; don't log on release builds
        is_compiled := A_IsCompiled

        if ! is_compiled
            OutputDebug % Format("| {1} | {2} | {3}", level, this.tag, message)
    }
}
