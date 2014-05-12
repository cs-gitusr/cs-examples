

function BashUnit_prepare()
{
    export BashUnitCfg_FilenamePattern="^Test"

    export BashUnitCfg_SetupOnceFuncName="setUp"

    export BashUnitCfg_TearDownFuncName="tearDown"

    export BashUnitCfg_TestSuiteArrayName="TEST_SUITE"

    export BashUnitCfg_APIVersion="1.0"

    export BashUnitCfg_APIUnmatchedRetVal="111"

    ## Project root dir
    #
    export BashUnitVars_ProjectRoot=$PWD

    ## Name of the dir under the proj root to search for tests
    #
    export BashUnitVars_TestsDir="tests"

    ##
    # Name of the xml file under the proj root to load conf
    #
    export BashUnitVars_XmlFilename="bashunit.xml.dist"

    ##
    # Current Test dir being processed
    #
    export BashUnitVars_CurrDir=''

    ##
    # Current Test file being processed
    #
    export BashUnitVars_CurrFile=''
}

function BashUnit_onError()
{
    echo "An Error Happened $?"
    libenv_debugBacktrace
    BashUnit_dispose
}

function BashUnit_beforeRunChecks()
{
    local xmlFile=${BashUnitVars_XmlFilename}
    local testsDir=${BashUnitVars_TestsDir}

    ! libfile_fileExists "$xmlFile" &&
        liblog_error "XML not found, are you sure you are in the project root?" &&
        return 1

     ! libfile_dirExists "$testsDir" &&
        liblog_error "No tests dir found, are you sure this is the project root?" &&
        return 1

    return 0
}

function BashUnit_run()
{
    ! BashUnit_beforeRunChecks &&
        return 1

    BashUnit_enterSubDir ${BashUnitVars_TestsDir}
}

function BashUnit_enterSubDir()
{
    local testsDir=$1
    local filePattern=$BashUnitCfg_FilenamePattern

    liblog_debug "Entering $1"
    libenv_chDir "$testsDir"
    BashUnitVars_CurrDir=$(libenv_getCWD)

    local entries=$(libfile_lsGrep "./" "$filePattern")
    local entry=''

    for entry in $entries ; do

        if libfile_isFile "$entry" ; then
            BashUnit_runFile "$entry"

        elif libfile_isDir "$entry" ; then
            continue
            BashUnit_enterSubDir "$entry"

        fi

    done
}

function BashUnit_runFile()
{
    local fileName=$1

    liblog_info "Running $fileName"
    BashUnitVars_CurrFile="$fileName"

    local suiteSuffix=$BashUnitCfg_TestSuiteArrayName
    local klassName=$(libpath_stripExt $fileName)
    local exportSuiteFunc="${klassName}_exportSuite"
    local suiteArrayName="${klassName}_TEST_SUITE"

    source "$BashUnitVars_CurrDir/$fileName"

    if libenv_functionDefined "$exportSuiteFunc" ; then
        # In this case the test suite to run was explicitly
        # decared by the user
        liblog_info "Found explicitly defined export"\
                    "suite function $exportSuiteFunc"

        $exportSuiteFunc

        ! libenv_arrDefinedOrEmpty "$suiteArrayName"  &&
            liblog_error "Suite $suiteArrayName not found or empty" &&
            return

        liblog_info "Found test suite $suiteArrayName"

        local suiteFuncDecl=''
        BashUnit_runSuiteArray "$suiteArrayName" "$suiteFuncDecl"

    else
        # In this case the test suite is build automatically
        # with all the test functions found

        liblog_info "Building test suite $suiteArrayName with all"\
                    "test functions declared"

        local allFuncs=$(libenv_getFunctionsByPrefix "${klassName}_test")
        eval "$suiteArrayName=($allFuncs)"

        ! libenv_arrDefinedOrEmpty "$suiteArrayName"  &&
            liblog_error "No test functions were found" &&
            return

        local suiteFuncDecl="$suiteArrayName=($allFuncs)"
        BashUnit_runSuiteArray "$suiteArrayName" "$suiteFuncDecl"
    fi
}

function BashUnit_runSuiteArray()
{
    local suiteName="$1"
    local suiteFuncDecl="$2"

    #libarr_dump $suiteName

    ## Build Clean Env ##
    #
    # If the bashunit.sh is running as standalone program, maybe it was built
    # with embedded dependencies older or more recent than the preject ones,
    # so run a clean env and load project dependencies, avoiding namespace
    # pollution with those embedded in the bashunit standalone. Note that
    # the the assertions follow the projects BasUnit dep

    ##
    # bashunitsh app and the BashUnit lib defined in the bcomposer.json file
    # can also be different versions, but COMMUNICATION_API version must match
    #

    local callerApiVersion="$BashUnitCfg_APIVersion"
    local apiUnmatchedReturnValue="$BashUnitCfg_APIUnmatchedRetVal"
    local fileNameFullPath="$BashUnitVars_CurrDir/$BashUnitVars_CurrFile"

    local tpl=$(BashUnit_getAssetFile "templateRunIsolatedTest.sh")
    MiniTemplateEngine_dataProvider=(
        @@TEST_VENDOR_DIR@@="$BashUnitVars_ProjectRoot/vendor"
        @@BASHUNIT_APIVERSION@@="$callerApiVersion"
        @@TEST_API_MATCHFAILED@@="$apiUnmatchedReturnValue"
        @@TEST_FILENAMEFULLPATH@@="$fileNameFullPath"
        @@TEST_SUITE_ARRAYNAME@@="\${$suiteName[@]}"
        @@TEST_EXPORTSUITE_CALL@@="${klassName}_exportSuite"
    )
    local tplOut=$(MiniTemplateEngine_process "$tpl")
    unset MiniTemplateEngine_dataProvider

    local cleanEnv="$suiteFuncDecl $tplOut"
    echo "$cleanEnv" > "tpl_$suiteName.sh"

    ##
    # Run in a new clean  enviroment
    # Do not inline "out" declaration with the bash call, or
    # exit status will be lost
    #
    local out=''
    out=$(bash <<< "$cleanEnv")
    local exitStatus=$?

    liblog_debug "Running isolated environment returned $exitStatus"

    if [[ $exitStatus -eq $apiUnmatchedReturnValue ]] ; then

        liblog_error "The API version of the BashUnit lib [$out] is different"\
                     "from the bashunit.sh app in use [$callerApiVersion]"

    else
        echo "$out--$exitStatus"
    fi
}

function BashUnit_dispose()
{
    unset $(libenv_getVarsByPrefix BashUnitVars_)
}

