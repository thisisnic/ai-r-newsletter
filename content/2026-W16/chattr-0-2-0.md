---
title: "chattr 0.2.0"
url: https://github.com/mlverse/chattr/blob/HEAD/NEWS.md#chattr-0-2-0
source: chattr
date: 2025-08-18
---


## General

* Fixes how it identifies the user's current UI (console, app, notebook) and
appropriately outputs the response from the model end-point (#92)

## Databricks

* Adding support for Databricks foundation model API (DBRX, Meta Llama 3 70B,
Mixtral 8x7B) (#99)

## OpenAI

* Fixes how it displays error from the model end-point when being used in a 
notebook or the app

* Fixes how the errors from OpenAI are parsed and processed. This should make
it easier for users to determine where an downstream issue could be.

## Copilot

* Adds `model` to defaults 

* Improves token discovery 

