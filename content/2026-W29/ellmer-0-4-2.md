---
title: "ellmer 0.4.2"
url: https://github.com/tidyverse/ellmer/blob/HEAD/NEWS.md#ellmer-0-4-2
source: ellmer
date: 2026-07-17
---


* `AssistantTurn` gains a `finish_reason` property that reports why the model stopped generating (@thisisnic, #3).
* `batch_chat()` now supports `chat_google_gemini()` and `chat_groq()` for batch processing (@xmarquez, #914, #927).
* `Chat` gains a `set_model()` method for updating the model after chat creation. Unlike some `chat_*()` functions, the model name is not validated (#988).
* `chat()` now raises a warning and `chat_structured()` raises an informative error when a response is truncated, filtered, or otherwise incomplete (@thisisnic, #867).
* Default models have been updated for a number of providers (@thisisnic, #885, #1038):
  * `chat_anthropic()` now uses `claude-sonnet-4-6`.
  * `chat_aws_bedrock()` now uses `us.anthropic.claude-sonnet-4-6`.
  * `chat_databricks()` now uses `databricks-claude-sonnet-4-6`.
  * `chat_deepseek()` now uses `deepseek-v4-flash`.
  * `chat_github()` now uses `gpt-5.4`.
  * `chat_google_gemini()` now uses `gemini-3.5-flash`.
  * `chat_groq()` now uses `openai/gpt-oss-20b`.
  * `chat_openai()` now uses `gpt-5`.
  * `chat_openrouter()` now uses `gpt-5.4`.
  * `chat_snowflake()` now uses `claude-sonnet-4-6`.
* `chat_anthropic()` now supports `params(reasoning_effort =)` for Claude's adaptive thinking mode (@thisisnic, #987).
* `chat_deepseek()` no longer errors during tool calling when the assistant turn has no text content (@thisisnic, #1043).
* `chat_google_gemini()` and `chat_google_vertex()` now support `params(reasoning_effort =)` (@thisisnic, #873).
* `chat_google_vertex()` and `models_google_vertex()` now default `location` and `project_id` to the `GOOGLE_CLOUD_LOCATION` and `GOOGLE_CLOUD_PROJECT` environment variables, no longer incorrectly use `GOOGLE_API_KEY` for authentication, and give a clearer error when cached credentials are invalid (@thisisnic, #994).
* `chat_ollama()` now supports `params(reasoning_effort = ...)` to set thinking for reasoning models, and thinking content is now captured in turns (@thisisnic, #940).
* `chat_perplexity()` now defaults to `model = "sonar"` since the previous default (`"llama-3.1-sonar-small-128k-online"`) has been removed by Perplexity (@thisisnic, #538).
* `chat_portkey()` no longer errors when when using a custom Portkey gateway without the `PORTKEY_VIRTUAL_KEY` env var being set (@thisisnic, #872).
* New `chat_posit()` and `models_posit()` provide access to models hosted by Posit AI, authenticating via an OAuth device flow (@simonpcouch, #1024).
* `models_deepseek()` lists available models for `chat_deepseek()` (@jcrodriguez1989, #919).
* `models_groq()` lists available models for `chat_groq()` (@thisisnic, #921).
* `type_object(.additional_properties)` is deprecated. No supported provider can return additional properties when using structured output. Instead, use an array of name-value pairs (@thisisnic, #866).

