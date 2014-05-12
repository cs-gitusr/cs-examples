
function BComposerBuildAutoloadReq_enqueue()
{
    local queue="$BComposerVar_RequirementsQueue"
    local add=$'\n'
    local check=''

    [[ -z $queue ]] && add=''

    check="$1##$2"
    liblog_debug "Enqueuing check for $check"

    export BComposerVar_RequirementsQueue="$queue${add}$check"
}

function BComposerBuildAutoloadReq_queueRemoveDuplicates()
{
    local queue="$BComposerVar_RequirementsQueue"

    queue=$(echo "$queue" | sort | uniq)

    export BComposerVar_RequirementsQueue="$queue"
}

function BComposerBuildAutoloadReq_runRequirementsQueue()
{
    liblog_info "Checking All Requirements .."

    #BComposerBuildAutoloadReq_queueRemoveDuplicates

    local queue="$BComposerVar_RequirementsQueue"
    local check=''
    while read -r check; do

        liblog_info "Checking $check"
        #BComposerBuildAutoloadReq_checkBash "$reqName" "$reqVers"

    done <<< "$queue"
}

function BComposerBuildAutoloadReq_checkBash()
{
    local reqName="$1"
    local reqVers="$2"

    liblog_info "OK, shell:" "$reqName" "$reqVers"
}
