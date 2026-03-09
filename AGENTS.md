# Repository Instructions

## Overview
- This repo is a `blogdown`/Hugo site for the R4DS sports course.
- Blog posts live under `content/`.
- Generated site output lives under `public/`.
- Slide sources live under `slides-src/` and render into `static/slides/`.

## Local Workflow
- Use `make build` to render slides and build the site.
- Use `make serve` to serve the site locally from WSL.
- By default, the `Makefile` uses the Hugo version already installed for `blogdown`.
- Override Hugo explicitly with `make build HUGO_VERSION=0.110.0` or `make serve HUGO_VERSION=0.110.0`.
- Override the local server port with `make serve PORT=4321`.
- The default local port is `4321`.
- The dev server binds to `127.0.0.1`, so open `http://localhost:4321` from Windows unless you changed `PORT`.

## Implementation Details
- The site build runs through `blogdown::build_site()`.
- The local server runs through `blogdown::serve_site(host = "0.0.0.0", port = PORT)`.
- Slides are rendered by `bash ./scripts/render_slides.sh`, which calls `quarto render`.

## Guardrails
- Do not hand-edit files under `public/` unless the task is specifically about generated output.
- Prefer changing source files under `content/`, `layouts/`, `static/`, `themes/`, or `slides-src/`.
- Keep the `Makefile` as the canonical entry point for local build and serve tasks.
