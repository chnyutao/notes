#import "/preamble.typ": *

#show: template.with()

= Importance Sampling

Say we are interested in evaluating the following expectation:
$ EE_p(xx) [f(xx)] = integral p(xx)f(xx) d xx. $
A naive Monte Carlo approximation
$ EE_p(xx) [f(xx)] approx 1/N sum_(n=1)^N p(xx_n)f(xx_n) $
typically requires us being able to sample $xx_1,dots,xx_n$ from the _target distribution_ $p(xx)$.

== Direct Importance Sampling

However, it is generally difficult  to sample from $p(xx)$. Instead we resort to some _proposal distribution_ $q(xx)$:
$
  EE_p(xx) [f(xx)] & = integral p(xx)f(xx) d xx \
                   & = integral q(xx)p(xx)/q(xx)f(xx) d xx \
                   & = EE_q(xx) [p(xx)/q(xx)f(xx)] \
                   & approx 1/N sum_(n=1)^N w_n f(xx_n),
$
where $w_n = p(xx_n) \/ q(xx_n)$ is referred to as the _importance weight_.

In this way, we bypass sampling from $p(xx)$ by instead sampling from the proposal distribution $q(xx)$. However, we still need to evaluate the densities $p(xx)$ or $q(xx)$.

== Self-Normalized Importance Sampling

In some cases, even evaluating the densities $p(xx)$ or $q(xx)$ is difficult. In this case, we instead consider the unnormalized densities $tilde(p)(xx)$ and $tilde(q)(xx)$ such that
$
  p(xx) & =tilde(p)(xx) \/ Z_p, \
  q(xx) & =tilde(q)(xx) \/ Z_q,
$
where $Z_p=integral tilde(p)(xx) d xx$ and $Z_q=integral tilde(q)(xx) d xx$. We now have
$
  EE_p(xx) [f(xx)] & = integral p(xx)f(xx) d xx \
                   & = Z_q/Z_p integral q(xx) (tilde(p)(xx)) / (tilde(q)(xx)) f(xx) d xx \
                   & = Z_q/Z_p EE_q(xx) [(tilde(p)(xx)) / (tilde(q)(xx)) f(xx)] \
                   & approx Z_q/Z_p 1/N sum_(n=1)^N tilde(w)_n f(xx_n),
$
where $tilde(w)_n = tilde(p)(xx_n) \/ tilde(q)(xx_n)$. Similarly, we can derive that
$
  Z_p/Z_q = integral q(xx) (tilde(p)(xx)) / (tilde(q)(xx)) d xx approx 1/N sum_(n=1)^N tilde(w)_n.
$
Putting everything together, we have the following simplified form of _self-normalized importance sampling_:
$
  EE_p(x)[f(x)] approx (sum_(n=1)^N tilde(w)_n f(xx_n)) / (sum_(n=1)^N tilde(w)_n).
$
