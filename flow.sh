# Flow
# Diminish distracting applications to achieve flow, restoring them when done.

if [[ ! -d "$FLOW_DIR" ]]; then
    export FLOW_DIR=$(cd $(dirname ${BASH_SOURCE[0]:-$0}); pwd)
fi

flow() {
    local TARGET=$FLOW_DIR/target
    local SCRIPTDIR=$FLOW_DIR/flow.d
    
    case $1 in
        compile)
            [[ -d "$TARGET" ]] && return # FIXME: recompile when scripts modifed

            mkdir -p $TARGET
            local SCRIPTS=`find -L $SCRIPTDIR \( -type f -o -type l \) -regex '.*/[0-9][0-9][0-9][^/]*'`
            cat $FLOW_DIR/include/diminish.scpt $FLOW_DIR/include/common.scpt $SCRIPTS |osacompile -o $TARGET/Enter\ Flow.app
            cat $FLOW_DIR/include/restore.scpt $FLOW_DIR/include/common.scpt $SCRIPTS |osacompile -o $TARGET/Leave\ Flow.app
            ;;

        enter)
            flow compile
            $TARGET/Enter\ Flow.app/Contents/MacOS/applet
            ;;

        leave)
            flow compile
            $TARGET/Leave\ Flow.app/Contents/MacOS/applet
            ;;

        install)
            flow compile
            local APPLICATIONS=$HOME/Applications

            mkdir -p $APPLICATIONS
            rm -rf $APPLICATIONS/Enter\ Flow.app && ln -sh $TARGET/Enter\ Flow.app $APPLICATIONS
            rm -rf $APPLICATIONS/Leave\ Flow.app && ln -sh $TARGET/Leave\ Flow.app $APPLICATIONS

            printf "Installed \`Enter Flow.app\` and \`Leave Flow.app\`\n"
            ;;

        *)
            cat <<'EOF' |cut -c17-
                usage: flow COMMAND
                   
                Commands:
                  enter      Enter a state of flow by reducing distractions
                  leave      Leave a state of flow, restore communications, notifications, etc.

                  install    Install `Enter Flow.app` and `Leave Flow.app` to $HOME/Applications

EOF
            ;;
    esac
}
