import json
import os
import subprocess
import tempfile
import time


def run_backup(src, name, dst):
    with tempfile.TemporaryDirectory() as d:
        tarfile = d + '/' + name + '.tar'
        subprocess.run(["tar", "-cf", tarfile, src], check=True)
        cmd = [
            "flatpak",
            "--user",
            "run",
            "--file-forwarding",
            "ch.proton.drive",
            "filesystem",
            "upload",
            "-f",
            "merge",
            "@@",
            tarfile,
            "@@",
            dst
        ]
        subprocess.run(cmd, check=True)


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
