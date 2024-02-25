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
#show: thmrules
```
The second line is crucial for displaying `thmenv`s and references correctly!

The core of this module consists of `thmenv`.
The functions `thmbox`, `thmplain`, and `thmproof` provide some simple
defaults for the appearance of `thmenv`s.


= Feature demonstration <feat>

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
#theorem("Euclid")[
  There are infinitely many primes.
] <euclid>
```

This produces the following.
#theorem("Euclid")[
  There are infinitely many primes.
] <euclid>

Note that the `name` is optional. This `theorem` environment will be numbered
based on its parent `heading` counter, with successive `theorem`s
automatically updating the final index.

The `<euclid>` label can be used to refer to this Theorem via the reference
`@euclid`. Go to @references to read more.

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
#link("https://typst.app/docs/reference/meta/numbering/")[numbering]
documentation.


== Proofs

The `thmproof` function gives nicer defaults for formatting proofs.
```typst
#let proof = thmproof("proof", "Proof")

#proof([of @euclid])[
  Suppose to the contrary that $p_1, p_2, dots, p_n$ is a finite enumeration
  of all primes. Set $P = p_1 p_2 dots p_n$. Since $P + 1$ is not in our list,
  it cannot be prime. Thus, some prime factor $p_j$ divides $P + 1$.  Since
  $p_j$ also divides $P$, it must divide the difference $(P + 1) - P = 1$, a
  contradiction.
]
```
#let proof = thmproof("proof", "Proof")

#proof([of @euclid])[
  Suppose to the contrary that $p_1, p_2, dots, p_n$ is a finite enumeration
  of all primes. Set $P = p_1 p_2 dots p_n$. Since $P + 1$ is not in our list,
  it cannot be prime. Thus, some prime factor $p_j$ divides $P + 1$.  Since
  $p_j$ also divides $P$, it must divide the difference $(P + 1) - P = 1$, a
  contradiction.
]

If your proof ends in a block equation, or a list/enum, you can place
`qedhere` to correctly position the qed symbol.
```typst
#theorem[
  There are arbitrarily long stretches of composite numbers.
]
#proof[
  For any $n > 2$, consider $
    n! + 2, quad n! + 3, quad ..., quad n! + n #qedhere
  $
]
```
#theorem[
  There are arbitrarily long stretches of composite numbers.
]
#proof[
  For any $n > 2$, consider $
    n! + 2, quad n! + 3, quad ..., quad n! + n #qedhere
  $
]

*Caution*: The `qedhere` symbol does not play well with numbered/multiline
equations!

You can set a custom qed symbol (say $square$) by setting the appropriate
option in `thmrules` as follows.
```typst
#show: thmrules.with(qed-symbol: $square$)
```

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

You can also override the automatic numbering as follows.
```typst
#lemma(number: "42")[
  The square of any natural number cannot be two more than a multiple of 4.
]
```
#lemma(number: "42")[
  The square of any natural number cannot be two more than a multiple of 4.
]

Note that this does _not_ affect the counters either!


== Limiting depth

You can limit the number of levels of the `base` numbering used as follows.
```typst
#let definition = thmbox(
  "definition",
  "Definition",
  base_level: 1,          // take only the first level from the base
  stroke: rgb("#68ff68") + 1pt
)

#definition("Prime numbers")[
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
#definition("Prime numbers")[
  A natural number is called a _prime number_ if it is greater than $1$ and
  cannot be written as the product of two smaller natural numbers. <prime>
]

Note that this environment is _not_ numbered 3.2.1!

```typst
#definition("Composite numbers")[
  A natural number is called a _composite number_ if it is greater than $1$
  and not prime.
]
```
#definition("Composite numbers")[
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
#let proof-custom = thmplain(
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
#proof-custom[
  Every even natural number $n$ can be written as the product of the natural
  numbers $2$ and $n\/2$. When $n > 2$, both of these are smaller than $2$
  itself.
]
```
#let proof-custom = thmplain(
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
#proof-custom[
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
  (name, number, body, color: black) => [
                              // fmt - format content using the environment
                              // name, number, body, and an optional color
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
```
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

Note that the `color: green` named argument supplied to the theorem
environment gets passed to the `fmt` function. In general, all extra named
arguments supplied to the theorem will be passed to `fmt`.
On the other hand, the positional argument `"for Reals"` will always be
interpreted as the `name` argument in `fmt`.

```typst
#lemma(title: "Lem.", stroke: 1pt)[
  All multiples of 3 greater than 3 are composite.
]
```
#lemma(title: "Lem.", stroke: 1pt)[
  All multiples of 3 greater than 3 are composite.
]

Here, we override the `title` (which defaults to the `head`) as well as the
`stroke` in the `fmt` produced by `thmbox`. All `block` arguments can be
overridden in `thmbox` environments in this way.


== Labels and references <references>

You can place a `<label>` outside a theorem environment, and reference it
later via `@` references! For example, go back to @euclid.

```typst
Recall that there are infinitely many prime numbers via @euclid.
```
#pad(
  left: 1.2em,
  [
    Recall that there are infinitely many prime numbers via @euclid.
  ]
)


```typst
You can reference future environments too, like @oddprime[Cor.].
```
#pad(
  left: 1.2em,
  [
    You can reference future environments too, like @oddprime[Cor.].
  ]
)

```typst
#lemma(supplement: "Lem.", refnumbering: "(1.1)")[
  All primes apart from $2$ and $3$ are of the form $6k plus.minus 1$.
] <primeform>

