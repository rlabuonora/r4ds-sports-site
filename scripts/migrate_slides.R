#!/usr/bin/env Rscript

source_root <- normalizePath("../r4ds-sports-slides", mustWork = TRUE)
target_root <- normalizePath(".", mustWork = TRUE)
slides_root <- file.path(target_root, "slides-src")

session_dates <- c(
  "r4ds-sports-session1" = "2023-09-20",
  "r4ds-sports-session2" = "2023-09-26",
  "r4ds-sports-session3" = "2023-09-28",
  "r4ds-sports-session4" = "2023-10-11",
  "r4ds-sports-session5" = "2023-10-18",
  "r4ds-sports-session6" = "2023-11-22",
  "r4ds-sports-session7" = "2023-12-14",
  "r4ds-sports-session8" = "2024-01-03"
)

dir.create(slides_root, recursive = TRUE, showWarnings = FALSE)

write_lines <- function(path, lines) {
  writeLines(lines, path, useBytes = TRUE)
}

sanitize_yaml_string <- function(x) {
  x <- gsub("^['\"]|['\"]$", "", trimws(x))
  x <- gsub("\"", "\\\\\"", x, fixed = TRUE)
  x
}

extract_yaml_value <- function(yaml, key) {
  pattern <- sprintf("^%s:\\s*(.*)$", key)
  hit <- grep(pattern, yaml, perl = TRUE, value = TRUE)
  if (!length(hit)) {
    return(NULL)
  }
  sub(pattern, "\\1", hit[[1]], perl = TRUE)
}

drop_chunk <- function(lines, label) {
  start <- grep(sprintf("^```\\{r\\s+%s\\b", label), lines, perl = TRUE)
  if (!length(start)) {
    return(lines)
  }
  end <- start
  while (end <= length(lines) && trimws(lines[[end]]) != "```") {
    end <- end + 1
  }
  lines[-seq.int(start[[1]], min(end, length(lines)))]
}

pending_attrs <- function(id = NULL, classes = character(), background = NULL) {
  attrs <- character()
  if (!is.null(id) && nzchar(id)) {
    attrs <- c(attrs, paste0("#", id))
  }
  if (length(classes)) {
    attrs <- c(attrs, paste0(".", classes))
  }
  if (!is.null(background) && nzchar(background)) {
    attrs <- c(
      attrs,
      sprintf("background-image=\"url('%s')\"", background),
      "background-size=\"contain\"",
      "background-position=\"center\"",
      "background-repeat=\"no-repeat\""
    )
  }
  if (!length(attrs)) {
    return("")
  }
  paste0(" {", paste(attrs, collapse = " "), "}")
}

convert_body <- function(lines) {
  lines <- drop_chunk(lines, "xaringan-themer")
  out <- character()
  pending_id <- NULL
  pending_classes <- character()
  pending_background <- NULL
  in_pull <- FALSE
  slide_break_pending <- FALSE

  flush_pending_heading <- function() {
    attrs <- pending_attrs(pending_id, pending_classes, pending_background)
    pending_id <<- NULL
    pending_classes <<- character()
    pending_background <<- NULL
    if (!nzchar(attrs)) {
      return(character())
    }
    c(paste0("##", attrs), "")
  }

  for (line in lines) {
    if (trimws(line) == "---") {
      slide_break_pending <- TRUE
      next
    }

    if (grepl("^exclude:\\s*`r ", line)) {
      next
    }

    if (trimws(line) == "ry/branching.png)") {
      next
    }

    if (grepl("^name:\\s*", line)) {
      pending_id <- sub("^name:\\s*", "", line)
      next
    }

    if (grepl("^class:\\s*", line)) {
      classes <- gsub(",", "", trimws(sub("^class:\\s*", "", line)), fixed = TRUE)
      pending_classes <- unlist(strsplit(classes, "[[:space:]]+"))
      next
    }

    if (grepl("^background-image:\\s*url\\(", line)) {
      pending_background <- sub("^background-image:\\s*url\\((.*)\\)\\s*$", "\\1", line)
      next
    }

    if (grepl("^background-(size|position|repeat):\\s*", line)) {
      next
    }

    if (slide_break_pending && nzchar(trimws(line)) && !grepl("^#+\\s", line)) {
      heading <- flush_pending_heading()
      if (!length(heading)) {
        heading <- c("##", "")
      }
      out <- c(out, heading)
      slide_break_pending <- FALSE
    }

    if (grepl("^\\.(pull-left|pull-right|center)\\[", line)) {
      class_name <- sub("^\\.(pull-left|pull-right|center)\\[.*$", "\\1", line)
      remainder <- sub("^\\.(pull-left|pull-right|center)\\[", "", line)
      out <- c(out, sprintf("::: {.%s}", class_name))
      if (nzchar(remainder)) {
        out <- c(out, remainder)
      }
      in_pull <- TRUE
      next
    }

    if (trimws(line) == "]" && in_pull) {
      out <- c(out, ":::")
      in_pull <- FALSE
      next
    }

    if (grepl("^\\.foo?t?note\\[", line)) {
      footnote <- sub("^\\.foo?t?note\\[(.*)\\]\\s*$", "\\1", line)
      out <- c(out, sprintf("<div class=\"footer-note\">%s</div>", footnote))
      next
    }

    if (grepl("^#+\\s", line)) {
      if (grepl("^#\\s", line)) {
        line <- sub("^#\\s+", "## ", line)
      }
      attrs <- pending_attrs(pending_id, pending_classes, pending_background)
      pending_id <- NULL
      pending_classes <- character()
      pending_background <- NULL
      out <- c(out, paste0(line, attrs))
      slide_break_pending <- FALSE
      next
    }

    if (nzchar(trimws(line)) && (length(pending_classes) || !is.null(pending_id) || !is.null(pending_background))) {
      out <- c(out, flush_pending_heading())
      slide_break_pending <- FALSE
    }

    out <- c(out, line)
  }

  out
}

