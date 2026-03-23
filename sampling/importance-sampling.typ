#import "/preamble.typ": *

#show: template.with(
  title: [Importance Sampling],
  created: datetime(year: 2025, month: 8, day: 26),
  updated: datetime(year: 2026, month: 3, day: 23),
)

In this document, we describe a Monte Carlo method known as *importance sampling* for approximating expectations of the following form:
$ EE_p(x) [f(x)] = integral p(x)f(x) dif x. $
A naive Monte Carlo approximation
$ EE_p(x) [f(x)] approx 1/N sum_(n=1)^N p(x_n)f(x_n) $
typically requires sampling $x_1,dots,x_n$ from the _target distribution_ $p(x)$.

== Direct Importance Sampling

It is generally difficult to sample from an arbitrary target $p(x)$. Instead, we resort to some _proposal distribution_ $q(x)$:
$
  EE_p(x) [f(x)] & = integral p(x)f(x) dif x \
                 & = integral q(x)p(x)/q(x)f(x) dif x \
                 & approx 1/N sum_(n=1)^N w_n f(x_n),
$
where $x_n ~ q(x)$ and $w_n = p(x_n) \/ q(x_n)$ is the _importance weight_.

In this way, we replace sampling from an intractable target $p(x)$ with a tractable proposal $q(x)$. However, we still need to compute the densities $p(x)$ or $q(x)$ for $x ~ q(x)$.

== Self-Normalized Importance Sampling

#let tp = $tilde(p)$
#let tq = $tilde(q)$
#let tw = $tilde(w)$

In some cases, even the densities $p(x)$ and $q(x)$ can only be evaluated up to some _unknown_ normalizing constant. We consider the unnormalized densities $tp(x)$ and $tq(x)$ such that
$
  p(x) & =tp(x) \/ Z_p, \
  q(x) & =tq(x) \/ Z_q,
$
where $Z_p=integral tp(x) dif x$ and $Z_q=integral tq(x) dif x$ are constants. We now have
$
  EE_p(x) [f(x)] & = integral p(x)f(x) dif x \
                 & = Z_q/Z_p integral q(x) (tp(x)) / (tq(x)) f(x) dif x \
                 & approx Z_q/Z_p 1/N sum_(n=1)^N w_n f(x_n),
$
where $w_n = tp(x_n) \/ tq(x_n)$. Similarly, we can derive that
$
  Z_p/Z_q = integral q(x) (tp(x)) / (tq(x)) dif x approx 1/N sum_(n=1)^N w_n.
$
Putting everything together, we now have the following approximation:
$
  EE_p(x)[f(x)] approx sum_(n=1)^N tw_n f(x_n),
$
where $tw_n = w_n \/ sum_(m=1)^N w_m$ is the _self-normalized_ importance weight.
