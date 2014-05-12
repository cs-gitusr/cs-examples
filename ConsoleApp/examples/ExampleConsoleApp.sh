
source $(dirname $(realpath ${BASH_SOURCE[0]}))"/../vendor/autoload.sh"
Autoloader_loadAllFilesInPath "./commands"

function ConsoleApp_registerCommands()
{
    cat<<'COMMANDS'
CalculatorCommand
COMMANDS
}
ConsoleApp_run $*

