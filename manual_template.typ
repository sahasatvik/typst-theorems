#let linkb = (..it) => underline(text(fill: blue, link(..it)))

#let project(title: "", authors: (), url: "", body) = {
  set page(paper: "a4", numbering: "1", number-align: center)
  set document(author: authors, title: title)
  set text(font: "Linux Libertine", lang: "en")
  set heading(numbering: "1.1.")
  show heading: it => pad(bottom: 0.5em, it)
  set par(justify: true)
  show raw.where(block: true): it => pad(left: 4em, it)



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
        #linkb(url)
      ]),
    ),
  )

  outline(indent: true)

  v(2em)

  body
}
