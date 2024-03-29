#!/usr/bin/env python3
import atexit
import readline
import os

histfile = os.path.join(os.path.expanduser(os.environ['XDG_STATE_HOME']), 'python_history')
print(histfile)

try:
    readline.read_history_file(histfile)
    readline.set_history_length(1000)
except FileNotFoundError:
    pass

atexit.register(readline.write_history_file, histfile)
