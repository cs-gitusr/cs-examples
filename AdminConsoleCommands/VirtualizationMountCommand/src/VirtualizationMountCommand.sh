
function VirtualizationMountCommand_getName
{
    echo 'vm:mount'
}

function VirtualizationMountCommand_getDescription
{
    echo 'Mount Virtual Machine HD and disk utils'
}

function VirtualizationMountCommand_getDefinition
{
    ConsoleAppInputArg 'disk-path' $ConsoleAppInputArg_REQUIRED 'Path of the file'
    ConsoleAppInputArg 'fs-type' $ConsoleAppInputArg_REQUIRED 'Filesystem type'
    ConsoleAppInputOpt 'probe-vmdk' $ConsoleAppInputOpt_OPTIONAL 'Search initial sector automatically'
}

function VirtualizationMountCommand_getHelp
{
    cat<<'HELP'
    Mounts a disk file. Can also search the sector in a vmdk file that is
    recognized as the mount point for a certain fs
HELP
}

function VirtualizationMountCommand_execute
{
    Virtualization_prepare
    VirtualizationMountCommand_run
    Virtualization_dispose
}

function VirtualizationMountCommand_interact
{
    local retVal=0
    return $retVal
}

#######################
# private
#######################

function VirtualizationMountCommand_run
{
    local startOffset=208845
    local endOffset=300845
    local fsType=ext3
    local diskName=$2
    local mountDir='./mnt/';

    if ! [ -d "mnt" ] ; then
          mkdir mnt
    fi

    local i=$startOffset
    while [ $i -le $endOffset ] ; do

        mount -t $fsType $diskName $mountDir -o ro,loop,offset=$(($i*512))

        if [ $? -eq 0 ] ; then
            echo "#######################################"
            echo "- Mounted at sector $i -"
            echo "#######################################"
            break
        fi

        i=$(($i+1))
    done

}

