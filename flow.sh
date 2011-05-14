# Flow
# Diminish distracting applications to achieve flow, restoring them when done.

if [[ ! -d "$FLOW_DIR" ]]; then
    export FLOW_DIR=$(cd $(dirname ${BASH_SOURCE[0]:-$0}); pwd)
fi

flow() {
    local TARGET="$FLOW_DIR/target"
    local SCRIPTDIR="$FLOW_DIR/flow.d"
    local MANAGED="$FLOW_DIR/managed"

    local CMD=$1; shift
    case $CMD in
        compile)
            [[ -d "$TARGET" ]] && return # FIXME: recompile when scripts modifed
            flow force-compile
            ;;

        force-compile)
            mkdir -p $TARGET
            local SCRIPTS=$(find -L "$MANAGED" \( -type f -o -type l \) -regex '.*/[0-9][0-9][0-9][^/]*')
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

        manage)
            mkdir -p "$MANAGED"
            local APP=$1; shift
            if [[ "$(find $SCRIPTDIR -type f -regex .*/[0-9][0-9][0-9]_$APP -exec ln -v {} $MANAGED ';')" ]] ; then
                flow force-compile
            else
                printf "Error: \`$APP\` isn't managed by flow\n" >/dev/stderr
                return 1
            fi
            ;;

        unmanage)
            [[ -d "$MANAGED" ]] || return

            local APP=$1; shift
            if [[ "$(find $MANAGED -type l -regex .*/[0-9][0-9][0-9]_$APP -exec rm -v {} ';')" ]] ; then
                flow force-compile
            fi
            ;;

        ls)
            [[ -d "$MANAGED" ]] || return
            $(find $SCRIPTDIR -type f -execdir touch -a $MANAGED/{} ';')
            \ls -xG $MANAGED
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
                usage: flow COMMAND ...
                   
                Commands:
                  enter          Enter a state of flow by reducing distractions
                  leave          Leave a state of flow, restore communications, notifications, etc.
                  manage APP     Add APP to list of distracting apps; diminish it when entering flow
                  unmanage APP   Remove APP from list of distracting apps

                  install        Install `Enter Flow.app` and `Leave Flow.app` to $HOME/Applications

EOF
            ;;
    esac
}
