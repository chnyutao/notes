#import "/preamble.typ": *

#show: template.with(
  title: [Variational Auto-Encoder],
  created: datetime(year: 2026, month: 3, day: 23),
  updated: datetime(year: 2026, month: 3, day: 23),
)

The variational auto-encoder (VAE) @kingma2013auto is:
1. a *generative model* that learns a parametrized distribution $p_theta (x)$ to match an empirical data distribution $p_"data" (x)$, and
2. a *latent variable model* that explains observed data $x ~ p_"data" (x)$ by introducing latent variables $z ~ p_"prior" (z)$.

Specifically, a variational auto-encoder defines a marginal distribution $p_theta (x)$ over observed data $x$ as
$ p_theta (x) = integral p_theta (x,z) dif z, $
where $p_theta (x, z)$ is the joint distribution over $x$ and $z$
$ p_theta (x,z) = p_theta (x|z) dot p_"prior" (z). $

== Evidence Lower Bound

For generative modeling, our objective is to match the empirical data distribution by minimizing the KL divergence from $p_"data" (x)$ to $p_theta (x)$
$
  theta^* & = limits(arg min)_theta space DD_"KL" (p_"data" (x) || p_theta (x)) \
          & = limits(arg max)_theta space EE_(p_"data" (x)) [log p_theta (x)].
$
That is, we want to find parameters $theta^*$ that maximizes the _log-likelihood_ $log p_theta (x)$ w.r.t. the empirical dataset $p_"data" (x)$.

However, optimizing $log_theta p(x)$ is often computationally intractable due to the integration over $z$, especially when $z$ is continuous:
$ log p_theta (x) = log integral p_theta (x|z) p_"prior" (z) dif z. $

Instead, a common alternative  is to optimize a lower bound of $log p_theta (x)$, namely the #highlight[_evidence lower bound_] (ELBO):
$
  "ELBO"(q(z)) & = log p_theta (x) - DD_"KL" (q(z) || p_theta (z|x)) \
               & = EE_(q(z)) [log p_theta (x,z) - log q(z)] \
               & = EE_(q(z)) [log p_theta (x|z)] + DD_"KL" (q(z) || p_"prior" (z)),
$
where $q(z) in cal(Q)$ is a variational distribution from a variational family $cal(Q)$, and $"ELBO"(q(z)) <= log p_theta (x)$ with equality iff $q(z)$ perfectly matches the posterior $p_theta (z|x)$:
$ q(z) = p_theta (z|x) prop p_theta (x|z) dot p_"prior" (z). $

Variational auto-encoders are typically parametrized using the encoder and decoder neural networks:
- *Encoder* $q_phi.alt (z|x) = q(z)$, also known as the _inference network_, maps observed data $x$ to (a distribution over) latent variables $z$.
- *Decoder* $p_theta (x|z)$, also known as the _generative network_, maps latent variables $z$ back to (a distribution over) observed data $x$.

In summary, we optimize parameters ${phi.alt, theta}$ of variational auto-encoders by maximizing the the evidence lower bound as follows:
$
  phi.alt^*, theta^* = limits(arg max)_(phi.alt, theta) space EE_(q_phi.alt (z|x)) [log p_theta (x|z)] + DD_"KL" (q_phi.alt (z|x) || p_"prior" (z))
$

== Examples

=== Gaussian VAE

Gaussian VAEs assume that $p_"prior" (z), p_theta (x|z), q_phi.alt (z|x)$ are all Gaussian:
- $p_"prior" (z)$ is typically a standard Gaussian prior $cal(N)(0, I)$;
- $p_theta (x|z)$ is the Gaussian likelihood $cal(N)(mu_theta (z), I)$ with unknown mean $mu_theta (z)$ conditioned on $z$ and known unit variance;
- $q_phi.alt (z|x)$ is the variational distribution $cal(N)(mu_phi.alt (x), "diag"(sigma_phi.alt^2 (x)))$ with unknown mean and _diagonal_ covariance conditioned on $x$.

Recall that our objective is to maximize
$
  "ELBO"(q_phi.alt (z|x)) = underbrace(EE_(q_phi.alt (z|x)) [log p_theta (x|z)], "reconstruction") + underbrace(DD_"KL" (q_phi.alt (z|x) || p_"prior" (z)), "prior matching").
$
- The prior matching term is the KL divergence between two Gaussians, and can be computed in closed form analytically.
- The reconstruction term is approximated with Monte Carlo sampling
  $ E_(q_phi.alt (z|x)) [log p_theta (x|z)] approx 1/N sum_(n=1)^N log p_theta (x|z_n), $
  where $z_n ~ q_phi.alt (z|x)$.

However, Monte Carlo sampling introduces a challenge where gradients of the reconstruction term can not be back-propagated to $phi.alt$ as sampling $z ~ q_phi.alt (z|x)$ is a stochastic operation with no well-defined derivatives. We resort to the _reparametrization trick_ for Gaussian distributions:
$ z = mu_phi.alt (x) + sigma^2_phi.alt (x) dot epsilon, "where" epsilon ~ N(0, I). $
This way, we can sample $z ~ cal(N)(mu_phi.alt (x), sigma^2_phi.alt (x))$ and yet delegates the stochasticity to $epsilon ~ cal(N)(0, I)$, so that $(dif z) / (dif phi.alt)$ is well-defined.

=== Hierarchical VAE

Hierarchical VAEs introduce a chain of Markovian latent variable $z_(1:T) = {z_1, dots, z_T}$ such that
$ p_theta (x,z_(1:T)) = p_theta (x|z_T) product_(t=1)^(T-1) p_theta (z_(t+1)|z_t) p(z_1), $
and an encoder $q_phi.alt (z_(1:T)|x)$ with the same Markovian hierarchy
$ q_phi.alt (z_(1:T)|x) = q_phi.alt (z_T|x) product_(t=1)^(T-1) q_phi.alt (z_t|z_(t+1)). $

#let note(x) = text(fill: palette.fg.dim, size: 0.7em, weight: "medium", [(#x)])
The evidence lower bound of a hierarchical VAE can then be written as
$
  & "ELBO"(q_phi.alt (z_(1:T)|x)) \
  = & EE_(q_phi.alt) [log p_theta (x,z_(1:T)) - log q_phi.alt (z_(1:T)|x)] \
  = & EE_(q_phi.alt) [log (p_theta (x|z_T) product_(t=1)^(T-1) p_theta (z_(t+1)|z_t) p(z_1)) / (q_phi.alt (z_T|x) product_(t=1)^(T-1) q_phi.alt (z_t|z_(t+1)))] \
  = & EE_(q_phi.alt) [log p_theta (x|z_T)] - & note("reconstruction") \
  & EE_(q_phi.alt) [DD_"KL" (q_phi.alt (z_T|x) || p_theta (z_T|z_(T-1)))] - \
  & sum_(t=2)^(T-1) EE_(q_phi.alt) [DD_"KL" (q_phi.alt (z_t|z_(t+1)) || p_theta (z_t|z_(t-1)))] - & note("consistency") \
  & EE_(q_phi.alt) [DD_"KL" (q_phi.alt (z_1|z_2) || p(z_1))]. & note("prior matching")
$

While this particular bound appears intimidating, we shall later reveal surprising and yet elegant connections between hierarchical VAE and denoising diffusion probabilistic models (DDPM) @ho2020denoising.

#references()
