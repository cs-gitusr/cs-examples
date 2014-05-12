
function Autoload_loadAllFilesInPath()
{
    local srcDir="$1"
    local filename=''
    local filelist=''

    filelist=$(ls $srcDir|grep "sh$")
    [[ -z "$filelist" ]] &&
        echo "Autoload WARNING:Dir is empty:$srcDir" &&
        continue

    for entry in $filelist ; do

        filename="$srcDir/$entry"

        source "$filename"
    done
}

function Autoload_loadDependencies()
{
    local line=''
    local entry=''
    local srcDir=''

    local autoloadfile=$(realpath "${BASH_SOURCE[0]}")
    local vendorDir=$(dirname "$autoloadfile")

    local pathsFile="$vendorDir/autoload.paths"
    while read line
    do
        [[ -z "$line" ]] && continue

        [[ "$line" =~ ^# ]] && continue

        srcDir="$vendorDir/$line"
        [[ ! -d "$srcDir" ]] &&
            echo "Autoload WARNING:Dir not exists:$srcDir" &&
            continue

        Autoload_loadAllFilesInPath "$srcDir"

    done < "$pathsFile"
}

function Autoload_loadAssets()
{
    local autoloadfile=$(realpath "${BASH_SOURCE[0]}")
    local vendorDir=$(dirname "$autoloadfile")
    local assetsFile="autoload.assets.sh"

    source "$vendorDir/$assetsFile"
}

Autoload_loadDependencies
Autoload_loadAssets
