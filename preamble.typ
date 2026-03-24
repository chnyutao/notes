// =========
// VARIABLES
// =========

#let palette = (
  bg: (
    blue0: cmyk(1%, 1%, 0%, 0%),
    blue1: cmyk(10%, 5%, 0%, 0%),
    gray0: gray.lighten(80%),
    gray1: black.lighten(80%),
  ),
  fg: (
    blue: cmyk(100%, 100%, 0%, 0%),
    gray: gray.darken(20%),
  ),
)

#let counters = (def: counter(figure.where(kind: "def")))

// =========
// FUNCTIONS
// =========

#let fancybox(body, body-styles: (:), title: none, title-styles: (:)) = {
  let defaults = (
    inset: (x: 1em, y: 0.65em),
    stroke: (left: 1pt),
    width: 100%,
  )
  if title != none { block(..defaults, ..(below: 0pt, sticky: true), ..title-styles, title) }
  if body != none { block(..defaults, ..body-styles, body) }
}

#let definition(body, label: none, title: none) = fancybox(
  body,
  body-styles: (fill: palette.bg.blue0, stroke: (left: palette.fg.blue)),
  title: [
    // dummy label for counting + referencing
    #place[#figure(kind: "def", supplement: [Definition])[] #label]
    *Definition* #context counters.def.display() (#title)
  ],
  title-styles: (fill: palette.bg.blue1, stroke: (left: palette.fg.blue)),
)

#let dim(body) = text(body, fill: palette.fg.gray, size: 0.8em)

#let proof(body) = {
  set text(size: 0.8em)
  fancybox(body-styles: (stroke: none))[
    _Proof_. #sym.space #body
    #place(bottom + right, square(fill: palette.bg.blue1, size: 0.8em))
  ]
}

#let quote(body) = fancybox(
  body,
  body-styles: (fill: palette.bg.gray0),
)

#let references() = {
  show bibliography: set heading(outlined: false)
  bibliography("references.bib", style: "apa", title: smallcaps[References])
}

#let wikilink(dest, title: none) = {
  show link: underline
  show link: set text(fill: palette.fg.blue)
  dest = dest.replace(".typ", "")
  if title == none {
    let titlecase = word => upper(word.at(0)) + word.slice(1)
    title = dest.split("/").last().split("-").map(titlecase).join(" ")
  }
  [\[\[#link("https://chnyutao.github.io/notes" + dest + ".pdf", title)\]\]]
}

// ========
// TEMPLATE
// ========
#let template(
  title: [Title],
  author: "Yutao Chen",
  created: datetime(year: 1970, month: 1, day: 1),
  updated: datetime.today(),
  body,
) = {
  set document(author: author, date: created, title: title)
  set page(numbering: "1", paper: "a5")
  set par(justify: true)

  show cite: set text(fill: palette.fg.blue)
  show cite.where(supplement: [prose]): it => cite(it.key, form: "prose")
  show math.equation: set block(breakable: true)

  // heading
  grid(
    columns: (1fr, auto),
    align: (left, right + bottom),
    [
      #heading(level: 1, outlined: false, title)
      #author
    ],
    dim[
      #let format = "[month repr:short] [day] [year]"
      $hourglass.stroked$ #created.display(format) \
      $hourglass.filled$ #updated.display(format)
    ],
  )

  // contents
  fancybox(
    outline(indent: n => (n - 1) * 1em, title: none),
    body-styles: (fill: palette.bg.gray0),
    title: [*Contents*],
    title-styles: (fill: palette.bg.gray1),
  )

  body
}
