
function libunit_assertValueEquals()
{
    [[ $1 -eq $2 ]] &&
        libunit_passed "assertValueEquals OK $1 == $2 ($3)" ||
        libunit_failed "assertValueEquals FAIL $1 == $2 ($3)"
}

function libunit_assertStringEquals()
{
    [[ $1 == $2 ]] &&
        libunit_passed "assertStringEquals OK ($1) == ($2) ($3)" ||
        libunit_failed "assertStringEquals FAIL ($1) == ($2) ($3)"
}

function libunit_assertSuccess()
{
    [[ $1 == 0 ]] &&
        libunit_passed "assertSuccess OK ret:$1 == 0 ($2)" ||
        libunit_failed "assertSuccess FAIL ret:$1 == 0 ($2)"
}

function libunit_assertFailure()
{
    [[ $1 == 1 ]] &&
        libunit_passed "assertFailure OK ret:$1 == 1 ($2)" ||
        libunit_failed "assertFailure FAIL ret:$1 == 0 ($2)"
}

function libunit_assertNotExecuted()
{
    local more='This code should be not reached'
    echo "assertNotExecuted FAIL : $more"
}

function libunit_resetAssetionCounters()
{
    export libunit_TotalAsserts=0
    export libunit_PassedAsserts=0
    export libunit_FailedAsserts=0
}

function libunit_passed()
{
    ((libunit_TotalAsserts++))
    ((libunit_PassedAsserts++))
    echo "$1"
}

function libunit_failed()
{
    ((libunit_TotalAsserts++))
    ((libunit_FailedAsserts++))
    echo "$1"
}







