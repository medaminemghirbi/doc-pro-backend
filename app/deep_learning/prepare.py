import subprocess
import re
import os

def install_dependancies():
    commands = ['pip3 install Flask tensorflow numpy matplotlib werkzeug huggingface_hub']
    for command in commands:
        print(f'Running command: {command}')
        subprocess.run(command, shell=True, check=True)
if __name__ == "__main__":
    try:
        install_dependancies()
    except Exception as e:
        print(f'An error occurred: {e}')