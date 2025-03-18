/// Theorem environment counters
/// -> state
#let thm-counters = state("thm-counters", (:))

#let heading-counter = counter(heading)
#let _numbering = numbering


#let thm-counter-update(counter, update) = {
  return thm-counters.update(x => {
    if type(update) == int {
      x.insert(counter, (update, ))
    } else if type(update) == array {
      x.insert(counter, update)
    } else if type(update) == function {
      x.at(counter) = update(x.at(counter))
    }
    x
  })
}

#let thm-counter-get(counter) = {
  if (counter == "heading") {
    return heading-counter.get()
  }
  if not counter in thm-counters.get().keys() {
    return (0, )
  }
  return thm-counters.get().at(counter)
}


#let thm-fmt-default(
  name,
  number,
  body,
  supplement: "Theorem",
  /// Formatting for the environment name.
  /// -> function
  name-fmt: x => [(#x)],
  /// Formatting for the environment title (head and number).
  /// -> function
  title-fmt: x => x,
  /// Formatting for the environment body.
  /// -> function
  body-fmt: x => x,
  /// Separator between title and body.
  /// -> content
  separator: [. ],
  ..args,
) = {
  if not name == none {
    name = [ #name-fmt(name)]
  } else {
    name = []
  }
  let title = supplement
  if not number == none {
    title += " " + number
  }
  title = title-fmt(title)
  body = body-fmt(body)
  block(
    width: 100%,
    ..args.named(),
    [#box[#title]#name#separator#body]
  )
}

/// State containing theorem environment data, as an array of `thm` dictionaries.
/// See @thm-display for details on the structure of each `thm`.
/// -> state
#let thm-stored = state("thm-stored", ())

/// Creates a theorem environment, which is a function of the form
/// ```
///  (
///    ..thm-args,
///    body,
///    number: auto,
///    numbering: "1.1",
///    base: base,
///    base-level: base-level,
///    restate: false,
///    defer: false,
///    restate-keys: (counter, ),
///    supplement: counter,
///    ref-fmt: (supplement, thm) => {
///      if supplement != none { supplement = [#supplement~] }
///      [#supplement#link(thm.loc, (thm.number))]
///    },
///  ) -> content
/// ```
///
/// The `body` contains the content of the theorem environment, and `thm-args`
/// get passed to the formatting function `fmt`.
/// The first positional argument from `thm-args` is interpreted as the `name` of the theorem environment.
///
/// The `numbering` option specifies the numbering used for the theorem environment (set to `none` for turning numbering off).
/// Setting the `number` option lets you override the automatic numbering with content.
///
/// The `base` and `base-level` options are inherited from the `thm-env` call; see the list of parameters below.
///
/// The `supplement` determines the default supplement used when a labeled theorem environment is referenced.
/// The `ref-fmt` lets you specify custom formatting for references; see @thm-display for more details on the `thm` dictionary.
///
/// See @thm-restate for more information about the `restate`, `defer`, and `restate-keys` options.
///
/// #example(```
/// >>> #show: thm-rules
/// >>> #set heading(numbering: "1.1")
/// #let theorem = thm-env(
///   "Theorem",
///   fmt: (name, number, body, color: black, ..args) => {
///     if name != none { name = [~(#name)] }
///     text(color)[
///       *Theorem~#number*#name:~#body\
///     ]
///   },
///   base: "heading"
/// )
///
/// = First heading
/// #theorem[#lorem(5)]
/// #theorem("Named")[#lorem(7)]
///
/// Refer to @thm.
///
/// == First Subheading
/// #theorem[#lorem(3)]
/// #theorem[#lorem(4)]
///
/// == Second Subheading
/// #theorem[#lorem(6)]
/// #theorem(color: red)[#lorem(2)] <thm>
///
/// = Second heading
/// #theorem[#lorem(4)]
/// #theorem(number: $dagger$)[#lorem(9)]
/// #theorem[#lorem(7)]
/// ```,
/// mode: "markup",
/// scope: (thm-rules: thm-rules-1)
/// )
///
/// -> function
#let thm-env(
  /// Environment counter name
  /// -> string
  counter,
  /// Formatting function, of the form `(name, number, body, ..fmt-args) -> content`.
  /// When a theorem environment is called, the named arguments from
  /// `thm-args` are passed into `fmt-args`.
  /// -> function
  fmt: thm-fmt-default,
  /// Base counter name, whose numbering prefixes the theorem environment
  /// numbering.
  /// If `none`, the theorem environment maintains a global count with no
  /// prefix.
  /// -> string | none
  base: none,
  /// Base level, determining the number of levels of the `base` numbering to
  /// use during the theorem environment numbering.
  /// If `none`, all levels from the `base` numbering are used.
  /// -> int | none
  base-level: none,
) = {
  return (
    ..args,
    body,
    number: auto,
    numbering: "1.1",
    supplement: counter,
    base: base,
    base-level: base-level,
    restate: false,
    defer: false,
    restate-keys: (counter, ),
    ref-fmt: (supplement, thm) => {
      if supplement != none { supplement = [#supplement~] }
      [#supplement#link(thm.loc, (thm.number))]
    },
  ) => {
    let name = none
    if args != none and args.pos().len() > 0 {
      name = args.pos().first()
    }

    let result = none
    if number == auto and numbering == none {
      number = none
    }

    let number_ = number
    if number == auto and numbering != none {
      result = context {
        // Manually update heading counter
        thm-counter-update("heading", heading-counter.get())
        thm-counters.update(counters => {
          if not counter in counters.keys() {
            counters.insert(counter, (0, ))
          }

          let tc = counters.at(counter)
          if base != none {
            let bc = counters.at(base)

            // Pad or chop the base count
            if base-level != none {
              if bc.len() < base-level {
                bc = bc + (0,) * (base-level - bc.len())
              } else if bc.len() > base-level{
                bc = bc.slice(0, base-level)
              }
            }

            // Reset counter if the base counter has updated
            if tc.slice(0, -1) == bc {
              counters.at(counter) = (..bc, tc.last() + 1)
            } else {
              counters.at(counter) = (..bc, 1)
            }
          } else {
            // If we have no base counter, just count one level
            counters.at(counter) = (tc.last() + 1, )
          }

          return counters
        })
      }

      number = context _numbering(numbering, ..thm-counter-get(counter))
    }

    result = result + context {
      let loc = here()
      let number__ = number_
      if number__ == auto and numbering != none {
        number__ = thm-counter-get(counter)
        number__ = _numbering(numbering, ..number__)
      }
      thm-stored.update(x => {
        let thm = (
          args: args,
          name: name,
          body: body,
          supplement: supplement,
          fmt: fmt,
          number: number__,
          numbering: numbering,
          restate: restate,
          defer: defer,
          restate-keys: restate-keys,
          ref-fmt: ref-fmt,
          loc: loc,
          counter: counter,
          base: base,
          base-level: base-level
        )
        if x == none {
          return (thm, )
        } else {
          return x + (thm, )
        }
      })
    }

    if defer {
      return result
    }

    return figure(
      result +  // hacky!
      [#metadata(supplement) <meta:thm-env-counter>] +
      fmt(name, number, body, supplement: supplement, ..args.named()),
      kind: "thm-env",
      outlined: false,
      caption: name,
      supplement: supplement,
      numbering: numbering,
    )
  }
}


/// Displays all theorem environments, can be filtered.
/// A `thm` is a dictionary storing information about a theorem environment, with keys
/// ```
/// (
///   args,
///   name,
///   body,
///   supplement,
///   fmt,
///   number,
///   numbering,
///   restate,
///   defer,
///   restate-keys,
///   ref-fmt,
///   loc,
///   counter,
///   base,
///   base-level
/// )
/// ```
/// These contain information supplied to the theorem environment when created/called,
/// and can be used to reconstruct it completely.
/// #example(```
/// >>> #show: thm-rules
/// >>> #set heading(numbering: "1.1")
/// #let theorem = thm-plain("Theorem")
/// #let lemma = thm-plain(
///   "Lemma",
///   counter: "Theorem",
/// )
/// #let definition = thm-def("Definition")
/// #let proof = thm-proof("Proof")
///
/// = Heading <h1>
///
/// #theorem("Name")[#lorem(7)]
/// #proof[
///   #lorem(7)
/// ]
///
/// = New heading <h2>
///
/// #lemma[#lorem(8)]
/// #definition("Thing")[#lorem(2)]
/// #lemma[#lorem(4)]
///
/// = Display all
///
/// #thm-display()
/// ```,
/// mode: "markup",
/// scope: (thm-rules: thm-rules-1, thm-display: thm-display-1)
/// )
///
/// The key `loc` gives the location of the theorem environment in the document.
/// The `number` gives the (calculated and formatted) number of the theorem environment.
/// The remaining keys contain information as detailed in @thm-env.
///
/// -> content
#let thm-display(
  /// Filtering functions. Each `f` in `filters` is a function `thm -> boolean`.
  /// A `thm` is displayed if it passes _any_ of the filters.
  /// #example(```
  /// >>> #show: thm-rules
  /// >>> #set heading(numbering: "1.1")
  /// = Display only theorems/proofs
  ///
  /// #thm-display(
  ///   thm => thm.supplement == "Theorem",
  ///   thm => thm.supplement == "Proof",
  /// )
  ///
  /// = Display if `name` is present
  ///
  /// #thm-display(
  ///   thm => thm.name != none
  /// )
  /// ```,
  /// mode: "markup",
  /// scope: (thm-rules: thm-rules-2, thm-display: thm-display-1)
  /// )
  /// -> function
  ..filters,
  /// Formatting function of the form `thm -> content`.
  /// The default `auto` uses the same `fmt` originally supplied to the `thm-env`.
  /// #example(```
  /// >>> #show: thm-rules
  /// >>> #set heading(numbering: "1.1")
  /// = List of things
  ///
  /// #thm-display(
  ///   thm => thm.supplement != "Proof",
  ///   final: true,
  ///   fmt: thm => {
  ///     let head = [*#thm.supplement~#thm.number*]
  ///     if thm.name != none {
  ///       head = head + [~(#thm.name)]
  ///     }
  ///     let page = thm.loc.position().page
  ///     let page = link(thm.loc, [#page])
  ///     [#head~#box(width: 1fr, repeat[.])~#page\ ]
  ///   }
  /// )
  /// ```,
  /// mode: "markup",
  /// scope: (thm-rules: thm-rules-2, thm-display: (..args) => thm-display-1(..args, ..args.named(), final: false))
  /// )
  /// The `final: true` ensures that even if this `thm-display` call is
  /// placed at the beginning of the document, all theorem environments
  /// are listed.
  /// -> function | auto
  fmt: auto,
  /// Location up to which theorem environments will be displayed.
  /// The default `auto` uses the location where `thm-display` was called.
  /// #example(```
  /// >>> #show: thm-rules
  /// >>> #set heading(numbering: "1.1")
  /// = Display up to `<h2>`
  ///
  /// #thm-display(at: <h2>)
  /// ```,
  /// mode: "markup",
  /// scope: (thm-rules: thm-rules-2, thm-display: thm-display-1)
  /// )
  /// -> label | selector | location | function | auto
  at: auto,
  /// If `true`, display all theorem environments up to the end of the document.
  /// Useful for creating lists of theorems in the beginning of documents,
  /// before they've been stated.
  /// Overrides `at`.
  /// -> boolean
  final: false
) = {
  context {
    let thms = thm-stored.get()
    if at != auto {
      thms = thm-stored.at(at)
    }
    if final {
      thms = thm-stored.final()
    }
    if filters.pos().len() > 0 {
      // Use arg_1 or ... or arg_n style filter
      thms = thms.filter(thm =>
        filters.pos().any(x => x(thm))
      )
    }

    for thm in thms {
      if fmt == auto {
        (thm.fmt)(thm.name, thm.number, thm.body, ..thm.args.named())
      } else {
        fmt(thm)
      }
    }
  }
}


/// Displays theorem environments which have been marked to be restated or deferred, can be filtered.
/// Useful for pushing content to the appendix.
/// See @thm-display for the structure of a `thm`.
///
/// The following example illustrates the basic usage of
/// `thm-restate`, combined with the `restate` and `defer` flags for theorem environments.
/// #example(```
/// >>> #show: thm-rules
/// >>> #set heading(numbering: "1.1")
/// #let theorem = thm-plain("Theorem")
/// #let lemma = thm-plain(
///   "Lemma",
///   counter: "Theorem",
/// )
/// #let definition = thm-def("Definition")
/// #let proof = thm-proof("Proof")
///
/// = Heading
///
/// #definition[#lorem(2)]
/// #lemma[#lorem(8)]
///
/// #theorem("Name", restate: true)[#lorem(7)]
/// #proof(defer: true)[
///   #lorem(7)
/// ]
///
/// #lemma[#lorem(4)]
///
/// = Appendix
///
/// #thm-restate()
/// ```,
/// mode: "markup",
/// scope: (thm-rules: thm-rules-1, thm-display: thm-display-1)
/// )
///
/// -> content
#let thm-restate(
  /// String keys, array of keys, or functions used to filter theorem environments.
  /// A `thm` is displayed if it passes _any_ of the filters.
  ///
  /// If `k` in `keys` is a `string`, theorem environments containing `k` in its array of `restate-keys` will be matched.
  /// #example(```
  /// >>> #show: thm-rules
  /// >>> #set heading(numbering: "1.1")
  /// #let theorem = thm-plain("Theorem")
  /// #let lemma = thm-plain(
  ///   "Lemma",
  ///   counter: "Theorem",
  /// )
  /// #let proof = thm-proof("Proof")
  ///
  /// = Heading
  ///
  /// #theorem(restate: true)[#lorem(6)]
  /// #lemma(restate: true)[#lorem(4)]
  /// #proof(defer: true)[#lorem(7)]
  /// #lemma(restate: true)[#lorem(3)]
  ///
  /// = Restate lemmas/proofs
  /// #thm-restate("Lemma", "Proof")
  /// ```,
  /// mode: "markup",
  /// scope: (thm-rules: thm-rules-1),
  /// )
  ///
  /// If `k` in `keys` is an array of `string`s, theorem environments containing _all_ keys from `k` in its array of `restate-keys` will be matched.
  /// #example(```
  /// >>> #show: thm-rules
  /// >>> #set heading(numbering: "1.1")
  /// = Heading
  ///
  /// #theorem(
  ///   "Result A",
  ///   restate: true,
  ///   restate-keys: ("Theorem", "Result A")
  /// )[#lorem(6)]
  /// #proof(
  ///   defer: true,
  ///   restate-keys: ("Proof", "Result A")
  /// )[#lorem(7)]
  /// #theorem(restate: true)[#lorem(6)]
  /// #theorem(
  ///   "Result B",
  ///   restate: true,
  ///   restate-keys: ("Theorem", "Result B")
  /// )[#lorem(6)]
  /// #proof(
  ///   defer: true,
  ///   restate-keys: ("Proof", "Result B")
  /// )[#lorem(7)]
  ///
  /// = Restate Result A
  /// #thm-restate("Result A")
  ///
  /// = Restate theorems tagged Result B
  /// #thm-restate(("Theorem", "Result B"))
  /// ```,
  /// mode: "markup",
  /// scope: (thm-rules: thm-rules-2, theorem: thm-plain("Theorem"), lemma: thm-plain("Lemma", counter: "Theorem"), proof: thm-proof("Proof"))
  /// )
  ///
  /// If `k` in `keys` is a `function`, it must be of the form `restate-keys -> boolean`.
  /// #example(```
  /// >>> #show: thm-rules
  /// >>> #set heading(numbering: "1.1")
  /// = Heading
  ///
  /// #theorem(
  ///   restate: true,
  ///   restate-keys: (
  ///     "Theorem", "Unproven claim"
  ///   )
  /// )[#lorem(6)]
  /// #theorem(restate: true)[#lorem(6)]
  /// #lemma(
  ///   "Claim D",
  ///   restate: true,
  ///   restate-keys: ("Lemma", "Claim D")
  /// )[#lorem(6)]
  ///
  /// = Restate claims
  /// #thm-restate(
  ///   keys => keys.any(
  ///     k => lower(k).contains("claim")
  ///   )
  /// )
  /// ```,
  /// mode: "markup",
  /// scope: (thm-rules: thm-rules-2, theorem: thm-plain("Theorem"), lemma: thm-plain("Lemma", counter: "Theorem"), proof: thm-proof("Proof"))
  /// )
  /// -> string | array | function
  ..keys,
  /// Formatting function of the form `thm -> content`.
  /// The default `auto` uses the same `fmt` originally supplied to the `thm-env`.
  /// See @thm-display.fmt.
  /// -> function | auto
  fmt: auto,
  /// Location up to which theorem environments will be displayed.
  /// The default `auto` uses the location where `thm-restate` was called.
  /// See @thm-display.at.
  /// -> label | selector | location | function | auto
  at: auto,
  /// If `true`, display environments up to the end of the document.
  /// See @thm-display.final.
  /// -> boolean
  final: false
) = {
  context {
    let thms = thm-stored.get()
    if at != auto {
      thms = thm-stored.at(at)
    }
    if final {
      thms = thm-stored.final()
    }
    thms = thms.filter(thm => (thm.restate or thm.defer))
    if keys.pos().len() > 0 {
      // Use arg_1 or ... or arg_n style filter
      thms = thms.filter(thm =>
        keys.pos().any(x => {
          if type(x) == str {
            // keys contains x
            return thm.restate-keys.contains(x)
          } else if type(x) == array {
            // keys contain x_1 and ... and x_n
            return x.all(key => thm.restate-keys.contains(key))
          } else if type(x) == function {
            // keys passes filter x
            return x(thm.restate-keys)
          }
        })
      )
    }

    for thm in thms {
      if fmt == auto {
        (thm.fmt)(thm.name, thm.number, thm.body, ..thm.args.named())
      } else {
        fmt(thm)
      }
    }
  }
}

/// Creates a theorem environment wrapped in a padded block, with sensible
/// default styling. The block has `width: 100%` applied by default.
/// The `fmt` function is of the form `(name, number, body, title: auto, ..fmt-args) -> content`.
/// All named arguments from `args`, followed by all named `fmt-args`, are
/// passed to the `block` call.
///
/// #example(```
/// >>> #show: thm-rules
/// #let notation = thm-box(
///   "Notation",
///   base: none,
///   numbering: "I",
///   title-fmt: t => smallcaps(strong(t)),
///   body-fmt: emph,
///   outset: 0.7em,
///   padding: (y: 0.5em),
///   radius: 2pt,
///   fill: rgb("#d4e2fe"),
/// )
///
/// #lorem(5)
/// #notation[#lorem(3)]
/// #notation[#lorem(7)]
/// ```,
/// mode: "markup",
/// scope: (thm-rules: thm-rules-1)
/// )
///
/// -> function
#let thm-box(
  /// Environment heading.
  /// -> content
  head,
  /// Environment counter name. If `auto`, set to `head`.
  /// -> string | auto
  counter: auto,
  /// Named arguments for the block.
  /// -> any
  ..args,
  /// Environment numbering style.
  /// -> string | function
  numbering: "1.1",
  /// Supplement for references. If `auto`, set to `head`.
  /// -> string | auto
  supplement: auto,
  /// Padding around the block.
  /// -> dictionary
  padding: (y: 0.1em),
  /// Formatting for the environment name.
  /// -> function
  name-fmt: x => [(#x)],
  /// Formatting for the environment title (head and number).
  /// -> function
  title-fmt: x => x,
  /// Formatting for the environment body.
  /// -> function
  body-fmt: x => x,
  /// Separator between title and body.
  /// -> content
  separator: [. ],
  /// Base counter name.
  /// -> string
  base: "heading",
  /// Base level.
  /// -> int | none
  base-level: none,
) = {
  if counter == auto {
    counter = head
  }
  if supplement == auto {
    supplement = head
  }
  let fmt(
    name,
    number,
    body,
    title: auto,
    supplement: supplement,
    padding: padding,
    ..args-individual
  ) = {
    if not name == none {
      name = [ #name-fmt(name)]
    } else {
      name = []
    }
    if title == auto {
      title = head
    }
    if not number == none {
      title += " " + number
    }
    title = title-fmt(title)
    body = body-fmt(body)
    pad(
      ..padding,
      block(
        width: 100%,
        ..args.named(),
        ..args-individual.named(),
        [#box[#title]#name#separator#body]
      )
    )
  }
  return thm-env(
    counter,
    fmt: fmt,
    base: base,
    base-level: base-level,
  ).with(
    numbering: numbering,
    supplement: supplement,
    restate-keys: (head, )
  )
}


/// Creates a plain theorem environment, suitable for theorems, lemmas,
/// corollaries, propositions and conjectures.
/// Identical to @thm-box, with different defaults.
/// #example(```
/// >>> #show: thm-rules
/// #let theorem = thm-plain(
///   "Theorem",
///   base: none
/// )
///
/// #let lemma = thm-plain(
///   "Lemma",
///   counter: "Theorem",
///   base: none
/// )
///
/// #let corollary = thm-plain(
///   "Corollary",
///   base: "Theorem"
/// )
///
/// #lemma[#lorem(3)]
/// #theorem("Named")[#lorem(4)]
/// #corollary[#lorem(7)]
/// #theorem[#lorem(7)]
/// ```,
/// mode: "markup",
/// scope: (thm-rules: thm-rules-1)
/// )
///
/// -> function
#let thm-plain = thm-box.with(title-fmt: strong, body-fmt: emph, separator: [*.* ])

/// Creates a theorem environment, suitable for definitions, conditions, problems
/// and examples.
/// Identical to @thm-box, with different defaults.
/// #example(```
/// >>> #show: thm-rules
/// #let definition = thm-def(
///   "Definition",
///   base: none
/// )
///
/// #definition[#lorem(7)]
/// #definition[#lorem(4)]
/// ```,
/// mode: "markup",
/// scope: (thm-rules: thm-rules-1)
/// )
///
/// -> function
#let thm-def = thm-box.with(title-fmt: strong, separator: [*.* ])

/// Creates a theorem environment, suitable for remarks, notes, annotations,
/// claims, cases, acknowledgments and conclusions.
/// Identical to @thm-box, with different defaults.
/// #example(```
/// >>> #show: thm-rules
/// #let remark = thm-rem(
///   "Remark",
///   base: none
/// )
///
/// #remark[#lorem(3)]
/// #remark[#lorem(6)]
/// ```,
/// mode: "markup",
/// scope: (thm-rules: thm-rules-1)
/// )
///
/// -> function
#let thm-rem = thm-box.with(padding: (y: 0em), name-fmt: name => emph([(#name)]), title-fmt: emph, separator: [. ], numbering: none)

// Track whether the qed symbol has already been placed in a proof
#let thm-qed-done = state("thm-qed-done", ())

// Show the qed symbol, update state
#let thm-qed-show = {
  metadata("thm-qed-symbol")
  thm-qed-done.update(stack => {
    stack.slice(0, -1) + (true, )
  })
}

/// If placed in a block equation/enum/list within a proof, place a qed symbol
/// to its right.
///
/// #example(```
/// >>> #show: thm-rules
/// #let proof = thm-proof("Proof")
///
/// #proof[
///   #lorem(3)
///   $ x^2 + y^2 = z^2. #qedhere $
/// ]
///
/// #proof[
///   + #lorem(4)
///   + #lorem(5) #qedhere
/// ]
///
/// #proof[
///   $
///     (a + b)^2 &= (a + b)(a + b) \
///               &= a^2 + 2 a b + b^2. #qedhere
///   $
/// ]
/// ```,
/// mode: "markup",
/// scope: (thm-rules: thm-rules-1)
/// )
///
/// -> metadata
#let qedhere = metadata("thm-qedhere")


/// Add content which floats to the right in an equation.
/// #example(```
/// >>> #show: thm-rules
/// $
///   
///   (a + b)^2
///     &= a^2 + 2 a b + b^2 \
///     &<= 2a^2 + 2b^2 #tag[(AM-GM)] \
///     &<= 2 thin max{a, b}^2.
/// $
/// ```,
/// mode: "markup",
/// scope: (thm-rules: thm-rules-1)
/// )
///
/// -> content
#let tag(
  /// Content to use as tag
  /// -> any
  t
) = metadata((eq-tag: t))




/// Used as the `body-fmt` in @thm-proof, for properly styling proofs
/// by inserting a `qed` symbol at the end of the body.
/// Also see @qedhere.
/// #example(```
/// #show: thm-rules.with(qed-symbol: $"Q.E.D."$)
///
/// #proof-body-fmt[#lorem(3)]
/// #v(2em)
///
/// #proof-body-fmt[
///   $
///     phi.alt(x) = 1/sqrt(2 pi) e^(-x^2\/2) #qedhere
///   $
/// ]
/// ```,
/// mode: "markup",
/// scope: (thm-rules: thm-rules-1)
/// )
///
/// -> content
#let proof-body-fmt(
  /// Proof body.
  /// -> content
  body
) = {
  thm-qed-done.update(stack => {
    stack + (false, )
  })
  body
  context {
    if thm-qed-done.get().last() == false {
      h(1fr)
      thm-qed-show
    }
  }
  thm-qed-done.update(stack => {
    stack.slice(0, -1)
  })
}

/// Creates a proof environment
/// Identical to @thm-rem, with different defaults.
/// #example(```
/// >>> #show: thm-rules
/// #let theorem = thm-plain(
///   "Theorem",
///   base: none
/// )
/// #let proof = thm-proof("Proof")
///
/// #theorem[#lorem(6)]
/// #proof[#lorem(3)]
/// ```,
/// mode: "markup",
/// scope: (thm-rules: thm-rules-1)
/// )
///
/// -> function
#let thm-proof = thm-rem.with(name-fmt: emph, body-fmt: proof-body-fmt)


/// Rules for styling theorem environments, references, proofs, etc.
/// _Must appear at the beginning of the document._
///
/// -> content
#let thm-rules(
  /// Symbol displayed at the end of proofs.
  /// See @thm-proof, @qedhere, @proof-body-fmt.
  /// Use as
  /// #example(```
  /// #show: thm-rules.with(
  ///   qed-symbol: $square$
  /// )
  ///
  /// #let proof = thm-proof("Proof")
  ///
  /// #proof[#lorem(3)]
  /// #proof[
  ///   #lorem(5)
  ///   $ integral_0^oo sin(x)/x = pi/2. #qedhere $
  /// ]
  ///
  /// ```,
  /// mode: "markup",
  /// scope: (thm-rules: thm-rules-1)
  /// )
  /// -> content
  qed-symbol: $qed$,
  /// Document
  /// -> content
  doc
) = {

  show figure.where(kind: "thm-env"): it => {
    set block(breakable: true)
    set align(left)
    it.body
  }

  show ref: it => {
    if it.element == none {
      return it
    }
    if it.element.func() != figure {
      return it
    }
    if it.element.kind != "thm-env" {
      return it
    }

    let supplement = it.element.supplement
    if it.citation.supplement != none {
      supplement = it.citation.supplement
    }
    if (supplement == [] or (supplement.has("text") and supplement.text == "")) {
      supplement == none
    }

    let loc = it.element.location()
    let thms = query(selector(<meta:thm-env-counter>).after(loc))
    let thmloc = thms.first().location()
    let thm = thm-stored.at(thmloc).last()
    return (thm.ref-fmt)(supplement, thm)
  }

  show math.equation: eq => {
    show metadata.where(value: "thm-qedhere"): tag(thm-qed-show)
    show metadata: data => {
      if type(data.value) == dictionary and data.value.keys().contains("eq-tag") {
        context{
          let pos-numbering = query(metadata.where(value: "thm-equation-numbering").after(eq.location())).first().location().position()
          let pos-here = here().position()
          let height = measure(data.value.eq-tag).height
          let width = measure(data.value.eq-tag).width
          move(dx: -pos-here.x + pos-numbering.x - width, data.value.eq-tag)
        }
      } else {
        data
      }
    }

    if eq.numbering == none {
      math.equation(
        block: eq.block,
        numbering: x => {
          metadata("thm-equation-numbering")
        },
        number-align: eq.number-align,
        supplement: eq.supplement,
        eq.body
      )
    } else {
      eq
    }
  }

  show enum.item: it => {
    show metadata.where(value: "thm-qedhere"): {
      h(1fr)
      thm-qed-show
    }
    it
  }

  show list.item: it => {
    show metadata.where(value: "thm-qedhere"): {
      h(1fr)
      thm-qed-show
    }
    it
  }

  show metadata.where(value: "thm-qed-symbol"): qed-symbol

  doc
}
