---
title: "ellmer 0.4.0"
url: https://github.com/tidyverse/ellmer/blob/HEAD/NEWS.md#ellmer-0-4-0
source: ellmer
date: 2026-04-13
---


## Lifecycle changes

* `chat_claude()` is no longer deprecated and is an alias for `chat_anthropic()`, reflecting Anthropic's recent rebranding of developer tools under the Claude name (#758). `models_claude()` is now an alias for `models_anthropic()`.
* `parallel_chat()` and `batch_chat()` are no longer experimental.
* The following deprecated functions/arguments/methods have now been removed:
  * `Chat$extract_data()` -> `chat$chat_structured()` (0.2.0)
  * `Chat$extract_data_async()` -> `chat$chat_structured_async()` (0.2.0)
  * `chat_anthropic(max_tokens)` -> `chat_anthropic(params)` (0.2.0)
  * `chat_azure()` -> `chat_azure_openai()` (0.2.0)
  * `chat_azure_openai(token)` (0.1.1)
  * `chat_bedrock()` -> `chat_aws_bedrock()` (0.2.0)
  * `chat_claude()` -> `chat_anthropic()` (0.2.0)
  * `chat_cortex()` -> `chat_snowflake()` (0.2.0)
  * `chat_gemini()` -> `chat_google_gemini()` (0.2.0)
  * `chat_openai(seed)` -> `chat_openai(params)` (0.2.0)
  * `create_tool_def(model)` -> `create_tool_def(chat)` (0.2.0)

## New features

* `batch_*()` no longer hashes properties of the provider besides the `name`, `model`, and `base_url`. This should provide some protection from accidentally reusing the same `.json` file with different providers, while still allowing you to use the same batch file across ellmer versions. It also has a new `ignore_hash` argument that allows you to opt out of the check if you're confident the difference only arises because ellmer itself has changed.
* `chat_claude()` gains new `cache` parameter to control caching. By default it is set to "5m". This should (on average) reduce the cost of your chats (#584).
* `chat_openai()` now uses OpenAI's responses endpoint (#365, #801). This is their recommended endpoint and gives more access to built-in tools.
* `chat_openai_compatible()` replaces `chat_openai()` as the interface to use for OpenAI-compatible APIs, and `chat_openai()` is reserved for the official OpenAI API. Unlike previous versions of `chat_openai()`, the `base_url` parameter is now required (#801).
* `chat_*()` functions now use a `credentials` function instead of an `api_key` (#613). This means that API keys are never stored in the chat object (which might be saved to disk), but are instead retrieved on demand as needed. You generally shouldn't need to use the `credentials` argument, but when you do, you should use it to dynamically retrieve the API key from some other source (i.e. never inline a secret directly into a function call).
* New set of `claude_file_()` functions for managing file uploads with Claude (@dcomputing, #761).
* ellmer now supports a variety of built-in web search and fetch tools (#578):
  - `claude_tool_web_search()` and `claude_tool_web_fetch()` for Claude.
  - `google_tool_web_search()` and `google_tool_web_fetch()` for Gemini.
  - `openai_tool_web_search()` for OpenAI.
  If you want to do web fetch for other providers, you could use `btw::btw_tool_web_read_url()`.
* `parallel_chat()` and friends now have a more permissive attitude to errors. By default, they will now return when hitting the first error (rather than erroring), and you can control this behaviour with the `on_error` argument. Or if you interrupt the job, it will finish up current requests and then return all the work done so far. The main downside of this work is that the output of `parallel_chat()` is more complex: it is now a mix of `Chat` objects, error objects, and `NULL` (#628).
* `parallel_chat_structured()` no longer errors if some results fail to parse. Instead it warns, and the corresponding rows will be filled in with the appropriate missing values (#628).
* New `schema_df()` to describe the schema of a data frame to an LLM (#744).
* `tool()`s can now return image or PDF content types, with `content_image_file()` or `content_image_pdf()` (#735).
* `params()` gains new `reasoning_effort` and `reasoning_tokens` so you can control the amount of effort a model spends on thinking. Initial support is provided for `chat_claude()`, `chat_google_gemini()`, and `chat_openai()` (#720).
* New `type_ignore()` allows you to specify that a tool argument should not be provided by the LLM when the R function has a suitable default value (#764).

## Minor improvements and bug fixes

* Updated pricing data (#790).
* `AssistantTurn`s now have a `@duration` slot, containing the total time to complete the request (@simonpcouch, #798).
* `batch_chat()` logs tokens once, on retrieval (#743).
* `batch_chat()` now retrieves failed results for `chat_openai()` (#830) and gracefully handles invalid JSON (#845).
* `batch_chat()` now works once more for `chat_anthropic()` (#835).
* `batch_chat_*()` and `parallel_chat_*()` now accept a string as the chat object, following the same rules as `chat()` (#677).
* `chat_claude()` and `chat_aws_bedrock()` now default to Claude Sonnet 4.5 (#800).
* `chat_databricks()` lifts many of its restrictions now that Databricks' API is more OpenAI compatible (#757).
* `chat_google_gemini()` and `chat_openai()` support image generation (#368).
* `chat_google_gemini()` has an experimental fallback interactive OAuth flow, if you're in an interactive session and no other authentication options can be found (#680).
* `chat_groq()` now defaults to llama-3.1-8b-instant.
* `chat_openai()` gains a `service_tier` argument (#712).
* `chat_portkey()` now requires you to supply a model (#786).
* `chat_portkey(virtual_key)` no longer needs to be supplied; instead Portkey recommends including the virtual key/provider in the `model` (#786).
* `Chat$chat()`, `Chat$stream()`, and similar methods now add empty tool results when a the chat is interrupted during a tool call loop, allowing the conversation to be resumed without causing an API error (#840).
* `Chat$chat_structured()` and friends now only warn if multiple JSON payloads found (instead of erroring) (@kbenoit, #732).
* `Chat$get_tokens()` gives a brief description of the turn contents to make it easier to see which turn tokens are spent on (#618) and also returns the cost (#824). It now returns one row for each assistant turn, better representing the underlying data received from LLM APIs. Similarly, the `print()` method now reports costs on each assistant turn, rather than trying to parse out individual costs.
* `interpolate_package()` now provides an informative error if the requested prompt file is not found in the package's `prompts/` directory (#763) and now works with in-development packages loaded with devtools (#766).
* `models_mistral()` lists available models (@rplsmn, #750).
* `models_ollama()` was fixed to correctly query model capabilities from remote Ollama servers (#746).
* `chat_ollama()` now uses `credentials` when checking if Ollama is available and `models_ollama()` now has a `credentials` argument. This is useful when accessing Ollama servers that require authentication (@AdaemmerP, #863).
* `parallel_chat_structured()` now returns a tibble, since this does a better job of printing more complex data frames (#787).

