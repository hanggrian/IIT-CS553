[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/xjbwHwc9)

# CS553 Cloud Computing Written Assignment 1 Repo

**Illinois Institute of Technology**

**Team Name:** Hendra
**Students:**
- Hendra Wijaya (hwijaya@hawk.illinoistech.edu)

## AI prompts

Here are the relevant AI prompts and their answer. The selected model for this
homework is *Gemini 2.5 Flash,* a free model from Google.

### Prompt 1

> Split the `"$FILENAME"` declaration into name and extension. The `_sorted`
  suffix is appended to the name while leaving the extension unchanged.

```sh
local filename_ext="${FILENAME##*.}"
local filename_no_ext="${FILENAME%.*}"
local output_filename="${filename_no_ext}_sorted.${filename_ext}"
```
