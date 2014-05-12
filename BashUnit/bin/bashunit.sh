
source $(dirname $(realpath ${BASH_SOURCE[0]}))"/../vendor/autoload.sh"

function bashunit_run()
{
    BashUnit_prepare $PWD "tests"
    BashUnit_run $*
    BashUnit_dispose
}

bashunit_run $*
