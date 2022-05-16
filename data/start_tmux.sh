HISTCONTROL="ignorespace${HISTCONTROL:+:$HISTCONTROL}"
ulimit -Sv 3000000 # Force set 3gb ram limit
tmux kill-server
tmux new-session -d -s baypaw 
tmux send-keys -t baypaw ' cd ~/baypaw && target/release/baypaw; exec $SHELL' Enter
tmux new-session -d -s flamepaw 
tmux send-keys -t flamepaw ' cd ~/FatesList/modules/infra/flamepaw && ./flamepaw --cmd server; exec $SHELL' Enter
tmux new-session -d -s squirrelflight 
tmux send-keys -t squirrelflight ' cd ~/fates-list-helper && target/release/fateslisthelper; exec $SHELL' Enter
tmux new-session -d -s api 
tmux send-keys -t api ' cd ~/api-v3 && make run; exec $SHELL' Enter
export HISTCONTROL
#echo "Run 'systemd-run --scope -p CPUQuota=50% modules/infra/flamepaw/flamepaw --cmd server' to stop memory leaks"
