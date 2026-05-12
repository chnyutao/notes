#import "/preamble.typ": *

#show: template.with(
  title: [Diffusion #dim[#sym.section Variational Inference]],
  created: datetime(year: 2026, month: 4, day: 10),
  updated: datetime(year: 2026, month: 4, day: 10),
)

#let epsilon = $bold(epsilon)$
#let theta = $bold(theta)$
#let ub(x) = $upright(bold(#x))$
#let xx = $bold(x)$

Diffusion models @sohl-dickstein2015deep are among the most versatile and powerful generative models nowadays. In this document, we aim to understand diffusion through the lens of _variational inference_.

Diffusion models involve a forward and reverse process:
- The *forward process* corrupts data by gradually injecting Gaussian noise #footnote[We assume continuous data with Gaussian noise in this document.] over multiple time steps $t in {1, dots, T}$, until the corrupted data become pure noise.
- The *reverse process* learns a parametrized model that can, starting from pure noise, iteratively denoise corrupted data to generate clean samples akin to those from the data distribution.

#let node(..args) = fletcher.node(..args, width: 25pt)
#let edge(..args) = fletcher.edge(..args, bend: -50deg)
#figure(
  {
    v(1em)
    fletcher.diagram(
      label-size: 0.75em,
      node-fill: palette.bg.blue1,
      node-shape: circle,
      node-outset: 2pt,
      spacing: 2em,
      // nodes
      node((0, 0), $xx_0$, name: <x0>),
      node((1, 0), $dots$, fill: none, name: <x1>),
      node((2, 0), $xx_(t-1)$, name: <xtm1>),
      node((3, 0), $xx_t$, name: <xt>),
      node((4, 0), $xx_(t+1)$, name: <xtp1>),
      node((5, 0), $dots$, fill: none, name: <xTm1>),
      node((6, 0), $xx_T$, name: <xT>),
      // edges
      edge(<x0>, <x1>, "-|>", [$q(xx_1|xx_0)$]),
      edge(<xtm1>, <xt>, "-|>", [$q(xx_t|xx_(t-1))$]),
      edge(<xt>, <xtp1>, "-|>", [$q(xx_(t+1)|xx_t)$]),
      edge(<xTm1>, <xT>, "-|>", [$q(xx_T|xx_(T-1))$]),
      edge(<xT>, <xTm1>, "-|>", [$p_theta (xx_(T-1)|xx_T)$]),
      edge(<xtp1>, <xt>, "-|>", [$p_theta (xx_t|xx_(t+1))$]),
      edge(<xt>, <xtm1>, "-|>", [$p_theta (xx_(t-1)|xx_t)$]),
      edge(<x1>, <x0>, "-|>", [$p_theta (xx_0|xx_1)$]),
    )
    v(1em)
  },
  caption: [Diffusion forward (_bottom_) and reverse (_top_) processes.],
)

== Forward Process

Given an empirical data distribution $p_"data" (xx)$, the forward process is a discrete-time Markov chain ${xx_0, xx_1, dots, xx_T}$
$
  xx_0 & ~ p_"data" (xx), \
  xx_t & = alpha_t xx_(t-1) + beta_t epsilon_t,
$
where $epsilon_t ~ cal(N)(ub(0), ub(I))$, $alpha_t = sqrt(1 - beta_t^2)$, and the sequence ${beta_t in (0, 1)}_(t=1)^T$ denotes a (usually monotically increasing) noise schedule.

We say ${xx_0, xx_1, dots, xx_T}$ is a Markov chain, as the distribution of $xx_t$ is fully determined by $xx_(t-1)$ such that
$ q(xx_t|xx_(t-1)) = cal(N)(alpha_t xx_(t-1), beta_t^2 ub(I)). $

*(Property #[#sym.section]1)* $space$
A particularly useful property of the forward process is that we can compute $q(xx_t|xx_0)$ analytically for $t=1,dots,T$
$
  q(xx_t|xx_0) = cal(N)(macron(alpha)_t xx_0, (1 - macron(alpha)_t^2) ub(I)), quad "where" macron(alpha)_t = product_(k=1)^t alpha_k.
$
#quote[
  - ($t=1$) $xx_1 = alpha_1 xx_0 + beta_1 epsilon_1$, that is
    $ q(xx_1|xx_0)=cal(N)(alpha_1 xx_0, (1 - alpha_1^2) ub(I)). $
  - ($t=2$) $xx_2 = alpha_2 xx_1 + beta_2 epsilon_2 = alpha_1 alpha_2 xx_0 + beta_1 alpha_2 epsilon_1 + beta_2 epsilon_2$, that is
    $ q(xx_2|xx_0) = cal(N)(alpha_1 alpha_2 xx_0, (1 - alpha_1^2 alpha_2^2) ub(I)). $
  #proof[
    Note that for $x_1 ~ cal(N)(mu_1,sigma_1^2)$ and $x_2 ~ cal(N)(mu_2, sigma_2^2)$, we have
    $ x_1 + x_2 ~ cal(N)(mu_1 + mu_2, sigma_1^2 + sigma_2^2). $
    Therefore, $beta_1 alpha_2 epsilon_1 + beta_2 epsilon_2$ is normally distributed with zero mean and variance
    $ beta_1^2 alpha_2^2 + beta_2^2 = (1-alpha_1^2)alpha_2^2 + (1-alpha_2^2) = 1-alpha_1^2alpha_2^2. $
  ]
  - ($t=dots.c$) Following recursive inductions, we can show generally
    $
      q(xx_t|xx_0) = cal(N)(macron(alpha)_t xx_0, (1 - macron(alpha)_t^2) ub(I)), quad "where" macron(alpha)_t = product_(k=1)^t alpha_k.
    $
]
Therefore, we can conveniently compute $xx_t$ without intermediate steps
$ xx_t = macron(alpha)_t xx_0 + sqrt(1-macron(alpha)_t^2) epsilon, quad epsilon ~ cal(N)(ub(0), ub(I)). $

