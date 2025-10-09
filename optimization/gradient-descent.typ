#import "/preamble.typ": *

#show: template.with(
  title: [Gradient Descent],
  created: datetime(year: 2025, month: 10, day: 3),
  updated: datetime(year: 2025, month: 10, day: 8),
)

#let theta = $bold(theta)$

In machine learning, we are often tasked with updating the model parameters $theta in RR^d$ to minimize some objective function $J(theta): RR^d arrow.bar RR$.

Gradient descent tells us to update $theta$ in the direction of the negative gradient, that is
$ theta_(t+1) = theta_t - eta nabla J(theta_t), $
where $eta$ is commonly known as the _learning rate_.

== Lagrangian Method

Directly minimizing the black-box objective $J(theta)$ is intractable in general. We instead consider a linear approximation of $J(theta)$ around $theta_t$ using the first-order Taylor expansion:
$ J(theta) approx J(theta_t) + nabla J(theta_t)^top (theta - theta_t). $

We minimize the linear approximation of $J(theta)$ with a squared Euclidean distance penalty $||theta-theta_t||_2^2$:
$
  limits(arg min)_theta space
  J(theta_t) + nabla J(theta_t)^top (theta - theta_t) +
  (2eta)^(-1)||theta-theta_t||_2^2,
$
where the learning rate $eta$ controls the _inverse_ strength of the penalty. Intuitively, the penalty discourages large updates as the linear approximation might only hold in the vicinity of $theta_t$.

Setting the gradient of the optimization objective above to zero, we have
$
                          0 & = nabla J(theta_t) + eta^(-1)(theta^*-theta_t) \
  arrow.double.long theta^* & = theta_t - eta nabla J(theta_t).
$

== Riemannian Manifold

By far, we have assumed a Euclidean parameter space $Theta$ such that $forall theta, theta' in Theta$, the squared distance between two parameters $D(theta, theta')$ is
$ D(theta,theta') = ||theta-theta'||_2^2 = (theta-theta')^top (theta-theta'). $

However, in general the parameter space $Theta$ is not Euclidean. For example, one can parametrize the variance of a univariate Gaussian distribution by letting $theta=sigma^2$, $theta=sigma$, or $theta=log sigma$ (and more). Dependending the chosen parametrization, updating $theta$ by the same constant $c$
$ theta_(t+1) = theta_t - c $
will result in very different distributions.

More generally, one can consider the parameter space as a _Riemannian manifold_. The squared distance between two parameters $theta$ and $theta'$ on a Riemannian manifold #footnote[Strictly speaking, in the tangent space of the Riemannian manifold at $theta$.] is
$ D(theta,theta') = (theta-theta')^top G(theta) (theta-theta'), $
where the _Riemannian metric tensor_ $G(theta) in RR^(d times d)$ is a symmetric and positive definite matrix depending on $theta$. Note that the Euclidean space corresponds to a special case where $G(theta)=bold(I)$.

@amari1998natural[prose] showed that the steepest descent on a Riemannian manifold is given by
$ theta_(t+1) = theta_t - eta G^(-1)(theta_t)nabla J(theta_t). $
Particularly when $G(theta)$ is the Fisher information matrix (FIM), this is known as the #wikilink("/optimization/natural-gradient-descent.typ").

#references()
