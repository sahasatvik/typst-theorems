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

The `typst-theorems` package provides `Typst` functions that help create
numbered `theorem` environments. This is heavily inspired by the `\newtheorem`
functionality of `LaTeX`.

A _theorem environment_ lets you wrap content together with automatically
updating _numbering_ information. Such environments use internal `state`
counters for this purpose. Environments can

- share the same counter (_Theorems_ and _Lemmas_ often do so)
- keep a global count, or be attached to
  - other environments (_Corollaries_ are often numbered based upon the parent _Theorem_)
  - headings
- have a numbering level depth fixed (for instance, use only top level heading
  numbers)
- be referenced elsewhere in the document, via `label`s


= Using `typst-theorems`

Import all functions provided by `typst-theorems` using
```typst
#import "theorems.typ": *
```

The core of this module consists of `thmenv` and `thmref`. The functions
`thmbox` and `thmplain` provide some simple defaults for the appearance of
`thmenv`s.


= Feature demonstration

Create box-like _theorem environments_ using `thmbox`, a wrapper around
`thmenv` which provides some simple defaults.

```typst
#let theorem = thmbox(
  "theorem",              // identifier
  "Theorem",              // head
  fill: rgb("#e8e8f8")
)
```
#let theorem = thmbox(
  "theorem",
  "Theorem",
  fill: rgb("#e8e8f8")
)

Such definitions are convenient to place in the preamble or a template; use
the environment in your document via
```typst
#theorem(name: "Euclid")[
  There are infinitely many primes. <euclid>
]
```

This produces the following.
#theorem(name: "Euclid")[
  There are infinitely many primes. <euclid>
]

Note that `name` is optional. This `theorem` environment will be numbered
based on its parent `heading` counter, with successive `theorem`s
automatically updating the final index.

The `<euclid>` label can be used to refer to this Theorem via `thmref`;
this will be futher explained in @references[Section].

You can create another environment which uses the same counter, say for
_Lemmas_, as follows.

```typst
#let lemma = thmbox(
  "theorem",              // identifier - same as that of theorem
  "Lemma",                // head
  fill: rgb("#efe6ff")
)

#lemma[
  If $n$ divides both $x$ and $y$, it also divides $x - y$.
]
```
#let lemma = thmbox(
  "theorem",
  "Lemma",
  fill: rgb("#efe6ff")
)
#lemma[
  If $n$ divides both $x$ and $y$, it also divides $x - y$.
]

You can _attach_ other environments to ones defined earlier. For instance,
_Corollaries_ can be created as follows.

```typst
#let corollary = thmbox(
  "corollary",            // identifier
  "Corollary",            // head
  base: "theorem",        // base - use the theorem counter
  fill: rgb("#f8e8e8")
)

#corollary(numbering: "1.1")[
  If $n$ divides two consecutive natural numbers, then $n = 1$.
]
```
#let corollary = thmbox(
  "corollary",
  "Corollary",
  base: "theorem",
  fill: rgb("#f8e8e8")
)

#corollary(numbering: "1.1")[
  If $n$ divides two consecutive natural numbers, then $n = 1$.
]

Note that we have provided a `numbering` string; this can be any valid
numbering pattern as described in the
#linkb("https://typst.app/docs/reference/meta/numbering/")[numbering]
documentation.


== Suppressing numbering
Supplying `numbering: none` to an environment suppresses numbering for that
block, and prevents it from updating its counter.

```typst
#let example = thmplain(
  "example",
  "Example"
).with(numbering: none)

#example[
  The numbers $2$, $3$, and $17$ are prime.
]
```
#let example = thmplain(
  "example",
  "Example"
).with(numbering: none)

#example[
  The numbers $2$, $3$, and $17$ are prime.
]

Here, we have used the `thmplain` function, which is identical to `thmbox` but
sets some plainer defaults. You can also write
```typst
#lemma(numbering: none)[
  The square of any even number is divisible by $4$.
]
#lemma[
  The square of any odd number is one more than a multiple of $4$.
]
```
#lemma(numbering: none)[
  The square of any even number is divisible by $4$.
]
#lemma[
  The square of any odd number is one more than a multiple of $4$.
]

