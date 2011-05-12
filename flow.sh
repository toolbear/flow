#!/usr/bin/env bash

if [ ! -d "$FLOW_DIR" ]; then
    export FLOW_DIR=$(cd $(dirname ${BASH_SOURCE[0]:-$0}); pwd)
fi

flow() {
    SCRIPTDIR=$FLOW_DIR/flow.d
    if [ -d $SCRIPTDIR ] ; then
        local action
        case $1 in
            install)
                install
                ;;
            *)
                usage
                ;;
        esac

        printf "\n"
    fi
}

function usage() {
    cat <<'EOF'
usage: flow COMMAND

Commands:
  install  Install `Enter Flow` and `Leave Flow` to $HOME/Applications
EOF
#
#  enter    Enter a state of flow by reducing distractions
#  leave    Leave a state of flow, restore communications, notifications, etc.
#EOF
}

function install() {
    local APPLICATIONS='$HOME/Applications'
    local TARGET='$FLOW_DIR/target'

    mkdir -p $TARGET
    local SCRIPTS=`flow_scripts`
    cat $FLOW_DIR/include/diminish.scpt $FLOW_DIR/include/common.scpt $SCRIPTS |osacompile -o $TARGET/Enter\ Flow.app
    cat $FLOW_DIR/include/restore.scpt $FLOW_DIR/include/common.scpt $SCRIPTS |osacompile -o $TARGET/Leave\ Flow.app

    mkdir -p $APPLICATIONS
    ln -sf $TARGET/Enter\ Flow.app $APPLICATIONS/Enter\ Flow.app
    ln -sf $TARGET/Leave\ Flow.app $APPLICATIONS/Leave\ Flow.app

    printf "Installed \`Enter Flow\` and \`Leave Flow\` to $APPLICATIONS\n"
}

function flow_scripts() {
    find -L $SCRIPTDIR \( -type f -o -type l \) -regex '.*/[0-9][0-9][0-9][^/]*'
}
