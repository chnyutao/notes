#import "/preamble.typ": *

#show: template.with(
  title: [Generative Adversarial Networks],
  created: datetime(year: 2026, month: 5, day: 13),
  updated: datetime(year: 2026, month: 5, day: 13),
)

#let phi = $bold(phi.alt)$
#let theta = $bold(theta)$
#let xx = $bold(x)$
#let zz = $bold(z)$

*Generative adversarial networks* (GANs) @goodfellow2014genrative are generative models consisting of:
- A generator $G$ that approximates the data distribution, and
- A discriminator $D$ that learns to distinguish real / generated data.

== Noise Contrastive Estimation

Generative adversarial networks are closely related to noise contrastive estimation (NCE) @gutmann2010noise, a parameter estimation method for (unnormalized) probabilistic models.

Assume we have samples from an unknown data distribution $p_"data" (xx)$, which we want to approximate with a probabilistic model $p_theta (xx)$. Noise contrastive estimation learns $p_theta (xx)$ by comparison:
#quote[
  Given a noise distribution $q(xx)$ #footnote[It must hold that $q(xx)$ is non-zero everywhere $p_"data" (xx)$ is non-zero.] with known density, we can learn $p_theta (xx)$ by estimating the _density ratio_
  $ r(xx) = p_"data" (xx) \/ q(xx). $
  That is, if we know $r(xx)$ and $q(xx)$, we have $p_theta (xx) approx r(xx) q(xx)$.
]

Furthermore, estimating the density ratio $r(xx)$ can be casted as _binary classification_. Assuming we label data samples $xx ~ p_"data" (xx)$ with $y=1$ and noise $xx ~ q(xx)$ with $y=0$, we have
$
  p_"data" (xx) & = p(xx|y=1), quad quad q(xx) & = p(xx|y=0).
$
By the Bayes theorem, we have $p(y|xx) = p(xx|y) dot p(y) \/ p(xx)$. Therefore, the density ratio $r(xx)$ can be equivalently written as
$
  r(xx) = (p_theta (xx)) / q(xx)
  = p(xx|y=1) / p(xx|y=0)
  = (D^*(xx)) / (1-D^*(xx)) dot (1-pi) / pi,
$
where $D^*(xx):=p(y=1|xx)$ and $pi:=p(y=1)$ #footnote[We assume without loss of generality $pi=1/2$ hereafter.]. Note that $D^*(xx)$ is the optimal binary classifier for $p_"data" (xx)$ and $q(xx)$, and
$
  D^*(xx) = (p_"data" (xx)) / (p_"data" (xx) + q(xx))
  = 1 / (1 + exp(-log r(xx))).
$

Finally, we can find $D^*(xx)$ by maximizing the Bernoulli log-likelihood for some parametric classifier $D_theta (xx)$
$
  limits(arg max)_theta space EE_(p_"data" (xx)) [log D_theta (xx)] + EE_q(xx) [log (1-D_theta (xx))].
$
If we find $D_theta (xx) approx D^*(xx)$, we also find $r(xx)$ and $p_theta (xx) approx p_"data" (xx)$.

== Generative Adversarial Networks

NCE turns density estimation of $p_theta (xx)$ into binary classification $D_theta (xx)$. The noise distribution $q(xx)$ is often chosen to be simplistic and tractable (e.g. Gaussians). In constrast, _generative adversarial networks_ learn the noise distribution $q_phi (xx)$ jointly with the binary classifier $D_theta (xx)$:
$
  min_phi max_theta EE_(p_"data" (xx)) [log D_theta (xx)] + EE_(q_phi (xx)) [log (1-D_theta (xx))]
$
With the above minimax optimization framework, a unique equilibrium exists at $q_phi (xx) = p_"data" (xx)$ and $D_theta (xx) = 1/2$ for all $xx$.
#proof[
  Note that for any fixed $phi$, the optimal $theta$ corresponds to
  $
    D_theta (xx) = (p_"data" (xx)) / (p_"data" (xx) + q_phi (xx)).
  $
  Furthermore, for any optimal $theta$, the optimal $phi$ minimizes the following objective
  $
    && EE_(p_"data" (xx)) [log (p_"data" (xx)) / (p_"data" (xx) + q_phi (xx))] + EE_(q_phi (xx)) [log (q_phi (xx)) / (p_"data" (xx) + q_phi (xx))] & \
    = && DD_"KL" (p_"data" mid(||) (p_"data" + q_phi) / 2) + DD_"KL" (q_phi mid(||) (p_"data" + q_phi) / 2) - 2 log 2 & \
    = && 2 "JSD" (p_"data" (xx) || q_phi (xx)) - log 4 & ,
  $
  where $"JSD"(p || q)$ denotes the Jensen-Shannon divergence, minimized when $p = q$. Therefore, the optimal $phi$ for any optimal $theta$ is given by $p_"data" (xx) = q_phi (xx)$.
]

The noise distribution $q_phi (xx)$ is often parametrized as a neural network $G_phi (zz)$, where $zz ~ p(zz)$ and $p(zz)$ is a simple prior noise distribution.

#rule()

We refer the readers to @murphy2023probabilistic[prose] Section 26.2 for further analysis on connecting GAN, _proper scoring rule_, and statistical divergence.

#references()
