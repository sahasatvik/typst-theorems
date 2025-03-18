#import "@preview/tidy:0.4.2"
#import "lib.typ": *
#import thm-themes.standard: *

#import "tidy-template.typ": *

#show: thm-rules
#show: project.with(
  title: "cTheorems",
  author: "sahasatvik",
  url: "https://github.com/sahasatvik/typst-theorems",
)



= Introduction

This package provides functions that help create numbered theorem environments.
This is heavily inspired by the #LATEX packages `amsthm` and `thmtools`.

A _theorem environment_ lets you wrap content together with automatically
updating _numbering_ information. Such environments use internal `state`
counters for this purpose. Environments can

- share the same counter (_Theorems_ and _Lemmas_ often do so)
- keep a global count, or be attached to
  - other environments (_Corollaries_ are often numbered based upon the parent _Theorem_)
  - headings
- have a numbering level depth fixed (for instance, use only top level heading
  numbers)
- be referenced elsewhere in the document, via `@reference`s and `<label>`s
- be restated or deferred to later in the document, via #fn("thm-restate")

This package also adds a couple of miscellaneous features:
- _QED_ symbols are inserted at the end of proofs, and can be positioned via
  #var("qedhere").
- Equations can be tagged (as in #LATEX's `\tag`).



= Usage

Import all functions provided by `typst-theorems` using
#example-code(
```typst
#import "@preview/ctheorems:2.0.0": *
#show: thm-rules      // Must include!
```
)
*_Including the show rule in the second line is crucial for displaying theorem
environments, references, and equations correctly!_*
All of the examples in this document will presume that #fn("thm-rules") has
been applied.


#example-code(
```typst
#import thm-themes.standard: *
```
)

The core of this module consists of #fn("thm-env").
Functions like #fn("thm-plain"), #fn("thm-def"), #fn("thm-rem"), and
#fn("thm-proof") provide some simple defaults for the appearance of
#fn("thm-env")s, analogous to the styles in `amsthm`.
All theorem environment data is stored in the state #var("thm-stored").
This is used by functions like #fn("thm-restate") and #fn("thm-display") to
manipulate and display theorem environments elsewhere in the document.


// #pagebreak()

= Features


We will create a `theorem` using #fn("thm-plain"), and use it as follows.

#example(
```
#let theorem = thm-plain("Theorem")

#theorem("Euclid")[
  There are infinitely many primes.
] <euclid>
```
)

Note that this `theorem` inherits its numbering from the heading by default.
Since this theorem has been labeled `<euclid>`, we can reference it elsewhere in the
document via `@euclid`.

#example(
```
We will supply a proof of @euclid later.
```
)


== Proofs

Theorems go hand in hand with proofs.
#example(
```
>>>#let theorem = thm-plain("Theorem")
#let proof = thm-proof("Proof")

#proof([of @euclid])[
  Suppose to the contrary that $p_1, p_2,
  dots, p_n$ is a finite enumeration of
  all primes. Set $P = p_1 p_2 dots p_n$.
  Since $P + 1$ is not in our list, it cannot
  be prime. Thus, some prime factor $p_j$
  divides $P + 1$. Since $p_j$ also divides
  $P$, it must divide the difference $(P + 1)
  - P = 1$, a contradiction.
]
```
)

Proof environments will float a _QED_ symbol ($qed$) at the bottom right by
default.
The symbol can be customized by setting #var("thm-rules.qed-symbol").
#example-code(
```typst
#show: thm-rules.with(qed-symbol: $square$)
```
)

If your proof ends in a block equation, or a list/enum, you can place
`qedhere` to correctly position the qed symbol.
#example(
```
>>>#let theorem = thm-plain("Theorem")
>>>#let proof = thm-proof("Proof")
#theorem[
  There are arbitrarily long stretches
  of composite numbers.
]
#proof[
  For any $n > 2$, consider $
    n! + 2, quad
    n! + 3, quad ..., quad
    n! + n #qedhere
  $
]
```
)

