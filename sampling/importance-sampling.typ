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
typically requires sampling ${xx_n}$ from the _target distribution_ $p(xx)$.

== Direct Importance Sampling

In general, it could be expensive or intractable to sample from arbitrary targets $p(xx)$. We can instead resort to some _proposal distribution_ $q(xx)$:
$
  EE_p(xx) [f(xx)] & = integral p(xx)f(xx) dif xx \
                   & = integral q(xx)p(xx)/q(xx)f(xx) dif xx
                     = EE_(q(xx)) [w(xx) f(xx)],
$
where $w(xx) = p(xx) \/ q(xx)$ is the _importance weight_. Therefore,
$ EE_p(xx) [f(xx)] approx 1/N sum_(n=1)^N w(xx_n) f(xx_n). $

In this way, samples ${xx_n}$ are drawn from the proposal $q(xx)$ instead of the target $p(xx)$. However, we are still required to evaluate the densities $p(xx)$ and $q(xx)$ for computing $w(xx)$.

== Self-Normalized Importance Sampling

#let tp = $tilde(p)$
#let tq = $tilde(q)$
#let tw = $tilde(w)$

In some cases, even the densities $p(xx)$ and $q(xx)$ can only be evaluated up to unknown _normalizing constants_. Consider unnormalized densities $tp(xx)$ and $tq(xx)$ such that
$
  p(xx) & =tp(xx) \/ Z_p, \
  q(xx) & =tq(xx) \/ Z_q,
$
where $Z_p=integral tp(xx) dif xx$ and $Z_q=integral tq(xx) dif xx$ are normalizing constants. We can show that
$
  EE_p(xx) [f(xx)] & = Z_q/Z_p integral q(xx) (tp(xx)) / (tq(xx)) f(xx) dif xx \
                   & = Z_q/Z_p EE_q(xx) [w(xx) f(xx)],
$
where $w(xx) = tp(xx) \/ tq(xx)$. Similarly, we can show that
$
  Z_p/Z_q = integral q(xx) (tp(xx)) / (tq(xx)) dif xx = EE_q(xx) [w(xx)].
$
Putting everything together, we now have the following approximation:
$
  EE_p(xx)[f(xx)] approx sum_(n=1)^N tw_n f(xx_n),
$
where $tw_n = w_n \/ (sum_(k=1)^N w_k)$ is the _self-normalized_ importance weight.