copy_support_files <- function(from_dir, to_dir) {
  files <- list.files(from_dir, all.files = TRUE, no.. = TRUE, full.names = TRUE)
  keep <- files[!grepl("(^|/)(\\.git|index_files)$", files)]
  keep <- keep[!grepl("(session[0-9]+\\.Rproj|xaringan-themer\\.css|index\\.html)$", keep)]
  keep <- keep[basename(keep) != "index.Rmd"]
  keep <- keep[basename(keep) != ".gitignore"]

  for (path in keep) {
    rel <- substring(path, nchar(from_dir) + 2)
    dest <- file.path(to_dir, rel)
    if (dir.exists(path)) {
      dir.create(dest, recursive = TRUE, showWarnings = FALSE)
      next
    }
    dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
    file.copy(path, dest, overwrite = TRUE, recursive = FALSE)
  }
}

create_session_qmd <- function(session_dir) {
  session_name <- basename(session_dir)
  target_dir <- file.path(slides_root, sub("^r4ds-sports-", "", session_name))
  dir.create(target_dir, recursive = TRUE, showWarnings = FALSE)

  lines <- readLines(file.path(session_dir, "index.Rmd"), warn = FALSE, encoding = "UTF-8")
  yaml_end <- which(lines == "---")[2]
  yaml <- lines[2:(yaml_end - 1)]
  body <- lines[(yaml_end + 1):length(lines)]

  title <- sanitize_yaml_string(extract_yaml_value(yaml, "title") %||% sub("^r4ds-sports-", "", session_name))
  subtitle <- extract_yaml_value(yaml, "subtitle")

  front_matter <- c(
    "---",
    sprintf("title: \"%s\"", title),
    sprintf("date: \"%s\"", session_dates[[session_name]]),
    "format:",
    "  revealjs:",
    "    theme: default",
    "    css: ../_styles/slides.css",
    "    title-slide: false",
    "    slide-number: true",
    "    width: 1600",
    "    height: 900",
    "execute:",
    "  warning: false",
    "  message: false",
    "  cache: false",
    "---",
    ""
  )

  if (!is.null(subtitle) && nzchar(trimws(subtitle))) {
    front_matter <- append(front_matter, sprintf("subtitle: \"%s\"", sanitize_yaml_string(subtitle)), after = 2)
  }

  qmd <- c(front_matter, convert_body(body))
  write_lines(file.path(target_dir, "index.qmd"), qmd)
  copy_support_files(session_dir, target_dir)
}

`%||%` <- function(x, y) {
  if (is.null(x) || !length(x) || !nzchar(trimws(x))) y else x
}

dir.create(file.path(slides_root, "_styles"), recursive = TRUE, showWarnings = FALSE)

write_lines(
  file.path(slides_root, "_quarto.yml"),
  c(
    "project:",
    "  type: default",
    "  output-dir: ../static/slides",
    ""
  )
)

write_lines(
  file.path(slides_root, "_styles", "slides.css"),
  c(
    ":root {",
    "  --slide-accent: #1381b0;",
    "  --slide-accent-2: #ff961c;",
    "  --slide-ink: #1f2a37;",
    "}",
    "",
    ".reveal {",
    "  font-size: 30px;",
    "}",
    "",
    ".reveal h1,",
    ".reveal h2,",
    ".reveal h3 {",
    "  color: var(--slide-accent);",
    "}",
    "",
    ".reveal a {",
    "  color: var(--slide-accent-2);",
    "}",
    "",
    ".reveal pre code {",
    "  font-size: 0.8em;",
    "}",
    "",
    ".reveal .slide-number {",
    "  color: var(--slide-accent);",
    "}",
    "",
    ".reveal .pull-left,",
    ".reveal .pull-right {",
    "  float: left;",
    "  width: 48%;",
    "}",
    "",
    ".reveal .pull-right {",
    "  float: right;",
    "}",
    "",
    ".reveal .pull-left > :last-child,",
    ".reveal .pull-right > :last-child {",
    "  margin-bottom: 0;",
    "}",
    "",
    ".reveal .footer-note {",
    "  position: absolute;",
    "  left: 1.5rem;",
    "  right: 1.5rem;",
    "  bottom: 1rem;",
    "  font-size: 0.55em;",
    "  color: #555;",
    "}",
    "",
    ".reveal section.inverse {",
    "  background: var(--slide-accent);",
    "  color: #fff;",
    "}",
    "",
    ".reveal section.inverse h1,",
    ".reveal section.inverse h2,",
    ".reveal section.inverse h3,",
    ".reveal section.inverse a,",
    ".reveal section.inverse .slide-number {",
    "  color: #fff;",
    "}",
    "",
    ".reveal section.center {",
    "  text-align: center;",
    "}",
    "",
    ".reveal section.middle {",
    "  top: 50% !important;",
    "}",
    ""
  )
)

session_dirs <- list.dirs(source_root, recursive = FALSE, full.names = TRUE)
session_dirs <- session_dirs[grepl("r4ds-sports-session[0-9]+$", session_dirs)]

for (session_dir in session_dirs) {
  create_session_qmd(session_dir)
}
