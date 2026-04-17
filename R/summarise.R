# Read all items in content/<current week>/ and ask Claude to draft a digest.
# Writes to newsletters/<week>.md.

source("R/utils.R")
suppressPackageStartupMessages({
  library(fs)
  library(ellmer)
})

week <- week_key()
content_dir <- file.path("content", week)

if (!dir_exists(content_dir)) {
  message("No content directory for ", week, " - nothing to summarise")
  quit(save = "no", status = 0)
}

items <- dir_ls(content_dir, glob = "*.md")
if (length(items) == 0) {
  message("No items in ", content_dir, " - nothing to summarise")
  quit(save = "no", status = 0)
}

message("Summarising ", length(items), " items from ", content_dir)

bundle <- paste(
  vapply(items, function(p) {
    paste0("=== ", path_file(p), " ===\n", paste(readLines(p, warn = FALSE), collapse = "\n"))
  }, character(1)),
  collapse = "\n\n"
)

system_prompt <- paste(
  "You are drafting a weekly digest for a newsletter about AI tooling and the R ecosystem.",
  "Given a bundle of articles fetched this week (each with frontmatter: title, url, source, date),",
  "produce a markdown newsletter with:",
  "- a one-line intro framing the week",
  "- grouped sections (e.g. LLM tooling, R packages, commentary, security) with short H2 headers",
  "- for each item, 2-4 sentence summary, link the title to its url",
  "- skip items that aren't genuinely interesting or are off-topic",
  "Keep the voice practical, readable, a little dry. No emojis.",
  sep = "\n"
)

chat <- chat_anthropic(
  model = "claude-sonnet-4-6",
  system_prompt = system_prompt
)

draft <- chat$chat(bundle)

dir_create("newsletters")
out_path <- file.path("newsletters", paste0(week, ".md"))
writeLines(as.character(draft), out_path)
message("Wrote ", out_path)
