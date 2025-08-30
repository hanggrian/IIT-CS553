# AI prompts

Here are the relevant AI prompts and their answer. The selected model for this
homework is Gemini 2.5 Flash, a free model from Google.

## Prompt 1

> Split the `"$FILENAME"` declaration into name and extension. The `_sorted`
  suffix is appended to the name while leaving the extension unchanged.

```sh
local filename_ext="${FILENAME##*.}"
local filename_no_ext="${FILENAME%.*}"
local output_filename="${filename_no_ext}_sorted.${filename_ext}"
```
