---
title: "chattr 0.3.0"
url: https://github.com/mlverse/chattr/blob/HEAD/NEWS.md#chattr-0-3-0
source: chattr
date: 2025-08-18
---


* Switches to `ellmer` for all integration with the LLMs. This effectively 
removes any direct integration such as that one used for OpenAI, Databricks
and LlamaGPT-chat. It will now only integrate with whatever backend
`ellmer` integrates with.

* Shiny app now uses the stream from functionality from `ellmer` instead of the
more complex, and error prone, background process.