Note that the last _Lemma_ is _not_ numbered 3.1.2!


== Limiting depth

You can limit the number of levels of the `base` numbering used as follows.
```typst
#let definition = thmbox(
  "definition",
  "Definition",
  base_level: 1,          // take only the first level from the base
  stroke: rgb("#68ff68") + 1pt
)

#definition(name: "Prime numbers")[
  A natural number is called a _prime number_ if it is greater than $1$ and
  cannot be written as the product of two smaller natural numbers. <prime>
]
```
#let definition = thmbox(
  "definition",
  "Definition",
  base_level: 1,
  stroke: rgb("#68ff68") + 1pt
)
#definition(name: "Prime numbers")[
  A natural number is called a _prime number_ if it is greater than $1$ and
  cannot be written as the product of two smaller natural numbers. <prime>
]

Note that this environment is _not_ numbered 3.2.1!

```typst
#definition(name: "Composite numbers")[
  A natural number is called a _composite number_ if it is greater than $1$
  and not prime.
]
```
#definition(name: "Composite numbers")[
  A natural number is called a _composite number_ if it is greater than $1$
  and not prime.
]

Setting a `base_level` higher than what `base` provides will introduce padded
zeroes.

```typst
#example(base_level: 4, numbering: "1.1")[
  The numbers $4$, $6$, and $42$ are composite.
]
```
#example(base_level: 4, numbering: "1.1")[
  The numbers $4$, $6$, and $42$ are composite.
]


== Custom formatting
The `thmbox` function lets you specify rules for formatting the `title`, the
`name`, and the `body` individually. Here, the `title` refers to the `head`
and `number` together.

```typst
#let proof = thmplain(
  "proof",
  "Proof",
  base: "theorem",
  titlefmt: smallcaps,
  bodyfmt: body => [
    #body #h(1fr) $square$    // float a QED symbol to the right
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
```
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

You can go even further and use the `thmenv` function directly. It accepts an
`identifier`, a `base`, a `base_level`, and a `fmt` function.
```typst
#let notation = thmenv(
  "notation",                 // identifier
  none,                       // base - do not attach, count globally
  none,                       // base_level - use the base as-is
  (name, number, body) => [   // fmt - format content using the environment
                              // name, number, and body
    #h(1.2em) *Notation (#number) #name*:
    #h(0.2em)
    #body
    #v(0.5em)
  ]
).with(numbering: "I")        // use Roman numerals

#notation[
  The variable $p$ is reserved for prime numbers.
]
```
#let notation = thmenv(
  "notation",                 // identifier
  none,                       // base - do not attach, count globally
  none,                       // base_level - use the base as-is
  (name, number, body) => [   // fmt - format content using the environment name, number, and body
    #h(1.2em) *Notation (#number) #name*:
    #h(0.2em)
    #body
    #v(0.5em)
  ]
).with(numbering: "I")        // use Roman numerals

#notation[
  The variable $p$ is reserved for prime numbers.
]


== Labels and references <references>

You can place a `<label>` _inside_ a theorem environment to reference it later
via `thmref`.

```typst
Recall that there are infinitely many prime numbers via
#thmref(<euclid>)[Theorem].
```
#pad(
  left: 1.2em,
  [
    Recall that there are infinitely many prime numbers via
    #thmref(<euclid>)[Theorem].
  ]
)

The optional `fmt` argument can be used to convert the counter value (an array
of integers) and the optional body text into content.

