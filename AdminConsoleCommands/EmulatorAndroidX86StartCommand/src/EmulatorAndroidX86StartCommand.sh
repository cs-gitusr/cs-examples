
function EmulatorAndroidX86StartCommand_getName
{
    echo 'emu:android-start'
}

function EmulatorAndroidX86StartCommand_getDescription
{
    echo 'Starts the android emulator'
}

function EmulatorAndroidX86StartCommand_getDefinition
{
    ConsoleAppInputArg 'avd-name' $ConsoleAppInputArg_REQUIRED 'The avd name'
    ConsoleAppInputArg 'ram-size' $ConsoleAppInputArg_OPTIONAL 'Ram size'
    ConsoleAppInputArg 'remote-ip' $ConsoleAppInputArg_OPTIONAL 'Ip to listen for redir'
}

function EmulatorAndroidX86StartCommand_getHelp
{
    cat<<'HELP'
    Starts the Android emulator.

    Notes
    --remote-ip: when provided, runs the redir program to
    accept remote connections from the given ip.
    It is useful when emulator host uses wifi
    card, since kernel cannot do pat/nat is that case

HELP
}

function EmulatorAndroidX86StartCommand_execute
{
    EmulatorAndroidX86StartCommand_run
}

function EmulatorAndroidX86StartCommand_interact
{
    local retVal=0
    return $retVal
}

#######################
# private
#######################

function EmulatorAndroidX86StartCommand_run
{
    local binEmu='$ADT_HOME/sdk/tools/emulator'
    local binRedir=redir

    local avdName=$(ConsoleAppInputArg_getArg 'avd-name')
    local ramSize=$(ConsoleAppInputArg_getArg 'ram-size')
    local remoteIp=$(ConsoleAppInputArg_getArg 'remote-ip')

    if [[ "$ramSize" == "" ]] ; then
        ramSize=512
    fi

    if [[ "$remoteIp" != "" ]] ; then
        liblog_info "Starting redir for ip: $remoteIp"
        $binRedir --laddr=$remoteIp --lport=8899 --caddr=127.0.0.1 --cport=7799 &
        $binRedir --laddr=$remoteIp --lport=5554 --caddr=127.0.0.1 --cport=5554 &
        $binRedir --laddr=$remoteIp --lport=5555 --caddr=127.0.0.1 --cport=5555 &
    fi

    liblog_info "Running emulator: $binEmu"
    $binEmu -avd $avdName -qemu -m $runSize -enable-kvm
}


