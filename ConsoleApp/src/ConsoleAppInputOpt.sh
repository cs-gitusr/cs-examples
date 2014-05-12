
ConsoleAppInputOpt_OPTIONAL='ConsoleAppInputOpt_OPTIONAL'

function ConsoleAppInputOpt()
{
    local optName="$1"
    local optFlag="$2"
    local optDesc="$3"

    echo "'$optName' '$optFlag' '$optDesc'"
}

function ConsoleAppInputOpt_getOpt()
{
    local optName="$1"
    local retVal=1

    local argsLine=$(ConsoleApp_getArgsLine)

    local regex='\s\-\-'$optName'\s*'

    grep -q $regex <<< "$argsLine"
    local retVal=$?

    return $retVal
}