```typst
#let numfmt = (nums, body) => {
  if body.pos().len() > 0 {
    body = body.pos().join(" ")
    return smallcaps([#body (#strong(numbering("1.1", ..nums)))])
  }
  return smallcaps(strong(numbering("1.1", ..nums)))
}

You can reference future environments too, like
#thmref(<oddprime>, fmt: numfmt)[Corollary].
```
#let numfmt = (nums, body) => {
  if body.pos().len() > 0 {
    body = body.pos().join(" ")
    return smallcaps([#body (#strong(numbering("1.1", ..nums)))])
  }
  return smallcaps(strong(numbering("1.1", ..nums)))
}
#pad(
  left: 1.2em,
  [
    You can reference future environments too, like
    #thmref(<oddprime>, fmt: numfmt)[Corollary].
  ]
)

Note that all such references are links to the the label location. The
`makelink` argument lets you disable this behaviour.
```typst
This reference to #thmref(<prime>, makelink: false)[Definition] is not
linked!
```
#pad(
  left: 1.2em,
  [
    This reference to #thmref(<prime>, makelink: false)[Definition] is not
    linked!
  ]
)


== Overriding `base`

```typst
#let remark = thmplain("remark", "Remark", base: "heading")
#remark[
  There are infinitely many composite numbers.
]

#corollary[
  All primes greater than $2$ are odd. <oddprime>
]
#remark(base: "corollary")[
  Two is a _lone prime_.
]
```

#let remark = thmplain("remark", "Remark", base: "heading")
#remark[
  There are infinitely many composite numbers.
]
#corollary[
  All primes greater than $2$ are odd. <oddprime>
]
#remark(base: "corollary")[
  Two is a _lone prime_.
]

This `remark` environment, which would normally be attached to the current
_heading_, now uses the `corollary` as a base.


#v(4em)

= Function reference
== `thmenv`

The `thmenv` function produces a _theorem environment_.
```typst
#let thmenv(
  identifier,             // environment counter name
  base,                   // base counter name, can be "heading" or none
  base_level,             // number of base number levels to use
  fmt                     // formatting function of the form
                          // (name, number, body) -> content
) = { ... }
```

A _theorem environment_ is itself a map of the following form.
```typst
(
  body,                   // body content
  name: "",               // name, often used in the title
  numbering: "1.1",       // numbering style, can be a function
  base: base,             // base counter name override
  base_level: base_level  // base_level override
) -> content
```

== `thmref`

A `<label>` placed within an environment can be referenced using `thmref`.
```typst
#let thmref(
  label,                  // label
  fmt: auto,              // formatting function, of the form
                          // (number array, body arguments) -> content
  makelink: true,         // create link to label
  ..body                  // body - typically prepended to number
) = { ... }
```

Note that the `<label>` _must_ be attached to something _inside_ the
environment.

*Caution*: Links created by `thmref` will be styled according to `#show link:`
rules, not `#show ref:` rules.


== `thmbox` and `thmplain`

The `thmbox` wraps `thmenv`, supplying a box-like `fmt` function.
```typst
#let thmbox(
  identifier,             // identifier
  head,                   // head - common name, used in the title
  fill: none,             // box fill
  stroke: none,           // box stroke
  inset: 1.2em,           // box inset
  radius: 0.3em,          // box corner radius
  breakable: false,       // box breakability
  padding: (top: 0.5em, bottom: 0.5em),
                          // box padding, passed to #pad
  namefmt: x => [(#x)],   // formatting for name
  titlefmt: strong,       // formatting for title (head + number)
  bodyfmt: x => x,        // formatting for body
  base: "heading",        // base - defaults to using headings
  base_level: none,       // base_level - defaults to using base as-is
) = { ... }
```

The `thmplain` function is identical to `thmbox`, except with plainer
defaults.

```typst
#let thmplain = thmbox.with(
  padding: (top: 0em, bottom: 0em),
  breakable: true,
  inset: (top: 0em, left: 1.2em, right: 1.2em),
  namefmt: name => emph([(#name)]),
  titlefmt: emph,
)
```


= Acknowledgements

Thanks to #linkb("https://github.com/MJHutchinson")[MJHutchinson] for
suggesting and implementing the `base_level` and `base: none` features, and to
the awesome devs of #linkb("https://typst.app/")[typst.app] for their support.
