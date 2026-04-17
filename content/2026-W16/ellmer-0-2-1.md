---
title: "ellmer 0.2.1"
url: https://github.com/tidyverse/ellmer/blob/HEAD/NEWS.md#ellmer-0-2-1
source: ellmer
date: 2026-04-13
---


* When you save a `Chat` object to disk, API keys are
  This means that you can no longer easily resume a chat you've saved on disk
  (we'll figure this out in a future release) but ensures that you never
  accidentally save your secret key in an RDS file (#534).

* `chat_anthropic()` now defaults to Claude Sonnet 4, and I've added pricing
  information for the latest generation of Claude models.

* `chat_databricks()` now picks up on Databricks workspace URLs set in the
  configuration file, which should improve compatibility with the Databricks CLI
  (#521, @atheriel). It now also supports tool calling (#548, @atheriel).

* `chat_snowflake()` no longer streams answers that include a mysterious
  `list(type = "text", text = "")` trailer (#533, @atheriel). It now parses
  streaming outputs correctly into turns (#542), supports structured ouputs
  (#544), and standard model parameters (#545, @atheriel).

* `chat_snowflake()` and `chat_databricks()` now default to Claude Sonnet 3.7,
  the same default as `chat_anthropic()` (#539 and #546, @atheriel).

* `type_from_schema()` lets you to use pre-existing JSON schemas in structured
  chats (#133, @hafen)

