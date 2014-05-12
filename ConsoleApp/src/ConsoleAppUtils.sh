
    function ConsoleAppUtils_getHelpHeader()
    {
        local output=$(cat<<EOF
ConsoleApp Helper console, version $ConsoleAppVar_Version
EOF
        )
        echo -e "$output"
    }

    ##
    #
    # $1 int Total number of commands
    # $2 string Command list block
    #
function ConsoleAppUtil_getHelpBody()
{
    local scriptName=$(libpath_getBasename "$0")
    local cmdnum="$1"; shift
    local cmdlist="$@"

    local output=$(cat<<EOF
Usage:

    #> $scriptName [options] command [arguments]

Options:

    --help
    --version

Available commands (Total [$cmdnum]):
$cmdlist

For command specific help, type: console <commandname> --help\n
EOF
        )
        echo -e "$output"
}
