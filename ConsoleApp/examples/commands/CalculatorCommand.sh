
function CalculatorCommand_getName()
{
    echo "calculator:add"
}

function CalculatorCommand_getDescription()
{
    echo "Calculates the sum of two numbers"
}

function CalculatorCommand_getDefinition()
{
    ConsoleAppInputArg 'x' $ConsoleAppInputArg_REQUIRED 'First addend'
    ConsoleAppInputArg 'y' $ConsoleAppInputArg_REQUIRED 'Second addend'
}

function CalculatorCommand_getHelp()
{
    cat<<'HELP'
    This is a simple command to add two numbers
    Just call like this:

    calculator:add --x=5 --y=6
HELP
}

function CalculatorCommand_execute()
{
    local x="$(ConsoleAppInputArg_getArg 'x')"
    local y="$(ConsoleAppInputArg_getArg 'y')"

    liblog_debug "x=$x"
    liblog_debug "y=$y"

    local result=$((x+y))
    local output="Result is $result"

    liblog_debug "$output"

    ConsoleApp_outputWrite "$output"
}

function CalculatorCommand_interact()
{
    local retVal=0

    if [[ "$(ConsoleAppInputArg_getArg 'x')" == "" ]] ; then
        local xVal=''
        read -p "Please insert x value: " -r xVal
        if ! libnum_isNumber "$xVal" ; then
            return 1
        fi
        ConsoleAppInputArg_setArg 'x' "$xVal"
    fi

    if [[ "$(ConsoleAppInputArg_getArg 'y')" == "" ]] ; then
        local yVal=''
        read -p "Please insert y value: " -r xVal
        if ! libnum_isNumber "$yVal" ; then
            return 1
        fi
        ConsoleAppInputArg_setArg 'y' "$yVal"
    fi

    return $retVal
}
