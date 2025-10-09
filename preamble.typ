// =========
// VARIABLES
// =========
#let palette = (
  bg: (
    dark: black.lighten(80%),
    light: gray.lighten(80%),
  ),
  blue: cmyk(100%, 100%, 0%, 0%),
  fg: (dim: gray.darken(20%)),
)

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
#let quote(body) = fancybox(body, body-styles: (fill: palette.bg.light))
#let references() = {
  show bibliography: set heading(outlined: false)
  bibliography("references.bib", style: "apa", title: smallcaps[References])
}
#let wikilink(dest, title: none) = {
  show link: underline
  show link: set text(fill: palette.blue)
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
  set page(paper: "a5")
  set par(justify: true)

  show cite: set text(fill: palette.blue)
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
    text(fill: palette.fg.dim, size: 0.8em)[
      #let format = "[month repr:short] [day] [year]"
      $hourglass.stroked$ #created.display(format) \
      $hourglass.filled$ #updated.display(format)
    ],
  )

  // CONTENTS
  fancybox(
    outline(indent: n => (n - 1) * 1em, title: none),
    body-styles: (fill: palette.bg.light),
    title: [*Contents*],
    title-styles: (fill: palette.bg.dark),
  )

  body
}
