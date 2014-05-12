
function BComposerBuildCache_getName()
{
    echo 'bcomposer:build-cache'
}

function BComposerBuildCache_getDescription()
{
    echo 'Builds cache collecting dependecies in one single file'
}

function BComposerBuildCache_getDefinition()
{
    :
}

function BComposerBuildCache_getHelp()
{
    cat<<'HELP'
    Builds a cache file copying all dependencies
    in a single file. Can be sourced alternatively to
    autoload.sh
HELP
}

function BComposerBuildCache_execute()
{
    BComposerBuildCache_build
}

function BComposerBuildCache_interact()
{
    local retVal=0
    return $retVal
}

#######################
# private
#######################

function BComposerBuildCache_isEmptyLineOrComment()
{
    local line="$1"
    [[ -z "$line" ]] && return 0
    [[ "$line" =~ ^# ]] && return 0
    return 1
}

function BComposerBuildCache_build()
{
    local line=''
    local srcDir=''
    local entries=''
    local entry=''

    local vendorDir=$BComposerVar_VendorDir
    local cacheFile=$BComposerVar_CacheFile
    local pathsFile=$BComposerVar_AutoloadPathsFile

    while read line
    do
        BComposerBuildCache_isEmptyLineOrComment "$line" && continue

        srcDir="$vendorDir/$line"
        ! libfile_dirExists "$srcDir" &&
            liblog_warn "BuildCache: Dir not exists:$srcDir" && continue

        entries=$(libfile_lsGrep "$srcDir" "sh$")
        [[ -z "$entries" ]] &&
            liblog_warn "BuildCache: Dir is empty:$srcDir" && continue

        for entry in $entries ; do

            if libfile_cat "$srcDir/$entry" >> "$cacheFile" ; then
                liblog_debug "Adding $srcDir/$entry to cache file"
            else
                liblog_error "Unable to write cache file"
                return
            fi
            #libfile_putContents "$vendorDir/autoload.paths" "$list" "FILE_APPEND"
        done

    done < "$pathsFile"

    liblog_info "OK, Cache file created: $cacheFile"
}
