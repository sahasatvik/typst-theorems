#import "counter.typ": thm-counters, thm-counter-get, thm-counter-step
#import "state.typ": thm-stored

#let _numbering = numbering

/// Default formatting function for theorem environments, wrapping everything in a block.
/// Intended for use in @thm.fmt.
/// Named arguments from @thm.args can override all of the arguments below;
/// any remaining named arguments are passed to the block.
///
/// -> content
#let thm-fmt-block(
  /// Theorem data.
  /// See @thm.fmt for details.
  /// -> dictionary
  thm,
  /// Named arguments for the block.
  /// -> dictionary
  block-args: (:),
  /// Formatting for the environment name.
  /// -> function
  name-fmt: x => [(#x)],
  /// Formatting for the environment title (head and number).
  /// -> function
  title-fmt: strong,
  /// Formatting for the environment body.
  /// -> function
  body-fmt: x => x,
  /// Separator between title and body.
  /// -> content
  separator: [*.* ],
) = {
  let name = []
  if thm.name != none {
    name = [ #name-fmt(thm.name)]
  }

  // Swallow formatting arguments passed directly to the `thm`
  block-args = thm.args.remove("block-args", default: block-args)
  name-fmt   = thm.args.remove("name-fmt",   default: name-fmt)
  title-fmt  = thm.args.remove("title-fmt",  default: title-fmt)
  body-fmt   = thm.args.remove("body-fmt",   default: body-fmt)
  separator  = thm.args.remove("separator",  default: separator)

  let title = thm.supplement
  if not thm.number == none {
    title += [ #thm.number]
  }
  title = title-fmt(title)
  let body = body-fmt(thm.body)
  return block(
    width: 100%,
    ..block-args,
    ..thm.args,
    [#box[#title]#name#separator#body]
  )
}



/// Theorem environment.
/// -> figure | context
#let thm(
  /// Extra arguments.
  /// See @thm.name.
  /// -> arguments
  ..args,
  /// Theorem body.
  /// -> content
  body,
  /// Theorem supplement.
  /// -> str | content
  supplement: "Theorem",
  /// Environment counter name.
  /// If ```typc auto```, defaults to @thm.supplement.
  /// -> str | auto
  counter: auto,
  /// Formatting function, of the form ```typc thm => content```, where `thm` is a
  /// dictionary whose keys are essentially the arguments of @thm, with a
  /// couple of additions/exceptions.
  /// - The keys `name`, `counter`, `number`, `restate-keys` contain their
  ///   finally computed values.
  /// - The key `loc` contains the theorem's location.
  /// - The key `args` contains a dictionary of only the named arguments from
  ///   @thm.args.
  /// -> function
  fmt: thm-fmt-block,
  /// Base counter name, whose numbering prefixes the theorem environment
  /// numbering.
  /// If ```typc "heading"```, use the heading counter.
  /// If ```typc none```, the theorem environment maintains a global count with no
  /// prefix.
  /// -> str | none
  base: "heading",
  /// Base level, determining the number of levels of the `base` numbering to
  /// use for the theorem environment numbering.
  /// If ```typc none```, all levels from the `base` numbering are used.
  /// Setting a base level higher than what the `base` provides will introduce zeros for padding.
  /// -> int | none
  base-level: none,
  /// Theorem name.
  /// If ```typc auto```, the first positional argument from
  /// @thm.args (if present) is chosen as the theorem environment's name.
  /// -> content
  name: auto,
  /// Theorem number.
  /// If ```typc auto``` (and @thm.numbering is not ```typc none```), the
  /// number is computed based on @thm.counter, @thm.base, @thm.base-level.
  /// -> content | auto
  number: auto,
  /// Theorem numbering style.
  /// If ```typc none```, numbering is suppressed.
  /// -> str | function | none
  numbering: "1.1",
  /// Restate flag. See @thm-restate.
  /// -> bool
  restate: false,
  /// Defer flag. See @thm-restate.
  /// -> bool
  defer: false,
  /// Keys used by @thm-restate.keys for filtering.
  /// If ```typc auto```, defaults to an array containing @thm.supplement and @thm.name (if present).
  /// -> array
  restate-keys: auto,
  /// Formatting function for references, with the same form as @thm.fmt.
  /// The `thm` dictionary carries an additional `ref-supplement` key containing
  /// the supplement used in the ```typ @cite[ref-supplement]``` call.
  /// -> function
  ref-fmt: thm => {
    let supplement = thm.supplement
    if thm.ref-supplement != none { supplement = thm.ref-supplement }
    if supplement != none and supplement != [] { supplement = [#supplement~] }
    [#supplement#link(thm.loc, (thm.number))]
  },
) = {
  if name == auto {
    if args != none and args.pos().len() > 0 {
      name = args.pos().first()
    } else {
      name = none
    }
  }

  if counter == auto {
    counter = supplement
  }

  if restate-keys == auto {
    restate-keys = (supplement, )
    if name != none {
      restate-keys += (name, )
    }
  }

  if number == auto and numbering == none {
    number = none
  }

  let number-update = none
  if number == auto and numbering != none {
    number-update = context thm-counter-step(
      counter,
      base: base,
      base-level: base-level
    )
  }

  let thm = (
    args: args.named(),
    supplement: supplement,
    counter: counter,
    base: base,
    base-level: base-level,
    name: name,
    body: body,
    fmt: fmt,
    numbering: numbering,
    restate: restate,
    defer: defer,
    restate-keys: restate-keys,
    ref-fmt: ref-fmt,
  )

  let thm-update = context {
    let loc = here()
    let number-computed = number
    if number == auto and numbering != none {
      number-computed = _numbering(numbering, ..thm-counter-get(counter))
    }
    thm-stored.update(thms => {
      let thm = thm + (number: number-computed, loc: loc)
      if thms == none {
        return (thm, )
      } else {
        return thms + (thm, )
      }
    })
  }

  if defer {
    return number-update + thm-update
  }

  return figure(
    number-update + thm-update +  // hacky!
    [#metadata(supplement) <meta:thm-env-counter>] +
    context {
      let thm-s = thm-stored.get().last()
      let thm = thm + (number: thm-s.number, loc: thm-s.loc)
      fmt(thm)
    },
    kind: "thm-env",
    outlined: false,
    caption: name,
    supplement: supplement,
    numbering: numbering,
  )
}




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
/// scope: (thm-rules: thm-rules-2)
/// )
///
/// -> metadata
#let qedhere = metadata("thm-qedhere")


/// Add content which floats to the right in an equation.
/// #example(```
/// >>> #show: thm-rules
/// $
///   (a + b)^2
///     &= a^2 + 2 a b + b^2 \
///     &<= 2a^2 + 2b^2 #tag[(AM-GM)] \
///     &<= 2 thin max{a, b}^2.
/// $
/// ```,
/// mode: "markup",
/// scope: (thm-rules: thm-rules-2)
/// )
///
/// -> content
#let tag(
  /// Content to use as tag
  /// -> any
  t,
  /// If ```typc false```, tags occupy no horizontal space in the equation layout.
  /// Set this to ```typc true``` if equation content overlaps the tag.
  /// This will have the minor disadvantage of moving the equation off-center
  /// to accommodate the tag.
  ///
  /// *Note:* Trying to determine this option automatically currently causes
  /// layout convergence issues in some cases.
  ///
  /// -> bool
  move: false,
) = metadata((eq-tag: t, move: move))




/// Used as the `body-fmt` in @proof, for properly styling proofs
/// by inserting a `qed` symbol at the end of the body.
/// Also see @qedhere.
/// #example(```
/// #show: thm-rules.with(qed-symbol: $"Q.E.D."$)
///
/// #proof-body-fmt[#lorem(3)]
///
/// #proof-body-fmt[
///   $
///     phi.alt(x) = 1/sqrt(2 pi) e^(-x^2\/2) #qedhere
///   $
/// ]
/// ```,
/// mode: "markup",
/// scope: (thm-rules: thm-rules-2)
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

/// Proof environment.
/// Identical to @thm, with different defaults.
/// Uses the @thm-fmt-block formatting function (for @thm.fmt), with
/// @proof-body-fmt (for @thm-fmt-block.body-fmt).
/// #example(```
/// >>> #show: thm-rules
/// #let theorem = thm.with(
///   supplement: "Theorem",
///   base: none
/// )
///
/// #theorem[#lorem(6)]
/// #proof[#lorem(3)]
/// ```,
/// mode: "markup",
/// scope: (thm-rules: thm-rules-2)
/// )
///
/// -> function
#let proof = thm.with(supplement: "Proof", numbering: none, fmt: thm-fmt-block.with(name-fmt: emph, title-fmt: emph, body-fmt: proof-body-fmt, separator: [. ]))


/// Rules for styling theorem environments, references, proofs, etc.
/// _Must appear at the beginning of the document._
///
/// -> content
#let thm-rules(
  /// Symbol displayed at the end of proofs.
  /// See @proof, @qedhere, @proof-body-fmt.
  /// Use as
  /// #example(```
  /// #show: thm-rules.with(
  ///   qed-symbol: $square$
  /// )
  ///
  /// #proof[
  ///   #lorem(5)
  ///   $ integral_0^oo sin(x)/x thin d x = pi/2. #qedhere $
  /// ]
  ///
  /// ```,
  /// mode: "markup",
  /// scope: (thm-rules: thm-rules-2)
  /// )
  /// -> content
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

    // let ref-supplement = it.element.supplement
    // if it.citation.supplement != none {
    //   ref-supplement = it.citation.supplement
    // }

    let ref-supplement = it.citation.supplement
    // if (ref-supplement == none or ref-supplement == [] or (ref-supplement.has("text") and ref-supplement.text == "")) {
    //   ref-supplement = none
    // }

    let loc = it.element.location()
    let thms = query(selector(<meta:thm-env-counter>).after(loc))
    let thmloc = thms.first().location()
    let thm = thm-stored.at(thmloc).last()
    return (thm.ref-fmt)(thm + (ref-supplement: ref-supplement))
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
          let dx = -pos-here.x + pos-numbering.x - width
          if data.value.move {
            move(dx: dx, data.value.eq-tag)
          } else {
            place(horizon, dx: dx, data.value.eq-tag)
          }
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
