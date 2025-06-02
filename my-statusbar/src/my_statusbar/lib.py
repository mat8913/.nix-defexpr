import time
from datetime import datetime
import json
import sys
import psutil


def output(x):
    json.dump(x, sys.stdout)
    sys.stdout.write('\n')


def output_header():
    output({'version': 1})


def output_block(text):
    output({'full_text': text})


def block_date():
    output_block(datetime.now().strftime("%a %b %_d %Y %I:%M:%S%p"))


def block_cpu():
    output_block(f'CPU: {psutil.cpu_percent()}%')


def block_mem():
    mem = psutil.virtual_memory()
    used = 1 - mem.available / mem.total
    output_block(f'Mem: {used:.1%}')


def block_disk():
    output_block(f'Disk: {psutil.disk_usage("/").percent}%')


def main():
    blocks = [
        block_cpu,
        block_mem,
        block_disk,
        block_date,
    ]
    output_header()
    sys.stdout.write('[\n')

    while True:
        sys.stdout.write('[\n')
        first = True
        for block in blocks:
            if first:
                first = False
            else:
                sys.stdout.write(',')
            block()
        sys.stdout.write('],\n')
        sys.stdout.flush()
        time.sleep(1)
