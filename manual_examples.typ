#import "manual_template.typ": *
#import "theorems.typ": *

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

#theorem(name: "Euclid")[
  There are infinitely many primes. <euclid>
]

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


== Limiting depth

#let definition = thmbox(
  "definition",
  "Definition",
  base_level: 1,
  stroke: rgb("#68ff68") + 1pt
)
#definition(name: "Prime numbers")[
  A natural number is called a _prime number_ if it is greater than $1$ can
  cannot be written as the product of two smaller natural numbers.
]

#definition(name: "Composite numbers")[
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
  "notation",
  none,
  none,
  (name, number, body) => [
    #h(1.2em) *Notation (#number) #name*:
    #h(0.2em)
    #body
    #v(0.5em)
  ]
).with(numbering: "I")

#notation[
  The variable $p$ is reserved for prime numbers.
]


== Labels and references <references>

#let numfmt = (nums) => {
  let joined = nums.map(str).join(".")
  return [(#strong(joined))]
}

Recall that there are infinitely many prime numbers via Theorem
#thmref(<euclid>, fmt: numfmt).

You can reference future environments too, like Corollary
#thmref(<oddprime>).


== Overriding `base`

#corollary[
  All primes greater than $2$ are odd. <oddprime>
]
#proof(base: "corollary", numbering: "of 1.1")[
  Trivial.
]
