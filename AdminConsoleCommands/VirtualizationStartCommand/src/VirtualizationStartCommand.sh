
function VirtualizationStartCommand_getName
{
    echo 'vm:start'
}

function VirtualizationStartCommand_getDescription
{
    echo 'Run Virtual Machine'
}

function VirtualizationStartCommand_getDefinition
{
    ConsoleAppInputArg 'vmname' $ConsoleAppInputArg_REQUIRED 'VM name on assets dir'
    ConsoleAppInputOpt 'cdboot' $ConsoleAppInputOpt_OPTIONAL 'Boot from CD'
    ConsoleAppInputOpt 'showin' $ConsoleAppInputOpt_OPTIONAL 'Show window'
    ConsoleAppInputOpt 'dryrun' $ConsoleAppInputOpt_OPTIONAL 'Echo run command'
}

function VirtualizationStartCommand_getHelp
{
    cat<<'HELP'
    Starts a virtual machine by name, searching the name in the
    assets dir. The matched file contains info about
    virtual machine configuration
HELP
}

function VirtualizationStartCommand_execute
{
    Virtualization_prepare
    VirtualizationStartCommand_run
    Virtualization_dispose
}

function VirtualizationStartCommand_interact
{
    local retVal=0
    return $retVal
}

#######################
# private
#######################

function VirtualizationStartCommand_run
{
    local vmName="$(ConsoleAppInputArg_getArg 'vmname')"
    local cmdRun=$VirtualizationVar_CmdRun
    local keyVal=''

    ! libfile_fileExists $vmName &&
        liblog_error "Unexistent virtual machine of name: $vmName" &&
        return 1

    keyVal=$(VirtualizationStartCommand_getAsset "$vmName")
    eval "$keyVal"

    ! libfile_fileExists $HD_HDA &&
        liblog_error "HD_HDA file not exists: $HD_HDA" &&
        return 1

    ConsoleAppInputOpt_getOpt 'cdboot' || OPT_BOOTFROMCD=""
    ConsoleAppInputOpt_getOpt 'showin' && OPT_NOGRAPHIC=""
    ConsoleAppInputOpt_getOpt 'dryrun' && cmdRun='ConsoleApp_outputWrite'

    if ConsoleAppInputOpt_getOpt 'cdboot' ; then
        ! libfile_fileExists $CD_ISO &&
            liblog_error "CD_ISO file not exists: $CD_ISO" &&
            return 1
    fi

    liblog_info "Starting: $vmName"

    $cmdRun \
        $OPT_FLAGS \
        $OPT_RAMSIZE \
        -hda $HD_HDA \
        -cdrom $CD_ISO $OPT_BOOTFROMCD \
        $NET_PARAMS \
        $OPT_NOGRAPHIC \
        $OPT_DAEMONIZE &
}

