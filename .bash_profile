[ -f /root/.profile ] && source /root/.profile
[ -f /root/.bashrc ] && source /root/.bashrc


export TERM=xterm

# fix some keys
case $TERM in
xterm*)
    bind '"\e[1~": beginning-of-line'
    bind '"\e[3~": delete-char'
    bind '"\e[4~": end-of-line'
    bind '"\177": backward-delete-char'
    ;;
esac
