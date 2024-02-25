#import "manual_template.typ": *
#import "theorems.typ": *
#show: thm-rules

#show: project.with(
  title: "typst-theorems",
  authors: (
    "sahasatvik",
  ),
  urls: ("https://github.com/sahasatvik/typst-theorems",)
)



= Introduction

This document only includes the examples given in the manual; each one of
these has been explained in full detail there.


= Feature demonstration

```typst
#let theorem = thm-plain("Theorem")
```
#let theorem = thm-plain(
  "Theorem",
)

#table[
```typst
#theorem("Euclid")[
  There are infinitely many primes.
] <euclid>
```
][
  #theorem("Euclid")[
    There are infinitely many primes.
  ] <euclid>
]

```typst
#let lemma = thm-plain(
  "Lemma",                // head
  identifier: "Theorem",  // identifier - same as that of Theorem
                          // options for styling the block
  fill: rgb("#e8e8f8"),
  outset: 0.7em,
  padding: (y: 0.5em)
)
```
#let lemma = thm-plain(
  "Lemma",
  identifier: "Theorem",
  fill: rgb("#e8e8f8"),
  outset: 0.7em,
  padding: (y: 0.5em)
)

#table[
```typst
#lemma[
  If $n$ divides both $x$ and $y$, it
  also divides $x - y$.
]
```
][
#lemma[
  If $n$ divides both $x$ and $y$, it also divides $x - y$.
]
]

```typst
#let corollary = thm-plain(
  "Corollary",            // head
  base: "Theorem",        // base - use the theorem counter
)
```
#let corollary = thm-plain(
  "Corollary",
  base: "Theorem",
)


#table[
```typst
#corollary(numbering: "1.1")[
  If $n$ divides two consecutive natural
  numbers, then $n = 1$.
]
```
][
#corollary(numbering: "1.1")[
  If $n$ divides two consecutive natural numbers, then $n = 1$.
]
]


== Proofs

```typst
#let proof = thm-proof("Proof")
```
#let proof = thm-proof("Proof")

#table[
```typst
#proof([of @euclid])[
  Suppose to the contrary that $p_1,
  p_2, dots, p_n$ is a finite
  enumeration of all primes. Set $P
  = p_1 p_2 dots p_n$. Since $P + 1$
  is not in our list, it cannot be
  prime. Thus, some prime factor
  $p_j$ divides $P + 1$. Since $p_j$
  also divides $P$, it must divide
  the difference $(P + 1) - P = 1$, a
  contradiction.
]
```
][
#proof([of @euclid])[
  Suppose to the contrary that $p_1, p_2, dots, p_n$ is a finite enumeration
  of all primes. Set $P = p_1 p_2 dots p_n$. Since $P + 1$ is not in our list,
  it cannot be prime. Thus, some prime factor $p_j$ divides $P + 1$.  Since
  $p_j$ also divides $P$, it must divide the difference $(P + 1) - P = 1$, a
  contradiction.
]
]

#table[
```typst
#theorem[
  There are arbitrarily long stretches
  of composite numbers.
]
#proof[
  For any $n > 2$, consider $
    n! + 2, quad n! + 3, quad ...,
    quad n! + n #qedhere
  $
]
```
][
#theorem[
  There are arbitrarily long stretches of composite numbers.
]
#v(1em)
#proof[
  For any $n > 2$, consider $
    n! + 2, quad n! + 3, quad ..., quad n! + n #qedhere
  $
]
]


== Suppressing numbering

```typst
#let conjecture = thm-plain(
  "Conjecture",
  numbering: none
)
```
#let conjecture = thm-plain(
  "Conjecture",
  numbering: none
)

#table[
```typst
#conjecture[
  The numbers $2$, $3$, and $17$ are
  prime.
]
```
][
#conjecture[
  The numbers $2$, $3$, and $17$ are prime.
]
]

#table[
```typst
#lemma(numbering: none)[
  The square of any even number is
  divisible by $4$.
]
#lemma[
  The square of any odd number is one
  more than a multiple of $4$.
]
```
][
#lemma(numbering: none)[
  The square of any even number is divisible by $4$.
]
#v(1em)
#lemma[
  The square of any odd number is one more than a multiple of $4$.
]
]

#table[
```typst
#lemma(number: "42")[
  The square of any natural number cannot be two more than a multiple of 4.
]
```
][
#lemma(number: "42")[
  The square of any natural number cannot be two more than a multiple of 4.
]
]


== Limiting depth

```typst
#let definition = thm-def(
  "Definition",
  base_level: 1           // take only the first level from the base
)
```
#let definition = thm-def(
  "Definition",
  base_level: 1
)

#table[
```typst
#definition("Prime numbers")[
  A natural number is called a _prime
  number_ if it is greater than $1$ and
  cannot be written as the product of
  two smaller natural numbers.
] <prime>
```
][
#definition("Prime numbers")[
  A natural number is called a _prime number_ if it is greater than $1$ and
  cannot be written as the product of two smaller natural numbers.
] <prime>
]

