#!/bin/bash

# Nombre de la sesión de tmux
SESSION_NAME="voting-app"

# Comprobar si la sesión ya existe DENTRO de la VM
vagrant ssh -c "tmux has-session -t $SESSION_NAME" 2>/dev/null

if [ $? != 0 ]; then
  echo "Creando nueva sesión de tmux en la VM: $SESSION_NAME"

  # Usar vagrant ssh -c para ejecutar cada comando tmux DENTRO de la VM
  vagrant ssh -c "tmux new-session -d -s $SESSION_NAME -n 'Vote' 'cd /vagrant/vote && sudo /vagrant/vote/venv/bin/python3 app.py'"

  vagrant ssh -c "tmux split-window -h -t $SESSION_NAME:0"
  vagrant ssh -c "tmux send-keys -t $SESSION_NAME:0.1 'cd /vagrant/worker && node main.js' C-m"

  vagrant ssh -c "tmux split-window -v -t $SESSION_NAME:0.1"
  vagrant ssh -c "tmux send-keys -t $SESSION_NAME:0.2 'cd /vagrant/result && node main.js' C-m"

  echo "Sesión '$SESSION_NAME' creada con 3 paneles."
  echo "Vote App, Worker y Result App están iniciándose."
  echo "Para ver los procesos, ejecuta: vagrant ssh -c \"tmux attach -t $SESSION_NAME\""
  echo "Para detener todos los procesos, ejecuta: vagrant ssh -c \"tmux kill-session -t $SESSION_NAME\""
else
  echo "La sesión '$SESSION_NAME' ya existe en la VM."
  echo "Para conectarte, ejecuta: vagrant ssh -c \"tmux attach -t $SESSION_NAME\""
  echo "Para detenerla, ejecuta: vagrant ssh -c \"tmux kill-session -t $SESSION_NAME\""
fi

