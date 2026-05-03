---
title: "tidyllm 0.5.0"
url: https://github.com/edubruell/tidyllm/blob/HEAD/NEWS.md#tidyllm-0-5-0
source: tidyllm
date: 2026-04-27
---


## Unified Media Interface

### `.media` argument on `llm_message()`

All non-text content now attaches to messages through a single `.media` argument that accepts any combination of media types. Pass a single object or a list:

```r
# Single image
llm_message("What is in this image?",
            .media = img("photo.jpg")) |>
  chat(claude())

# Multiple images in one message
llm_message("Describe the difference between these two images.",
            .media = list(img("before.jpg"), img("after.jpg"))) |>
  chat(openai())

# Mixed types: image + PDF together
llm_message("Does this figure match what is reported in Table 2?",
            .media = list(img("figure_3.png"),
                          pdf_file("paper.pdf", pages = 1:8))) |>
  chat(gemini())
```

### New media constructors

Three new constructors join `img()`:

- **`audio_file(path)`**: attach audio inline; supported by `gemini()`, `openrouter()`, and `mistral()` (Voxtral models)
- **`video_file(path)`**: attach video inline; supported by `gemini()` and `openrouter()`
- **`pdf_file(path, pages, .text_extract)`**: attach a PDF; Claude and Gemini receive the binary file (preserving layout, tables, and scanned content); all other providers receive extracted text automatically

```r
# Transcribe a recording
llm_message("Summarise what is discussed in this interview.",
            .media = audio_file("bosch_interview.mp3")) |>
  chat(gemini())

# Analyse a video clip with a JSON schema
video_schema <- tidyllm_schema(
  title      = field_chr("Title or subject of the clip"),
  era        = field_chr("Approximate decade or period depicted"),
  key_people = field_chr("Names mentioned, semicolon-separated")
)

llm_message("Analyse this video clip.",
            .media = video_file("documentary.mp4")) |>
  chat(gemini(), .json_schema = video_schema)

# Extract references from a scanned PDF (binary path, no OCR needed)
llm_message("Extract all references in APA format.",
            .media = pdf_file("1995_Neal_Industry_Specific.pdf")) |>
  chat(claude(), .json_schema = ref_schema)

# Force text extraction for any provider
llm_message("Summarise this report.",
            .media = pdf_file("annual_report.pdf", .text_extract = TRUE)) |>
  chat(openai())
```

### Multi-image support

All providers that accept images now handle multiple images per message. Pass them as a list inside `.media`. Claude supports up to 600 images per message; Gemini up to 3,600.

## Provider Files API

A unified set of verbs manages files stored on provider servers. Upload once, reuse across many requests:

```r
# Upload; returns a tidyllm_file handle
report <- upload_file(gemini(), .path = "quarterly_report.pdf")

# Attach the handle to any message via .files
llm_message("What were the key results this quarter?",
            .files = report) |>
  chat(gemini())

llm_message("List the top three risks in the document.",
            .files = report) |>
  chat(gemini())

# Inspect and manage uploaded files
list_files(gemini())
file_info(gemini(), report)      # accepts a tidyllm_file or a plain ID string
delete_file(gemini(), report)
```

The same pattern works with `claude()` and `openai()`. Provider support:

- **Gemini**: PDFs, images, audio, video, plain text, CSV, HTML, and more; files expire after 48 hours
- **Claude**: PDFs and images; no automatic expiry
- **OpenAI**: 80+ formats including PDFs, Office documents (DOCX, PPTX, XLSX), source code, ZIP archives, and images; note that images uploaded via the Files API cannot be used for vision tasks in chat; use inline `img()` instead

A `tidyllm_file` is provider-specific: a file uploaded to Claude cannot be sent to Gemini. tidyllm validates provider match before every request.

## OpenAI Provider Rewrite

### Responses API