Furthermore, note that since $beta_t in (0, 1)$, $macron(alpha)_t arrow 0$ as $t arrow infinity$. Therefore, $q(xx_t|xx_0)$ converges to the standard Gaussian $cal(N)(ub(0), ub(I))$ as $t arrow infinity$.

*(Property #[#sym.section]2)* $space$
Another useful property is that the forward process can be equivalently expressed as a _conditional_ reverse process.

Specifically, consider the forward process
$ q(xx_(1:T)|xx_0) = product_(t=1)^T q(xx_t|xx_(t-1)), $
where each forward transition $q(xx_t|xx_(t-1))$ follows that
$ q(xx_t|xx_(t-1)) = q(xx_t|xx_(t-1),x_0) = (q(xx_(t-1)|xx_t,xx_0) dot q(xx_t|xx_0)) / (q(xx_(t-1)|xx_0)). $
The first equality results from the Markov property, and the second equality follows the Bayes theorem. Consequently, we can rewrite the forward process as
$ q(xx_(1:T)|xx_0) = q(xx_T|xx_0) product_(t=2)^T q(xx_(t-1)|xx_t,xx_0), $
which describes a reverse process $xx_T arrow dots arrow xx_1$ conditioned on $xx_0$.
#proof[
  #let del(x) = $cancel(#x, inverted: #true)$
  Note how $q(xx_t|xx_0)$ terms naturally cancel out upon expansion:
  $
    q(xx_(1:T)|xx_0)
    = & q(xx_1|xx_0) q(xx_2|xx_1) dots q(xx_T|xx_(t-1)) \
    = & del(q(xx_1|xx_0)) space (q(xx_1|xx_2,xx_0) dot del(q(xx_2|xx_0))) / del(q(xx_1|xx_0)) space dots.c space (q(xx_(T-1)|xx_T,xx_0) dot q(xx_T|xx_0)) / del(q(xx_(T-1)|xx_0)) \
    = & q(xx_1|xx_2,xx_0) space dots space q(xx_(T-1)|xx_T,xx_0) q(xx_T|xx_0).
  $
]

== Reverse Process

We have shown that the forward process is equivalently a conditional reverse process given $xx_0 ~ p_"data" (xx)$. For generative modeling, however, we are more interested in the _unconditional_ reverse process.

Formally, the reverse process is a parametrized probabilistic model
$ p_theta (xx_(0:T)) = p(xx_T) product_(t=1)^T p_theta (xx_(t-1)|xx_t), $
where $p(xx_T) = cal(N)(ub(0), ub(I))$ is the prior noise distribution #footnote[Recall that for suffciently large $T$, $q(xx_T|xx_0)$ also converges to $cal(N)(ub(0), ub(I))$.].

Starting from a random noise $xx_T ~ p(xx_T)$, the reverse process leverages the learned reverse transition $p_theta (xx_(t-1)|xx_t)$ to iteratively denoise $xx_t arrow xx_(t-1)$ until we have reached a _clean_ sample $xx_0$.

To learn the reverse process, we find parameters $theta^*$ that maximizes the model log likelihood w.r.t. the empirical data $p_"data" (xx)$:
$
  theta^* & = limits(arg min)_theta space DD_"KL" (p_"data" (xx) || p_theta (xx_0)) \
          & = limits(arg max)_theta space EE_(xx_0 ~ p_"data" (xx)) [log p_theta (xx_0)],
$
where $p_theta (xx_0) = integral p_theta (xx_(0:T)) dif x_(1:T)$.

#quote[
  There exists an analytical optimal solution to the reverse process
  $ p_(theta^*) (xx_(t-1)|xx_t) & = EE_(xx_0~p_"data" (xx)) [q(xx_(t-1)|xx_t,xx_0)]. $
  This solution is, however, not interesting in practice, as it can only generate samples that are already in the dataset, i.e. it memorizes but not generalizes.
]

