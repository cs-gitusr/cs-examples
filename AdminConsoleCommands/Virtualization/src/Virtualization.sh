
function Virtualization_prepare
{
    export VirtualizationVar_CmdRun="qemu-kvm"

    export VirtualizationVar_CmdCreateImg="qemu-img"
}

function Virtualization_dispose
{
    unset $(libenv_getVarsByPrefix Virtualization_)
}
