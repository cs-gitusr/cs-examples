
function BComposerBuildAutoload_getName()
{
    echo 'bcomposer:build-autoload'
}

function BComposerBuildAutoload_getDescription()
{
    echo 'Build vendor/autoload* stuff'
}

function BComposerBuildAutoload_getDefinition()
{
    :
}

function BComposerBuildAutoload_getHelp()
{
    cat<<'HELP'
    Builds vendor dir with autoload.sh and related stuff
HELP
}

function BComposerBuildAutoload_execute()
{
    BComposerBuildAutoload_build
}

function BComposerBuildAutoload_interact()
{
    local retVal=0
    return $retVal
}

#######################
# private
#######################

function BComposerBuildAutoload_build()
{
    BComposerBuildAutoload_isProjectRoot || return

    BComposerBuildAutoload_deleteVendorDir

    BComposerBuildAutoload_createVendorDir

    BComposerBuildAutoload_parseJSONFile "$BComposerVar_JSONFilename" "../"

    BComposerBuildAutoload_writeAutoload

    BComposerBuildAutoloadReq_runRequirementsQueue
}

function BComposerBuildAutoload_isProjectRoot()
{
    local jsonFile=$BComposerVar_JSONFilename

    ! libfile_isFile "$BComposerVar_JSONFilename" &&
        liblog_error "$jsonFile not found, are you in the project root dir?" &&
        return 1
    return 0
}

function BComposerBuildAutoload_createVendorDir()
{
    local vendorDir=$BComposerVar_VendorDir

    liblog_trace "Creating vendor Dir: $vendorDir"

    ! libfile_dirCreate $vendorDir &&
        liblog_error "Unable to create Vendor dir"
}

function BComposerBuildAutoload_deleteVendorDir()
{
    local vendorDir=$BComposerVar_VendorDir

    liblog_trace "Deleting vendor Dir: $vendorDir"

    ! libfile_dirDelete $vendorDir
        liblog_error "Unable to delete Vendor dir"
}

function BComposerBuildAutoload_parseJSONFile()
{
    local jsonFile="$1"
    local prefixPath="$2"

    liblog_debug ""
    liblog_debug "Processing JSON $jsonFile"
    liblog_debug ""

    local json=$(libfile_getContents $jsonFile)
    local tree=$(JSONTree_getAsTree "$json")

    foreachLine "$(JSONTree_getSubTree "require" "$tree")" \
        BComposerBuildAutoload_parseRequireLine

    foreachLine "$(JSONTree_getSubTree "require-dev" "$tree")" \
        BComposerBuildAutoload_parseRequireLine

    foreachLine "$(JSONTree_getSubTree "autoload" "$tree")" \
        BComposerBuildAutoload_parseAutoloadLine "$prefixPath"

    BComposerBuildAutoload_updateAssetsLoaders "$prefixPath"
}

function BComposerBuildAutoload_parseRequireLine()
{
    local line="$1"
    local reqName=$(libstr_getDQStringAt 1 "$line")
    local reqVers=$(libstr_getDQStringAt 2 "$line")
    local depName=$(libstr_trim '"' "$reqName")
    local depVers=$(libstr_trim '"' "$reqVers")
    BComposerBuildAutoload_manageRequirementOrDependency "$depName" "$depVers"
}

function BComposerBuildAutoload_parseAutoloadLine()
{
    local line="$1"
    local prefixPath="$2"

    local namespaceDir=$(libstr_trim '"' $(libstr_getWordAt 2 "$line"))
    local srcDir=$(libstr_trim '"' $(libstr_getWordAt 3 "$line"))

    local pathEntry="$prefixPath/$srcDir/$namespaceDir"
    libfile_putContents "$BComposerVar_AutoloadPathsFile" "$pathEntry" "FILE_APPEND"
}

function BComposerBuildAutoload_manageRequirementOrDependency()
{
    local reqName="$1"
    local reqVers="$2"

    case "$reqName" in
        bash*)

            BComposerBuildAutoloadReq_enqueue "$reqName" "$reqVers"
            ;;

        *)
            if libstr_equals "$depName" "$BComposerVar_ProjectName" ; then
                liblog_debug "SKIPPING $depName SELF REFERENCE in deps"
                return
            fi

            if BComposerBuildAutoloadDep_alreadyInstalled "$depName" "$depVers" ; then
                liblog_debug "SKIPPING $depName already installed"
                return
            fi

            liblog_info "Trying to install dependency -->" "$reqName" "$reqVers"

            if BComposerBuildAutoloadDep_install "$reqName" "$reqVers" ; then

                local vendorDir=$BComposerVar_VendorDir
                BComposerBuildAutoload_parseJSONFile "$vendorDir/$reqName/bcomposer.json" "$reqName"

                liblog_info ""
                liblog_info "OK, $reqName and its dependencies have been installed"
                liblog_info ""
            fi
            ;;
    esac
}

function BComposerBuildAutoload_updateAssetsLoaders()
{
    #local prefixPath=$(libpath_getBasename "$1")
    #local depName=$prefixPath

    local prefixPath=$1
    local depName=$(libpath_getBasename "$1")

    if libstr_equals "$depName" ".." ; then
        depName=$(libpath_getBasename "$PWD")
    fi

    BComposerBuildAutoload_updateAssetsLazyLoad "$depName"

    BComposerBuildAutoload_updateAssetsEmbeddedLoad "$depName" "$prefixPath"
}

function BComposerBuildAutoload_updateAssetsLazyLoad()
{
    local depName="$1"
    local vendorDir=$BComposerVar_VendorDir
    local funcGetAsset="
function ${depName}_getAssetFile()
{
    cat $vendorDir/$prefixPath/assets/\$1
}
"
    libfile_putContents $BComposerVar_AssetsLoadLazyFile "$funcGetAsset" "FILE_APPEND"
}

function BComposerBuildAutoload_updateAssetsEmbeddedLoad()
{
    local depName="$1"
    local prefixPath="$2"

    local header="
function ${depName}_getAssetFile()
{
    local retVal=''

    case \$1 in
"
    local footer='
    esac

    echo "$retVal"
}
'
    ##
    # Write the case entry embedding the file
    #

    local assetsDir="$BComposerVar_VendorDir/$prefixPath/assets"

    function writeCaseEntry() {
        local assetFile="$1"
        local md5sum=$(libenc_calcMD5OfFile "$assetsDir/$assetFile")

        cat <<EOF >> $BComposerVar_AssetsLoadEmbeddedFile
        $assetFile)
            retVal=\$(cat<<'HARD_TO_MATCH_${md5sum}'
$(cat $assetsDir/$assetFile)
HARD_TO_MATCH_${md5sum}
)
            ;;
EOF
    }

    echo "$header" >> $BComposerVar_AssetsLoadEmbeddedFile
    foreachFile "$assetsDir" writeCaseEntry
    echo "$footer" >> $BComposerVar_AssetsLoadEmbeddedFile
}

function BComposerBuildAutoload_writeAutoload()
{
    local fileName=$BComposerVar_AutoloadFile
    local fileContent=$(BComposerBuildAutoload_getAssetFile "autoload.tpl.sh")

    libfile_putContents "$fileName" "$fileContent"
}
