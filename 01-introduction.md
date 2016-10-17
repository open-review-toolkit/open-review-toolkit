# Introduction
\minitoc

## Mini Table of Contents

The mini table of contents that you see in the PDF is created by adding `\minitoc` to the markdown file after the header for the chapter.

## Tables {#sec:tables}

You can create tables in your markdown files, and you can reference @tbl:example_table from the text.  For more on references see @sec:cross-ref.

| Header #1 | Header #2 |
|-----------|-----------|
| data | more data |
| data 2 | more data 2|

: Caption of example table. {#tbl:example_table}


## Figures {#sec:figures}

Any figures for your book should be added to the `figures/` directory.

@fig:anscombe shows Anscomb's quartet which was first proposed in @anscombe_graphs_1973.  

![Anscombe's Quartet, which was first proposed in @anscombe_graphs_1973. Image created by "Schultz" and used under a [Creative Commons license](https://commons.wikimedia.org/wiki/File:Anscombe%27s_quartet_3.svg).](figures/anscombes_quartet.png){#fig:anscombe}

## Equations {#sec:equations}

When $a \ne 0$, there are two solutions to $ax^2 + bx + c = 0$ and they are

$$x = {-b \pm \sqrt{b^2-4ac} \over 2a}$$ {#eq:quad}

This paragraph does not have any formulas but should render the dollar sign properly in $5 and $10.

## Citations {#sec:citations}

Citations to articles, books, and other materials are handled by BibTeX, and your .bibtex file should be stored in `support/sample-book.bibtex`.  If you want to change the name of your BibTeX file you will need to change `Makefile`.

You can make inline citiations like this: @anscombe_graphs_1973.  And, you can have citations come at the end of a sentence [@anscombe_graphs_1973].  For more on citation see the pandoc documentation: http://pandoc.org/.

## Cross referencing {#sec:cross-ref}

Cross references like the ones in the sections above are handled by pandoc-crossref.  You can read more about that software and its syntax at https://github.com/lierdakil/pandoc-crossref.
