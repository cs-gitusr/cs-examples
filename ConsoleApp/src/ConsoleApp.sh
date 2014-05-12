
function ConsoleApp_prepare
{
    export ConsoleAppVar_ArgsLine=''

    export ConsoleAppVar_Output=''

    export ConsoleAppVar_Version='0.9'
}

function ConsoleApp_dispose
{
    unset $(libenv_getVarsByPrefix ConsoleAppVar_)
}

function ConsoleApp_run()
{
    local cmdName='--nocmd'

    if [[ $# -gt 0 ]] ; then
        cmdName=$1
    fi

    case "$cmdName" in

        -h|--h|-help|--help|-l|--l|-list|--list|--nocmd)
            ConsoleApp_list
            ;;

        *)
            ConsoleApp_selectAndRunCommand $*
            ;;
    esac
}

function ConsoleApp_setArgsLine()
{
    export ConsoleAppVar_ArgsLine="$*"
}

function ConsoleApp_getArgsLine()
{
    echo "$ConsoleAppVar_ArgsLine"
}

function ConsoleApp_outputWrite
{
    local curr=$ConsoleAppVar_Output
    export ConsoleAppVar_Output="$curr$*"
}

function ConsoleApp_outputRead
{
    echo "$ConsoleAppVar_Output"
}

#######################
# private
#######################

function ConsoleApp_klassImplementsCommandInterface
{
    local klass="$1"

    libenv_implementsFunctions \
        "$klass" \
        "$(ConsoleAppInterface_getInterface)" &&
        return 0

    liblog_warn "$klass not implements all ConsoleApp Interface functions" &&
    return 1
}

function ConsoleApp_selectAndRunCommand()
{
    local search="$1"; shift
    ConsoleApp_setArgsLine $*

    for klass in $(ConsoleApp_registerCommands) ; do

        ! ConsoleApp_klassImplementsCommandInterface "$klass" &&
            continue

        ConsoleAppKlass_setCommand $klass

        local cmdName=$(ConsoleAppKlass_getName)

        if [[ "$cmdName" == "$search" ]] ; then

            liblog_info "Found [$cmdName] [$klass]"

            if [[ "$1" == "--help" ]] ; then
                local definition=$(ConsoleAppKlass_getDefinition)
                local help=$(ConsoleAppKlass_getHelp)
                echo "Command Help:"
                echo "$definition"
                echo "$help"
                return 0
            fi

            if ! ConsoleApp_argsMatchDefinition $* ; then

                if ! ConsoleAppKlass_interact ; then
                    echo "not interact"
                    return 1
                fi

            fi
            ConsoleAppKlass_execute
        fi
    done
}

function ConsoleApp_list()
{
    local cmdlist=""
    local cmdnum=0
    local klass=""

    local header=$(ConsoleAppUtils_getHelpHeader)
    echo "$header"

    for klass in $(ConsoleApp_registerCommands) ; do

        ! ConsoleApp_klassImplementsCommandInterface "$klass" &&
            continue

        ConsoleAppKlass_setCommand $klass
        local cmdName=$(ConsoleAppKlass_getName)
        local cmdDesc=$(ConsoleAppKlass_getDescription)

        cmdlist=$cmdlist$(printf "\n%3s %-35s" "" "$cmdName")"$cmdDesc"

        ((cmdnum++))
    done

    local help=$(ConsoleAppUtil_getHelpBody "$cmdnum" "$cmdlist")
    echo "$help"
}

function ConsoleApp_getArgNameOccurrenceCount()
{
    local argName="$1"
    local argsLine="$2"
    local count="0"

    count=$(grep -o "\-\-$argName=" <<< "$argsLine" | wc -l)
    echo $count
}

function ConsoleApp_getOptNameOccurrenceCount()
{
    local optName="$1"
    local argsLine="$2"
    local count="0"

    count=$(grep -o "\-\-$optName" <<< "$argsLine" | wc -l)
    echo $count
}

function ConsoleApp_argsMatchDefinition()
{
    local argsLine="$(ConsoleApp_getArgsLine)"
    local retVal=0

    local lines="$(ConsoleAppKlass_getDefinition)"
    local line=''

    [[ "$lines" == "" ]] &&
        return $retVal

    while read -r line; do

        local argName=$(libstr_trim '"' $(libstr_getDQStringAt 0 "$line"))
        local argFlag=$(libstr_trim '"' $(libstr_getDQStringAt 1 "$line"))
        local argDesc=$(libstr_trim '"' $(libstr_getDQStringAt 2 "$line"))

        local count="0"
        local skip=0

        case "$argFlag" in
            ConsoleAppInputArg_REQUIRED)
                count=$(ConsoleApp_getArgNameOccurrenceCount "$argName" "$argsLine")
                skip=0

                if (( count == 0 )) ; then
                    liblog_error "Argument '--${argName}' is mandatory [$count]"
                    skip=1
                elif (( count > 1 )) ; then
                    liblog_error "Argument '--${argName}' was provided more than once [$count]"
                    skip=1
                fi

                [[ skip -eq 1 ]] && continue

                local argValue=$(sed -n 's/.*--'$argName'=\(.*\)\( \|$\).*/\1/p' <<< "$argsLine")
                liblog_info "Argument '--${argName}' is [$argValue]"
            ;;

            ConsoleAppInputArg_OPTIONAL)
                count=$(ConsoleApp_getArgNameOccurrenceCount "$argName" "$argsLine")
                skip=0

                if (( count > 1 )) ; then
                    liblog_error "Argument '--${argName}' was provided more than once [$count]"
                    skip=1
                fi
            ;;

            ConsoleAppInputOpt_REQUIRED)
                count=$(ConsoleApp_getOptNameOccurrenceCount "$argName" "$argsLine")
                skip=0

                if (( count == 0 )) ; then
                    liblog_error "Option '--${argName}' is mandatory [$count]"
                    skip=1
                elif (( count > 1 )) ; then
                    liblog_warn "Option '--${argName}' was provided more than once [$count]"
                    skip=1
                fi

                [[ skip -eq 1 ]] && continue

                liblog_info "Option '--${argName}' is set"
            ;;

            ConsoleAppInputOpt_OPTIONAL)
                count=$(ConsoleApp_getOptNameOccurrenceCount "$argName" "$argsLine")
                skip=0

                if (( count == 0 )) ; then
                    skip=1
                elif (( count > 1 )) ; then
                    liblog_warn "Option '--${argName}' was provided more than once [$count]"
                    skip=1
                fi

                [[ skip -eq 1 ]] && continue
                #count==1
                liblog_info "Option '--${argName}' is set"
            ;;

            *)
                liblog_error "Unknown argument flag '$argFlag'"
            ;;

        esac

    done <<< "$lines"

    return $retVal
}


