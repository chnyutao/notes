#import "/preamble.typ": *

#show: template.with(
  title: [Normalizing Flow],
  created: datetime(year: 2026, month: 3, day: 24),
  updated: datetime(year: 2026, month: 3, day: 24),
)

Normalizing flows (NFs) are a class of generative models that gradually transform noise into data through an _invertible_ mapping, following the *change-of-variables formula* of probability densities.
#definition(title: [Change-of-Variables Formula])[
  For $x ~ p_x (x)$, given a smooth invertible mapping $f: RR^d arrow RR^d$ such that $y = f(x)$, the probability density $p_y (y)$ is
  $
    p_y (y)
    = p_x (x) dot lr(| (partial f^(-1)) / (partial y) |)
    = p_x (x) dot lr(| (partial f) / (partial x) |)^(-1),
  $
  where $f^(-1)$ denotes the inverse of $f$ such that $x = f^(-1)(y)$ #footnote[Note that $x = f^(-1)(f(x))$, and therefore $(partial f^(-1) \/ partial y) dot (partial f \/ partial x) = I$.].
]
#proof[
  Informally, using the change-of-variables rule in multivariate calculus, we can prove that for any $Omega subset RR^d$
  $
    integral_Omega p_y (y) dif y = integral_(f^(-1)(Omega)) p_x (x) dif x = integral_(f^(-1)(Omega)) p_x (x) lr(|(partial f^(-1)) / (partial y)|) dif y.
  $
]

== Invertible Transformation

The essence of normalizing flows is to build a parametrized invertible mapping $f_theta: RR^d arrow RR^d$ by composing a sequence of $K$ simpler learnable invertible mappings ${f_k}_(k=0)^(K-1)$ such that
$ f_theta = f_(K-1) space circle.small space dots.c space f_1 space circle.small space f_0. $

Specifically, starting from a prior noise distribution $p_0(x_0)$ #footnote[Typically, we use a standard Gaussian $p_0(x_0) = cal(N)(0, I)$ as the prior distribution.], we gradually tranform a sampled noise $x_0 ~ p_0$ such that
$ x_(k+1) = f_k (x_k), "where" k in {0, dots, K-1}, $
and consequently
$ x_K = f_(k-1) (x_(k-1)) = (f_(K-1) space circle.small space dots.c space f_1 space circle.small space f_0) (x_0). $

The probability density $p_K (x_K; theta)$ over $x_K$ is given by the change-of-variables formula as follows:
$ p_K (x_K; theta) = p_0 (x_0) product_(k=0)^(K-1) lr(| (partial f_k) / (partial x_k) |)^(-1), $
or equivalently the log-density is
$ log p_K (x_K; theta) = log p_0 (x_0) - sum_(k=0)^K log lr(| (partial f_k) / (partial x_k) |), $
where $x_0 = (f_0^(-1) space circle.small space f_1^(-1) space dots.c space circle.small space f_(K-1)^(-1)) (x_K)$.

Learning normalizing flows essentially amouts to maximizing the log-likelihood of $p_K (dot; theta)$ w.r.t. an empirical data distribution $p_"data" (x)$
$ theta^* = limits(arg max)_theta EE_(x ~ p_"data" (x)) [log p_K (x;theta)] $

== Examples

The major challenge of normalizing flows is to design learnable mappings $f_k$ that is _(a)_ suffciently expressive, _(b)_ invertible, and _(c)_ has efficiently computable Jacobians $partial f_k \/ partial x_k$.

#quote[
  As an example, a linear mapping $f(x) = A x + b$ easily satisfies _(b)_ and _(c)_, but is not suffciently expressive for modeling distributions over high-dimensional data.
]

Often times, we parametrize such learnable mappings $f_k$ using purposefully designed neural networks that are non-linear (expressive), yet invertible and has easily computable Jacobians. Here we provide a few (opinionated) pointers to recent works:
- Planar and radial flows @rezende2015variational;
- Coupling flows @dinh2017density
- Block neural autoregressive flows @cao2020block
- Transformer autoregressive flows @zhai2025normalizing

#references()
