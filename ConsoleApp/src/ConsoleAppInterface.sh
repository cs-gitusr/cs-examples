
function ConsoleAppKlass_setCommand()
{
    export KLASS="$1"
}

function ConsoleAppInterface_getInterface()
{
    local interface=$(cat<<INTERFACE
getName
getDescription
getDefinition
getHelp
execute
INTERFACE
    )
    echo "$interface"
}

function ConsoleAppKlass_getName()
{
    ${KLASS}_getName
}

function ConsoleAppKlass_getDescription()
{
    ${KLASS}_getDescription
}

function ConsoleAppKlass_getDefinition()
{
    ${KLASS}_getDefinition
}

function ConsoleAppKlass_getHelp()
{
    ${KLASS}_getHelp
}

function ConsoleAppKlass_execute()
{
    ${KLASS}_execute
}

function ConsoleAppKlass_interact()
{
    ${KLASS}_interact
}


