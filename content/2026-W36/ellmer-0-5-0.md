---
title: "ellmer 0.5.0"
url: https://github.com/tidyverse/ellmer/blob/HEAD/NEWS.md#ellmer-0-5-0
source: ellmer
date: 2026-09-04
---


## Lifecycle changes

* `chat_github()` and `models_github()` are now defunct because GitHub Models has been retired (@thisisnic, #1069).
* `tool()` functions that return complex objects like data frames or lists now produce a deprecation warning. Tool functions should return a character vector, an atomic vector, a JSON string (from `jsonlite::toJSON()`), or a `Content` object. Use `jsonlite::toJSON()` to convert complex objects before returning (@thisisnic, #858).

## New features

* When running on Posit Connect, ellmer now forwards the viewer's session token to Connect's LLM gateway so gateway usage can be attributed to the viewer. This happens automatically for Shiny content and only affects requests to the gateway (@karawoo, #1105).
* `chat_aws_bedrock()` gains an `api` argument to select between the Converse API on the `bedrock-runtime` endpoint and the Anthropic Messages or OpenAI Responses APIs on the `bedrock-mantle` endpoint. This makes models that Converse can't serve, like Claude Mythos and the GPT-5 family, available on Bedrock. The API is picked from `model` by default, so you only need to set `api` for models ellmer doesn't recognize (#1064).
* `Chat` gains experimental `$file_upload()`, `$file_list()`, `$file_get()`, `$file_download()`, and `$file_delete()` methods for managing provider-hosted files with `chat_openai()`, `chat_anthropic()`, and `chat_google_gemini()`: upload a file once, then pass the returned reference to `$chat()` instead of re-sending the file's contents every turn. Uploads expire after 48 hours by default; use `expires_in_h` to change this. `claude_file_upload()` and friends and `google_upload()` are deprecated in favor of these (@thisisnic, #1091).
* `Chat` gains `$get_rounds()` and `$last_round()` methods for retrieving the conversation history grouped into `Round`s. The new `Round` class groups a `Chat`'s flat turn history into rounds, each containing a user turn and the assistant/tool-result turns that follow it (#507).
* `Chat` gains `$on_request_start()` and `$on_request_end()` callbacks that fire before and after each model request, including each round of the tool loop. `$on_request_start()` receives the turns about to be sent, so you can inspect the request or compact the conversation with `$set_turns()`. `$on_request_end()` receives the assistant turn just returned, so you can track latency or cost per request (@kaipingyang, #1051).
* `Chat$stream()` and `Chat$stream_async()` gain a `type` argument for streaming structured output from providers with native support (@cpsievert, #1102).
* `Chat` gains a `$token_count()` method that estimates the number of tokens in new input using the provider's token counting endpoint (@thisisnic, #814).
* `claude_tool_web_search()`, `claude_tool_web_fetch(citations = TRUE)`, `google_tool_web_search()`, and `openai_tool_web_search()` now return citations, which are preserved in chat history and streamed content and shown as cited sources in console output (@cpsievert, #775).
* New `content_document_file()` and `content_document_url()` send text-based documents like CSV, markdown, and code files to the model, and `content_pdf_url()` now lets providers that can fetch URLs do so themselves (@thisisnic, #1090).
* New `Model` class separates model configuration (name, parameters, extra arguments) from the `Provider` class, which now only captures API endpoint details. `Chat` gains a new `$get_model_object()` method to retrieve the `Model` object. `provider@model`, `provider@params`, and `provider@extra_args` are deprecated and will be removed in a future release; use the `Model` object instead (@thisisnic, #1098).
* New `models_update_prices()` downloads the latest model pricing data from GitHub and saves it to a local cache. Subsequent calls to `token_usage()` and related functions will use the updated prices (#968).
* `tool_context()` lets a tool access its calling context, including the `ContentToolRequest` and the conversation history, during a tool call. `with_tool_context()` and `local_tool_context()` support testing tools that use it (#871).

## Minor improvements and bug fixes

* Default models have been updated for a number of providers (@thisisnic, #1040, #1066, #1125):
  * `chat_anthropic()` now uses `claude-sonnet-5`.
  * `chat_aws_bedrock()` now uses `us.anthropic.claude-sonnet-5`.
  * `chat_databricks()` now uses `databricks-claude-sonnet-5`.
  * `chat_google_gemini()` and `chat_google_vertex()` now use `gemini-3.7-flash`.
  * `chat_huggingface()` now uses `Qwen/Qwen3-235B-A22B-Instruct-2507`.
  * `chat_openai()` now uses `gpt-5.6-terra`.
  * `chat_openrouter()` now uses `gpt-5.6-terra`.
  * `chat_posit()` now uses `claude-sonnet-5`.
  * `chat_snowflake()` now uses `claude-sonnet-5`.
* `chat_anthropic()` and `chat_aws_bedrock()` now handle empty responses from the model (@thisisnic, #1070).
* `chat_anthropic()` now defaults `base_url` to the `ANTHROPIC_BASE_URL` environment variable, and `chat_aws_bedrock()` to `AWS_ENDPOINT_URL_BEDROCK_RUNTIME` or `AWS_ENDPOINT_URL_BEDROCK_MANTLE` depending on `api`, matching the official SDKs (@karawoo, #1103).
* `chat_anthropic()` now handles the `fallback` content block returned when a model's server-side refusal fallback (`server-side-fallback-2026-06-01`) is triggered (@simonpcouch, #1057).
* `chat_aws_bedrock()` now handles thinking blocks with no text (@thisisnic, #1085).
* `chat_aws_bedrock()` now supports bearer token authentication for enterprise API gateways (@thisisnic, #1002).
* `chat_databricks()` now supports models that return content as an array of typed objects (e.g. `databricks-gpt-oss-120b`), capturing reasoning parts as thinking content (@thisisnic, #1078).
* `chat_databricks()` now works with tools that have no arguments (@thisisnic, #1084).
* `Chat` gains a `conversation_id` active binding. When set, it is recorded on the OpenTelemetry spans emitted for each model call so that tracing backends can group spans belonging to the same conversation (@cpsievert, #1106).
* `chat_google_gemini()` now supports mixing regular tools with built-in tools like `google_tool_web_search()` (@thisisnic, #1054).
* `chat_openrouter()` now preserves provider error messages (@xmarquez, #1059).
* `params(top_k = )` is now sent as `top_k` rather than `top_logprobs` for OpenAI-based providers (@thisisnic, #1113).

