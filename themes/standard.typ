#import "../theorems.typ": *

#let theorem = thm-plain(
  "Theorem",
)
#let lemma = thm-plain(
  "Lemma",
  counter: "Theorem"
)
#let proposition = thm-plain(
  "Proposition",
  counter: "Theorem"
)

#let corollary = thm-plain(
  "Corollary",
  base: "Theorem"
)

#let definition = thm-def(
  "Definition"
)
#let example = thm-def(
  "Example"
)

#let remark = thm-rem(
  "Remark"
)
#let claim = thm-rem(
  "Claim"
)
