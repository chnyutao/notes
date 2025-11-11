#import "/preamble.typ": *

#set page(numbering: "1")

#show: template.with(
  title: [Natural Gradient Descent],
  created: datetime(year: 2025, month: 10, day: 3),
  updated: datetime(year: 2025, month: 10, day: 11),
)

#let KL = $DD_"KL"$
#let lambda = $bold(lambda)$
#let mu = $bold(mu)$
#let theta = $bold(theta)$
#let xx = $bold(x)$

Natural gradient descent (NGD) @amari1998natural is a second-order optimization method for parametrized probability distributions $p(xx|theta)$:
$ theta_(t+1) = theta_t - eta F^(-1)(theta_t) nabla J(theta_t), $
where $F^(-1)(theta_t)$ is the inverse of the _Fisher information matrix_ (FIM).

#definition(label: <fim>, title: [Fisher Information Matrix])[
  The Fisher information matrix $F(theta)$ for $p(x|theta)$ is defined as the variance of the _score_ function $nabla_theta log p(x|theta)$ #footnote[The expectation of the score function $EE_(p(x|theta))[nabla_theta log p(x|theta)]=0$.]:
  $ F(theta) = EE_(p(x|theta))[(nabla_theta log p(x|theta)) (nabla_theta log p(x|theta))^top], $
  or equivalently the negative expected Hessian of the log likelihood
  $ F(theta) = - EE_(p(x|theta))[nabla^2_theta log p(x|theta)]. $
]

== Kullback-Leibler Divergence

Recall that #wikilink("/optimization/gradient-descent.typ") can be derived from
$ limits(arg min)_theta space J(theta_t) + nabla J(theta_t)^top (theta-theta_t) + (2eta)^(-1) ||theta-theta_t||_2^2, $
which penalizes large updates by measuring the (squared) Euclidean distance $||theta-theta_t||_2^2$ between parameter.

For probabilistic models, however, the parameter space is generally _not_ Euclidean. Instead, a more natural penalty would be measuring the Kullback-Leibler (KL) divergence between the induced distributions:
$
  limits(arg min)_theta space J(theta_t) + nabla J(theta_t)^top (theta-theta_t) + eta^(-1) KL(p(x|theta_t) || p(x|theta)).
$

Unfortunately, $KL(p||q)$ do not have an analytical form in general. We instead consider its second-order Taylor approximation. Let $f(theta) = KL(p(x|theta_t) || p(x|theta))$ and $delta theta = theta - theta_t$, and we have
$
  f(theta) approx f(theta_t) + nabla f(theta_t)^T delta theta + 1/2 delta theta^top nabla^2 f(theta_t) delta theta.
$
#quote[
  1. The first term is trivially zero as #h(1fr)
    $ f(theta_t)=KL(p(x|theta_t) || p(x|theta_t))=0. $
  2. The second term is also zero as
    $
      nabla f(theta_t) & = - EE_(p(x|theta_t)) [lr(nabla_theta log p(x|theta)|)_(theta=theta_t)] \
                       & = - integral cancel(p(x|theta_t) / p(x|theta_t)) nabla_theta p(x|theta_t) dif x = 0,
    $
    where $nabla$ and $integral$ are exchangeable by the _Leibniz integral rule_.
  3. The third term is non-zero. However, note that by @fim
    $
      nabla^2 f(theta_t) & = - EE_(p(x|theta_t)) [lr(nabla^2_theta log p(x|theta)|)_(theta=theta_t)] \
                         & = - EE_(p(x|theta_t)) [nabla^2_(theta) log p(x|theta_t)] = F(theta_t).
    $
]

Therefore, we have $KL(p(x|theta_t) || p(x|theta)) approx 1/2 delta theta^top F(theta_t) delta theta$. Plugging back into the optimization objective, we have
$
  limits(arg min)_theta space J(theta_t) + nabla J(theta_t)^top delta theta + (2eta)^(-1) delta theta^top F(theta_t) delta theta,
$
which can be solved by $theta^* = theta_t - eta F^(-1)(theta_t) nabla J(theta_t)$.

== Efficiency and Approximations

A major drawback of NGD is that computing and inverting the FIM is expensive. Therefore, efficient approximation methods or alternative routines have been of particular research interests.

=== Empirical Fisher

Recall that FIM can be defined as the variance of the score function
$ F(theta) = EE_(p(x|theta))[(nabla_theta log p(x|theta)) (nabla_theta log p(x|theta))^top]. $

_Empirical Fisher_ approximates FIM by evaluating the expectation w.r.t. an empirical distribution $p_(cal(D))(x)$, where $cal(D)$ is a dataset:
$ F(theta) approx 1 / (|cal(D)|) sum_(x in cal(D)) (nabla_theta log p(x|theta)) (nabla_theta log p(x|theta))^top. $

=== Exponential Family Distributions

For an exponential family distribution with natural parameters $lambda$ and corresponding moment parameters $mu$, one can show that
$ F(lambda)^(-1) nabla_lambda cal(L)(lambda) = nabla_mu cal(L)(mu). $
That is, the natural gradient w.r.t $lambda$ equals the regular gradient w.r.t. $mu$.

This result, under certain circumstances, conveniently allows performing NGD without actually computing FIM. We refer the readers to @khan2023bayesian[prose] and @murphy2023probabilistic[prose] Section 6.4.5 for more context.

#references()
