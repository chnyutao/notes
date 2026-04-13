#import "/preamble.typ": *

#show: template.with(
  title: [Inverse Transform Sampling],
  created: datetime(year: 2026, month: 4, day: 12),
  updated: datetime(year: 2026, month: 4, day: 13),
  outlined: false,
)

The simplest method for sampling from univariate distributions is the _inverse transform sampling_.

#definition(title: [Probability Integral Transform])[
  Let $x$ be a continuous r.v. with the cumulative distribution function $F_x: RR arrow [0,1]$. We have
  $ u = F_x (x) ~ "Uniform"(0, 1). $
]
#proof[
  Let $F_u$ be the cumulative distribution function (CDF) of $u$. We can show that
  $
    F_u (U) & = "Pr"{u <= U} = "Pr"{F_x (x) <= U} \
            & = "Pr"{x <= F_x^(-1)(U)} = F_x (F_x^(-1)(U)) = U.
  $
  Note that $F_u (U)=U$ is simply the CDF of a uniform distribution on $[0,1]$. #footnote[See also the change-of-variables formula, as detailed in #wikilink("/generative-model/nf", title: [Normalizing Flow]).]
]

Therefore, we can sample from any univariate probability density $p(x)$, of which we can evaluate the inverse CDF $F_x^(-1)$
$
  u & ~ "Uniform"(0, 1), \
  x & = F_x^(-1)(U) ~ p(x),
$
by applying the inverse of the probability integral transform.
