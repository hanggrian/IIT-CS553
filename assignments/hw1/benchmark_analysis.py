#!/usr/bin/env python3

from os import remove
from os.path import exists, splitext
from subprocess import run, CalledProcessError
from sys import exit, stderr
from time import time

from matplotlib.pyplot import figure, plot, xlabel, ylabel, title, legend, grid, xscale, yscale, \
    tight_layout, savefig, show

END = '\033[0m'
BOLD = '\033[1m'
RED = '\033[91m'
GREEN = '\033[92m'
YELLOW = '\033[93m'

SCALES = [1000, 10000, 1000000]


def warn(message):
    print(f"{YELLOW}{message}{END}", file=stderr)


def die(message):
    print(f"\n{RED}{message}{END}\n", file=stderr)
    exit(1)


def run_timed(command):
    """Run a command and return the execution time in seconds."""
    start_time = time()
    try:
        run(command, shell=True, check=True, capture_output=True)
        end_time = time()
        return end_time - start_time
    except CalledProcessError:
        return None


def main():
    print('Starting benchmark...')

    if not exists('./generate_dataset.sh') or not exists('./sort_data.sh'):
        die('Required scripts not found.')

    generation_times = []
    sorting_times = []

    for scale in SCALES:
        print(f"Testing {scale:,} records...")

        filename = f"output_{scale}.txt"
        filename_sorted = f"{splitext(filename)[0]}_sorted{splitext(filename)[1]}"

        gen_time = run_timed(f"./generate_dataset.sh {filename} {scale}")
        if gen_time is None:
            die(f"Failed to generate records.")

        sort_time = run_timed(f"./sort_data.sh {filename}")
        if sort_time is None:
            die(f"Failed to sort records.")

        generation_times.append(gen_time)
        sorting_times.append(sort_time)

        print(f"{GREEN}Completed at {gen_time + sort_time:.2f}s.{END}")

        for file_name in [filename, f"{filename_sorted}"]:
            if exists(file_name):
                remove(file_name)

    figure(figsize=(10, 6))

    plot(SCALES, generation_times, 'o-', label='Generation time', linewidth=2)
    plot(SCALES, sorting_times, 's-', label='Sorting time', linewidth=2)

    xlabel('# of Records')
    ylabel('Duration')
    title('Generation vs. sorting time')

    legend()
    grid(True, alpha=0.3)

    if max(SCALES) / min(SCALES) > 50:
        xscale('log')
    if (max(max(generation_times), max(sorting_times)) /
        min(min(generation_times), min(sorting_times)) > 10):
        yscale('log')

    tight_layout()
    savefig('benchmark_results.png')
    show()

    print("Graph saved as 'benchmark_results.png'")
    print()
    print('Goodbye!')
    exit(0)


if __name__ == '__main__':
    main()