`openai()` now uses the [Responses API](https://platform.openai.com/docs/api-reference/responses) (`POST /v1/responses`). All existing workflows continue to work unchanged. New capabilities unlocked by the rewrite:

```r
# Reasoning effort for o-series models
llm_message("Prove that there are infinitely many primes.") |>
  chat(openai(.model = "o4-mini"), .reasoning_effort = "high")

# Stateful multi-turn conversations (server retains context by ID)
first  <- llm_message("My name is Alex.") |>
  chat(openai(), .stateful = TRUE)

second <- llm_message("What is my name?") |>
  chat(openai(), .previous_response_id = first)
```

Batch processing (`send_batch(openai())`) continues to use the Chat Completions endpoint internally.

### Built-in server-executed tools

```r
# Web search: the server runs the search, results appear in the reply
llm_message("What happened in AI research this week?") |>
  chat(openai(), .tools = openai_websearch())

# Code interpreter
llm_message("Plot a histogram of 1,000 standard-normal samples.") |>
  chat(openai(), .tools = openai_code_interpreter())

# Mix built-in and custom tools in one call
llm_message("Find today's EUR/USD rate and convert 500 EUR.") |>
  chat(openai(), .tools = list(openai_websearch(), my_converter_tool))
```

### OpenAI deep research

```r
# Background research job (slow; typically 5 to 30 minutes)
job <- llm_message("Survey the literature on causal inference with LLMs.") |>
  deep_research(openai(.model = "o4-mini-deep-research"), .background = TRUE)

check_job(job)
result <- fetch_job(job)
```

## New Provider: `chat_completions()`

A `chat_completions()` provider for any OpenAI-compatible endpoint (vLLM, LiteLLM, Together AI, Anyscale, and others), without having to repurpose `openai()`:

```r
llm_message("Hello!") |>
  chat(chat_completions(
    .api_url        = "https://api.together.xyz/v1/",
    .api_key_env_var = "TOGETHER_API_KEY",
    .model          = "meta-llama/Llama-3-8b-chat-hf"
  ))
```

## Provider Enhancements

### Mistral

- New `.reasoning_effort` parameter for Magistral thinking models (`"low"`, `"medium"`, `"high"`):
  ```r
  llm_message("Is this argument valid?", .media = pdf_file("proof.pdf")) |>
    chat(mistral(.model = "magistral-medium-latest"), .reasoning_effort = "high")
  ```

### OpenRouter

- Audio and video support: `audio_file()` and `video_file()` now work with OpenRouter and are routed to the underlying model's audio/video endpoint. Filter for capable models by the `audio` modality at openrouter.ai/models.

## Deprecations

The following are soft-deprecated with warnings in 0.5.0 and will remain as permanent aliases:

- **`.imagefile`** on `llm_message()`: use `.media = img(path)` instead
- **`.pdf`** on `llm_message()`: use `.media = pdf_file(path)` instead
- **`claude_upload_file()`, `claude_delete_file()`, `claude_file_metadata()`, `claude_list_files()`**: use `upload_file(claude())`, `delete_file(claude())`, `file_info(claude())`, `list_files(claude())` instead
- **`gemini_upload_file()`, `gemini_delete_file()`, `gemini_file_metadata()`, `gemini_list_files()`**: use the corresponding `upload_file(gemini())` etc. verbs instead
- **`.file_ids`** on `claude_chat()` and **`.fileid`** on `gemini_chat()`: upload with `upload_file()` and attach with `.files` on `llm_message()` instead

## Small Changes

- `file_info()` and `delete_file()` accept a `tidyllm_file` object directly in addition to a plain ID string
- Default model for `claude()` updated to `claude-sonnet-4-6`; fast model updated to `claude-haiku-4-5`
- Default model for `gemini()` updated to `gemini-2.5-flash`; default embedding model updated to `gemini-embedding-2-preview`
- Default model for `voyage_embedding()` updated to `voyage-4`
- Default model for `openai()` updated to `gpt-5.5` (released April 2026)
- Default model for `deepseek()` updated to `deepseek-v4-pro` (DeepSeek V4, released April 2026); `.thinking = TRUE` now enables thinking mode via the `thinking` body parameter instead of switching to the deprecated `deepseek-reasoner` model name; both `deepseek-v4-pro` and `deepseek-v4-flash` support thinking mode

---

