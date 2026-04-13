#import "/preamble.typ": *

#show: template.with(
  title: [Rejection Sampling],
  created: datetime(year: 2026, month: 4, day: 12),
  updated: datetime(year: 2026, month: 4, day: 13),
)

#let tp = $tilde(p)$
#let xx = $bold(x)$

_Rejection sampling_ is a basic method for sampling from distributions
$ p(xx) = tp(xx) \/ Z_p, $
with possibly unknown normalizing constants $Z_p = integral tp(xx) dif xx$.

== Rejection Sampling

The core idea is to use a proposal distribution $q(xx)$ such that $C q(xx)>=tp(xx)$ for some constant $C$, that is, $C q(xx)$ is an upper bound of $tp(xx)$.

#quote[
  The proposal distribution $q(xx)$ generally should be easy to sample from (e.g. Gaussians) compared to the target distribution $p(xx)$.
]

To sample from the $p(xx)$, we first sample $xx~q(xx)$, and then either _accpet_ or _reject_ the sample $xx$ with probability
$ q("accept"|xx) = tp(xx) / (C q(xx)). $
Consequently, using the Bayes theorem we can show that
$
  q(xx|"accept") & = q("accept"|xx) dot q(xx) \/ q("accept") \
                 & = (tp(xx) \/ C) / (integral tp(xx) \/ C dif xx)
                   = tp(xx) / Z_p
                   = p(xx).
$
That is, the accepted samples will be distributed according to $p(xx)$.

== Adaptive Rejection Sampling

The efficiency of rejection sampling is mostly determined by how "tight" the upper bound $C q(xx)$ is.

#quote[
  For example, one can in theory use an arbitrarily large $C$, but this results in a loose bound and hence high rejection rate.
]

Adaptive rejection sampling is a method for automatically constructing a tight upper bound $q(xx)$ for any log-concave univariate density $p(xx)$.
1. We discretize the support of $p(xx)$ into finitely many grids;
2. We construct a linear upper bound of $log tp(xx)$ for each grid.
The resulting upper bound $q(xx)$ will be piecewise exponential as the log of the bound is piecewise linear.

#rule()

Rejection sampling does not scale to high dimensional space very well, as _(a)_ it is challenging to come up with a tight bound, and _(b)_ rejection rates are almost always $approx 1$ due to the curse of dimensionality.
