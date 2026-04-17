---
title: "ellmer 0.3.0"
url: https://github.com/tidyverse/ellmer/blob/HEAD/NEWS.md#ellmer-0-3-0
source: ellmer
date: 2026-04-13
---


## New features

* New `chat()` allows you to chat with any provider using a string like `chat("anthropic")` or `chat("openai/gpt-4.1-nano")` (#361).

* `tool()` has a simpler specification: you now specify the `name`, `description`, and `arguments`. I have done my best to deprecate old usage and give clear errors, but I have likely missed a few edge cases. I apologize for any pain that this causes, but I'm convinced that it is going to make tool usage easier and clearer in the long run. If you have many calls to convert, `?tool` contains a prompt that will help you use an LLM to convert them (#603). It also now returns a function so that you can call it (and/or export it from your package) (#602).

* `type_array()` and `type_enum()` now have the description as the second argument and `items`/`values` as the first. This makes them easier to use in the common case where the description isn't necessary (#610).

* ellmer now retries requests up to 3 times, controllable with `option(ellmer_max_tries)`, and will retry if the connection fails (rather than just if the request itself returns a transient error). The default timeout, controlled by `option(ellmer_timeout_s)`, now applies to the initial connection phase. Together, these changes should make it much more likely for ellmer requests to succeed.

* New `parallel_chat_text()` and `batch_chat_text()` make it easier to just get the text response from multiple prompts (#510).

* ellmer's cost estimates are considerably improved. `chat_openai()`, `chat_google_gemini()`, and `chat_anthropic()` capture the number of cached input tokens. This is primarily useful for OpenAI and Gemini since both offer automatic caching, yielding improved cost estimates (#466). We also have a better source of pricing data, LiteLLM. This considerably expands the number of providers and models that include cost information (#659).

## Bug fixes and minor improvements

* The new `ellmer_echo` option controls the default value for `echo`.
* `batch_chat_structured()` provides clear messaging when prompts/path/provider don't match (#599).
* `chat_aws_bedrock()` allows you to set the `base_url()` (#441).
* `chat_aws_bedrock()`, `chat_google_gemini()`, `chat_ollama()`, and `chat_vllm()` use a more robust method to generate model URLs from the `base_url` (#593, @benyake).
* `chat_cortex_analyst()` is deprecated; please use `chat_snowflake()` instead (#640).
* `chat_github()` (and other OpenAI extensions) no longer warn about `seed` (#574).
* `chat_google_gemini()` and `chat_google_vertex()` default to Gemini 2.5 flash (#576).
* `chat_huggingface()` works much better.
* `chat_openai()` supports `content_pdf_()` (#650).
* `chat_portkey()` works once again, and reads the virtual API key from the `PORTKEY_VIRTUAL_KEY` env var (#588).
* `chat_snowflake()` works with tool calling (#557, @atheriel).
* `Chat$chat_structured()` and friends no longer unnecessarily wrap `type_object()` for `chat_openai()` (#671).
* `Chat$chat_structured()` suppresses tool use. If you need to use tools and structured data together, first use `$chat()` for any needed tools, then `$chat_structured()` to extract the data you need.
* `Chat$chat_structured()` no longer requires a prompt (since it may be obvious from the context) (#570).
* `Chat$register_tool()` shows a message when you replace an existing tool (#625).
* `contents_record()` and `contents_replay()` record and replay `Turn` related information from a `Chat` instance (#502). These methods can be used for bookmarking within {shinychat}.
* `models_github()` lists models for `chat_github()` (#561).
* `models_ollama()` includes a `capabilities` column with a comma-separated list of model capabilities (#623).
* `parallel_chat()` and friends accept lists of `Content` objects in the `prompt` (#597, @thisisnic).
* Tool requests show converted arguments when printed (#517).
* `tool()` checks that the `name` is valid (#625).