Integrating over $x_(1:T)$ is generally intractable. We instead  consider the #highlight[_evidence lower bound_] (ELBO) of the log-likelihood $log p_theta (xx_0)$
$
  "ELBO"(q) = & EE_q [log p_theta (x_(0:T)) - log q(xx_(1:T)|xx_0)] \
            = & EE_q [log p_theta (xx_0|xx_1)] - \
              & EE_q [DD_"KL" (q(xx_T|xx_(T-1)) || p(xx_T)) ] - \
              & sum_(t=1)^(T-1) EE_q [DD_"KL" (q(xx_t|xx_(t-1)) || p_theta (xx_t|xx_(t+1)))].
$

However, the bound above is not quite appealing, as it involves computing $DD_"KL" (q(xx_t|xx_(t-1)) || p_theta (xx_t|xx_(t+1)))$ that relies on two r.v.s. $xx_(t-1)$ and $xx_(t+1)$, hence inducing _high variance_ in gradients.

Fortunately, we can sidestep this issue by rewriting the forward process as an equivalent conditional reverse process, leading to:
$
  "ELBO"(q) = & EE_q [log p_theta (xx_0|xx_1)] - \
              & DD_"KL" (q(xx_T|xx_0) || p(xx_T)) ] - \
              & sum_(t=2)^T EE_q [DD_"KL" (q(xx_(t-1)|xx_t,xx_0) || p_theta (xx_(t-1)|xx_t))].
$

Now $DD_"KL" (q(xx_(t-1)|xx_t,xx_0) || p_theta (xx_(t-1)|xx_t))$ only relies on $xx_t$ (given $xx_0$).

#quote[
  By treating the forward process $q(xx_(1:T)|xx_0)$ as the encoder, and the backward process $p_theta (xx_(0:T-1)|xx_T)$ as the decoder, diffusion can be seen as a special case of hierarchical #wikilink("generative-model/vae", title: [Variational Auto-Encoders]).
]

Furthermore, note that $q(xx_(t-1)|xx_1,xx_0)$ is also a Gaussian distribution
$
  q(xx_(t-1)|xx_t,xx_0) = cal(N)(bold(mu)(xx_t, xx_0, t), sigma(t)^2 ub(I)).
$
#proof[
  We start with $p(z)=cal(N)(a,c^2)$, $p(x|z)=cal(N)(b z,d^2)$, and
  $
    p(z|x) prop p(x|z) p(z) & prop exp(-1/2 [((x-b z)^2) / d^2 + ((z-a)^2) / c^2]) \
                            & = exp(-1/2 [(b^2 / d^2 + 1 / c^2) z^2 - 2 ((b x) / d^2 + a / c^2) z + dots.c]).
  $
  Let $p(z|x)=cal(N)(mu,sigma^2)prop exp(-1/2 [z^2 / sigma^2 - (2 mu z) / sigma^2 + dots.c])$. We can solve for
  $
    1 / sigma^2 = b^2 / d^2 + 1 / c^2,
    quad "and" quad
    mu / sigma^2 = (b x) / d^2 + a / c^2.
  $
  Therefore, we have $p(z|x) = cal(N)(mu := (b c^2 x + a d^2) / (b^2 c^2 + d^2), sigma^2 := (c^2 d^2) / (b^2 c^2 + d^2))$.

  Similarly, we have
  $
    q(xx_(t-1)|xx_t,xx_0) & prop q(xx_t|xx_(t-1),xx_0) q(xx_(t-1)|xx_0) \
    & = cal(N)(alpha_t xx_(t-1), beta_t^2ub(I)) cal(N)(macron(alpha)_(t-1) xx_0, (1 - macron(alpha)_(t-1)^2)ub(I)).
  $
  Noting that $a=macron(alpha)_(t-1) xx_0, b=alpha_t, c^2=1-macron(alpha)_(t-1)^2, d^2=beta_t^2$, we can compute
  $
    & bold(mu)(xx_t,xx_0,t) & = & (alpha_t (1-macron(alpha)_(t-1)^2)) / (1-macron(alpha)_t^2) xx_t + (macron(alpha)_(t-1) (1-alpha_t^2)) / (1-macron(alpha)_t^2) xx_0, \
    & sigma(t)^2 & = & (1-macron(alpha)_(t-1)^2) / (1-macron(alpha)_t^2) beta_t^2.
  $
]

If we also parametrize the reverse transition $p_theta (xx_t|xx_(t+1))$ as a Gaussian
$ p_theta (xx_(t-1)|xx_t) = cal(N)(bold(mu)_theta (xx_t, t), sigma^2(t)ub(I)) $
with the same variance as that of $q(xx_(t-1)|xx_t,xx_0)$, we can show that
$
  DD_"KL" (q(xx_(t-1)|xx_t,xx_0) & || p_theta (xx_(t-1)|xx_t)) \
                               = & 1 / (2sigma^2(t)) ||bold(mu)(xx_t,xx_0,t) - bold(mu)_theta (xx_t, t)||_2^2 + C
$

#references()
