
function RunIsolatedTest_sourceAutoloader()
{
    source @@TEST_VENDOR_DIR@@/autoloader.sh
}

function RunIsolatedTest_checkAPIMatchCallerAPI()
{
    local TEST_API_MATCHFAILED=@@TEST_API_MATCHFAILED@@
    local callerApi=@@BASHUNIT_APIVERSION@@
    local thisApi=$BashUnitCfg_APIVersion

    [[ "$callerApi" == "$thisApi" ]] &&
        return 0

    echo "$thisApi"
    exit $TEST_API_MATCHFAILED
}

function RunIsolatedTest_sourceTestFile()
{
    source @@TEST_FILENAMEFULLPATH@@
}

function RunIsolatedTest_exportSuite()
{
    @@TEST_EXPORTSUITE_CALL@@
}

function RunIsolatedTest_runTestSuiteArray()
{
    local testFun=''

    for testFun in @@TEST_SUITE_ARRAYNAME@@ ; do

        liblog_info "Running TEST:$testFun"

        libunit_resetAssetionCounters

        $testFun

        liblog_info "Total Assertions $libunit_TotalAsserts"\
                    "Passed $libunit_PassedAsserts"\
                    "Failed $libunit_FailedAsserts"
    done
}


function RunIsolatedTest_run()
{
    RunIsolatedTest_sourceAutoloader

    RunIsolatedTest_checkAPIMatchCallerAPI
    RunIsolatedTest_sourceTestFile
    RunIsolatedTest_exportSuite
    RunIsolatedTest_runTestSuiteArray
}


RunIsolatedTest_run