*Caution*: #var("qedhere") does not play well with numbered equations!


=== Equation tags

You can also insert tags into equations that float to the right, mimicking
`\tag` in #LATEX.
#example(
```
$
  (a + b)^2
    &= a^2 + 2 a b + b^2 \
    &<= 2a^2 + 2b^2 #tag[(AM-GM)] \
    &<= 2 thin max{a, b}^2.
$
```
)

This is essentially how the _QED_ symbol is placed inside equations by
#var("qedhere").


#example(
```
>>>#let theorem = thm-plain("Theorem")
>>>#let remark = thm-rem("Remark")
>>>#let corollary = thm-plain("Corollary", base: "Theorem")
#let theorem-standout = theorem.with(
  stroke: 1pt,
  outset: 0.7em,
  padding: (y: 1em)
)

#theorem-standout("Important")[#lorem(6)]
#lorem(8)
#remark[#lorem(4)]
#corollary[#lorem(2)]
#corollary[#lorem(4)]
```
)


= Acknowledgements

Thanks to
- #link("https://github.com/MJHutchinson")[MJHutchinson] for suggesting and
  implementing the `base-level` and `base: none` features,
- #link("https://github.com/rmolinari")[rmolinari] for suggesting and
  implementing the `separator: ...` feature,
- #link("https://github.com/DVDTSB")[DVDTSB] for contributing
  - the idea of passing named arguments from the theorem directly to the `fmt`
    function.
  - the `number: ...` override feature.
  - the `title: ...` override feature in `thm-plain`.
- #link("https://github.com/PgBiel")[PgBiel] for fixing breaking changes in
  version updates.
- The awesome devs of #link("https://typst.app/")[typst.app] for their
  support.


#pagebreak()
#set page(margin: 0.7in)

= Function documentation

#set heading(numbering: none, outlined: false)

#let docs = tidy.parse-module(
  read("theorems.typ"),
  name: "ctheorems",
  enable-curried-functions: false,
  preamble: "#set heading(outlined: false);",
  scope: (
    thm-rules-1: (..args, doc) => {
      counter(heading).update(0)
      thm-stored.update(())
      thm-counters.update((:))
      thm-rules(
        ..args.named(),
        doc
      )
    },
    thm-rules-2: (..args, doc) => {
      thm-rules(
        ..args.named(),
        doc
      )
    },
    thm-env: thm-env,
    thm-box: thm-box,
    thm-plain: thm-plain,
    thm-def: thm-def,
    thm-rem: thm-rem,
    thm-proof: thm-proof,
    proof-body-fmt: proof-body-fmt,
    tag: tag,
    qedhere: qedhere,
    thm-display-1: thm-display,
    thm-restate: thm-restate,
  ),
)


#tidy.show-module(
  docs,
  style: (
    show-outline: tidy.styles.default.show-outline,
    show-type: tidy.styles.default.show-type,
    show-function: tidy.styles.default.show-function,
    show-parameter-list: tidy.styles.default.show-parameter-list,
    show-parameter-block: tidy.styles.default.show-parameter-block,
    show-reference: tidy.styles.default.show-reference,
    show-variable: tidy.styles.default.show-variable,
    show-example: tidy.show-example.show-example.with(
      scale-preview: 100%,
      layout: layout-example,
      preview-block: block.with(
        radius: 3pt,
        fill: rgb("#e4e5ea"),
      ),
      code-block: block.with(
        radius: 3pt,
        stroke: .5pt + luma(200),
        breakable: false
      )
    ),
  ),
  sort-functions: f => {
    (
      "thm-rules",
      "thm-env",
      "thm-box",
      "thm-plain",
      "thm-def",
      "thm-rem",
      "thm-proof",
      "proof-body-fmt",
      "tag",
      "thm-restate",
      "thm-display",
    ).position(
      x => (f.name == x)
    )
  },
  show-outline: true,
  first-heading-level: 1,
  show-module-name: false,
  break-param-descriptions: true,
)

