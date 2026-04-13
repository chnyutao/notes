#import "/preamble.typ": *

#show: template.with(
  title: [Importance Sampling],
  created: datetime(year: 2025, month: 8, day: 26),
  updated: datetime(year: 2026, month: 4, day: 13),
)

#let xx = $bold(x)$

_Importance sampling_ is a Monte Carlo method for approximating expectations (integrals) of the following form:
$ EE_p(xx) [f(xx)] = integral p(xx)f(xx) dif xx. $
A naive Monte Carlo approximation
$ EE_(p(xx))[f(xx)] approx 1/N sum_(n=1)^N p(xx_n) f(xx_n) $
typically requires sampling $xx_1,dots,xx_n$ from the _target distribution_ $p(xx)$.

== Direct Importance Sampling

In general, it could be expensive or intractable to sample from arbitrary targets $p(xx)$. We can instead resort to some _proposal distribution_ $q(xx)$:
$
  EE_p(xx) [f(xx)] & = integral p(xx)f(xx) dif xx \
                   & = integral q(xx)p(xx)/q(xx)f(xx) dif xx
                     approx 1/N sum_(n=1)^N w_n f(xx_n),
$
where $xx_n ~ q(xx)$ and $w_n = p(xx_n) \/ q(xx_n)$ is the _importance weight_.

In this way, we replace sampling from the target $p(xx)$ with a proposal $q(xx)$. However, we are still required to compute the densities $p(xx)$ and $q(xx)$ for $xx ~ q(xx)$.

== Self-Normalized Importance Sampling

#let tp = $tilde(p)$
#let tq = $tilde(q)$
#let tw = $tilde(w)$

In some cases, even the densities $p(xx)$ and $q(xx)$ can only be evaluated up to some unknown _normalizing constant_. We consider the unnormalized densities $tp(xx)$ and $tq(xx)$ such that
$
  p(xx) & =tp(xx) \/ Z_p, \
  q(xx) & =tq(xx) \/ Z_q,
$
where $Z_p=integral tp(xx) dif xx$ and $Z_q=integral tq(xx) dif xx$ are normalizing constants. We can show that
$
  EE_p(xx) [f(xx)] & = Z_q/Z_p integral q(xx) (tp(xx)) / (tq(xx)) f(xx) dif xx \
                   & approx Z_q/Z_p 1/N sum_(n=1)^N w_n f(xx_n),
$
where $w_n = tp(xx_n) \/ tq(xx_n)$. Similarly, we can show that
$
  Z_p/Z_q = integral q(xx) (tp(xx)) / (tq(xx)) dif xx approx 1/N sum_(n=1)^N w_n.
$
Putting everything together, we now have the following form:
$
  EE_p(xx)[f(xx)] approx sum_(n=1)^N tw_n f(xx_n),
$
where $tw_n = w_n \/ sum_(k=1)^N w_k$ is the self-normalized importance weight.
