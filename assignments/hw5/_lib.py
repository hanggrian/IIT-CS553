from json import loads
from os.path import isfile

from pandas import DataFrame


def loads_data_frame(file_path: str) -> DataFrame:
  if not isfile(file_path):
    raise FileNotFoundError(f"File '{file_path}' not found.")
  with open(file_path, 'r', encoding='UTF-8') as file:
    experiments = loads(file.read())
  return DataFrame(experiments)