#table[
```typst
#definition("Composite numbers")[
  A natural number is called a
  _composite number_ if it is greater
  than $1$ and not prime.
]
```
][
#definition("Composite numbers")[
  A natural number is called a _composite number_ if it is greater than $1$
  and not prime.
]
]


```typst
#let example = thm-rem(
  "Example",
  numbering: "1.1"
)
```
#let example = thm-rem(
  "Example",
  numbering: "1.1"
)


#table[
```typst
#example(base_level: 4)[
  The numbers $4$, $6$, and $42$
  are composite.
]
```
][
#example(base_level: 4)[
  The numbers $4$, $6$, and $42$ are composite.
]
]


== Custom formatting

```typst
#let proof-custom = thm-box(
  "Proof",
  titlefmt: smallcaps,
  bodyfmt: body => [
    #body #h(1fr) $square$    // float a QED symbol to the right
  ],
  numbering: none
)
```
#let proof-custom = thm-box(
  "Proof",
  titlefmt: smallcaps,
  bodyfmt: body => [
    #body #h(1fr) $square$
  ],
  numbering: none
)

#table[
```typst
#lemma[
  All even natural numbers greater than
  2 are composite.
]
#proof-custom[
  Every even natural number $n$ can be
  written as the product of the natural
  numbers $2$ and $n\/2$. When $n > 2$,
  both of these are smaller than $2$
  itself.
]
```
][
#lemma[
  All even natural numbers greater than 2 are composite.
]
#proof-custom[
  Every even natural number $n$ can be written as the product of the natural
  numbers $2$ and $n\/2$. When $n > 2$, both of these are smaller than $2$
  itself.
]
]

```typst
#let notation = thm-env(
  "notation",                 // identifier
  none,                       // base - do not attach, count globally
  none,                       // base_level - use the base as-is
  (name, number, body, color: black) => [
                              // fmt - format content using the environment
                              // name, number, body, and an optional color
    #text(color)[#h(1.2em) *Notation (#number) #name*]:
    #h(0.2em)
    #body
    #v(0.5em)
  ]
).with(numbering: "I")        // use Roman numerals
```
#let notation = thm-env(
  "notation",                 // identifier
  none,                       // base - do not attach, count globally
  none,                       // base_level - use the base as-is
  (name, number, body, color: black) => [
                              // fmt - format content using the environment name, number, body, and an optional color
    #text(color)[*Notation (#number) #name*]:
    #h(0.2em)
    #body
    #v(0.5em)
  ]
).with(numbering: "I")        // use Roman numerals

#table[
```typst
#notation[
  The variable $p$ is reserved for
  prime numbers.
]
#notation("for Reals", color: green)[
  The variable $x$ is reserved for
  real numbers.
]
```
][
#notation[
  The variable $p$ is reserved for prime numbers.
]
#notation("for Reals", color: green)[
  The variable $x$ is reserved for real numbers.
]
]

#table[
```typst
#lemma(title: "Lem.", stroke: 1pt)[
  All multiples of 3 greater than 3
  are composite.
]
```
][
#lemma(title: "Lem.", stroke: 1pt, outset: 0.7em)[
  All multiples of 3 greater than 3 are composite.
]
]


== Labels and references <references>

#table[
```typst
Recall that there are infinitely many prime numbers via @euclid.
```
][
Recall that there are infinitely many prime numbers via @euclid.
][
```typst
You can reference future environments too, like @oddprime[Cor.].
```
][
You can reference future environments too, like @oddprime[Cor.].
][
```typst
#lemma(
  supplement: "Lem.",
  refnumbering: "(1.1)"
)[
  All primes apart from $2$ and $3$ are
  of the form $6k plus.minus 1$.
] <primeform>

You can modify the supplement and numbering to be used in references, like @primeform.
```
][
#lemma(supplement: "Lem.", refnumbering: "(1.1)")[
  All primes apart from $2$ and $3$ are of the form $6k plus.minus 1$.
] <primeform>

#v(4.5em)
You can modify the supplement and numbering to be used in references, like @primeform.
]


== Overriding `base`

```typst
#let remark = thm-rem(
  "Remark",
  base: "heading",
  numbering: "1.1"
)
```
#let remark = thm-rem(
  "Remark",
  base: "heading",
  numbering: "1.1"
)

#table[
```typst
#remark[
  There are infinitely many composite
  numbers.
]
```
][
#remark[
  There are infinitely many composite numbers.
]
][
```typst
#lemma[
  All primes greater than $2$ are odd.
] <oddprime>

#remark(base: "Theorem")[
  Two is a _lone prime_.
]
```
][
#lemma[
  All primes greater than $2$ are odd.
] <oddprime>
#remark(base: "Theorem")[
  Two is a _lone prime_.
]
]
