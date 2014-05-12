
function BComposerBuildAutoloadDep_alreadyInstalled()
{
    local vendorDir=$BComposerVar_VendorDir
    local depName="$1"
    local depVers="$2"

    local depDir="$vendorDir/$depName"
    liblog_debug "Checking if Dependency is installed $depDir"

    libfile_dirExists "$depDir"
}

function BComposerBuildAutoloadDep_install()
{
    local depName="$1"
    local depVers="$2"

    local installMethods=(
        BComposerBuildAutoloadDep_installByCopy
        BComposerBuildAutoloadDep_installByGit
        BComposerBuildAutoloadDep_installBySvn
        )

    local commandInstall=''
    for commandInstall in ${installMethods[@]} ; do

        "${commandInstall}" "$depName" "$depVers" && return 0

    done

    liblog_error "Unable to install $depName with any of the provided"\
                 "install methods ${installMethods[@]}"
    return 1
}

function BComposerBuildAutoloadDep_installByCopy()
{
    local vendorDir=$BComposerVar_VendorDir
    local depName="$1"
    local depVers="$2"

    liblog_trace "Entering " $(libenv_getFuncname)

    ! libenv_varDefined "$BCOMPOSER_FSREPO" &&
        liblog_debug "No local repository found in BCOMPOSER_FSREPO" &&
        return 1

    liblog_trace "A local FS repository is defined by the var BCOMPOSER_FSREPO"

    local srcDir="$BCOMPOSER_FSREPO/$depName"
    local dstDir="$vendorDir/$depName"

    ! libfile_dirExists "$srcDir" &&
        liblog_info "package not found in the local FS repository" &&
        return 1

    liblog_trace "Creating vendor dir:$dstDir"
    libfile_mkdirRecursive "$dstDir"

    liblog_trace "Copying files from repo"

    #libfile_copyFiles "$srcDir" "$dstDir"
    local entries=$(libfile_lsVGrep "$srcDir" ".*vendor.*")
    local entry=''

    for entry in $entries; do
        cp -rf $srcDir/$entry $dstDir
    done

    return 0
}

function BComposerBuildAutoloadDep_installByGit() {

    liblog_debug "Entering " $(libenv_getFuncname)
}

function BComposerBuildAutoloadDep_installBySvn() {

    liblog_debug "Entering " $(libenv_getFuncname)
}

