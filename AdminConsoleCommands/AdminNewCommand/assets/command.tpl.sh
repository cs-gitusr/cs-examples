
function @@COMMAND_NAME@@_getName
{
    echo 'admin:new-command'
}

function @@COMMAND_NAME@@_getDescription
{
    echo 'Description not given'
}

function @@COMMAND_NAME@@_getDefinition
{
    # Ex.
    #ConsoleAppInputArg 'arg-name' $ConsoleAppInputArg_REQUIRED 'Short arg description'
    #ConsoleAppInputOpt 'opt-name' $ConsoleAppInputOpt_OPTIONAL 'Short opt description'
    :
}

function @@COMMAND_NAME@@_getHelp
{
    cat<<'HELP'
    No help given
HELP
}

function @@COMMAND_NAME@@_execute
{
    @@COMMAND_NAME@@_run
}

function @@COMMAND_NAME@@_interact
{
    local retVal=0
    return $retVal
}

#######################
# private
#######################

function @@COMMAND_NAME@@_run
{

}

