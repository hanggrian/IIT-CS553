from matplotlib.pyplot import subplots, tight_layout, show
from numpy import power

from _lib import loads_data_frame

INPUT_FILE = 'search_benchmark.json'

if __name__ == '__main__':
  frame = loads_data_frame(INPUT_FILE)

  frame['GB size'] = power(2, frame['k']) / (1024 ** 3)
  frame['Label'] = frame['approach'] + ' (Diff ' + frame['difficulty'].astype(str) + ')'

  figure, axes = subplots(figsize=(10, 6))

  for label, group in frame.groupby('Label'):
    group_sorted = group.sort_values(by='k')
    axes.plot(
      group_sorted['k'],
      group_sorted['throughput'],
      marker='o',
      linestyle='-',
      label=label,
    )

  figure.suptitle('Search benchmark', fontweight='bold')
  axes.set_xlabel('Dataset size (K)')
  axes.set_ylabel('Throughput (searches/sec)')

  k_ticks = frame['k'].unique()
  axes.set_xticks(k_ticks)
  axes.set_xticklabels(
    [f"K={k} ({int(power(2, k) / (1024 ** 3))}GB)" for k in k_ticks],
    rotation=0,
  )

  axes.legend(title='Approach', loc='upper right')
  axes.grid(True, alpha=0.3, axis='y')
  axes.set_yscale('log')

  tight_layout()
  show()
