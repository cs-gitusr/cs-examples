
function BComposerBuildStandalone_getName()
{
    echo 'bcomposer:build-standalone'
}

function BComposerBuildStandalone_getDescription()
{
    echo 'Build standalone command'
}

function BComposerBuildStandalone_getDefinition()
{
    ConsoleAppInputArg 'bin-script' $ConsoleAppInputArg_OPTIONAL 'Bin Script'
}

function BComposerBuildStandalone_getHelp()
{
    cat<<'HELP'
    Builds a standalone file for a given script, collecting dependencies
    and embedding all assets files recursicely

    The --bin-script argument specifies the path of the script
HELP
}

function BComposerBuildStandalone_execute()
{
    local binScript="$(ConsoleAppInputArg_getArg 'bin-script')"

    liblog_debug "binScript=$binScript"

    BComposerBuildStandalone_build "$binScript"
}

function BComposerBuildStandalone_interact()
{
    local retVal=0

    if [[ "$(ConsoleAppInputArg_getArg 'bin-script')" == "" ]] ; then
        local binScript=''
        read -p "Please insert bin-script: " -r binScript
        if ! libfile_isFile "$binScript" ; then
            return 1
        fi
        ConsoleAppInputArg_setArg 'bin-script' "$binScript"
    fi

    return $retVal
}

#######################
# private
#######################

function BComposerBuildStandalone_build()
{
    local vendorDir=$BComposerVar_VendorDir
    local buildDir=$BComposerVar_BuildDir
    local cacheFile=$BComposerVar_CacheFile
    local assetsFile=$BComposerVar_AssetsLoadEmbeddedFile
    local srcFile="$1"
    local dstDir=''
    local dstFile=''

    liblog_info "Creating standalone package for $srcFile on build dir"

    dstDir=$(libpath_getDirname "$srcFile")
    ! libfile_dirExists "$buildDir/$dstDir" &&
        liblog_debug "Creating '$buildDir/$dstDir' dir" &&
        libfile_mkdirRecursive "$buildDir/$dstDir"

    ##
    # Create the file
    #
    dstFile="$(libpath_getBasename "$srcFile")"
    if libfile_cat "$cacheFile" "$assetsFile" "$srcFile" > "$buildDir/$dstDir/$dstFile" ; then
        liblog_info "OK, Standalone File Created under: $buildDir/$dstDir/$dstFile"
    fi

    ##
    # Comment out the source "../vendor/autoload.sh"
    #
    local lineNum=$(awk '/^((\s*source\s)|(^\s*\.\s)).*autoload.*/ {print NR}' "$buildDir/$dstDir/$dstFile")

    if libstr_isEmpty "$lineNum" ; then
        liblog_debug "The file didn't contained the source autoload statement"
    else
        liblog_debug "Commenting the source autoload.sh statement at line $lineNum"
        # -i if print on stdout
        sed  -i "${lineNum}s/.*/#&/" "$buildDir/$dstDir/$dstFile"
    fi
}
