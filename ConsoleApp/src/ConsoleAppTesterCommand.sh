
function ConsoleAppTesterCommand()
{
    ConsoleAppKlass_setCommand $1
}

function ConsoleAppTesterCommand_setArg()
{
    ConsoleAppInputArg_setArg $1 $2
}

function ConsoleAppTesterCommand_execute()
{
    ConsoleAppKlass_execute
}

function ConsoleAppTesterCommand_getOutput()
{
    ConsoleApp_outputRead
}

