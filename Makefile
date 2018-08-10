## Put this Makefile in your project directory---i.e., the directory
## containing the paper you are writing. Assuming you are using the
## rest of the toolchain here, you can use it to create .html, .tex,
## and .pdf output files (complete with bibliography, if present) from
## your markdown file.
## -	Change the paths at the top of the file as needed.
## -	Using `make` without arguments will generate html, tex, and pdf
## 	output files from all of the files with the designated markdown
##	extension. The default is `.md` but you can change this.
## -	You can specify an output format with `make tex`, `make pdf` or
## - 	`make html`.
## -	Doing `make clean` will remove all the .tex, .html, and .pdf files
## 	in your working directory. Make sure you do not have files in these
##	formats that you want to keep!

BOOK_NAME_SLUG = sample-book
EDITION := open-review
.DEFAULT_GOAL := chapters
.PRECIOUS: website/book-html/$(BOOK_NAME_SLUG).%.html

## Markdown extension (e.g. md, markdown, mdown).
MEXT = md

## All markdown files in the working directory
FRONT_MATTER = $(sort $(wildcard _[0-9][0-9]-*.$(MEXT)))
CHAPTERS = $(sort $(wildcard [0-9][0-9]-*.$(MEXT)))
BUILD_DIR = output

## Location of Pandoc support files.
PREFIX = support

## Location of your working bibliography file
BIB = support/$(BOOK_NAME_SLUG).bibtex

HASKELL_BIN_PATH = ~/.cabal/bin
PANDOC_CROSSREF_PATH = $(HASKELL_BIN_PATH)/pandoc-crossref
PANDOC_CITEPROC_PREAMBLE_PATH = $(HASKELL_BIN_PATH)/pandoc-citeproc-preamble

POST_FRONT_MATTER = support/post_front_matter.md
CITEPROC_PREAMBLE = support/citeproc-preamble.tex
LATEX_TEMPLATE = support/templates/default.latex
DOCX_TEMPLATE = support/templates/default.docx
HTML_TEMPLATE = support/templates/default.html
INCLUDE_IN_HEADER = support/include-in-header


PDFS=$(patsubst %.$(MEXT),$(BUILD_DIR)/%.pdf,$(CHAPTERS))
HTML=$(patsubst %.$(MEXT),$(BUILD_DIR)/%.html,$(CHAPTERS))
DOCX=$(patsubst %.$(MEXT),$(BUILD_DIR)/%.docx,$(CHAPTERS))
BOOKS=output/$(BOOK_NAME_SLUG).pdf

