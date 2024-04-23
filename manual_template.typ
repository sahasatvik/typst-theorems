#let project(title: "", authors: (), urls: (), body) = {
  set page(paper: "a4", numbering: "1", number-align: center)
  set document(author: authors, title: title)
  set text(font: "Linux Libertine", lang: "en")
  set heading(numbering: "1.1.")
  set par(justify: true)
  set list(marker: ([•], [--]))
  show heading: it => pad(bottom: 0.5em, it)
  // show raw.where(block: true): it => pad(left: 4em, it)
  show link: it => underline(text(fill: blue, it))

  set table(columns: (1fr, 1fr), inset: 1em, stroke: 1pt + black.lighten(70%))
  show table: it => block(breakable: false, it)



  align(center)[
    #block(text(weight: 700, 1.75em, title))
  ]

  pad(
    top: 0.5em,
    bottom: 2em,
    x: 2em,
    grid(
      columns: (1fr,) * calc.min(3, authors.len()),
      gutter: 1em,
      ..authors.map(author => align(center)[
        #author \
        #urls.map(x => link(x)).join("\n")
      ]),
    ),
  )

  outline(indent: true)

  v(2em)

  body
}


#let LATEX = {
  set text(font: "New Computer Modern")
  [L];box(move(
    dx: -5.2pt, dy: -1.2pt,
    box(scale(65%)[A])
  ));box(move(
    dx: -7.8pt, dy: 0pt,
    [T]
  ));box(move(
    dx: -9.6pt, dy: 2.7pt,
    box(scale(100%)[E])
  ));box(move(
    dx: -11.2pt, dy: 0pt,
    [X]
  ));h(-10.6pt)
}
