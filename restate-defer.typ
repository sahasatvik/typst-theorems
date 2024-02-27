#import "theorems.typ": *
#show: thm-rules.with(qed-symbol: $square$)

#set page(width: 16cm, height: auto, margin: 1.5cm)
#set text(font: "Linux Libertine", lang: "en")
#set heading(numbering: "1.1.")
#show heading: set block(below: 1em)

#let theorem = thm-plain("Theorem")
#let corollary = thm-plain("Corollary", base: "Theorem")
#let definition = thm-def("Definition")
#let proof = thm-proof("Proof")


= Prime numbers

#definition("Prime numbers")[
  A natural number is called a #highlight[_prime number_] if it is greater
  than 1 and cannot be written as the product of two smaller natural numbers.
]

#theorem[
  #lorem(10)
]

#theorem("Euclid", restate: true)[
  There are infinitely many primes.
]
#proof(defer: true)[
  Suppose to the contrary that $p_1, p_2, dots, p_n$ is a finite enumeration
  of all primes. Set $P = p_1 p_2 dots p_n$. Since $P + 1$ is not in our list,
  it cannot be prime. Thus, some prime factor $p_j$ divides $P + 1$.  Since
  $p_j$ also divides $P$, it must divide the difference $(P + 1) - P = 1$, a
  contradiction.
]

#corollary[
  There is no largest prime number.
]
#corollary(restate: true, restate-keys: ("Corollary", "Result"))[
  There are infinitely many composite numbers.
]

#lorem(20)

#theorem(restate: true, restate-keys: ("Theorem", "Result"))[
  #lorem(7)
]

#theorem(restate: true)[
  There are arbitrarily long stretches of composite numbers.
]
#proof(restate: true)[
  For any $n > 2$, consider $
    n! + 2, quad n! + 3, quad ..., quad n! + n. #qedhere
  $
]

= Restated or deferred

#thm-restate()

= Only Theorems and Corollaries

#thm-restate("Theorem", "Corollary")

= Only 'Results'

#thm-restate("Result")
