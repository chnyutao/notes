#import "/preamble.typ": *

#show: template.with(
  title: [Expectation Maximization],
  created: datetime(year: 2025, month: 10, day: 6),
  updated: datetime(year: 2025, month: 10, day: 11),
)

#let KL = $DD_"KL"$
#let theta = $bold(theta)$
#let xx = $bold(x)$
#let zz = $bold(z)$

*Expectation maximization* (EM) @dempster1977maximum is designed for _maximum likelihood_ estimation of parameters in probabilistic models with _missing data_ or _hidden variables_.

Let ${xx_n}$ denote the set of observed data, and ${zz_n}$ the set of hidden data. We want to maximize the likelihood w.r.t. the observed data:
$
    & limits(arg max)_theta sum_(xx_n) log p(xx_n|theta) \
  = & limits(arg max)_theta sum_(xx_n) log (integral p(xx_n,zz_n|theta) dif zz_n),
$
where $p(xx|theta)$ is known as the _incomplete-data_ likelihood, and $p(xx,zz|theta)$ is known as the _complete-data_ likelihood.

== Evidence Lower Bound

Unfortunately, this maximization is generally intractable, because of the $log integral p(xx,zz|theta) dif zz$ term.

We can bypass the intractability by transforming $log p(xx|theta)$ as follows:
$
  log p(xx|theta)
  & = EE_(q(zz))[log p(xx|theta)] \
  & = EE_(q(zz))[log (p(xx,zz|theta) \/ p(zz|xx,theta))] \
  & = underbrace(EE_(q(zz))[log p(xx,zz|theta) / q(z)], cal(F)(q(zz), theta)) + KL(q(zz) || p(zz|xx,theta)),
$
where $cal(F)(q(zz), theta)$ is known as the _evidence lower bound_ (ELBO). We have
$ cal(F)(q(zz), theta) <= log p(xx|theta) $
for any $q(zz)$ and $theta$, with equality holding iff $q(zz)=p(zz|xx,theta)$.

The #highlight[EM algorithm] then maximizes $log p(xx|theta)$ by instead maximizing the lower bound $cal(F)(q(zz), theta)$ iteratively. For each iteration $t$, we perform _coordinate ascent_ on $cal(F)(q(zz),theta)$ alternating between $q(zz)$ and $theta$.
- In the *E-step*, we maximize $cal(F)(q(zz), theta)$ with $theta=theta_t$ fixed:
  $ q_t (zz) = limits(arg max)_(q(zz)) space cal(F)(q(zz), theta_t) = p(zz|xx,theta_t). $
- In the *M-step*, we maximize $cal(F)(q(zz), theta)$ with $q(zz)=q_t (zz)$ fixed: #h(1fr)
  $
    theta_(t+1) & = limits(arg max)_theta space cal(F)(q_t (zz), theta) \
                & = limits(arg max)_theta space EE_(q_t (zz))[log p(xx,zz|theta)].
  $

This iterative process guarantees monotonic improvement of $log p(xx|theta)$ until convergence to some _local_ maxima, because for each iteration $t$
$
  log p(xx|theta_t)
  = underbrace(cal(F)(q_t (zz), theta_t), "E-step")
  <= underbrace(cal(F)(q_t (zz),theta_(t+1)), "M-step")
  <= log p(xx|theta_(t+1)).
$

#quote[
  The EM algorithm can also be applied to _maximum a posteriori_ with a prior distribution $p(theta)$ over the parameters. This simply amounts to a modified lower bound objective $tilde(cal(F))$:
  $ tilde(cal(F))(q(zz),theta) = cal(F)(q(zz),theta) + log p(theta) <= log p(x|theta)p(theta). $
]

== Extensions and Connections

=== Variational EM

One of the basic assumption we have made in EM is that we can easily evaluate $q_t (zz)=p(zz|xx,theta_t)$ in the E-step.

However, evaluating the posterior $p(zz|xx,theta_t)$ itself could be intractable, especially if $zz$ is a continuous r.v. We can instead use _variational inference_ (VI) to pick $q_t$ such that
$ q_t (zz) = limits(arg max)_(q in cal(Q)) space KL(q(zz) || p(zz|xx,theta)), $
where $Q$ is the variational family. Intuitively, we pick a distribution $q_t (zz) in cal(Q)$ that can best approximate the exact posterior $p(zz|xx,theta)$.

This approach, unfortunately, does not guarantee monotonic improvement of $log p(xx|theta)$ due to approximation errors. Only when the variational family $Q$ is sufficiently versatile such that $p(zz|xx,theta) in cal(Q)$ can we (in theory) recover the behaviors of regular EM.

=== Stochastic Gradient EM

Another basic assumption we have made in EM is that we can compute $theta_(t+1) = arg max_theta cal(F)(q_t (zz),theta)$ in the M-step.

For many practical problems, however, such maximization is not easy. Fortunately, note that in the M-step, as long as we can find some $theta_(t+1)$ that guarantees
$ cal(F)(q_t (zz), theta_t) <= cal(F)(q_t (zz), theta_(t+1)), $
the monotonic improvement of $log p(xx|theta)$ (and hence convergence) still holds. Therefore, we can find $theta_(t+1)$ by taking one or a few gradient ascent steps following $nabla_theta cal(F)$:
$ theta_(t+1) = theta_t + eta nabla_theta cal(F)(q_t (zz), theta_t). $

#quote[
  The varational auto-encoders (VAEs) @kingma2013auto can be interpreted as an instance of variational stochastic gradient EM.
]

However, EM becomes less appealling when there is no close form for the M-step, as one might just as well directly optimize $log p(xx|theta)$ using gradient-based methods. Particularly, one can show that
$ nabla_theta log p(xx|theta_t) = nabla_theta cal(F)(q_t (zz), theta_t). $

#references()
