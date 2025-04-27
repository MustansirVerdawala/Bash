# Check if inside a tmux session

if [ -z "$TMUX" ]; then
  # Start a new tmux session named 'default' or attach to an existing one
  tmux has-session -t default 2>/dev/null
  if [ $? != 0 ]; then
    # Create a new tmux session and split into 3 panes
    tmux new-session -d -s default
    tmux split-window -h  # Split into two columns
    tmux select-pane -t 0
    tmux split-window -v  # Split the left column into two rows

    # Run the scripts in respective panes
    tmux select-pane -t 0  # Top-left pane
    tmux send-keys "./welcome.sh" C-m

    tmux select-pane -t 1  # Bottom-left pane
    tmux send-keys "./weather.sh" C-m

    # Right pane is left empty for manual use
    tmux select-pane -t 2
  fi
  tmux attach-session -t default
  exit  # Prevent further execution of the shell after launching tmux
fi
