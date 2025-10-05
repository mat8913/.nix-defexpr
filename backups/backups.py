import json
import os
import subprocess
import tempfile
import time


PDRIVE=os.environ["PDRIVE"]


def run_backup(src, name, dst):
    with tempfile.TemporaryDirectory() as d:
        tarfile = d + '/' + name + '.tar'
        subprocess.run(["tar", "-cf", tarfile, src])
        subprocess.run([PDRIVE, "put", "--enable-sdk-log", tarfile, dst])


def main():
    config = None
    with open(os.path.expanduser("~/.config/backups.json")) as f:
        config = json.load(f)
    dst = config['dst']
    for backup in config['backups']:
        src = os.path.expanduser(backup['src'])
        name = backup['name']
        run_backup(src, name, dst)


main()
