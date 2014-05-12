#!/bin/bash

source $(dirname $(realpath ${BASH_SOURCE[0]}))"/../vendor/autoload.sh"

function ConsoleApp_registerCommands()
{
    cat<<'COMMANDS'
AdminNewCommand
EmulatorAndroidX86StartCommand
VirtualizationMountCommand
VirtualizationStartCommand
COMMANDS
}
ConsoleApp_run $*



