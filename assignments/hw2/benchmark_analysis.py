#!/usr/bin/env python3

from json import load
from os.path import exists
from sys import exit, stderr

from matplotlib.pyplot import subplots, tight_layout, show

END = '\033[0m'
BOLD = '\033[1m'
RED = '\033[91m'
GREEN = '\033[92m'
YELLOW = '\033[93m'

RESULT_FILE = 'benchmark_result.json'
THREADS = [1, 2, 4, 8, 16, 32, 64]


def warn(message: str) -> None:
    print(f'{YELLOW}{message}{END}', file=stderr)


def die(message: str) -> None:
    print(f'\n{RED}{message}{END}\n', file=stderr)
    exit(1)


def get_collection(root, hardware_type: str):
    collection = root.get(hardware_type)
    if collection is None:
        die(f'No {hardware_type} data in benchmark file.')
    return collection


def parenthesized_or_empty(description: str | None) -> str:
    return '' if description is None else f" ({description})"


def latency_graph(
    collection,
    hardware_type: str,
    latency_description: str | None = None,
    throughput_description: str | None = None,
) -> None:
    print(f'Generating {hardware_type} graph...')

    figure, ((axes1, axes2), (axes3, axes4)) = subplots(2, 2, figsize=(10, 6))
    figure.suptitle(f'{hardware_type} benchmark', fontsize=16, fontweight='bold')

    for host_type, metric_type in collection.items():
        axes1.plot(
            THREADS,
            [metric_type[str(t)]['latency'] for t in THREADS], 's-',
            label=f"{host_type}",
        )
        axes2.plot(
            THREADS,
            [metric_type[str(t)]['throughput'] for t in THREADS],
            'o-',
            label=f"{host_type}",
        )
        axes3.plot(
            THREADS,
            [metric_type[str(t)]['overheads'] for t in THREADS],
            '^-',
            label=f"{host_type}",
        )

    axes1.set_xlabel('# of threads')
    axes1.set_ylabel(f'Latency{parenthesized_or_empty(latency_description)}')
    axes1.set_title('Average latency')
    axes1.legend()
    axes1.grid(True, alpha=0.3)
    axes1.set_xscale('log', base=2)

    axes2.set_xlabel('# of threads')
    axes2.set_ylabel(f'Throughput{parenthesized_or_empty(throughput_description)}')
    axes2.set_title('Measured throughput')
    axes2.legend()
    axes2.grid(True, alpha=0.3)
    axes2.set_xscale('log', base=2)

    axes3.set_xlabel('# of threads')
    axes3.set_ylabel('%')
    axes3.set_title('Overheads')
    axes3.legend()
    axes3.grid(True, alpha=0.3)
    axes3.set_xscale('log', base=2)

    axes4.axis('off')

    tight_layout()
    show()


def operations_graph(
    collection,
    hardware_type: str,
    operations_description: str | None = None,
    throughput_description: str | None = None,
) -> None:
    print(f'Generating {hardware_type} graph...')

    figure, ((axes1, axes2), (axes3, axes4)) = subplots(2, 2, figsize=(10, 6))
    figure.suptitle(f'{hardware_type} benchmark', fontsize=16, fontweight='bold')

    for host_type, metric_type in collection.items():
        axes1.plot(
            THREADS,
            [metric_type[str(t)]['operations'] for t in THREADS],
            's-',
            label=f"{host_type}",
        )
        axes2.plot(
            THREADS,
            [metric_type[str(t)]['throughput'] for t in THREADS],
            'o-',
            label=f"{host_type}",
        )
        axes3.plot(
            THREADS,
            [metric_type[str(t)]['efficiency'] for t in THREADS],
            '^-',
            label=f"{host_type}",
        )

    axes1.set_xlabel('# of threads')
    axes1.set_ylabel(f'Operations{parenthesized_or_empty(operations_description)}')
    axes1.set_title('Total operations')
    axes1.legend()
    axes1.grid(True, alpha=0.3)
    axes1.set_xscale('log', base=2)

    axes2.set_xlabel('# of threads')
    axes2.set_ylabel(f'Throughput{parenthesized_or_empty(throughput_description)}')
    axes2.set_title('Measured throughput')
    axes2.legend()
    axes2.grid(True, alpha=0.3)
    axes2.set_xscale('log', base=2)

    axes3.set_xlabel('# of threads')
    axes3.set_ylabel('%')
    axes3.set_title('Efficiency')
    axes3.legend()
    axes3.grid(True, alpha=0.3)
    axes3.set_xscale('log', base=2)

    axes4.axis('off')

    tight_layout()
    show()


if __name__ == '__main__':
    print('Loading benchmark results...')

    if not exists(RESULT_FILE):
        die(f"Input file '{RESULT_FILE}' not found.")

    with open(RESULT_FILE) as f:
        result_file = load(f)

    latency_graph(get_collection(result_file, 'cpu'), 'CPU', 'ms', 'records/s')
    operations_graph(get_collection(result_file, 'memory'), 'Memory', None, 'MiB/sec')
    operations_graph(get_collection(result_file, 'disk'), 'Disk', None, 'MiB/sec')
    operations_graph(
        get_collection(result_file, 'network'), 'Network', None, 'Gbits/sec',
    )
    print(f'{GREEN}Plotting complete.{END}')

    print()
    print('Goodbye!')
    exit(0)