You can modify the supplement and numbering to be used in references, like @primeform.
```
#lemma(supplement: "Lem.", refnumbering: "(1.1)")[
  All primes apart from $2$ and $3$ are of the form $6k plus.minus 1$.
] <primeform>

You can modify the supplement and numbering to be used in references, like @primeform.

*Caution*: Links created by references to `thmenv`s will be styled according
to `#show link:` rules.


== Overriding `base`

```typst
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
```

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
                          // (name, number, body, ..args) -> content
) = { ... }
```

The `fmt` function must accept a theorem `name`, `number`, `body`, and produce
formatted content. It may also accept additional positional arguments, via
`args`.

A _theorem environment_ is itself a map of the following form.
```typst
(
  ..args,
  body,                   // body content
  number: auto,           // number, overrides numbering if present
  numbering: "1.1",       // numbering style, can be a function
  refnumbering: auto,     // numbering style used in references,
                          // defaults to "numbering"
  supplement: identifier, // supplement used in references
  base: base,             // base counter name override
  base_level: base_level  // base_level override
) -> content
```

Positional arguments in `args` are as follows
- `name`: The name of the theorem, typically displayed after the title.

All additional named arguments in `args` will be passed on to the associated
`fmt` function supplied in `thmenv`.


== `thmbox` and `thmplain`

The `thmbox` wraps `thmenv`, supplying a box-like `fmt` function.
```typst
#let thmbox(
  identifier,             // identifier
  head,                   // head - common name, used in the title
  ..blockargs,            // named arguments, passed to #block
  supplement: auto,       // supplement for references, defaults to "head"
  padding: (top: 0.5em, bottom: 0.5em),
                          // box padding, passed to #pad
  namefmt: x => [(#x)],   // formatting for name
  titlefmt: strong,       // formatting for title (head + number)
  bodyfmt: x => x,        // formatting for body
  separator: [#h(0.1em):#h(0.2em)],
                          // separator inserted between name and body
  base: "heading",        // base - defaults to using headings
  base_level: none,       // base_level - defaults to using base as-is
) = { ... }
```

The `thmbox` function sets the following defaults for the `block`.
```typst
(
  width: 100%,
  inset: 1.2em,
  radius: 0.3em,
  breakable: false,
)
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


== `thmproof`, `proof-bodyfmt` and `qedhere`

The `thmproof` function is identical to `thmplain`, except with defaults
appropriate for proofs.

```typst
#let thmproof(..args) = thmplain(
    ..args,
    namefmt: emph,
    bodyfmt: proof-bodyfmt,
    ..args.named()
).with(numbering: none)
```

The `proof-bodyfmt` function is a `bodyfmt` function that automatically places
a qed symbol at the end of the body.

You can place `#qedhere` inside a block equation, or at the end of a list/enum
item to place the qed symbol on the same line.


== `thmrules`

The `thmrules` show rule sets important styling rules for theorem
environments, references, and equations in proofs.

```typst
#let thmrules(
  qed-symbol: $qed$,      // QED symbol used in proofs
  doc
) = { ... }
```


= Acknowledgements

Thanks to
- #link("https://github.com/MJHutchinson")[MJHutchinson] for suggesting and
  implementing the `base_level` and `base: none` features,
- #link("https://github.com/rmolinari")[rmolinari] for suggesting and
  implementing the `separator: ...` feature,
- #link("https://github.com/DVDTSB")[DVDTSB] for contributing
  - the idea of passing named arguments from the theorem directly to the `fmt`
    function.
  - the `number: ...` override feature.
  - the `title: ...` override feature in `thmbox`.
- The awesome devs of #link("https://typst.app/")[typst.app] for their
  support.
