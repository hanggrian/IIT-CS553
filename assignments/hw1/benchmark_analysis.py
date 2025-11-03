from os import remove
from os.path import exists, splitext
from subprocess import run, CalledProcessError
from sys import stdout, stderr, exit as sysexit
from time import time

from matplotlib import pyplot

END = '\033[0m'
BOLD = '\033[1m'
RED = '\033[91m'
GREEN = '\033[92m'
YELLOW = '\033[93m'


def warn(message: str) -> None:
    print(f'{YELLOW}{message}{END}', file=stdout)


def die(message: str) -> None:
    print(f'\n{RED}{message}{END}\n', file=stderr)
    sysexit(1)


GENERATE_SCRIPT = './generate_dataset.sh'
SORT_SCRIPT = './sort_dataset.sh'
SCALES = [1000, 10000, 1000000]


def run_timed(command: str) -> float | None:
    """Run a command and return the execution time in seconds."""
    start_time = time()
    try:
        run(command, shell=True, check=True, capture_output=True)
        end_time = time()
        return end_time - start_time
    except CalledProcessError:
        return None


if __name__ == '__main__':
    print('Starting benchmark...')

    if not exists(GENERATE_SCRIPT) or not exists(SORT_SCRIPT):
        die('Required scripts not found.')

    generation_times = []
    sorting_times = []

    for scale in SCALES:
        print(f'Testing {scale:,} records...')

        filename = f'temp_{scale}.txt'
        filename_sorted = f'{splitext(filename)[0]}_sorted{splitext(filename)[1]}'

        generate_time = run_timed(f'{GENERATE_SCRIPT} {filename} {scale}')
        if generate_time is None:
            die('Failed to generate records.')

        sort_time = run_timed(f'{SORT_SCRIPT} {filename}')
        if sort_time is None:
            die('Failed to sort records.')

        generation_times.append(generate_time)
        sorting_times.append(sort_time)

        print(f'{GREEN}Completed at {generate_time + sort_time:.2f}s.{END}')

        for file_name in (filename, f'{filename_sorted}'):
            if exists(file_name):
                remove(file_name)

    pyplot.figure(figsize=(10, 6))

    pyplot.plot(SCALES, generation_times, 'o-', label='Generation time', linewidth=2)
    pyplot.plot(SCALES, sorting_times, 's-', label='Sorting time', linewidth=2)

    pyplot.xlabel('# of records')
    pyplot.ylabel('Duration')
    pyplot.suptitle('Generation vs. sorting time', fontweight='bold')

    pyplot.legend()
    pyplot.grid(True, alpha=0.3)

    if max(SCALES) / min(SCALES) > 50:
        pyplot.xscale('log')
    if max(*generation_times, *sorting_times) / \
        min(*generation_times, *sorting_times) > 10:
        pyplot.yscale('log')

    pyplot.tight_layout()
    pyplot.show()

    print()
    print('Goodbye!')
