---
title: "tidyllm 0.5.1"
url: https://github.com/edubruell/tidyllm/blob/HEAD/NEWS.md#tidyllm-0-5-1
source: tidyllm
date: 2026-07-23
---


## Anthropic API migration

The Anthropic Messages API changed for current-generation models (Claude Sonnet 5, Opus 4.7 and newer): the fixed-budget thinking interface and the sampling parameters `temperature`, `top_k`, and `top_p` are rejected with a 400 error. tidyllm 0.5.1 tracks these changes:

* `.thinking = TRUE` in `claude_chat()` and `send_claude_batch()` now maps to adaptive thinking (`thinking: {type: "adaptive"}`) on models that support it (Claude Sonnet 4.6, Opus 4.6 or newer). Older models keep the `budget_tokens` interface; `.thinking_budget` only applies there.
* New `.effort` argument on `claude_chat()` and `send_claude_batch()`: one of `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"`. Controls thinking depth and token spend on models with adaptive thinking; replaces the thinking budget as the depth control.
* Sampling parameters passed to a model that rejects them now raise a clear client-side error before any request is sent. Older models accept them as before.
* Structured output requests moved from the deprecated top-level `output_format` parameter to `output_config.format`; the `structured-outputs` beta header is no longer sent (the feature is generally available).
* Response parsing and metadata extraction now handle thinking blocks in any position of the response content; batch fetching collapses text blocks correctly when thinking is enabled.
* `claude_websearch()` defaults to the `web_search_20260209` tool version with dynamic result filtering, and gains `.max_uses`, `.allowed_domains`, `.blocked_domains`, and `.version` arguments. Pass `.version = "web_search_20250305"` for models older than Claude Sonnet 4.6 / Opus 4.6.

## Prompt caching

* New `.cache` argument on `claude_chat()` and `send_claude_batch()`. `.cache = TRUE` enables Anthropic prompt caching with the default 5-minute time to live; `.cache = "1h"` requests a one-hour time to live. In `claude_chat()` the cache breakpoint is placed automatically at the end of the request; in `send_claude_batch()` the shared system prompt is cached across all requests in the batch, which is where batch workloads save the most.
* `get_metadata()` for Claude replies now reports `cache_creation_input_tokens` and `cache_read_input_tokens` in `api_specific`, so cache hits are verifiable.

## Other changes

* `gemini_embedding()` default model updated from `gemini-embedding-2-preview` to the generally available `gemini-embedding-2`.

