from json import load
from os.path import exists
from sys import stdout, stderr, exit as sysexit

from colorama import Fore, Style
from matplotlib.pyplot import subplots, tight_layout, show

SMALL_RESULT_FILE = 'benchmark_result1.json'
LARGE_RESULT_FILE = 'benchmark_result2.json'
SEARCH_RESULT_FILE = 'benchmark_result3.json'

SMALL_BENCHMARK_THREADS = [1, 2, 4, 8, 12, 24, 48]
LARGE_BENCHMARK_MEMORIES = [1024, 2048, 4096, 8192, 16384, 32768, 65536]
SEARCH_BENCHMARK_DIFFICULTIES = [3, 4, 5]


def warn(message: str) -> None:
    print(f'{Fore.YELLOW}{message}{Style.RESET_ALL}', file=stdout)


def die(message: str) -> None:
    print(f'\n{Fore.RED}{message}{Style.RESET_ALL}\n', file=stderr)
    sysexit(1)


if __name__ == '__main__':
    print('Loading benchmark results...')
    if not exists(SMALL_RESULT_FILE) or \
        not exists(LARGE_RESULT_FILE) or \
        not exists(SEARCH_RESULT_FILE):
        die(f'Benchmark results not found.')
    with open(SMALL_RESULT_FILE, 'r', encoding='UTF-8') as f:
        small_result = load(f)
    with open(LARGE_RESULT_FILE, 'r', encoding='UTF-8') as f:
        large_result = load(f)
    with open(SEARCH_RESULT_FILE, 'r', encoding='UTF-8') as f:
        search_result = load(f)

    fig3, ((axes1, axes2), (axes3, axes4)) = subplots(2, 2, figsize=(10, 6))
    fig3.suptitle('Small workload (K=26)', fontweight='bold')

    for io_threads, ax in {1: axes1, 2: axes2, 4: axes3}.items():
        for mem in [256, 512, 1024]:
            ax.plot(
                SMALL_BENCHMARK_THREADS,
                [small_result[str(t)][str(mem)][str(io_threads)] for t in SMALL_BENCHMARK_THREADS],
                'o-',
                label=f'{mem} MB',
            )

        ax.set_xlabel('# of compute threads')
        ax.set_ylabel('Throughput (MH/s)')
        ax.set_title(f'{io_threads} IO threads')
        ax.legend()
        ax.grid(True, alpha=0.3)
        ax.set_xscale('log', base=2)
        ax.set_xticks(SMALL_BENCHMARK_THREADS)
        ax.set_xticklabels(SMALL_BENCHMARK_THREADS)

    axes4.axis('off')

    tight_layout()
    show()

    fig2, ax = subplots(figsize=(10, 6))
    fig2.suptitle('Large workload (K=32)', fontweight='bold')

    throughputs = [large_result['24'][str(mem)]['1'] for mem in LARGE_BENCHMARK_MEMORIES]

    ax.plot(
        LARGE_BENCHMARK_MEMORIES,
        throughputs,
        'o-',
        color='tab:red',
        linewidth=3,
        markersize=12,
    )
    ax.set_xlabel('Memory size (MB)')
    ax.set_ylabel('Throughput (MH/s)')
    ax.set_title('24 threads, 1 IO thread')
    ax.grid(True, alpha=0.3)
    ax.set_xscale('log', base=2)
    ax.set_xticks(LARGE_BENCHMARK_MEMORIES)
    ax.set_xticklabels(
        [f'{m // 1024}GB' if m >= 1024 else f'{m}MB' for m in LARGE_BENCHMARK_MEMORIES],
    )

    for mem, tp in zip(LARGE_BENCHMARK_MEMORIES, throughputs):
        ax.annotate(
            f'{tp:.1f}',
            xy=(mem, tp),
            xytext=(0, 10),
            textcoords='offset points',
            ha='center',
        )

    tight_layout()
    show()

    fig4, axes = subplots(1, 2, figsize=(10, 6))
    fig4.suptitle('Search benchmark', fontweight='bold')

    for ax, k in zip(axes, [26, 32]):
        difficulties = sorted(int(d) for d in search_result[str(k)].keys())
        times = [(search_result[str(k)][str(d)]['Time / search'] * 1000) for d in difficulties]

        ax.plot(
            difficulties,
            times,
            '-o',
            label=f"K={k}",
            color='tab:purple' if k == 26 else 'tab:pink',
            linewidth=3,
            markersize=12,
        )
        ax.set_xlabel('Difficulty level')
        ax.set_ylabel('Search time per search (ms)')
        ax.set_title(f"Search performance (K={k})")
        ax.grid(True)
        ax.set_xticks(difficulties)
        ax.legend()

    tight_layout()
    show()

    print(f'{Fore.GREEN}Plotting complete.{Style.RESET_ALL}')
    print()
    print('Goodbye!')
