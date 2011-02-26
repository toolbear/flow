# Flow
# Diminish distracting applications to achieve flow, restoring them when done.

if [ ! -d "$FLOW_DIR" ]; then
    export FLOW_DIR=$(cd $(dirname ${BASH_SOURCE[0]:-$0}); pwd)
fi

flow() {
    trap 'local error=$?; trap - ERR; return $error' ERR
    trap 'trap - RETURN; set +E' RETURN
    set -E

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
  install    Install `Enter Flow.app` and `Leave Flow.app` to $HOME/Applications
EOF
#
#  enter    Enter a state of flow by reducing distractions
#  leave    Leave a state of flow, restore communications, notifications, etc.
#EOF
}

function install() {
    local APPLICATIONS=$HOME/Applications
    local TARGET=$FLOW_DIR/target

    mkdir -p $TARGET
    local SCRIPTS=`flow_scripts`
    cat $FLOW_DIR/include/diminish.scpt $FLOW_DIR/include/common.scpt $SCRIPTS |osacompile -o $TARGET/Enter\ Flow.app
    cat $FLOW_DIR/include/restore.scpt $FLOW_DIR/include/common.scpt $SCRIPTS |osacompile -o $TARGET/Leave\ Flow.app

    mkdir -p $APPLICATIONS
    rm -rf $APPLICATIONS/Enter\ Flow.app && ln -sh $TARGET/Enter\ Flow.app $APPLICATIONS
    rm -rf $APPLICATIONS/Leave\ Flow.app && ln -sh $TARGET/Leave\ Flow.app $APPLICATIONS

    printf "Installed \`Enter Flow.app\` and \`Leave Flow.app\`\n"
}

function flow_scripts() {
    find -L $SCRIPTDIR \( -type f -o -type l \) -regex '.*/[0-9][0-9][0-9][^/]*'
}
