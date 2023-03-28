#import "theorems.typ": *

// Define theorem environments

#let theorem = thmbox(
  "theorem",            // The Theorem counter is attached to headings
  "Theorem",
  fill: rgb("#e8e8f8")
)
#let lemma = thmbox(
  "theorem",            // Lemmas use the same counter as Theorems
  "Lemma",
  fill: rgb("#efe6ff")
)
#let corollary = thmbox(
  "corollary",
  "Corollary",
  base: "theorem",      // Corollaries are 'attached' to Theorems
  fill: rgb("#f8e8e8")
)
#let definition = thmbox(
  "definition",         // Definitions use their own counter
  "Definition",
  stroke: rgb("#68ff68") + 1pt
)

// Examples and remarks are not numbered
#let example = thmplain("example", "Example").with(numbering: none)
#let remark = thmplain("remark", "Remark").with(numbering: none)

// Proofs are attached to theorems, although they are not numbered
#let proof = thmplain(
  "proof",
  "Proof",
  base: "theorem",
  bodyfmt: body => [
    #body #h(1fr) $square$    // Insert QED symbol
  ]
).with(numbering: none)


#let project(title: "", authors: (), body) = {
  set page(height: auto)
  set document(author: authors, title: title)
  set text(font: "Linux Libertine", lang: "en")
  set heading(numbering: "1.1.")
  set par(justify: true)

  align(center)[
    #block(text(weight: 700, 1.75em, title))
  ]

  v(2em)

  body
}


// Document starts here

#show: project.with(
  title: "Theorems!",
  authors: (
    "Satvik Saha",
  ),
)

= Introduction

#lemma(name: "Pythagoras")[
  In a right angled triangle, $ a^2 + b^2 = c^2. $
]
#theorem(name: "WLLN")[#lorem(20)]
#proof[
  #lorem(30)
  $ integral_(-infinity)^infinity sin(x)/x space upright(d) x = pi $
  #lorem(5)
]

#corollary[#lorem(4)]
#corollary[#lorem(8)]

#example[#lorem(10)]

#lemma[#lorem(10)]


== Sub-Heading

#definition[#lorem(16)]

#example(name: [#lorem(3)])[#lorem(10)]
#remark[#lorem(5)]

#theorem[#lorem(6)]

// Numbering can be reactivated
#proof(numbering: "1.1")[#lorem(4)]
#proof(numbering: "1.1")[#lorem(5)]

= Heading
#lemma[#lorem(14)]
#remark[#lorem(8)]

#corollary(name: [#lorem(4)])[#lorem(12)]
// The base can be overridden
#example(numbering: "1.1.1.a", base: "corollary")[#lorem(20)]
#example(numbering: "1.1.1.a", base: "corollary")[#lorem(10)]
