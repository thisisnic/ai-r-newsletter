---
title: "tidyllm 0.6.0"
url: https://github.com/edubruell/tidyllm/blob/HEAD/NEWS.md#tidyllm-0-6-0
source: tidyllm
date: 2026-09-03
---


**tidyllm no longer has to block.** A script can fire a request and keep working,
several prompts can run at once, and a Shiny app can stream tokens into its UI
without freezing itself or anyone else's session. The headline verbs are
`send_chat()` and `parallel_chat()`; underneath them sit a shared streaming pump
and a chat pipeline split that every provider now goes through. Streaming and
tool calls also stop being mutually exclusive.

No new required dependency: `later` and `promises` are in `Suggests` and checked
where they are used, and the Shiny path needs neither `promises` nor `coro`.

## `send_chat()`: a chat that does not block the session

There are now three ways to run a chat. `chat()` when you want the answer now.
`send_batch()` when you have thousands of prompts and want them at half price
overnight. And new in 0.6.0, `send_chat()` when you have *one* slow request and
a session you would rather keep using. All three end in an `LLMMessage`, and the
last two share the same `check_job()` / `fetch_job()` vocabulary.

```r
job <- llm_message("Summarise this 400-page report") |>
  send_chat(claude(), .stream = TRUE)

while (check_job(job) == "running") {
  do_something_else()
  cat("\r", nchar(get_partial(job)), "characters so far")
}

reply <- fetch_job(job)          # the LLMMessage chat() would have returned
```

`get_partial()` is the text so far and `cancel_job()` stops the request.
`.on_chunk` is the push form of the same thing: a function called with each
delta as it arrives, which is all a Shiny app needs to render a reply
token-by-token into a `reactiveVal`, with no `promises` and no `coro` involved.

Nothing runs on a thread or in a second process. The request is driven from R's
own event loop, waiting on curl's file descriptors rather than on a timer, in
the gaps between whatever else the session is doing. Two consequences follow
from that and are worth knowing: several jobs run genuinely concurrently, and a
blocking call of your own pauses them all for its duration.

Requires the `later` package, and `promises` as well for `.stream = FALSE`.
Neither is a new hard dependency; both are checked at the point of use.

Known limits of the first cut: a job with `.tools` performs its tool rounds
without yielding, so the session pauses for their duration, and a streamed job
is not retried after a transient 429 the way `chat()` is.

`check_job()` and `fetch_job()` are S3 generics now rather than a chain of
`if`s, so batch jobs, background research jobs and chat jobs are one vocabulary
reached by one mechanism.

## `parallel_chat()`: many prompts at once

```r
answers <- parallel_chat(list(physics = llm_message("What is a photon?"),
                              biology = llm_message("What is a ribosome?")),
                         claude())
```

Performs a list of messages concurrently against one provider and returns their
replies in the same order under the same names. Measured on three one-sentence
questions to `claude()`: 2.1 seconds against 5.4 for the same three in a loop.

`.max_active` bounds how many are in flight and `.throttle` caps requests per
second; both matter more than they look, because `httr2` applies retries across
the whole set rather than per request, so a high `.max_active` against a
rate-limited provider is a good way to collect 429s.

A failed request is returned in its own slot as the condition that failed,
rather than as a hole that would silently shorten a downstream `map()`.
Streaming and tool calls are refused rather than quietly ignored: use
`send_chat()`, which can hold several conversations at once.

## Shiny: an example app and an article

`tidyllm_example_app("model_explainer")` runs a small Shiny app that ships with
the package. It fits a linear model to a public dataset and streams two
explanations of the coefficients side by side, one in plain English and one from
a sceptical referee, while the app stays responsive. Every number the model sees
is computed in R and pasted into the prompt verbatim; the model does the
narrating and none of the arithmetic.

It defaults to a local `ollama()` model, so it runs with no API key and no spend,
and a dropdown switches it to Claude, OpenAI or Gemini. The source is a single
file, and it is the reference implementation for the things a real app needs:
`.on_chunk` into a `reactiveVal`, a status observer for the failures that carry
no delta, `cancel_job()` on a button and on `session$onSessionEnded()`, and a
follow-up turn on the immutable `LLMMessage`.

The new article *Using tidyllm in Shiny* walks through those patterns and closes
with what to watch out for, including one worth knowing before you design a UI: a
streaming `send_chat()` returns when the response headers arrive, so a server
that answers one request at a time (a stock Ollama) makes a second concurrent
job wait, while cloud providers stream both at once.

`shiny` and `wooldridge` are new in `Suggests`, for the app and one of its
datasets.

## Streaming and tool calls work together

`.stream = TRUE` and `.tools` used to be mutually exclusive: every provider
raised "Streaming is not supported for requests with tool calls" if both were
given. That restriction is gone for `claude()`, `openai()`, `gemini()`,
`ollama()`, `groq()`, `mistral()`, `deepseek()`, `openrouter()`, `llamacpp()`,
`azure_openai()` and `chat_completions()`. The reply streams to the console, the
tool calls run when the stream ends, and each follow-up round streams too.

