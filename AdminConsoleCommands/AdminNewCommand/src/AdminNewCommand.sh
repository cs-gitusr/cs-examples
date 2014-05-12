
function AdminNewCommand_getName
{
    echo 'admin:new-command'
}

function AdminNewCommand_getDescription
{
    echo 'Creates a new Command skeleton'
}

function AdminNewCommand_getDefinition
{
    ConsoleAppInputArg 'name' $ConsoleAppInputArg_REQUIRED 'Command Name'
}

function AdminNewCommand_getHelp
{
    cat<<'HELP'
    Creates a new Command skeleton in the AdminConsoleCommands dir
    to be loaded in the AdminConsole
HELP
}

function AdminNewCommand_execute
{
    AdminNewCommand_run
}

function AdminNewCommand_interact
{
    local retVal=0
    return $retVal
}

#######################
# private
#######################

function AdminNewCommand_run
{
    local repoDir=$(libenv_getParentDir $(libenv_getCWD))
    local commandName=$(ConsoleAppInputArg_getArg 'name')

    local commandsDir="$repoDir/AdminConsoleCommands"
    local newCommandDir="$commandsDir/$commandName"

    libfile_dirExists "$newCommandDir" &&
        liblog_error "Command dir already exists: $newCommandDir" &&
        return 1

    libfile_dirCreate "$newCommandDir"
    libfile_dirCreate "$newCommandDir/src"

    local tplOut=''
    local bcomposerJSONTemplate=$(AdminNewCommand_getAssetFile "bcomposer.tpl.sh")
    local commandTemplate=$(AdminNewCommand_getAssetFile "command.tpl.sh")

    MiniTemplateEngine_dataProvider=(
        @@COMMAND_NAME@@="$commandName"
    )

    tplOut=$(MiniTemplateEngine_process "$bcomposerJSONTemplate")
    echo "$tplOut" > "$newCommandDir/bcomposer.json"

    tplOut=$(MiniTemplateEngine_process "$commandTemplate")
    echo "$tplOut" > "$newCommandDir/src/${commandName}.sh"

    unset MiniTemplateEngine_dataProvider

    liblog_info "Done"
}

