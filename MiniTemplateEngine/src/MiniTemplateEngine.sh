
##
#
# This is the global var for declaring the placeholder. You
# need to fill it before calling the MiniTemplateEngine_process
# DO NOT assign to placeholders multi line string
#
# $Example
#    anotherVar="Newline are not allowed"
#    MiniTemplateEngine_dataProvider=(
#        @@GENERATED_BY@@="${BASH_SOURCE[0]}"
#        @@SIMPLE_VAR@@="Template Hello"
#        @@ANOTHER_VAR@@="$anotherVar"
#    )
#    local tplOut=$(MiniTemplateEngine_process "$myTemplate")
#    echo "$tplOut"
#
MiniTemplateEngine_dataProvider=()

function MiniTemplateEngine_dataProviderEmpty()
{
    [[ ! -n "${MiniTemplateEngine_dataProvider+1}" ]] && return 0
    return 1
}
##
# Replaces in a template the given placeholders, previously
# defined in the MiniTemplateEngine_dataProvider
#
# $1 string The template string
#
# $Example
#
#    MiniTemplateEngine_dataProvider=(
#        @@GENERATED_BY@@="${BASH_SOURCE[0]}"
#        @@SIMPLE_VAR@@="Template Hello"
#        @@CMD_PLACEHOLDER@@="simpleFunction"
#    )
#    local tplOut=$(MiniTemplateEngine_process "$myTemplate")
#    echo "$tplOut"
#
function MiniTemplateEngine_process()
{
    MiniTemplateEngine_dataProviderEmpty &&
        return

    local sedLine='sed'

    local sub=''
    for sub in "${MiniTemplateEngine_dataProvider[@]}" ; do
        sedLine="$sedLine -e 's=$sub=g'"
    done
    #echo "$sedLine"
    eval $sedLine <<< "$1"
}

##
# Sanitizes values for the template engine dataProvider
#
# $1 string String to sanitize
#
# $Example
#
#   #Note the presence of '=' and parentesis '(' ')'
#   myUnsaneVar="some=data ( other )"
#   mySaneVar=$(MiniTemplateEngine_sanitize "$myUnsaneVar")
#
#    MiniTemplateEngine_dataProvider=(
#        @@MY_VAR@@="$mySaneVar"
#    )
#
function MiniTemplateEngine_sanitize()
{
    sed -e 's/=/\\=/g' -e 's/(/\\(/g' -e 's/)/\\)/g' <<< "$1"
}


