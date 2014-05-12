
ConsoleAppInputArg_REQUIRED='ConsoleAppInputArg_REQUIRED'
ConsoleAppInputArg_OPTIONAL='ConsoleAppInputArg_OPTIONAL'

function ConsoleAppInputArg()
{
    local argName="$1"
    local argFlag="$2"
    local argDesc="$3"

    #local line=$*\n"
    #printf "%s" $*
    echo "'$argName' '$argFlag' '$argDesc'"
    #eval echo  "Z$*S"
}

function ConsoleAppInputArg_getArg()
{
    local argName="$1"

    local argsLine=$(ConsoleApp_getArgsLine)

    local argValue=$(sed -n 's/.*--'$argName'=\(.*\)\( \|$\).*/\1/p' <<< "$argsLine")
    #liblog_info "Value of $argName is [$argValue]"

    echo "$argValue"
}

function ConsoleAppInputArg_setArg()
{
    local argName="$1"
    local argValue="$2"

    local argStr="--${argName}=${argValue}"

    local argsLine=$(ConsoleApp_getArgsLine)
    ConsoleApp_setArgsLine "$argsLine $argStr"

    #check here type ? (like integer, string etc.)
}