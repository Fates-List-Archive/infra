tmux kill-session -t flamepaw
tmux kill-session -t flamepaw-pinger
tmux send-keys -t flamepaw-pinger ' cd ~/FatesList/modules/infra/flamepaw-pinger && python3 pinger.py exec $SHELL' Enter