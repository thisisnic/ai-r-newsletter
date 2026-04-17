---
title: "ollamar 1.2.2"
url: https://github.com/hauselin/ollama-r/blob/HEAD/NEWS.md#ollamar-1-2-2
source: ollamar
date: 2025-03-24
---


- `generate()` and `chat()` support [structured output](https://ollama.com/blog/structured-outputs) via `format` parameter.
- `test_connection()` returns `httr2::response` object by default, but also support returning a logical value. #29
- `chat()` supports [tool calling](https://ollama.com/blog/tool-support) via `tools` parameter. Added `get_tool_calls()` helper function to process tools. #30
- Simplify README and add Get started vignette with more examples.

