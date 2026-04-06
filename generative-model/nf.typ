#import "/preamble.typ": *

#show: template.with(
  title: [Normalizing Flow],
  created: datetime(year: 2026, month: 3, day: 24),
  updated: datetime(year: 2026, month: 4, day: 6),
)

*Normalizing flows* (NFs) are generative models that gradually transform noise into data using an _invertible_ mapping, following the _change-of-variables formula_ for probability densities.
#definition(title: [Change-of-Variables Formula])[
  For $x ~ p_x (x)$, given a smooth invertible mapping $f: RR^d arrow RR^d$ such that $y = f(x)$, the probability density $p_y (y)$ is
  $
    p_y (y)
    = p_x (x) dot lr(| det (partial f^(-1)) / (partial y) |)
    = p_x (x) dot lr(| det (partial f) / (partial x) |)^(-1),
  $
  where $f^(-1)$ denotes the inverse of $f$ such that $x = f^(-1)(y)$ #footnote[Note that $x = f^(-1)(f(x))$, and therefore $(partial f^(-1) \/ partial y) dot (partial f \/ partial x) = I$.].
]
#proof[
  Informally, using the change-of-variables rule in multivariate calculus, we can show that for any $Omega subset RR^d$
  $
    underbrace(integral_Omega p_y (y) dif y = integral_(f^(-1)(Omega)) p_x (x) dif x, "Pr"[y in f(Omega)] space = "Pr"[x in Omega]) = integral_Omega p_x (x) lr(|det (partial f^(-1)) / (partial y)|) dif y.
  $
]

== Invertible Transformation

A normalizing flow essentially builds an invertible mapping $f_theta: RR^d arrow RR^d$ parametrized by $theta$ by composing a sequence of $K$ simpler learnable invertible mappings ${f_k: RR^d arrow RR^d}_(k=0)^(K-1)$ such that
$ f_theta = f_(K-1) space circle.small space dots.c space f_1 space circle.small space f_0. $

Specifically, starting from some noise distribution $p_0(x_0)$ #footnote[Typically a standard Gaussian $p_0(x_0) = cal(N)(0, I)$.], we push a sampled noise $x_0 ~ p_0$ through the sequence of mappings
$ x_(k+1) = f_k (x_k), $
for $k = 0, dots, K-1$. Consequently, we have
$ x := x_K = (f_(K-1) space circle.small space dots.c space f_1 space circle.small space f_0) (x_0). $

The resulting probability density $p_theta (x)$ is given by the change-of-variables formula as follows:
$ p_theta (x) = p_0 (x_0) product_(k=0)^(K-1) lr(| det (partial f_k) / (partial x_k) |)^(-1), $
or equivalently the log-density is
$ log p_theta (x) = log p_0 (x_0) - sum_(k=0)^K log lr(| det (partial f_k) / (partial x_k) |), $
where $x_0 = (f_0^(-1) space circle.small space f_1^(-1) space dots.c space circle.small space f_(K-1)^(-1)) (x_K)$.

Learning normalizing flows essentially amouts to maximizing the log-likelihood of $p_theta (x)$ w.r.t. an empirical data distribution $p_"data" (x)$
$
  theta^* & = limits(arg max)_theta space EE_(x ~ p_"data" (x)) [log p_theta (x)] \
          & = limits(arg min)_theta space DD_"KL" (p_"data" (x) || p_theta (x))
$

== Examples

The major challenge of normalizing flows is to design learnable mappings $f_k$ that is _(a)_ suffciently expressive, _(b)_ invertible, and _(c)_ has efficiently computable Jacobians $partial f_k \/ partial x_k$.

#quote[
  For example, a linear mapping $f(x) = A x + b$ can easily satisfy _(b)_ and _(c)_, but is not suffciently expressive.
]

Often times, we parametrize such learnable mappings $f_k$ using purposefully designed neural networks that are non-linear (hence expressive), yet invertible and has easily computable Jacobians. Here we provide a list of (opinionated) pointers to such recent works:
- Planar and radial flows @rezende2015variational;
- Coupling flows @dinh2017density
- Residual flows @chen2019residual
- Block neural autoregressive flows @cao2020block

#references()
