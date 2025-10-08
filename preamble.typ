// =========
// FUNCTIONS
// =========
#let dim(body) = text(fill: gray.darken(25%), size: 0.8em, body)
#let fancybox(body, body-styles: (:), title: none, title-styles: (:)) = {
  let defaults = (
    inset: (x: 1em, y: 0.65em),
    stroke: (left: 1pt + black),
    width: 100%,
  )
  if title != none { block(..defaults, ..(below: 0pt, sticky: true), ..title-styles, title) }
  if body != none { block(..defaults, ..body-styles, body) }
}
#let quote(body) = fancybox(body, body-styles: (fill: gray.lighten(80%)))
#let references() = {
  show bibliography: set heading(outlined: false)
  bibliography("references.bib", style: "apa", title: smallcaps[References])
}
#let wikilink(dest, body) = {
  show link: underline
  show link: set text(fill: cmyk(100%, 100%, 0%, 0%))
  [\[\[#link("https://chnyutao.github.io/notes/" + dest + ".pdf", body)\]\]]
}

// ========
// TEMPLATE
// ========
#let template(
  title: [Title],
  author: [Yutao Chen],
  created: datetime(year: 1970, month: 1, day: 1),
  updated: datetime.today(),
  body,
) = {
  set page(paper: "a5")
  set par(justify: true)

  show cite: set text(fill: cmyk(100%, 100%, 0%, 0%))
  show cite.where(supplement: [prose]): it => cite(it.key, form: "prose")
  show math.equation: set block(breakable: true)

  // HEADING
  grid(
    columns: (1fr, auto),
    align: (left, left + bottom),
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

  // CONTENTS
  fancybox(
    outline(indent: n => (n - 1) * 1em, title: none),
    body-styles: (fill: gray.lighten(80%)),
    title: [*Contents*],
    title-styles: (fill: black.lighten(80%)),
  )

  body
}
