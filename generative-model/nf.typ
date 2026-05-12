#import "/preamble.typ": *

#show: template.with(
  title: [Normalizing Flow],
  created: datetime(year: 2026, month: 3, day: 24),
  updated: datetime(year: 2026, month: 4, day: 6),
)

#let II = $bold(upright(I))$
#let theta = $bold(theta)$
#let xx = $bold(x)$
#let yy = $bold(y)$

*Normalizing flows* (NFs) are generative models that transform noise into data using an _invertible_ mapping, built on the _change-of-variables formula_ for probability densities.
#definition(title: [Change-of-Variables Formula])[
  For $xx ~ p(xx)$, given a smooth invertible mapping $f: RR^d arrow RR^d$ such that $yy = f(xx)$, the probability density $q(yy)$ is
  $
    q(yy)
    = q(xx) dot lr(| det (partial f^(-1)) / (partial yy) |)
    = p(xx) dot lr(| det (partial f) / (partial xx) |)^(-1),
  $
  where $f^(-1)$ denotes the inverse of $f$ such that $xx = f^(-1)(yy)$ #footnote[Note that $xx = f^(-1)(f(xx))$, and therefore $(partial f^(-1) \/ partial yy) dot (partial f \/ partial xx) = I$.].
]
#proof[
  Informally, using the change-of-variables rule in multivariate calculus, we can show that for any $Omega subset RR^d$
  $
    underbrace(integral_(f(Omega)) q(yy) dif yy = integral_(Omega) p(xx) dif xx, "Pr"[yy in f(Omega)] space = "Pr"[xx in Omega]) = integral_(f(Omega)) p(xx) lr(|det (partial f^(-1)) / (partial yy)|) dif yy.
  $
]

== Invertible Transformation

A normalizing flow is essentially an invertible mapping $f_theta: RR^d arrow RR^d$ parametrized by $theta$, usually composed of a sequence of simple learnable invertible mappings ${f_k: RR^d arrow RR^d}_(k=1)^K$ such that
$ f_theta = f_K space circle.small space dots.c space f_2 space circle.small space f_1. $

Specifically, starting from some base noise distribution $p(xx_0)$ #footnote[Typically a standard Gaussian $p(xx_0) = cal(N)(bold(0), II)$.], we push a sampled noise $xx_0 ~ p$ through the sequence of mappings
$ xx_k = f_k (xx_(k-1)), $
for $k = 1, dots, K$. Consequently, we have
$ xx := xx_K = (f_K space circle.small space dots.c space f_2 space circle.small space f_1) (xx_0). $

The resulting probability density $p_theta (xx)$ can be derived from the change-of-variables formula as follows:
$ p_theta (xx) = p(xx_0) product_(k=0)^(K-1) lr(| det (partial f_k) / (partial xx_k) |)^(-1), $
or equivalently the log-density
$ log p_theta (xx) = log p(xx_0) - sum_(k=0)^K log lr(| det (partial f_k) / (partial xx_k) |), $
where $xx_0 = (f_1^(-1) space circle.small space f_2^(-1) space dots.c space circle.small space f_K^(-1)) (xx)$.

Learning normalizing flows essentially amouts to maximizing the log-likelihood of $p_theta (xx)$ w.r.t. an empirical data distribution $p_"data" (xx)$
$
  theta^* & = limits(arg max)_theta space EE_(xx ~ p_"data" (xx)) [log p_theta (xx)] \
          & = limits(arg min)_theta space DD_"KL" (p_"data" (xx) || p_theta (xx))
$

== Examples

The major challenge of normalizing flows is to design learnable mappings $f_k$ which are _(a)_ suffciently expressive, _(b)_ invertible, and _(c)_ has efficiently computable Jacobians $partial f_k \/ partial xx_k$.

#quote[
  For example, an affine transformation $f(xx) = bold(upright(A)) xx + bold(b)$ can easily satisfy _(b)_ and _(c)_, but is not suffciently expressive.
]

Often times, we parametrize such learnable mappings $f_k$ using neural networks that are expressive, invertible, and yet has easily computable Jacobians. Here we provide pointers to some such recent works:
- Planar and radial flows @rezende2015variational;
- Coupling flows @dinh2017density
- Residual flows @chen2019residual
- Block neural autoregressive flows @cao2020block

#references()
