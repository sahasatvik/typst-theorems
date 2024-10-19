// Store theorem environment numbering
#let thm-counters = state("thm-counters",
  (
    "counters": ("heading": ()),
    "latest": ()
  )
)

/// State containing theorem environment data, as an array of `thm` dictionaries.
/// See @@thm-display() for details on the structure of each `thm`.
#let thm-stored = state("thm-stored", ())
()

#let heading-counter = counter(heading)

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
///      link(thm.loc, [#supplement#(thm.number)])
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
/// The `ref-fmt` lets you specify custom formatting for references; see @@thm-display() for more details on the `thm` dictionary.
///
/// See @@thm-restate() for more information about the `restate`, `defer`, and `restate-keys` options.
///
/// #example(```
/// #show: thm-rules
/// #set heading(numbering: "1.1")
///
/// #let theorem = thm-env(
///   "Theorem",
///   (name, number, body, color: black) => {
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
/// scale-preview: 95%,
/// scope: (thm-rules: thm-rules-1)
/// )
///
/// - counter (string): Environment counter name.
/// - fmt (function): Formatting function, of the form
///       `(name, number, body, ..fmt-args) -> content`.
///        When a theorem environment is called, the named arguments
///        from `thm-args` are passed into `fmt-args`.
/// - base (string): Base counter name, whose numbering prefixes the theorem
///        environment numbering.
///        If `none`, the theorem environment maintains a global count
///        with no prefix.
/// - base-level (integer): Base level, determining the number of levels of
///        the `base` numbering to use during the theorem environment
///        numbering.
///        If `none`, all levels from the `base` numbering are used.
/// -> function
#let thm-env(
  counter,
  fmt,
  base: none,
  base-level: none,
) = {

  let global_numbering = numbering

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
      link(thm.loc, [#supplement#(thm.number)])
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
        let loc = here()
        return thm-counters.update(thmpair => {
          let counters = thmpair.at("counters")
          // Manually update heading counter
          counters.at("heading") = heading-counter.at(loc)
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
            counters.at(counter) = (tc.last() + 1,)
            let latest = counters.at(counter)
          }

          let latest = counters.at(counter)
          return (
            "counters": counters,
            "latest": latest
          )
        })
      }

      number = context global_numbering(numbering, ..thm-counters.get().latest)
    }

    result = result + context {
      let loc = here()
      let number__ = number_
      if number__ == auto and numbering != none {
        number__ = thm-counters.at(loc).latest
        number__ = global_numbering(numbering, ..number__)
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
      fmt(name, number, body, ..args.named()) +
      [#metadata(counter) <meta:thm-env-counter>],
      kind: "thm-env",
      outlined: false,
      caption: name,
      supplement: supplement,
      numbering: if number == auto and numbering != none { numbering } else { (..nums) => number },
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
/// #example(```
/// #show: thm-rules
/// #set heading(numbering: "1.1")
///
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
/// scale-preview: 95%,
/// scope: (thm-rules: thm-rules-1, thm-display: thm-display-1)
/// )
///
/// The key `loc` gives the location of the theorem environment in the document.
/// The `number` gives the (calculated and formatted) number of the theorem environment.
/// The remaining keys contain information as detailed in @@thm-env().
/// - ..filters (function): Filtering functions. Each `f` in `filters` is a function `thm -> boolean`.
///       A `thm` is displayed if it passes _any_ of the filters.
///       #example(```
///       #show: thm-rules
///       #set heading(numbering: "1.1")
///
///       = Display only theorems/proofs
///
///       #thm-display(
///         thm => thm.supplement == "Theorem",
///         thm => thm.supplement == "Proof",
///       )
///
///       = Display if `name` is present
///
///       #thm-display(
///         thm => thm.name != none
///       )
///       ```,
///       mode: "markup",
///       scale-preview: 95%,
///       ratio: 0.95,
///       scope: (thm-rules: thm-rules-2, thm-display: thm-display-1)
///       )
/// - fmt (function): Formatting function of the form `thm -> content`.
///       The default `auto` uses the same `fmt` originally supplied to the `thm-env`.
///       #example(```
///       #show: thm-rules
///       #set heading(numbering: "1.1")
///
///       = List of things
///
///       #thm-display(
///         thm => thm.supplement != "Proof",
///         final: true,
///         fmt: thm => {
///           let head = [*#thm.supplement~#thm.number*]
///           if thm.name != none {
///             head = head + [~(#thm.name)]
///           }
///           let page = thm.loc.position().page
///           let page = link(thm.loc, [#page])
///           [#head~#box(width: 1fr, repeat[.])~#page\ ]
///         }
///       )
///       ```,
///       mode: "markup",
///       scale-preview: 95%,
///       ratio: 0.95,
///       scope: (thm-rules: thm-rules-2, thm-display: (..args) => thm-display-1(..args, ..args.named(), final: false))
///       )
///       The `final: true` ensures that even if this `thm-display` call is
///       placed at the beginning of the document, all theorem environments
///       are listed.
/// - at (label, selector, location, function): Location up to which theorem environments will be displayed.
///       The default `auto` uses the location where `thm-display` was called.
///       #example(```
///       #show: thm-rules
///       #set heading(numbering: "1.1")
///
///       = Display up to `<h2>`
///
///       #thm-display(at: <h2>)
///       ```,
///       mode: "markup",
///       scale-preview: 95%,
///       ratio: 0.95,
///       scope: (thm-rules: thm-rules-2, thm-display: thm-display-1)
///       )
/// - final (boolean): If `true`, display all theorem environments up to the end of the document.
///       Useful for creating lists of theorems in the beginning of documents, before they've been stated.
///       Overrides `at`.
/// -> content
#let thm-display(..filters, fmt: auto, at: auto, final: false) = {
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
/// See @@thm-display() for the structure of a `thm`.
///
/// The following example illustrates the basic usage of
/// `thm-restate`, combined with the `restate` and `defer` flags for theorem environments.
/// #example(```
/// #show: thm-rules
/// #set heading(numbering: "1.1")
///
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
/// scale-preview: 95%,
/// scope: (thm-rules: thm-rules-1, thm-display: thm-display-1)
/// )
/// - ..keys (string, array, function): String keys, array of keys, or functions used to filter theorem environments.
///       A `thm` is displayed if it passes _any_ of the filters.
///
///       If `k` in `keys` is a `string`, theorem environments containing `k` in its array of `restate-keys` will be matched.
///       #example(```
///       #show: thm-rules
///       #set heading(numbering: "1.1")
///
///       #let theorem = thm-plain("Theorem")
///       #let lemma = thm-plain(
///         "Lemma",
///         counter: "Theorem",
///       )
///       #let proof = thm-proof("Proof")
///
///       = Heading
///
///       #theorem(restate: true)[#lorem(6)]
///       #lemma(restate: true)[#lorem(4)]
///       #proof(defer: true)[#lorem(7)]
///       #lemma(restate: true)[#lorem(3)]
///
///       = Restate lemmas/proofs
///       #thm-restate("Lemma", "Proof")
///       ```,
///       mode: "markup",
///       scale-preview: 95%,
///       ratio: 0.95,
///       scope: (thm-rules: thm-rules-1),
///       )
///
///       If `k` in `keys` is an array of `string`s, theorem environments containing _all_ keys from `k` in its array of `restate-keys` will be matched.
///       #example(```
///       #show: thm-rules
///       #set heading(numbering: "1.1")
///
///       = Heading
///
///       #theorem(
///         "Result A",
///         restate: true,
///         restate-keys: ("Theorem", "Result A")
///       )[#lorem(6)]
///       #proof(
///         defer: true,
///         restate-keys: ("Proof", "Result A")
///       )[#lorem(7)]
///       #theorem(restate: true)[#lorem(6)]
///       #theorem(
///         "Result B",
///         restate: true,
///         restate-keys: ("Theorem", "Result B")
///       )[#lorem(6)]
///       #proof(
///         defer: true,
///         restate-keys: ("Proof", "Result B")
///       )[#lorem(7)]
///
///       = Restate Result A
///       #thm-restate("Result A")
///
///       = Restate theorems tagged Result B
///       #thm-restate(("Theorem", "Result B"))
///       ```,
///       mode: "markup",
///       scale-preview: 95%,
///       ratio: 0.95,
///       scope: (thm-rules: thm-rules-2, theorem: thm-plain("Theorem"), lemma: thm-plain("Lemma", counter: "Theorem"), proof: thm-proof("Proof"))
///       )
///
///       If `k` in `keys` is a `function`, it must be of the form `restate-keys -> boolean`.
///       #example(```
///       #show: thm-rules
///       #set heading(numbering: "1.1")
///
///       = Heading
///
///       #theorem(
///         restate: true,
///         restate-keys: (
///           "Theorem", "Unproven claim"
///         )
///       )[#lorem(6)]
///       #theorem(restate: true)[#lorem(6)]
///       #lemma(
///         "Claim D",
///         restate: true,
///         restate-keys: ("Lemma", "Claim D")
///       )[#lorem(6)]
///
///       = Restate claims
///       #thm-restate(
///         keys => keys.any(
///           k => lower(k).contains("claim")
///         )
///       )
///       ```,
///       mode: "markup",
///       scale-preview: 95%,
///       ratio: 0.95,
///       scope: (thm-rules: thm-rules-2, theorem: thm-plain("Theorem"), lemma: thm-plain("Lemma", counter: "Theorem"), proof: thm-proof("Proof"))
///       )
///
/// - fmt (function): Formatting function of the form `thm -> content`.
///       The default `auto` uses the same `fmt` originally supplied to the `thm-env`.
///       See corresponding option in @@thm-display().
/// - at (label, selector, location, function): Location up to which theorem environments will be displayed.
///       The default `auto` uses the location where `thm-restate` was called.
///       See corresponding option in @@thm-display().
/// - final (boolean): If `true`, display environments up to the end of the document.
///       See corresponding option in @@thm-display().
/// -> content
#let thm-restate(..keys, fmt: auto, at: auto, final: false) = {
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
/// #show: thm-rules
///
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
/// scale-preview: 95%,
/// scope: (thm-rules: thm-rules-1)
/// )
///
/// - head (content): Environment heading.
/// - counter (string): Environment counter name. If `auto`, set to `head`.
/// - numbering (string, function): Environment numbering style.
/// - supplement (string): Supplement for references. If `auto`, set to `head`.
/// - padding (dictionary): Padding around the block.
/// - name-fmt (function): Formatting for the environment name.
/// - title-fmt (function): Formatting for the environment title (head and number).
/// - body-fmt (function): Formatting for the environment body.
/// - separator (content): Separator between title and body.
/// - base (string): Base counter name.
/// - base-level (integer): Base level.
/// -> function
#let thm-box(
  head,
  counter: auto,
  ..args,
  numbering: "1.1",
  supplement: auto,
  padding: (y: 0.1em),
  name-fmt: x => [(#x)],
  title-fmt: x => x,
  body-fmt: x => x,
  separator: [.#h(0.2em)],
  base: "heading",
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
    padding: padding,
    ..args_individual
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
        ..args_individual.named(),
        [#title#name#separator#body]
      )
    )
  }
  return thm-env(
    counter,
    fmt,
    base: base,
    base-level: base-level,
  ).with(
    numbering: numbering,
    supplement: supplement,
    restate-keys: (head, )
  )
}


/// Creates a plain theorem environment.
/// Identical to @@thm-box(), with different defaults.
/// #example(```
/// #show: thm-rules
///
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
/// scale-preview: 95%,
/// scope: (thm-rules: thm-rules-1)
/// )
#let thm-plain = thm-box.with(
  title-fmt: strong,
  body-fmt: emph,
  separator: [*.*#h(0.2em)],
)

/// Creates a theorem environment, suitable for definitions.
/// Identical to @@thm-box(), with different defaults.
/// #example(```
/// #show: thm-rules
///
/// #let definition = thm-def(
///   "Definition",
///   base: none
/// )
///
/// #definition[#lorem(7)]
/// #definition[#lorem(4)]
/// ```,
/// mode: "markup",
/// scale-preview: 95%,
/// scope: (thm-rules: thm-rules-1)
/// )
#let thm-def = thm-box.with(
  title-fmt: strong,
  separator: [*.*#h(0.2em)],
)

/// Creates a theorem environment, suitable for remarks.
/// Identical to @@thm-box(), with different defaults.
/// #example(```
/// #show: thm-rules
///
/// #let remark = thm-rem(
///   "Remark",
///   base: none
/// )
///
/// #remark[#lorem(3)]
/// #remark[#lorem(6)]
/// ```,
/// mode: "markup",
/// scale-preview: 95%,
/// scope: (thm-rules: thm-rules-1)
/// )
#let thm-rem = thm-box.with(
  padding: (y: 0em),
  name-fmt: name => emph([(#name)]),
  title-fmt: emph,
  separator: [.#h(0.2em)],
  numbering: none
)

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
/// #show: thm-rules
///
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
/// scale-preview: 95%,
/// scope: (thm-rules: thm-rules-1)
/// )
#let qedhere = metadata("thm-qedhere")

// Checks if content x contains the qedhere tag
#let thm-has-qedhere(x) = {
  if x == qedhere {
    return true
  }

  if type(x) == content {
    for (f, c) in x.fields() {
      if thm-has-qedhere(c) {
        return true
      }
    }
  }

  if type(x) == array {
    for c in x {
      if thm-has-qedhere(c) {
        return true
      }
    }
  }

  return false
}


/// Used as the `body-fmt` in @@thm-proof, for properly styling proofs
/// by inserting a `qed` symbol at the end of the body.
/// Also see @@qedhere.
/// #example(```
/// #show: thm-rules.with(qed-symbol: "Q.E.D.")
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
/// scale-preview: 95%,
/// scope: (thm-rules: thm-rules-1)
/// )
/// - body (content): Proof body.
/// -> content
#let proof-body-fmt(body) = {
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
/// Identical to @@thm-rem, with different defaults.
/// #example(```
/// #show: thm-rules
///
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
/// scale-preview: 95%,
/// scope: (thm-rules: thm-rules-1)
/// )
#let thm-proof = thm-rem.with(
    name-fmt: emph,
    body-fmt: proof-body-fmt,
)


/// Rules for styling theorem environments, references, proofs, etc.
/// Must appear at the beginning of the document.
/// #example(```
/// #show: thm-rules
/// #set heading(numbering: "1.1")
///
/// #let theorem = thm-plain("Theorem")
/// #let lemma = thm-plain(
///   "Lemma",
///   counter: "Theorem",
/// )
/// #let corollary = thm-plain(
///   "Corollary",
///   base: "Theorem"
/// )
/// #let definition = thm-def("Definition")
/// #let remark = thm-rem("Remark")
/// #let proof = thm-proof("Proof")
///
/// = Heading
///
/// #theorem[#lorem(7)] <mythm>
/// #definition("Thing")[#lorem(2)]
/// #lemma[#lorem(4)]
/// #proof[
///   #lorem(7)
/// ]
/// #lorem(10)
/// #proof([of @mythm])[
///   $
///     1/n sum_(i = 1)^n X_i -->^p EE[X_1] #qedhere
///   $
/// ]
///
/// = More theorems
///
/// #let theorem-standout = theorem.with(
///   stroke: 1pt,
///   outset: 0.7em,
///   padding: (y: 1em)
/// )
/// #theorem-standout("Important")[#lorem(6)]
/// #lorem(8)
/// #remark[#lorem(4)]
/// #corollary[#lorem(2)]
/// #corollary[#lorem(4)]
/// ```,
/// mode: "markup",
/// scale-preview: 95%,
/// scope: (thm-rules: thm-rules-1)
/// )
/// - qed-symbol (content): Symbol displayed at the end of proofs.
///     See @@thm-proof, @@qedhere, @@proof-body-fmt().
///     Use as
///     #example(```
///     #show: thm-rules.with(
///       qed-symbol: $square$
///     )
///
///     #let proof = thm-proof("Proof")
///
///     #proof[#lorem(3)]
///     #proof[
///       #lorem(5)
///       $ integral_0^oo sin(x)/x = pi/2. #qedhere $
///     ]
///
///     ```,
///     mode: "markup",
///     scale-preview: 95%,
///     ratio: 0.95,
///     scope: (thm-rules: thm-rules-1)
///     )
#let thm-rules(
  qed-symbol: $qed$,
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
    if eq.numbering == none and thm-has-qedhere(eq) and thm-qed-done.at(eq.location()).last() == false {
      math.equation(
        block: eq.block,
        numbering: x => {
          context {
            let pos-qedhere = query(metadata.where(value: "thm-qedhere").after(eq.location())).first().location().position()
            let pos-here = here().position()
            let height = measure(qed-symbol).height
            move(dy: -pos-here.y + pos-qedhere.y - height/2, thm-qed-show)
          }
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
