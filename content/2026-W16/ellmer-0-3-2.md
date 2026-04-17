---
title: "ellmer 0.3.2"
url: https://github.com/tidyverse/ellmer/blob/HEAD/NEWS.md#ellmer-0-3-2
source: ellmer
date: 2026-04-13
---


* `chat()` is now compatible with most `chat_` functions (#699).
  * `chat_aws_bedrock()`, `chat_databricks()`, `chat_deepseek()`, `chat_github()`, `chat_groq()`, `chat_ollama()`, `chat_openrouter()`, `chat_perplexity()`, and `chat_vllm()` now support a `params` argument that accepts common model parameters from `params()`.
  * The `deployment_id` argument in `chat_azure_openai()` was deprecated and replaced with `model` to better align with other providers.

* `chat_openai()` now correctly maps `max_tokens` and `top_k` from `params()` to the OpenAI API parameters (#699).

