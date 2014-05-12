
source $(dirname $(realpath ${BASH_SOURCE[0]}))"/../vendor/autoload.sh"

function BComposer_prepare
{
    local cwd=$PWD

    export BComposerVar_ProjectDir=$cwd

    export BComposerVar_ProjectName=$(libpath_getBasename $cwd)

    export BComposerVar_JSONFilename='bcomposer.json'

    export BComposerVar_VendorDir="$BComposerVar_ProjectDir/vendor"

    export BComposerVar_BuildDir="$BComposerVar_ProjectDir/build"

    export BComposerVar_AutoloadFile="$BComposerVar_VendorDir/autoload.sh"

    export BComposerVar_CacheFile="$BComposerVar_VendorDir/autoload.cache.sh"

    export BComposerVar_AutoloadPathsFile="$BComposerVar_VendorDir/autoload.paths"

    export BComposerVar_AssetsLoadLazyFile="$BComposerVar_VendorDir/autoload.assets.sh"

    export BComposerVar_AssetsLoadEmbeddedFile="$BComposerVar_VendorDir/autoload.assetsEmbed.sh"

    export BComposerVar_RequirementsQueue=''
}

function BComposer_dispose
{
    unset $(libenv_getVarsByPrefix BComposerVar_)
}

function ConsoleApp_registerCommands()
{
    cat<<COMMANDS
BComposerBuildAutoload
BComposerBuildCache
BComposerBuildStandalone
COMMANDS
}

BComposer_prepare
    ConsoleApp_prepare
    ConsoleApp_run $*
    ConsoleApp_dispose
BComposer_dispose


