---
title: "rollama 0.3.1"
url: https://github.com/JBGruber/rollama/blob/HEAD/NEWS.md#rollama-0-3-1
source: rollama
date: 2026-08-24
---


* `query()` can now batch annotate several images with the same prompt by passing `images` as a list (one element per query)
* updated image annotation vignette to explain batch annotation
* `create_model()` gains renderer and parser params
* `query()/chat()` `output = "data.frame"`/`"list"` now include `thinking` and `tool_calls` from the response
* `think` argument in `query()/chat()` now accepts `"high"`/`"medium"`/`"low"`/`"max"` in addition to `TRUE`/`FALSE`
* fixes issue in tests
* bug fixes

