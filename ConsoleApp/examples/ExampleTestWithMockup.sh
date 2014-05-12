
source $(dirname $(realpath ${BASH_SOURCE[0]}))"/../vendor/autoload.sh"
Autoloader_loadAllFilesInPath "./commands"

function ExampleTestWithMockup()
{
    # Mockup
    ConsoleAppTesterCommand "CalculatorCommand"
    ConsoleAppTesterCommand_setArg 'x' 5
    ConsoleAppTesterCommand_setArg 'y' 7
    ConsoleAppTesterCommand_execute

    local output=$(ConsoleAppTesterCommand_getOutput)
    libunit_assertStringEquals "$output" "Result is 12" "Mockup Test"
}

##
# @BashUnitMockup tester
#
function ExampleTestWithMockup_dataProvider()
{
    cat<<'DATA_PROVIDER'
5, 7, Result is 12
2, 9, Result is 11
500, 291, Result is 791
DATA_PROVIDER
}

if libenv_isMain ${BASH_SOURCE[0]} ; then
    ExampleTestWithMockup
fi

