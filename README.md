# typst-theorems

An implementation of numbered theorem environments in
[typst](https://github.com/typst/typst).
Copy and import the [theorems.typ](theorems.typ) file to use in your own projects.

Minimal example below; also see [example.typ](example.typ) for a demonstration of more features, and [differential_calculus.typ](differential_calculus.typ) for a practical use case.

![basic example](basic.png)

```
#import "theorems.typ": *

#set page(width: 16cm, height: auto, margin: 1.5cm)
#set heading(numbering: "1.1.")

#let theorem = thmbox("theorem", "Theorem", fill: rgb("#eeffee"))
#let corollary = thmplain(
  "corollary",
  "Corollary",
  base: "theorem",
  titlefmt: strong
)
#let definition = thmbox("definition", "Definition")

#let example = thmplain("example", "Example").with(numbering: none)
#let proof = thmplain(
  "proof",
  "Proof",
  base: "theorem",
  bodyfmt: body => [#body #h(1fr) $square$]
).with(numbering: none)


= Prime numbers

#definition[
  A natural number is called a _prime number_ if it is greater than 1
  and cannot be written as the product of two smaller natural numbers.
]
#example[The numbers $2$, $3$, and $17$ are prime.]

#theorem(name: "Euclid")[
  There are infinitely many primes.
]
#proof[
  Suppose to the contrary that $p_1, p_2, dots p_n$ is a finite enumeration
  of all primes. Set $P = p_1 p_2 dots p_n$. Since $P + 1$ is not in our list,
  it cannot be prime. Thus, some prime factor $p_j$ divides $P + 1$.
  Since $p_j$ also divides $P$, it must divide the difference $(P + 1) - P =
  1$, a contradiction.
]

#corollary[There is no largest prime number.]
#corollary[There are infinitely many composite numbers.]
```

