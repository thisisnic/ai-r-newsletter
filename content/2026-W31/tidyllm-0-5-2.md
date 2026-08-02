---
title: "tidyllm 0.5.2"
url: https://github.com/edubruell/tidyllm/blob/HEAD/NEWS.md#tidyllm-0-5-2
source: tidyllm
date: 2026-07-30
---


A bugfix release. No new providers, verbs, or media types.

## JSON schemas (structured output and tool definitions)

* `tidyllm_schema()` now sets `additionalProperties: false` on **every** object node of the assembled schema, not just the root. Schemas containing `field_object(..., .vector = TRUE)`, i.e. an array of objects, were rejected with an HTTP 400 `invalid_json_schema` by every provider enforcing OpenAI strict mode: `openai()` itself and any `openrouter()` route to OpenAI or Azure. The same recursive normalization is applied at the provider boundary, so raw list schemas and `ellmer` types are covered as well.
* `gemini()` strips `additionalProperties` recursively before sending a schema. Gemini rejects the key on any node, and previously only the root was stripped.
* Tool definitions get the same treatment. A `tidyllm_tool()` with a `field_object()` argument produced a nested object node without `additionalProperties`, which `openai()` rejected with a 400 because tidyllm sends `strict = TRUE` on tool schemas.
* The schema name is now read with `attr(..., exact = TRUE)`. Passing a hand-written list schema without a `name` attribute previously partial-matched the `names` attribute, so the property names went on the wire as the schema name and strict providers rejected the request.
* Note that an explicit `additionalProperties = TRUE`, for instance from `ellmer::type_object(.additional_properties = TRUE)`, is now normalized to `FALSE`, since that is what strict mode requires.

## Error messages

* Provider errors coming through an OpenAI-compatible gateway are no longer empty. `openrouter()` reports a generic `"Provider returned error"` in `error$message` and keeps the real upstream diagnostic in `error$metadata$raw`; tidyllm now unwraps that payload and names the upstream provider in the error it raises. This is what made the schema bug above so hard to diagnose in the field. It applies to the whole ChatCompletions family and to `azure_openai()`.
* The error type falls back to `error$code` when a provider reports no `error$type`, so the error header is no longer `Type: NULL`.

## Token metadata

* `get_metadata()` gains two top-level columns: `cached_tokens` (prompt tokens served from the provider's cache, the billing-relevant number) and `cache_creation_tokens` (cache writes; Claude only). Providers that do not report cache usage return `NA_integer_`, so "no caching" and "cache miss" stay distinguishable. Raw provider fields remain in `api_specific`, so existing code keeps working.
* Cache counts are now read where they were previously discarded: `openai()` (Responses API), `gemini()`, `deepseek()`, `chat_ellmer()`, and the whole ChatCompletions family including `openrouter()`. `openrouter()` additionally reports `cache_discount` in `api_specific`.
* `gemini()` and `groq()` replies now report `stream = FALSE` instead of `NA`, so a metadata tibble mixing providers is consistent.
* Claude streaming metadata is no longer a stub. Streamed replies now report `stop_reason`, `id`, `stop_sequence`, cache tokens and the thinking trace, matching the non-streaming path.

## Provider fixes

* `gemini()` tool calls work again. Gemini now rejects a `functionCall` part whose `thoughtSignature` was dropped ("Function call is missing a thought_signature"), which broke every multi-round tool call. tidyllm sends the model's parts back verbatim.
* `claude_websearch()` defaults to the current `web_search_20260318` tool version and gains `.allowed_callers` and `.response_inclusion`. Since `web_search_20260209` the API defaults `allowed_callers` to the code execution tool, which only models with programmatic tool calling support; web search therefore failed with a 400 on Claude Haiku 4.5 and other older models. tidyllm now sends `allowed_callers = "direct"` by default, so web search works on every model again. Pass `.allowed_callers = "code_execution_20260120"` for the dynamic filtering path.
* `ellmer_tool()` no longer produces a `tidyllm_field` whose type carries a stray name, and it uses the built-in tool's own description when `ellmer` provides one. `ellmer` is now declared as `Suggests: ellmer (>= 0.4.0)`, which is the version tidyllm's tool conversion actually requires.
* The `.cache` documentation for `claude_chat()` now states the per-model minimum cacheable prompt length. Anthropic silently caches nothing below that floor, and the floor is higher on the cheap models (4096 tokens on Haiku 4.5) than on Sonnet 5 (1024).

