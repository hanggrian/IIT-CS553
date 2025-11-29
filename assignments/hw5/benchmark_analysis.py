from json import loads
from os.path import isfile

from matplotlib.pyplot import subplots, tight_layout, show
from numpy import arange, power
from pandas import DataFrame

PERFORMANCE_INPUT_FILE = 'benchmark_result1.json'
SEARCH_INPUT_FILE = 'benchmark_result2.json'
APPROACHES = ['hashgen', 'vaultx', 'Hadoop', 'Spark']


def loads_data_frame(file_path):
  if not isfile(file_path):
    raise FileNotFoundError(f"File '{file_path}' not found.")
  with open(file_path, 'r', encoding='UTF-8') as file:
    output = loads(file.read())
  return DataFrame(output)


if __name__ == '__main__':
  frame1 = loads_data_frame(PERFORMANCE_INPUT_FILE)
  frame1_expanded = \
    frame1.melt(
      id_vars='experiment',
      value_vars=APPROACHES,
      var_name='approach',
      value_name='time',
    )

  fig1, ax1 = subplots(figsize=(14, 6))

  bar_width = 0.2
  experiments = frame1['experiment'].unique()
  x_pos = arange(len(experiments))
  colors = ['#66C2A5', '#FC8D62', '#8DA0CB', '#E78AC3']  # from seaborn Set2

  for i, approach in enumerate(APPROACHES):
    subset = frame1_expanded[frame1_expanded['approach'] == approach]
    ax1.bar(
      x_pos + (i * bar_width) - (bar_width * (len(APPROACHES) - 1) / 2),
      subset['time'],
      bar_width,
      label=approach,
      color=colors[i]
    )

  fig1.suptitle('Performance benchmark', fontweight='bold')
  ax1.set_ylabel('Total time (seconds)')
  ax1.set_xticks(x_pos)
  ax1.set_xticklabels(experiments, rotation=45, ha='right')
  ax1.legend(title='Approach')
  ax1.grid(True, alpha=0.3, axis='y')

  tight_layout()
  show()

  frame2 = loads_data_frame(SEARCH_INPUT_FILE)

  frame2['GB size'] = power(2, frame2['k']) / (1024 ** 3)
  frame2['Label'] = frame2['approach'] + ' (Diff ' + frame2['difficulty'].astype(str) + ')'

  fig2, ax2 = subplots(figsize=(10, 6))

  for label, group in frame2.groupby('Label'):
    group_sorted = group.sort_values(by='k')
    ax2.plot(
      group_sorted['k'],
      group_sorted['throughput'],
      marker='o',
      linestyle='-',
      label=label,
    )

  fig2.suptitle('Search benchmark', fontweight='bold')
  ax2.set_xlabel('Dataset size (K)')
  ax2.set_ylabel('Throughput (searches/sec)')

  k_ticks = frame2['k'].unique()
  ax2.set_xticks(k_ticks)
  ax2.set_xticklabels(
    [f"K={k} ({int(power(2, k) / (1024 ** 3))}GB)" for k in k_ticks],
    rotation=0,
  )

  ax2.legend(title='Approach', loc='upper right')
  ax2.grid(True, alpha=0.3, axis='y')
  ax2.set_yscale('log')

  tight_layout()
  show()
