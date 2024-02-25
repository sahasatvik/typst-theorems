// Store theorem environment numbering

#let thmcounters = state("thm",
  (
    "counters": ("heading": ()),
    "latest": ()
  )
)


#let thm-env(identifier, base, base_level, fmt) = {

  let global_numbering = numbering

  return (
    ..args,
    body,
    number: auto,
    numbering: "1.1",
    refnumbering: auto,
    supplement: identifier,
    base: base,
    base_level: base_level
  ) => {
    let name = none
    if args != none and args.pos().len() > 0 {
      name = args.pos().first()
    }
    if refnumbering == auto {
      refnumbering = numbering
    }
    let result = none
    if number == auto and numbering == none {
      number = none
    }
    if number == auto and numbering != none {
      result = locate(loc => {
        return thmcounters.update(thmpair => {
          let counters = thmpair.at("counters")
          // Manually update heading counter
          counters.at("heading") = counter(heading).at(loc)
          if not identifier in counters.keys() {
            counters.insert(identifier, (0, ))
          }

          let tc = counters.at(identifier)
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
              counters.at(identifier) = (..bc, tc.last() + 1)
            } else {
              counters.at(identifier) = (..bc, 1)
            }
          } else {
            // If we have no base counter, just count one level
            counters.at(identifier) = (tc.last() + 1,)
            let latest = counters.at(identifier)
          }

          let latest = counters.at(identifier)
          return (
            "counters": counters,
            "latest": latest
          )
        })
      })

      number = thmcounters.display(x => {
        return global_numbering(numbering, ..x.at("latest"))
      })
    }

    return figure(
      result +  // hacky!
      fmt(name, number, body, ..args.named()) +
      [#metadata(identifier) <meta:thm-env-counter>],
      kind: "thm-env",
      outlined: false,
      caption: name,
      supplement: supplement,
      numbering: refnumbering,
    )
  }
}


#let thm-box(
  head,
  identifier: auto,
  ..args,
  numbering: "1.1",
  supplement: auto,
  padding: (y: 0.1em),
  namefmt: x => [(#x)],
  titlefmt: strong,
  bodyfmt: x => x,
  separator: [*.*#h(0.2em)],
  base: "heading",
  base_level: none,
) = {
  if identifier == auto {
    identifier = head
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
        breakable: false,
        ..args.named(),
        ..args_individual.named(),
        [#title#name#separator#body]
      )
    )
  }
  return thm-env(
    identifier,
    base,
    base_level,
    boxfmt
  ).with(
    numbering: numbering,
    supplement: supplement,
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
  breakable: true,
  namefmt: name => emph([(#name)]),
  titlefmt: emph,
  separator: [.#h(0.2em)],
  numbering: none
)

// Track whether the qed symbol has already been placed in a proof
#let thm-qed-done = state("thm-qed-done", false)

// Show the qed symbol, update state
#let thm-qed-show = {
  thm-qed-done.update("thm-qed-symbol")
  thm-qed-done.display()
}

// If placed in a block equation/enum/list, place a qed symbol to its right
#let qedhere = metadata("thm-qedhere")

// Checks if content x contains the qedhere tag
#let thm-has-qedhere(x) = {
  if x == "thm-qedhere" {
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
  locate(loc => {
    if thm-qed-done.at(loc) == false {
      h(1fr)
      thm-qed-show
    }
  })
}

#let thm-proof(..args) = thm-rem(
    ..args,
    namefmt: emph,
    bodyfmt: proof-bodyfmt,
    ..args.named()
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

    let loc = it.element.location()
    let thms = query(selector(<meta:thm-env-counter>).after(loc), loc)
    let number = thmcounters.at(thms.first().location()).at("latest")
    return link(
      it.target,
      [#supplement~#numbering(it.element.numbering, ..number)]
    )
  }

  show math.equation.where(block: true): eq => {
    if thm-has-qedhere(eq) and thm-qed-done.at(eq.location()) == false {
      grid(
        columns: (1fr, auto, 1fr),
        [], eq, align(right + horizon)[#thm-qed-show]
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

  show "thm-qed-symbol": qed-symbol

  doc
}