```r
llm_message("What is the weather in Berlin and Reykjavik?") |>
  chat(claude(), .tools = weather_tool, .stream = TRUE)
```

The reason it was blocked is that the tool loop reads tool calls out of a
complete response body, which a stream never produced; it produced a list of
events instead. A new `assemble_stream_body()` generic folds those events
back into the body shape, so `has_tool_calls()`, `extract_tool_calls()`,
`run_tool_calls()` and `append_tool_messages()` are reused without a single
streaming-specific branch. Streamed and blocking responses now carry the same
`raw$content`, which is also what the async driver needs.

Only Claude requires real reassembly: it streams tool arguments as JSON
fragments that split mid-token and interleave between two concurrent calls, so
they are accumulated per content block rather than into one buffer. OpenAI's
`response.completed` event already carries fully-formed calls, and Gemini and
Ollama send their calls parsed.

Details worth knowing, all of them cases that only exist because the two can now
be combined:

* A streamed reply whose tool call is cut off by `max_tokens` mid-arguments no
  longer raises. The partial arguments are dropped and the turn ends on its own
  `stop_reason`, so a reply the user has already watched arrive is not thrown
  away.
* Claude's `thinking` blocks and their signatures survive assembly, so
  `.thinking = TRUE` works together with `.stream` and `.tools`. Built-in tools
  such as `claude_websearch()` keep their arguments too.
* Streamed logprobs still work. They used to be read by a separate branch that
  walked the per-chunk deltas; they are now collected into the same place a
  blocking response carries them, and both transports take one path.
* A provider that streams but has no assembler raises rather than silently
  skipping its tools and returning the model's preamble as the answer.

## Internal: the chat pipeline

Nothing user-visible changed here, but it is the largest structural change in
the release. Every `*_chat()` used to be one function body welding request
construction, the HTTP call, the tool loop and `add_message()` together, which
meant nothing but `*_chat()` itself could reach the middle of it.

* Twelve providers now split into `<provider>_build_chat_request()` plus a thin
  wrapper. The builder returns everything the response handling needs; the
  shared `finish_chat_response()` runs the tool loop, extracts the reply and
  metadata, tracks rate limits and appends the message.
* Whether a request streams is decided at build time rather than at perform
  time, because every provider commits to streaming in the request itself:
  Gemini in the URL path, the rest in the request body.
* `.dry_run = TRUE` still returns the bare `httr2` request, unchanged.
* `ratelimit_from_header()` and `parse_logprobs()` gained an `APIProvider`
  default returning `NULL`, and the providers that inherit a method they should
  not use override it back. Whether a provider reports rate limits or logprobs is
  now a property of its class rather than a flag each call site had to set
  correctly. A new `api_compatible` class covers `chat_completions(.compatible =
  TRUE)`, which is a third-party endpoint speaking the OpenAI dialect and does
  not return OpenAI's rate limit headers.
* `interpret_chat_response()` splits response interpretation away from transport,
  so a driver holding a response from `req_perform_promise()` or
  `req_perform_parallel()` can reach the same handling the blocking path uses.
* A streamed response is now interpreted by exactly the same code as a blocking
  one. `extract_metadata_stream()`, a generic with six methods, is gone: once
  `assemble_stream_body()` turns the events into a response body, the reply
  comes from `parse_chat_response()` and the metadata from `extract_metadata()`,
  and the streaming branch ends in `interpret_chat_response()` like every other
  path. Beyond deleting the duplicate, this is what makes an incomplete
  assembler detectable: the reply used to come from the pump's own text
  accumulator, so an assembler could drop content and no plain streaming test
  would notice.
* `process_tool_loop()` performs its follow-up rounds through a closure the
  caller supplies rather than by calling `perform_chat_request()` itself. It had
  no business deciding how a round is performed, and deciding it twice is what
  made `openai_chat(.stateful = TRUE)` apply its retry to the opening request
  only (see the bug fixes below). It is also the seam the event-loop driver
  needs, which will hand in a non-blocking performer.
* Streamed `gemini()` metadata therefore reports the same `api_specific` fields
  as a blocking call: `cachedContentTokenCount`, `avgLogprobs` and
  `groundingMetadata` appear, and the streaming-only `token_details` entry (a
  copy of the raw `usageMetadata`) is gone. Token counts, `finishReason` and
  `thinking_tokens` are unchanged.

## Bug fixes (this development cycle)

* `pdf_page_batch(.page_range=)` rendered the wrong pages. The text was subset to
  the requested range but the images were rendered from the position within that
  subset, so `.page_range = c(3, 5)` paired page 3's text with page 1's image.
  The page numbers are now carried through the whole function.

* `pdf_page_batch()` returns a **named** list, `page_1`, `page_2` and so on, with
  the numbers from the original document. `parallel_chat()` preserves names, so a
  reply can now be traced back to its page.

* A verb a provider does not implement at all says so. `send_chat()` on
  `chat_ellmer()` used to fail with a generic complaint about unsupported
  arguments; it now names the verb and the provider and explains that
  `chat_ellmer()` hands the conversation to an ellmer `Chat` object rather than
  building a request, so there is nothing for tidyllm to stream. The same holds
  for `parallel_chat()`, and for any other verb/provider pair that was never
  registered.

