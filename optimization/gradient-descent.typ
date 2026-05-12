#import "/preamble.typ": *

#show: template.with(
  title: [Gradient Descent],
  created: datetime(year: 2025, month: 10, day: 3),
  updated: datetime(year: 2026, month: 5, day: 12),
  outlined: false,
)

#let theta = $bold(theta)$

In machine learning, we are often tasked with updating the model parameters $theta in RR^d$ to minimize some objective function $J(theta): RR^d arrow RR$.

Gradient descent updates $theta$ in the direction of the negative gradient:
$ theta_(t+1) = theta_t - beta nabla J(theta_t), $
where $beta$ is commonly known as the _learning rate_.

== Derviations

Directly minimizing the objective $J(theta)$ is often difficult, especially when $J(theta)$ is highly non-convex. We instead consider a linear approximation of $J(theta)$ around $theta_t$ using the first-order Taylor expansion:
$ J(theta) approx J(theta_t) + nabla J(theta_t)^top (theta - theta_t). $

We minimize the linear approximation of $J(theta)$ with a squared Euclidean distance penalty $||theta-theta_t||_2^2$:
$
  limits(arg min)_theta space
  J(theta_t) + nabla J(theta_t)^top (theta - theta_t) +
  (2beta)^(-1)||theta-theta_t||_2^2,
$
where the learning rate $beta$ controls the _inverse_ strength of the penalty. Intuitively, the penalty discourages large updates as the linear approximation might only hold in the vicinity of $theta_t$.

Setting the gradient of the optimization objective above to zero, we have
$
  0 & = nabla J(theta_t) + beta^(-1)(theta^*-theta_t)
      quad arrow.double.long quad theta^* & = theta_t - beta nabla J(theta_t).
$

#rule()

By far, we have assumed a Euclidean parameter space $Theta$ such that the squared distance between two parameters $theta$ and $theta'$ is
$ d^2(theta, theta') = ||theta-theta'||_2^2 = (theta-theta')^top (theta-theta'). $

However, the parameter space $Theta$ is generally non-Euclidean.

#quote[Consider a Bernoulli distribution parametrized by $pi in [0, 1]$:
  - Updating $pi$ from 1% $arrow$ 2% _doubles_ the chance of a rare event,
  - Updating $pi$ from 50% $arrow$ 51% barely changes the distribution.
]

We can instead formalize the parameter space as a _Riemannian manifold_. The squared distance between $theta$ and $theta'$ on a Riemannian manifold #footnote[Strictly speaking, in the tangent space of the Riemannian manifold at $theta$.] is
$ d^2(theta, theta') = (theta-theta')^top G(theta) (theta-theta'), $
where the _Riemannian metric tensor_ $G(theta) in RR^(d times d)$ is a symmetric and positive definite matrix depending on $theta$. Note that the Euclidean space corresponds to a special case where $G(theta)=bold(upright(I))$.

@amari1998natural[prose] showed that the Riemannian steepest descent is given by
$ theta_(t+1) = theta_t - beta G^(-1)(theta_t)nabla J(theta_t). $
Particularly when $G(theta)$ is the Fisher information matrix (FIM), this is known as the #wikilink("/optimization/natural-gradient-descent.typ").

#references()
