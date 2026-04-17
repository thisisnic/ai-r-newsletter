---
title: "ollamar 1.2.0"
url: https://github.com/hauselin/ollama-r/blob/HEAD/NEWS.md#ollamar-1-2-0
source: ollamar
date: 2025-03-24
---


- All functions calling API endpoints have `endpoint` parameter.
- All functions calling API endpoints have `...` parameter to pass additional model options to the API.
- All functions calling API endpoints have `host` parameter to specify the host URL. Default is `NULL`, which uses the default Ollama URL.
- Add `req` as an output format for `generate()` and `chat()`.
- Add new functions for calling APIs: `create()`, `show()`, `copy()`, `delete()`, `push()`, `embed()` (supercedes `embeddings()`), `ps()`.
- Add helper functions to manipulate chat/conversation history for `chat()` function (or other APIs like OpenAI): `create_message()`, `append_message()`, `prepend_message()`, `delete_message()`, `insert_message()`.
- Add `ohelp()` function to chat with models in real-time.
- Add helper functions: `model_avail()`, `image_encode_base64()`, `check_option_valid()`, `check_options()`, `search_options()`, `validate_options()`

