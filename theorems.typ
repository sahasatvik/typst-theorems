// Store theorem environment numbering
#let thm-counters = state("thm-counters",
  (
    "counters": ("heading": ()),
    "latest": ()
  )
)

// Store theorem data
#let thm-stored = state("thm-stored", ())

#let heading-counter = counter(heading)


#let thm-env(counter, base, base_level, fmt) = {

  let global_numbering = numbering

  return (
    ..args,
    body,
    number: auto,
    numbering: "1.1",
    supplement: counter,
    base: base,
    base_level: base_level,
    restate: false,
    defer: false,
    restate-keys: (counter, )
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
            if base_level != none {
              if bc.len() < base_level {
                bc = bc + (0,) * (base_level - bc.len())
              } else if bc.len() > base_level{
                bc = bc.slice(0, base_level)
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

      number = thm-counters.display(x => {
        return global_numbering(numbering, ..x.at("latest"))
      })
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
          loc: loc,
          counter: counter,
          base: base,
          base_level: base_level
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
      numbering: numbering,
    )
  }
}

#let thm-display(..args, fmt: auto, at: auto, final: false) = {
  context {
    let thms = thm-stored.get()
    if at != auto {
      thms = thm-stored.at(at)
    }
    if final {
      thms = thm-stored.final()
    }
    if args.pos().len() > 0 {
      // Use arg_1 or ... or arg_n style filter
      thms = thms.filter(thm =>
        args.pos().any(x => x(thm))
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

#let thm-restate(..args, fmt: auto, at: auto, final: false) = {
  context {
    let thms = thm-stored.get()
    if at != auto {
      thms = thm-stored.at(at)
    }
    if final {
      thms = thm-stored.final()
    }
    thms = thms.filter(thm => (thm.restate or thm.defer))
    if args.pos().len() > 0 {
      // Use arg_1 or ... or arg_n style filter
      thms = thms.filter(thm =>
        args.pos().any(x => {
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

#let thm-box(
  head,
  counter: auto,
  ..args,
  numbering: "1.1",
  supplement: auto,
  padding: (y: 0.1em),
  namefmt: x => [(#x)],
  titlefmt: x => x,
  bodyfmt: x => x,
  separator: [.#h(0.2em)],
  base: "heading",
  base_level: none,
) = {
  if counter == auto {
    counter = head
  }
  if supplement == auto {
    supplement = head
  }
  let boxfmt(name, number, body, title: auto, ..args_individual) = {
    if not name == none {
      name = [ #namefmt(name)]
    } else {
      name = []
    }
    if title == auto {
      title = head
    }
    if not number == none {
      title += " " + number
    }
    title = titlefmt(title)
    body = bodyfmt(body)
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
    base,
    base_level,
    boxfmt
  ).with(
    numbering: numbering,
    supplement: supplement,
    restate-keys: (head, )
  )
}


#let thm-plain = thm-box.with(
  titlefmt: strong,
  bodyfmt: emph,
  separator: [*.*#h(0.2em)],
)

#let thm-def = thm-box.with(
  titlefmt: strong,
  separator: [*.*#h(0.2em)],
)

#let thm-rem = thm-box.with(
  padding: (y: 0em),
  namefmt: name => emph([(#name)]),
  titlefmt: emph,
  separator: [.#h(0.2em)],
  numbering: none
)

// Track whether the qed symbol has already been placed in a proof
#let thm-qed-done = state("thm-qed-done", false)

// Show the qed symbol, update state
#let thm-qed-show = {
  thm-qed-done.update(metadata("thm-qed-symbol"))
  thm-qed-done.display()
}

// If placed in a block equation/enum/list, place a qed symbol to its right
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


// bodyfmt for proofs
#let proof-bodyfmt(body) = {
  thm-qed-done.update(false)
  body
  context {
    if thm-qed-done.get() == false {
      h(1fr)
      thm-qed-show
    }
  }
}

#let thm-proof = thm-rem.with(
    namefmt: emph,
    bodyfmt: proof-bodyfmt,
)


#let thm-rules(qed-symbol: $qed$, doc) = {

  show figure.where(kind: "thm-env"): it => it.body

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
    let supplement_spaced = if (supplement == none or supplement == [] or (supplement.has("text") and supplement.text == "")) {
      ""
    } else {
      [#supplement~]
    }

    let loc = it.element.location()
    let thms = query(selector(<meta:thm-env-counter>).after(loc), loc)
    let thmloc = thms.first().location()
    let number = thm-stored.at(thmloc).last().number
    return link(
      it.target,
      [#supplement_spaced#number]
    )
  }

  show math.equation: eq => {
    if eq.numbering == none and thm-has-qedhere(eq) and thm-qed-done.at(eq.location()) == false {
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
