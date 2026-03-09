.PHONY: build serve check-hugo render-slides

HUGO_VERSION ?= default
HOST ?= 127.0.0.1
PORT ?= 4321

build: check-hugo render-slides
	Rscript -e "ver <- '$(HUGO_VERSION)'; options(blogdown.hugo.version = if (identical(ver, 'default')) NULL else ver); blogdown::build_site(local = FALSE, build_rmd = FALSE)"

serve: check-hugo
	Rscript -e "ver <- '$(HUGO_VERSION)'; options(blogdown.hugo.version = if (identical(ver, 'default')) NULL else ver); blogdown::serve_site(host = '$(HOST)', port = $(PORT))"

check-hugo:
	Rscript -e "ver <- '$(HUGO_VERSION)'; options(blogdown.hugo.version = if (identical(ver, 'default')) NULL else ver); path <- tryCatch(blogdown::find_hugo(quiet = TRUE), error = function(e) ''); if (!nzchar(path)) stop(if (identical(ver, 'default')) 'No Hugo installation found for blogdown. Install one with blogdown::install_hugo().' else sprintf('Hugo %s is required. Install it with blogdown::install_hugo(version = \"%s\")', ver, ver), call. = FALSE); cat(sprintf('Using Hugo at %s\\n', path))"

render-slides:
	bash ./scripts/render_slides.sh
