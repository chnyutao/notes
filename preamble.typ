#import "@preview/showybox:2.0.4": showybox

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
  set page(paper: "iso-b5")
  set par(justify: true)

  // heading
  grid(
    columns: (1fr, auto),
    align: (left, left + bottom),
    [
      #heading(title, level: 1)
      #author
    ],
    text(fill: gray.darken(50%), size: 0.8em)[
      #let format = "[month repr:short] [day] [year]"
      $hourglass.stroked$ #created.display(format) \
      $hourglass.filled$ #updated.display(format)
    ],
  )

  // contents
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
    {
      show outline: set text(size: 0.8em)
      outline(target: heading.where(level: 2), title: none, indent: 0%)
    },
  )

  body
}

// =======
// SYMBOLS
// =======
#let xx = $bold(x)$
