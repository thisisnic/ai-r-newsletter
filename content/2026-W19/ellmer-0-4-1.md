---
title: "ellmer 0.4.1"
url: https://github.com/tidyverse/ellmer/blob/HEAD/NEWS.md#ellmer-0-4-1
source: ellmer
date: 2026-05-07
---


* ellmer is now instrumented with OpenTelemetry, so that traces are emitted whenever the (suggested) `otel` package is installed and a tracer is active.

  Each call to `$chat()`, `$chat_async()`, `$stream()`, or `$stream_async()` produces a top-level `invoke_agent` span that wraps one or more child `chat <model>` spans (one per request to the provider) and `execute_tool <tool>` spans (one per tool invocation). Chat spans record the provider name, request model, response model, and response id, plus input and output token usage; tool spans record the tool name, description, call id, and any error raised during execution. HTTP spans from httr2 are automatically nested under the chat spans (#526).

  Chat spans can additionally record conversation content as `gen_ai.input.messages`, `gen_ai.output.messages`, and `gen_ai.system_instructions`. This is opt-in via the `OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT` environment variable (set to `"true"`), since these payloads may contain user data.
* ellmer now distinguishes text content from thinking content while streaming, allowing downstream packages like shinychat to provide specific UI for thinking content (@simonpcouch, #909).
* `claude_tool_web_search()`, `openai_tool_web_search()`, and other built-in tools now include `description` and `annotations` properties, making their metadata consistent with user-defined tools created by `tool()` (#942).
* `chat_anthropic()` no longer fails when streaming web search results: `citations_delta` events are now handled correctly and `server_tool_use` input is parsed from JSON during streaming (#941).
* `chat_anthropic()` no longer applies a hidden 1.25x pricing weight to cache-creation tokens; the input token counts reported by `token_usage()` and `parallel_chat()` are now raw counts. Cost calculations are unchanged.
* `chat_aws_bedrock()` now supports reasoning/thinking content. To enable thinking in Anthropic Claude models, see the `api_args` argument in `?chat_aws_bedrock` for an example (#964).
* `chat_aws_bedrock()` gains a `cache` parameter for prompt caching. The default, `"auto"`, enables caching for models known to support it (Anthropic Claude and Amazon Nova) and disables it otherwise (#954).
* `chat_openai_compatible()` now extracts `reasoning_content` from model responses (both streaming and non-streaming) as `ContentThinking` objects. A new `preserve_thinking` parameter controls whether reasoning content is sent back to the API in multi-turn conversations; it defaults to `FALSE` (matching DeepSeek's requirement) but is set to `TRUE` for `chat_openrouter()` (#972).
* `chat_databricks()` (and other `chat_openai_compatible()` providers) no longer fail with HTTP 400 when the conversation history contains empty `ContentText("")` objects, which can occur during tool calling (@JamesHWade, #932).
* `chat_github()` now uses `chat_openai_compatible()` for improved compatibility and `models_github()` now supports custom `base_url` configuration (@D-M4rk, #877).
* `chat_groq()` now supports structured chat (@CoryMcCartan, #930).
* New `chat_lmstudio()` and `models_lmstudio()` provide support for [LM Studio](https://lmstudio.ai), a local model server with an OpenAI-compatible API (#963).
* `chat_ollama()` now supports `params(top_k = )` (@frankiethull, #896).
* `chat_openai()` no longer fails when streaming web search results for `web_search_call` action types other than `search` (e.g. `open_page`, `find_in_page`) (#941).
* `chat_openai()` now uses the default prices if the service tier is missing (@trangdata, #903).
* `chat_snowflake()` now correctly handles tool calling. Previously, when Snowflake's streaming API sent a tool-use chunk as the very first response (with no preceding text), the chunk merging logic produced malformed content, causing "argument is of length zero" errors (#938).
* `default_google_credentials()` no longer skips application default credentials (e.g. `GOOGLE_APPLICATION_CREDENTIALS`) in interactive sessions, instead falling through to the OAuth browser flow only when no gargle token is available (@stefanlinner, #922).
* `models_anthropic()` (and `models_claude()`) gains a `credentials` argument for consistency with `chat_anthropic()` and other `models_*()` functions (@jcrodriguez1989, #917).
* New `stream_controller()` enables programmatic cancellation of streaming chat responses, e.g. from a Shiny "Cancel" button with `chat$stream()` or `chat$stream_async()`. Streaming turns are now saved incrementally so that partial responses survive cancellation, interrupts (Ctrl-C), and errors. Incomplete turns are recorded as `AssistantPartialTurn` objects, display as interrupted in the chat history, and are included in subsequent model context like complete turns (#643).