FIGURES = $(wildcard figures/*)

ALL = $(FIGURES) $(PDFS) $(HTML) $(DOCX) $(BOOKS)

.PHONY: chapters all clean pdf html docx book webpage site figures tests

HUMAN_LANGUAGES = en
MACHINE_LANGUAGES = 
LANGUAGES = $(HUMAN_LANGUAGES) $(MACHINE_LANGUAGES)
HTML_OUTPUT_DIR := website/source/localizable/$(EDITION)
AUTO_JSON_DIR := website/data/$(EDITION)
AUTO_JSON_FILES = $(patsubst %, $(AUTO_JSON_DIR)/auto_%.json, $(LANGUAGES))
LOCALE_YAML_FILES = $(patsubst %, website/locales/%.yml, $(LANGUAGES))

chapters: $(FIGURES) $(PDFS) $(HTML) $(DOCX)

all:	$(ALL)

pdf:	$(FIGURES) $(PDFS)
html:	$(FIGURES) $(HTML)
docx:	$(FIGURES) $(DOCX)
book:   $(FIGURES) $(BOOKS)
webpage: $(FIGURES) website/book-html/$(BOOK_NAME_SLUG).en.html

sitedeps: $(AUTO_JSON_FILES) $(LOCALE_YAML_FILES)
	rsync -av --delete figures website/source/

site: sitedeps
	rsync -av --delete figures website/source/
	# cd website && bundle exec middleman build --no-clean --glob '*en/{about-the-author,code,open-review,privacy,machine-translations}/index.html'
	# ./scripts/translate-one-off-pages.rb website/ $(MACHINE_LANGUAGES)
	cd website && bundle exec middleman build --verbose

PANDOC_PDF = pandoc \
	-r markdown+footnotes \
	--template=$(LATEX_TEMPLATE) \
	--filter $(PANDOC_CROSSREF_PATH) \
	--filter pandoc-citeproc --bibliography=$(BIB) \
	--filter $(PANDOC_CITEPROC_PREAMBLE_PATH) -M citeproc-preamble=$(CITEPROC_PREAMBLE) \
	-V geometry:"top=1in, bottom=1in, left=1.25in, right=1.25in" \
	-V class:article \
	-V fontsize:11pt \
	-V fontfamily:lmodern \
	-H $(INCLUDE_IN_HEADER) \
	--default-image-extension=pdf \
	--toc \
	--toc-depth=4 \
	--number-section \

PANDOC_PDF_DEPS = $(LATEX_TEMPLATE) $(BIB) $(CITEPROC_PREAMBLE) $(INCLUDE_IN_HEADER)

PANDOC_DOCX = pandoc \
	-r markdown+footnotes \
	--number-section \
	--toc \
	--toc-depth=4 \
	--filter $(PANDOC_CROSSREF_PATH) \
	--reference-docx=$(DOCX_TEMPLATE) \
	--default-image-extension=svg \
	--filter pandoc-citeproc --bibliography=$(BIB) \

PANDOC_DOCX_DEPS = $(DOCX_TEMPLATE) $(BIB)

PANDOC_HTML = pandoc \
	-r markdown+footnotes+auto_identifiers+implicit_header_references \
	--template=$(HTML_TEMPLATE) \
	--toc \
	--toc-depth=4 \
	--filter $(PANDOC_CROSSREF_PATH) \
	--filter pandoc-citeproc --bibliography=$(BIB) --metadata link-citations=true \
	--default-image-extension=svg \
	-M chapters \
	--mathjax \
	--number-section \
	--section-divs \

PANDOC_HTML_DEPS = $(HTML_TEMPLATE) $(BIB)

PANDOC_BOOK_ARGS = support/book-metadata.yml support/shared-metadata.yml $(FRONT_MATTER) $(POST_FRONT_MATTER) $(CHAPTERS)

output/$(BOOK_NAME_SLUG).tex: $(PANDOC_PDF_DEPS) $(PANDOC_BOOK_ARGS)
	$(PANDOC_PDF) \
	--top-level-division=chapter \
	-s -o $@ $(PANDOC_BOOK_ARGS)

output/$(BOOK_NAME_SLUG).pdf: $(PANDOC_PDF_DEPS) $(PANDOC_BOOK_ARGS)
	$(PANDOC_PDF) \
	--top-level-division=chapter \
	-s -o $@ $(PANDOC_BOOK_ARGS)

website/book-html/$(BOOK_NAME_SLUG).en.html: $(PANDOC_HTML_DEPS) $(PANDOC_BOOK_ARGS)
	$(PANDOC_HTML) \
	-s $(PANDOC_BOOK_ARGS) | ./scripts/modify-citation-markup.rb > $@

website/book-html/$(BOOK_NAME_SLUG).%.html: output/$(BOOK_NAME_SLUG)-translate.html
	cat $< | TRANSLATE_TO="$*" ./scripts/translate.rb > $@

$(AUTO_JSON_DIR):
	mkdir -p $(AUTO_JSON_DIR)

$(HTML_OUTPUT_DIR):
	mkdir -p $(HTML_OUTPUT_DIR)

$(AUTO_JSON_DIR)/auto_%.json: website/book-html/$(BOOK_NAME_SLUG).%.html | $(AUTO_JSON_DIR) $(HTML_OUTPUT_DIR)
	LANGUAGE='$*' ./scripts/split-sections.rb $< $(HTML_OUTPUT_DIR)/ > $@

output/$(BOOK_NAME_SLUG)-translate.html: website/book-html/$(BOOK_NAME_SLUG).en.html
	./scripts/add-notranslate.rb $^ > $@

website/locales/en.yml:
	touch $@

website/locales/%.yml: website/locales/en.yml
	./scripts/translate-yml.rb $* $< > $@

output/$(BOOK_NAME_SLUG).docx: $(PANDOC_DOCX_DEPS) $(PANDOC_BOOK_ARGS)
	$(PANDOC_DOCX) \
	-s -o $@ $(PANDOC_BOOK_ARGS)

$(BUILD_DIR)/%.tex: support/shared-metadata.yml %.$(MEXT) 99-references.md
	$(PANDOC_PDF) \
	-s -o $@ $^

$(BUILD_DIR)/%.pdf: support/shared-metadata.yml %.$(MEXT) 99-references.md
	$(PANDOC_PDF) \
	-s -o $@ $^

$(BUILD_DIR)/%.html: support/shared-metadata.yml %.$(MEXT) 99-references.md
	$(PANDOC_HTML) \
	-s -o $@ $^

$(BUILD_DIR)/%.docx: support/shared-metadata.yml %.$(MEXT) 99-references.md
	$(PANDOC_DOCX) \
	-s -o $@ $^

tests:
	bundle exec ruby ./tests/tests.rb

clean:
	rm -f $(BUILD_DIR)/*
