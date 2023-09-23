#import "manual_template.typ": *
#import "theorems.typ": *
#show: thmrules

#show: project.with(
  title: "typst-theorems",
  authors: (
    "sahasatvik",
  ),
  url: "https://github.com/sahasatvik/typst-theorems"
)



= Introduction

This document only includes the examples given in the manual; each one of
these has been explained in full detail there.

= Feature demonstration

#let theorem = thmbox(
  "theorem",
  "Theorem",
  fill: rgb("#e8e8f8")
)

#theorem("Euclid")[
  There are infinitely many primes.
] <euclid>

#let lemma = thmbox(
  "theorem",
  "Lemma",
  fill: rgb("#efe6ff")
)

#lemma[
  If $n$ divides both $x$ and $y$, it also divides $x - y$.
]

#let corollary = thmbox(
  "corollary",
  "Corollary",
  base: "theorem",
  fill: rgb("#f8e8e8")
)

#corollary(numbering: "1.1")[
  If $n$ divides two consecutive natural numbers, then $n = 1$.
]


== Suppressing numbering

#let example = thmplain(
  "example",
  "Example"
).with(numbering: none)

#example[
  The numbers $2$, $3$, and $17$ are prime.
]

#lemma(numbering: none)[
  The square of any even number is divisible by $4$.
]
#lemma[
  The square of any odd number is one more than a multiple of $4$.
]
#lemma(number: "42")[
  The square of any natural number cannot be two more than a multiple of 4.
]

== Limiting depth

#let definition = thmbox(
  "definition",
  "Definition",
  base_level: 1,
  stroke: rgb("#68ff68") + 1pt
)

#definition("Prime numbers")[
  A natural number is called a _prime number_ if it is greater than $1$ and
  cannot be written as the product of two smaller natural numbers. <prime>
]

#definition("Composite numbers")[
  A natural number is called a _composite number_ if it is greater than $1$
  and not prime.
]

#example(base_level: 4, numbering: "1.1")[
  The numbers $4$, $6$, and $42$ are composite.
]


== Custom formatting

#let proof = thmplain(
  "proof",
  "Proof",
  base: "theorem",
  titlefmt: smallcaps,
  bodyfmt: body => [
    #body #h(1fr) $square$
  ]
).with(numbering: none)

#lemma[
  All even natural numbers greater than 2 are composite.
]
#proof[
  Every even natural number $n$ can be written as the product of the natural
  numbers $2$ and $n\/2$. When $n > 2$, both of these are smaller than $2$
  itself.
]

#let notation = thmenv(
  "notation",                 // identifier
  none,                       // base - do not attach, count globally
  none,                       // base_level - use the base as-is
  (name, number, body, color: black) => [
                              // fmt - format content using the environment name, number, body, and an optional color
    #text(color)[#h(1.2em) *Notation (#number) #name*]:
    #h(0.2em)
    #body
    #v(0.5em)
  ]
).with(numbering: "I")        // use Roman numerals

#notation[
  The variable $p$ is reserved for prime numbers.
]
#notation("for Reals", color: green)[
  The variable $x$ is reserved for real numbers.
]

#lemma(title: "Lem.")[
  All multiples of 3 greater than 3 are composite.
]

== Labels and references <references>

#pad(
  left: 1.2em,
  [
    Recall that there are infinitely many prime numbers via @euclid.
  ]
)

#pad(
  left: 1.2em,
  [
    You can reference future environments too, like @oddprime[Cor.].
  ]
)

#lemma(supplement: "Lem.", refnumbering: "(1.1)")[
  All primes apart from $2$ and $3$ are of the form $6k plus.minus 1$.
] <primeform>

#pad(
  left: 1.2em,
  [
    You can modify the supplement and numbering to be used in references, like @primeform.
  ]
)


== Overriding `base`

#let remark = thmplain("remark", "Remark", base: "heading")

#remark[
  There are infinitely many composite numbers.
]

#corollary[
  All primes greater than $2$ are odd.
] <oddprime>

#remark(base: "corollary")[
  Two is a _lone prime_.
]
