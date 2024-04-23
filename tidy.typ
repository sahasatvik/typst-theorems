#import "@preview/tidy:0.2.0"
#import "theorems.typ": *

#set page(margin: (x: 0.7in))
#set block(breakable: false)


#let docs = tidy.parse-module(
  read("theorems.typ"),
  scope: (
    thm-rules-1: (..args, doc) => {
      counter(heading).update(0)
      thm-stored.update(())
      thm-counters.update((
        "counters": ("heading": ()),
        "latest": ()
      ))
      block(
        width: 3.3in,
        inset: 0.7em,
        thm-rules(
          ..args.named(),
          doc
        )
      )
    },
    thm-rules-2: (..args, doc) => {
      block(
        width: 3.3in,
        inset: 0.7em,
        thm-rules(
          ..args.named(),
          doc
        )
      )
    },
    thm-env: thm-env,
    thm-box: thm-box,
    thm-plain: thm-plain,
    thm-def: thm-def,
    thm-rem: thm-rem,
    thm-proof: thm-proof,
    proof-body-fmt: proof-body-fmt,
    qedhere: qedhere,
    thm-display-1: thm-display,
    thm-restate: thm-restate,
  ),
)


#show link: it => text(blue, it)
#show raw: set text(font: "Cascadia Code")

= typst-theorems/ctheorems documentation

#tidy.show-module(
  docs,
  style: tidy.styles.default,
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
      "qedhere",
      "thm-restate",
      "thm-display",
    ).position(
      x => (f.name == x)
    )
  },
  show-outline: false,
  break-param-descriptions: true,
)

