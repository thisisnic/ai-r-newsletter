---
title: "ellmer 0.3.1"
url: https://github.com/tidyverse/ellmer/blob/HEAD/NEWS.md#ellmer-0-3-1
source: ellmer
date: 2026-04-13
---


* `chat_anthropic()` drops empty assistant turns to avoid API errors (#710).

* `chat_github()` now uses the `https://models.github.ai/inference` endpoint and `chat()` supports GitHub models in the format `chat("github/openai/gpt-4.1")` (#726).

* `chat_google_vertex()` authentication was fixed using broader scope (#704, @netique)

* `chat_google_vertex()` can now use `global` project location (#704, @netique)

* `chat_openai()` now uses `OPENAI_BASE_URL`, if set, for the `base_url`. Similarly, `chat_ollama()` also uses `OLLAMA_BASE_URL` if set (#713).

* `contents_record()` and `contents_replay()` now record and replay custom classes that extend ellmer's `Turn` or `Content` classes (#689). `contents_replay()` now also restores the tool definition in `ContentToolResult` objects (in `@request@tool`) (#693).

* `chat_snowflake()` now supports Privatelink accounts (#694, @robert-norberg). and works against Snowflake's latest API changes (#692, @robert-norberg).

* `models_google_vertex()` works once again (#704, @netique)

* In the `value_turn()` method for OpenAI providers, `usage` is checked if `NULL` before logging tokens to avoid errors when streaming with some OpenAI-compatible services (#706, @stevegbrooks).

