from matplotlib.pyplot import subplots, tight_layout, show
from numpy import arange

from _lib import loads_data_frame

INPUT_FILE = 'performance_benchmark.json'
APPROACHES = ['hashgen', 'vaultx', 'Hadoop', 'Spark']

if __name__ == '__main__':
  frame = loads_data_frame(INPUT_FILE)
  frame_expanded = \
    frame.melt(
      id_vars='experiment',
      value_vars=APPROACHES,
      var_name='approach',
      value_name='time',
    )

  figure, axes = subplots(figsize=(14, 6))

  bar_width = 0.2
  experiments = frame['experiment'].unique()
  x_pos = arange(len(experiments))
  colors = ['#66C2A5', '#FC8D62', '#8DA0CB', '#E78AC3']  # from seaborn Set2

  for i, approach in enumerate(APPROACHES):
    subset = frame_expanded[frame_expanded['approach'] == approach]
    axes.bar(
      x_pos + (i * bar_width) - (bar_width * (len(APPROACHES) - 1) / 2),
      subset['time'],
      bar_width,
      label=approach,
      color=colors[i]
    )

  figure.suptitle('Performance benchmark', fontweight='bold')
  axes.set_ylabel('Total time (seconds)')
  axes.set_xticks(x_pos)
  axes.set_xticklabels(experiments, rotation=45, ha='right')
  axes.legend(title='Approach')
  axes.grid(True, alpha=0.3, axis='y')

  tight_layout()
  show()