* Deprecation warnings for `claude(.file_ids=)` and `gemini(.fileid=)` no longer
  tell the user the feature "was likely used in the tidyllm package" and ask them
  to file an issue. The pipeline split moved these calls one frame deeper, which
  changed how `lifecycle` resolved the calling environment.

* `openai_chat(.stateful = TRUE)` recovers from an expired server-side context
  on any request of the turn, not just the first. Each round of the tool loop
  used to bypass the retry entirely, so a context that expired mid-conversation
  failed outright. The rebuild itself is still attempted only on the opening
  request, and now says why: the body it reconstructs is the conversation as it
  stood before the turn began, so using it later would discard the tool calls
  and results exchanged since. A round that falls back also tells the loop which
  request it actually sent, so the next round builds on that one.

* `perplexity()` attaches its search results to the metadata again. The hook
  read them from the response object rather than from the parsed body inside it,
  so `get_metadata()$api_specific$search_results` had always been `NULL`.
  Streamed replies carry them too, since the assembler now merges Perplexity's
  response-level `search_results` and `citations` fields.

## Streaming

* Every provider now streams through one shared pump. The six hand-rolled
  `repeat` loops are gone; a provider customises streaming by implementing
  `parse_stream_event()` and declaring its `stream_transport`, never by writing
  another loop.
* **A truncated or abnormally terminated stream raises instead of hanging.** The
  old loops relied solely on a provider-specific terminal event, so a closed
  connection, a mid-stream provider error or an unrecognised `finish_reason`
  span forever. The pump checks `resp_stream_is_complete()` on every empty read.
  Measured before the change, `openai()`, `claude()` and the whole
  ChatCompletions family hung; all providers now raise.
* `.timeout` finally applies to streaming, as an idle deadline between events
  rather than a total, so a long generation is not killed for being long. The
  streaming path previously had no timeout backstop at all.
* `perplexity()` streams now terminate on any `finish_reason`, not only
  `"stop"`; a reply cut short by `"length"` used to spin.
* `gemini()` streaming moved to the `alt=sse` endpoint. Without that query
  parameter the endpoint returns a pretty-printed JSON array in chunks with no
  SSE framing, which is why tidyllm buffered the text and pattern matched it.
  Gemini streaming metadata now reports `finishReason` and `thinking_tokens`
  alongside the token counts.
* Thinking deltas are distinguished from reply text on every provider that emits
  them, rather than being concatenated into the reply or dropped silently.
* The console path opens its connection with `blocking = TRUE` instead of
  spinning on empty reads. Output is unchanged; cadence may differ slightly, and
  Ollama no longer needs its 0.25s sleep per line.

## Credential handling

* `gemini()` no longer puts the API key in the URL query string. All fifteen Gemini
  request builders now send it as a redacted `x-goog-api-key` header, so
  `.dry_run = TRUE`, `req_verbose()` and any httr2 error carrying the URL no longer
  print the live key.
* `azure_openai()` marks its `api-key` header as redacted. It was stored as an
  ordinary string, so the key survived `print()` and `serialize()` on the request
  object.

## Bug fixes

* `chat_completions()` could not be reached through `chat()` with any common
  argument at all; `chat(..., .dry_run = TRUE)` and every other shared argument
  raised "not supported by the provider's `chat()` function". Provider functions
  that forward through `...` are now recognised as accepting any common argument.
* A missing API key raised `object 'api' not found` instead of the intended
  instruction naming the environment variable to set.
* `chat_ellmer()` sent the last user message twice. The full history, including the
  final user turn, was written onto the cloned ellmer `Chat` and then that same turn
  was sent again by `$chat()`. It now sets only the preceding turns, and it uses
  ellmer's public `$set_turns()` rather than reaching into the object's private
  environment.
* `chat_ellmer()` accepted `.stream = TRUE` and silently performed a non-streaming
  request. It now streams through ellmer's `$stream()`, and `get_metadata()` reports
  `stream = TRUE` for those replies.
* `claude_chat()` ignored `.max_tries` and always used the default of 3.
* `ollama_chat()` gains `.max_tries`, which was hardcoded to 3.
* The Ollama stream loop no longer crashes with a JSON lexer error on an empty read,
  and it raises instead of looping when the connection completes before the model
  reports `done`.
* The ChatCompletions stream loop recorded the last event twice. The duplicate is
  gone and the final usage-only chunk is now recorded where it is produced rather
  than on the `[DONE]` branch.
* `pdf_page_batch()` no longer emits one deprecation warning per page; it uses
  `.media = img()` instead of the deprecated `.imagefile`.
* Deleted the duplicate `openai` and `chatgpt` bindings in `R/api_chat_completions.R`,
  which shipped as dead code shadowed by the Responses API definitions.
* Deleted the `generate_callback_function()` generic, which wrote into an environment
  that is never created and would have errored if called.
* `R/api_ellmer.R` no longer short-circuits at the top level when ellmer is absent,
  which would have broken the NAMESPACE exports; `chat_ellmer()` checks for ellmer at
  call time instead.

