#import "/preamble.typ": *

#show: template.with(
  title: [Variational Auto-Encoder],
  created: datetime(year: 2026, month: 3, day: 23),
  updated: datetime(year: 2026, month: 4, day: 6),
)

#let II = $bold(upright(I))$
#let epsilon = $bold(epsilon)$
#let mu = $bold(mu)$
#let phi = $bold(phi.alt)$
#let sigma = $bold(sigma)$
#let theta = $bold(theta)$
#let xx = $bold(x)$
#let zz = $bold(z)$

Variational auto-encoders (VAE) @kingma2013auto are:
1. *generative models* that learn a parametrized distribution $p_theta (xx)$ to match the empirical data distribution $p_"data" (xx)$, and
2. *latent variable models* that explain observed data $xx ~ p_"data" (xx)$ via latent variables $zz ~ p(zz)$.

Specifically, variational auto-encoders define a distribution $p_theta (xx)$ over observed data $xx$ as
$ p_theta (xx) = integral p_theta (xx,zz) dif zz, $
where $p_theta (xx, zz)$ is the joint distribution over $xx$ and $zz$ given by
$ p_theta (xx,zz) = p_theta (xx|zz) dot p(zz). $

== Evidence Lower Bound

For generative modeling, our objective is to match the empirical data distribution by minimizing the KL divergence as follows:
$
  theta^* & = limits(arg min)_theta space DD_"KL" (p_"data" (xx) || p_theta (xx)) \
          & = limits(arg max)_theta space EE_(p_"data" (xx)) [log p_theta (xx)].
$
That is, we want to find parameters $theta^*$ that maximizes the _log-likelihood_ $log p_theta (xx)$ w.r.t. the empirical dataset $p_"data" (xx)$.

However, optimizing $log_theta p(xx)$ is often computationally intractable due to the integration over $zz$, especially when $zz$ is continuous:
$ log p_theta (xx) = log integral p_theta (xx|zz) p(zz) dif zz. $

Instead, a common strategy  is to optimize a lower bound of $log p_theta (xx)$, namely the #highlight[_evidence lower bound_] (ELBO):
$
  "ELBO"(q(zz)) & = log p_theta (xx) - DD_"KL" (q(zz) || p_theta (zz|xx)) \
                & = EE_(q(zz)) [log p_theta (xx,zz) - log q(zz)] \
                & = EE_(q(zz)) [log p_theta (xx|zz)] + DD_"KL" (q(zz) || p(zz)),
$
where $q(zz) in cal(Q)$ is a variational distribution from a variational family $cal(Q)$, and $"ELBO"(q(zz)) <= log p_theta (xx)$ with equality iff:
$ q(zz) = p_theta (zz|xx) prop p_theta (xx|zz) dot p(zz). $

Variational auto-encoders are typically parametrized using the encoder and decoder neural networks:
- *Encoder* $q_phi (zz|xx) = q(zz)$, also known as the _inference network_, maps observed data $xx$ to (a distribution over) latent variables $zz$.
- *Decoder* $p_theta (xx|zz)$, also known as the _generative network_, maps latent variables $zz$ back to (a distribution over) observed data $xx$.

In summary, we optimize the parameters ${phi, theta}$ of the variational auto-encoders by maximizing the the evidence lower bound as follows:
$
  phi^*, theta^* = limits(arg max)_(phi, theta) space EE_(q_phi (zz|xx)) [log p_theta (xx|zz)] + DD_"KL" (q_phi (zz|xx) || p(zz))
$

== Examples

=== Gaussian VAE

Gaussian VAEs assume that $p(zz), p_theta (xx|zz), q_phi (zz|xx)$ are all Gaussian:
- $p(zz) := cal(N)(bold(0), II)$ is a standard Gaussian prior;
- $p_theta (xx|zz) := cal(N)(mu_theta (zz), II)$ is the likelihood;
- $q_phi (zz|xx) := cal(N)(mu_phi (xx), "diag"(sigma_phi^2 (xx)))$ is the variational distribution..

Recall that our objective is to maximize
$
  "ELBO"(q_phi (zz|xx)) = underbrace(EE_(q_phi (zz|xx)) [log p_theta (xx|zz)], "reconstruction") + underbrace(DD_"KL" (q_phi (zz|xx) || p(zz)), "prior matching").
$
The _prior matching_ term is the KL divergence between two Gaussians, which can be computed analytically. However, the _reconstruction_ term requires approximating via Monte Carlo sampling
$ E_(q_phi (zz|xx)) [log p_theta (xx|zz)] approx 1/N sum_(n=1)^N log p_theta (xx|zz_n), $
where $zz_n ~ q_phi (zz|xx)$.

However, sampling $zz ~ q_phi (zz|xx)$ is a stochastic operation with no well-defined gradients, and therefore gradients can not be back-propagated to $phi$. We utilize the _reparametrization trick_ of diagonal Gaussians:
$ zz = mu_phi (xx) + sigma_phi (xx) dot epsilon, "where" epsilon ~ cal(N)(bold(0), II). $
This way, we can sample $zz ~ q_phi (zz|xx)$ and yet delegates the stochasticity to $epsilon ~ cal(N)(bold(0), II)$, so that $(dif zz) / (dif phi)$ is well-defined.

=== Hierarchical VAE

Hierarchical VAEs introduce a chain of Markovian latent variable $zz_(1:T) = {zz_1, dots, zz_T}$ such that
$ p_theta (xx,zz_(1:T)) = p_theta (xx|zz_1) product_(t=2)^T p_theta (zz_(t-1)|zz_t) p(zz_T), $
and an encoder $q_phi (zz_(1:T)|xx)$ with a mirroring Markovian structure
$ q_phi (zz_(1:T)|xx) = q_phi (zz_1|xx) product_(t=2)^T q_phi (zz_t|zz_(t-1)). $

#let note(xx) = text(fill: palette.fg.dim, size: 0.7em, weight: "medium", [(#xx)])
The evidence lower bound of a hierarchical VAE therefore is
$
  "ELBO"&(q_phi (zz_(1:T)|xx)) \
  & = EE_(q_phi) [log p_theta (xx,zz_(1:T)) - log q_phi (zz_(1:T)|xx)] \
  & = EE_(q_phi) [log (p_theta (xx|zz_1) product_(t=2)^T p_theta (zz_(t-1)|zz_t) p(zz_T)) / (q_phi (zz_1|xx) product_(t=2)^T q_phi (zz_t|zz_(t-1)))] \
  & = EE_(q_phi) [log p_theta (xx|zz_1)] - & #dim[(reconstruction)] \
  & quad EE_(q_phi) [DD_"KL" (q_phi (zz_1|xx) || p_theta (zz_1|zz_2))] - \
  & quad sum_(t=2)^(T-1) EE_(q_phi) [DD_"KL" (q_phi (zz_t|zz_(t-1)) || p_theta (zz_t|zz_(t+1)))] - & #dim[(consistency)] \
  & quad EE_(q_phi) [DD_"KL" (q_phi (zz_T|zz_(T-1)) || p(zz_T))]. & #dim[(prior matching)]
$

While this particular bound might appear intimidating, we shall later reveal surprising and yet elegant connections between hierarchical VAE and denoising diffusion probabilistic models (DDPM) @ho2020denoising.

#references()
