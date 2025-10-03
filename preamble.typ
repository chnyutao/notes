#import "@preview/showybox:2.0.4": showybox

// =========
// FUNCTIONS
// =========
#let references() = {
  show bibliography: set heading(outlined: false)
  bibliography("references.bib", style: "apa", title: smallcaps[References])
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

  show cite: set text(fill: gray.darken(50%))
  show cite.where(supplement: [prose]): it => cite(it.key, form: "prose")

  // HEADING
  grid(
    columns: (1fr, auto),
    align: (left, left + bottom),
    [
      #heading(level: 1, outlined: false, title)
      #author
    ],
    text(fill: gray.darken(50%), size: 0.8em)[
      #let format = "[month repr:short] [day] [year]"
      $hourglass.stroked$ #created.display(format) \
      $hourglass.filled$ #updated.display(format)
    ],
  )

  // CONTENTS
  showybox(
    frame: (
      title-color: black.lighten(80%),
      body-color: gray.lighten(80%),
      radius: 0pt,
      thickness: (left: 1pt),
    ),
    title-style: (
      color: black,
      weight: "bold",
      sep-thickness: 0pt,
    ),
    title: [Contents],
    outline(title: none, indent: n => (n - 1) * 1em),
  )

  body
}
