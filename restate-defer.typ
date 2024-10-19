#import "theorems.typ": *
#show: thm-rules.with(qed-symbol: $square$)

#set page(width: 16cm, height: auto, margin: 1.5cm, numbering: "1")
#set heading(numbering: "1.1.")
#show heading: set block(below: 1em)

#let theorem = thm-plain("Theorem", stroke: 1pt + green, outset: 0.5em)
#let corollary = thm-plain("Corollary", base: "Theorem")
#let definition = thm-def("Definition", counter: "Theorem")
#let proof = thm-proof("Proof")


= List of Theorems and Definitions

#thm-display(
  thm => ("Theorem", "Definition").contains(thm.supplement),
  final: true,    // List matches up to the end of the document
                  // (default is to list matches which have appeared so far)
  fmt: thm => {
    let head = [*#thm.supplement~#thm.number*]
    if thm.name != none {
      head = head + [~(#thm.name)]
    }
    head = link(thm.loc, head)
    let page = thm.loc.position().page
    let page = link(thm.loc, [#page])
    [#head~#box(width: 1fr, repeat[.])~#page\ ]
  }
)

#pagebreak()

= Prime numbers

#definition("Prime numbers", restate: true)[
  A natural number is called a _prime number_ if it is greater than 1 and
  cannot be written as the product of two smaller natural numbers.
]

#theorem[
  #lorem(10)
]

#theorem("Euclid", restate: true)[
  There are infinitely many primes.
] <euclid>
#proof(defer: true)[
  Suppose to the contrary that $p_1, p_2, dots, p_n$ is a finite enumeration
  of all primes. Set $P = p_1 p_2 dots p_n$. Since $P + 1$ is not in our list,
  it cannot be prime. Thus, some prime factor $p_j$ divides $P + 1$.  Since
  $p_j$ also divides $P$, it must divide the difference $(P + 1) - P = 1$, a
  contradiction.
]

// Hack - since the proof is deferred to the end, the label must be attached
// to something appearing in the document here.
#metadata("") <euclid_proof>

#corollary[
  There is no largest prime number.
]
#corollary(restate: true, restate-keys: ("Corollary", "Result"))[
  There are infinitely many composite numbers.
]

#pagebreak()

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


#pagebreak()

= Appendix (restated or deferred)

#thm-restate()

#pagebreak()

= Only restate Theorem or Corollary

#thm-restate("Theorem", "Corollary")

#pagebreak()

= Only restate 'Result'

#thm-restate("Result")

#pagebreak()

= Only restate (Theorem and 'Result') or Definition

#thm-restate(("Theorem", "Result"), "Definition")

#pagebreak()

= Only restate if some key contains 'fi'

#thm-restate(keys => keys.any(x => x.contains("fi")))

#pagebreak()

= Only display if (`name` is not `none`) or is 'Result'

#thm-display(
  thm => thm.name != none,
  thm => thm.restate-keys.contains("Result")
)

#pagebreak()

= Only restate up to `<euclid_proof>`

#thm-restate(at: <euclid_proof>)
