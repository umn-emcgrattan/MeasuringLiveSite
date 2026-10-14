### A Pluto.jl notebook ###
# v1.0.3

using Markdown
using InteractiveUtils

# ╔═╡ 11111111-1111-4111-8111-111111111111
# Required packages
using DelimitedFiles, Measures, Plots, PlutoUI, HypertextLiteral

# ╔═╡ 7996ce3f-a2d1-4aed-9bad-fad683ae7c01
begin
  include("scripts/numerical_differentiation.jl")
  nothing
end


# ╔═╡ 66666666-6666-4666-8666-666666666666
TableOfContents()

# ╔═╡ 22222222-2222-4222-8222-222222222222
md"""
# Numerical Methods Appendix

In this appendix,  we review math and computational preliminaries
for the main lectures. The only Julia requirements are LinearAlgebra.jl
and Plots.jl.

"""


# ╔═╡ 42244444-4444-4444-8444-444444444444
md"""
## Numerical Differentiation

Suppose we have a function $f$ defined on interval $[a,b]$
with continuous first and second derivatives---so it is smooth---and 
we want to approximate $f'(x)$ at point $x_0$. 
We can approximate the function using a Taylor expansion
around $x_0$:

$$\begin{equation}
  f(x_0+\delta) = f(x_0) + \delta f'(x_0) +\frac{\delta^2}{2} f''(\zeta),
\end{equation}$$

and subtract $f(x_0)$ from both sides and divide by $\delta$ to get:

$$\begin{equation}
  f'(x_0) \approx \frac{f(x_0+\delta)- f(x_0)}{\delta}, \tag{forward difference}
\end{equation}$$

with the difference equal to a small number $\delta f''(\zeta)$
if $\delta$ is sufficiently small and the second derivative is
bounded.  The approximation in (forward derivative) is
the *forward difference*. We could approximate $f(x_0-\delta)$ around
$f(x_0)$ to derive the *backward difference* following the
same steps to get: 

$$\begin{equation}
  f'(x_0) \approx \frac{f(x_0-\delta)- f(x_0)}{\delta}. \tag{backward difference}
\end{equation}$$

For the *central difference*, we take the difference between the
Taylor expansion of $f(x_0+\delta)$ and the Taylor expansion of $f(x_0-\delta)$,
both around $x_0$:

$$\begin{equation}
  f'(x_0) \approx \frac{f(x_0+\delta)- f(x_0-\delta)}{2\delta}, \tag{central difference}
\end{equation}$$

with the error term depending on $\delta^2$ rather than $\delta$.
If we want an approximation to the second derivative $f''(x_0)$,
we add the forward and backward Taylor expansions and rearrange to get:

$$\begin{equation}
  f''(x_0) \approx \frac{f(x_0+\delta)-2f(x_0)+f(x_0-\delta)}{\delta^2}. \tag{second derivative}
\end{equation}$$


"""

# ╔═╡ 9bb36982-4d4f-4446-a7b7-8904e4daea7e
begin
    delta_selector = @bind forward_delta Slider(
        0.01:0.01:1.0;
        default = 0.5,
        show_value = true, 
    )
        
    @htl("""
    <div style="text-align:center; margin-bottom:.0em;">
        <div style="font-size:1.2em; font-weight:bold;">
            Forward-Difference Approximation
        </div>
        <div style="margin-top:0.5em;">
            Step size $\delta$: $(delta_selector)
        </div>
    </div>
    """)

end



# ╔═╡ 618d7424-efa6-4bbd-a18f-3ecf3320283a 
begin
  forward_difference_plot(delta=forward_delta,x0=1.0)
end 





# ╔═╡ 44444444-4444-4444-8444-444444444444
md"""
## Gaussian Quadrature

Suppose we want a good method to approximate the following integral:

$$\begin{equation}
   \int_a^b f(x)\, dx \approx \sum_{i=1}^n \omega_i f(x_i).\tag{integral}
\end{equation}$$

If we are allowed to choose weights $\omega_i$ and nodes
$x_i$, we could vary them in such a way
as to minimize the approximation error. In other words, we 
have $2n$ "parameters" to vary for the most accurate approximation
possible.  If we are integrating polynomials, this means
that we can potentially get an exact solution for a $2n-1$
degree polynomial (with at most $2n$ coefficents on 1, $x$,
$x^2$, $\ldots$, and $x^{2n-1}$)) using only $n$ nodes!

Let's try an example. Suppose $f(x)=1+2x+3x^2+4x^3$ with $a=-1$
and $b=1$. If we intergrate $f(x)$ on $[a,b]$---which can be broken
up into four integrals---we get $2+0+3\cdot 2/3+0=4$, with the two $0$'s appearing
because of symmetry when evaluating $\int x\,dx$ or $\int x^3\,dx$
at $-1$ and $1$.  Now, using the approximation in (integral), we can
state what we do more clearly: we solve a problem with four 
equations and four unknowns. The four unknowns are $\omega_1$, $\omega_2$, $x_1$, and
$x_2$ and the four equations are:

$$\begin{align}
    \int_{-1}^1 1\, dx & = 2 = \omega_1 +\omega_2 \\
    \int_{-1}^1 x\, dx & = 0 = \omega_1 x_1+\omega_2 x_2\\
    \int_{-1}^1 x^2\, dx & = 2/3 = \omega_1 x_1^2+\omega_2 x_2^2\\
    \int_{-1}^1 x^3\, dx & = 0 = \omega_1 x_1^3+\omega_2 x_2^3.
\end{align}$$

The solution to this system is pretty easy to find thanks to the symmetry: 
$\omega_1=\omega_2=1$ and $x_1=-x_2=-1/\sqrt{3}$.

The nice feature of this approximation is its generality. To see this,
note that we go through the same exact steps for \emph{any} cubic 
function $f(x)=a+bx+cx^2+dx^3$. No matter what values for the coefficients, 
we will find that:

$$\begin{equation}
   \int_{-1}^1 f(x)\, dx =  f(-1/\sqrt{3})+f(1/\sqrt{3}).
\end{equation}$$

The key insight here is that we use $2n$ conditions for any $n^{\text{th}}$
order polynomial:

$$\begin{equation}
   \int_{-1}^1 x^k\,dx = \sum_{i=1}^n \omega_i x_i^k, \quad k=0,\ldots, 2n-1.
\end{equation}$$

This will obviously become very messy to solve for large $n$, but there
is a simple way to use classes of polynomials to make the solution method recursive.
Let's take the example of the Legendre class of polynomial with 
$P_0(x)=1$, $P_1(x)=x$ and for $n>1$:

$$\begin{equation}
   (n+1)P_{n+1}(x) = (2n+1)xP_n(x) - nP_{n-1}(x).
\end{equation}$$

We now have enough to state the theorem. For any polynomial
$f$ of degree at most $2n-1$, the approximation in (integral) is exact
if $x_1,\ldots, x_n$ are the roots of the Legendre polynomial $P_n(x)$
and 

$$\begin{equation}
  \omega_i = \frac{2}{(1-x_i^2)[P'_n(x_i)]^2}.
\end{equation}$$

Suppose that we are integrating a function $f$ that is 
defined on $[a,b]$ and *not* necessarily a polynomial.
We can easily do a change of variables from $x$ on $[a,b]$
to $z$ on $[-1,1]$ by using the following linear relation:

$$\begin{equation}
   x = \frac{a+b}{2} + \frac{b-a}{2} z
\end{equation}$$

and $dx=(b-a)/2 dz$.  In this case, the approximation in (integral)
is replaced by 

$$\begin{equation}
   \int_a^b f(x)\, dx \approx \frac{b-a}{2} \sum_{i=1}^n \omega_i 
           f\left(\frac{a+b}{2}+\frac{b-a}{2}x_i\right),
\end{equation}$$

where $x_i$ and $\omega_i$ are the usual Gauss-Legendre nodes and 
weights. As long as $f$ is sufficiently smooth on $[-1,1]$---and therefore
has $2n$ derivatives that exist and are continuous on the interval---the
approximation method is valid even if $f$ is not a polynomial.
In this case, we use the same algorithm to find the $\omega_i$ weights
and $x_i$ nodes to evauate the integral but we have to keep in
mind that there is an approximation error that depends on $n$
and the derivative $f^{(2n)}$.



"""

# ╔═╡ 7e508426-a228-4962-8a2a-bf456c1c37c9
md"""
## Discretized Autoregressive Process


Suppose that we have an autoregressive process:

$$\begin{equation}
   y_{t+1} = \rho y_t + \epsilon_{t+1}, \quad  \epsilon_{t+1}\sim N(0,\sigma_\epsilon^2)
\end{equation}$$

and want to approximate it by an $n$-state Markov chain with 
discrete values $y_1,y_2,\ldots,y_n$ and an transition matrix $\Pi$
with element $\Pi_{ij}$ equal to the probability that the value is
$y_j$ tomorrow given it is $y_i$ today.

The first step is to choose points on the real line.  Let's do the
most simple thing and pick a range for the $y_i$ points (after cutting off left and
right tails of the normal distribution) and make them equally spaced.
As an example, we can pick the range to be $[-3\sigma_y,3\sigma_y]$, where
$\sigma_y=\sigma_\epsilon/\sqrt{1-\rho^2}$ is the standard deviation of
$y$, and we can place $n$ equally spaced points: $y_1=-3\sigma_y$, $\ldots$, 
$y_n=3\sigma_y$, and $\Delta=y_{i+1}-y_i$ constant.

The second step is to construct the elements $\Pi_{ij}$, which is possible
given we are working with normally distributed errors.  Start wih today's
value $y_i$.  The autoregressive process tells us that 
tomorrow's value is distributed as $N(\rho y_i,\sigma_\epsilon^2)$.
If we were to draw a normal density centered at $\rho y_i$ and divide
the real line into bins corresponding to the discrete states, we would
have intervals $[y_j-\Delta/2,y_t+\Delta/2]$ around tomorrow's state.
The $\Pi_{ij}$ we want to compute is the probability that we are
in the particular interval indexed by $j$:

$$\begin{equation}
   \Pi_{ij} = \Phi\left(\frac{y_j+\Delta/2 - \rho y_i}{\sigma_\epsilon}\right)
              -\Phi\left(\frac{y_j-\Delta/2 - \rho y_i}{\sigma_\epsilon}\right)
\end{equation}$$

where $\Phi(x) = prob(z\leq x)$ for $z\sim N(0,1)$ is the standard
normal cumulative distribution function (CDF). The CDF for standard
normal is known analytically and given by $\Phi(x) =1/\sqrt{2\pi} \int_{-\inf}^x \exp{-u^2/2}du$.
For the two endpoints, we can assume the bins extend forever:

$$\begin{align}
   \Pi_{i1} &= \Phi\left(\frac{y_1+\Delta/2 - \rho y_i}{\sigma_\epsilon}\right)\\
   \Pi_{in} &= 1-\Phi\left(\frac{y_n-\Delta/2 - \rho y_i}{\sigma_\epsilon}\right),
\end{align}$$

which ensures that $\sum_j \Pi_{ij}=1$.

Let's construct a 3$\times 3$ example to illustrate the method with
$y_1=-a$, $y_2=0$, and $y_3=a$, where $\rho$, $\sigma_\epsilon$, and $a$
are user-defined.  In this case, $y_{t+1}<-a/2$ is mapped
to discrete state $y_1$, $y_{t+1}\in [-a/2,a/2]$ is mapped to 
discrete state $y_2$ and $y_{t+1}>a/2$ is mapped to discrete state $y_3$.
To construct $P$, we work row by row. Start with the discrete state today
at $-a$. Tomorrow's value is distributed $N(-\rho a,\sigma_\epsilon^2)$
and therefore:

$$\begin{align}
   \Pi_{11} &= \Phi\left(\frac{-a/2 + \rho a}{\sigma_\epsilon}\right)\\
   \Pi_{12} &= \Phi\left(\frac{a/2 + \rho a}{\sigma_\epsilon}\right)
               -\Phi\left(\frac{-a/2 + \rho a}{\sigma_\epsilon}\right)\\
   \Pi_{13} &= 1-\Phi\left(\frac{a/2 + \rho a}{\sigma_\epsilon}\right),
\end{align}$$

Next, we construct the row associated with discrete state $y_i=0$. Using
the formulas above, we get

$$\begin{align}
   \Pi_{21} &= \Phi\left(\frac{-a}{2\sigma_\epsilon}\right)\\
   \Pi_{22} &= \Phi\left(\frac{a }{2\sigma_\epsilon}\right)
               -\Phi\left(\frac{-a}{2\sigma_\epsilon}\right)\\
   \Pi_{23} &= 1-\Phi\left(\frac{a}{2\sigma_\epsilon}\right).
\end{align}$$

Because of symmetry, we have $P_{31}=P_{13},$ $P_{32}=P_{23},$ and $P_{33}=P_{11}$.

"""


# ╔═╡ a61ff7cf-49f0-4a45-88a4-9f4cab7da31d
md"""
## Bisection Method

The bisection method is a very robust method to solve a
fixed point problem $f(x)=0$  in 
cases where $x$ and $f(x)$ are scalars and $f$ is continuous
on the interval $[a,b]$.  If $f(a)$ and $f(b)$ have opposite
signs and $f$ is continuous, then there must be at least
one fixed point. Let $c=(a+b)/2$ be the midpoint of the interval.
If $f(a)$ and $f(c)$ are of opposite signs, then we know
that the new smaller interval $[a,c]$ must contain a fixed
point of $f$---and we continue bisecting.  If $f(a)$ and $f(c)
are the same signs, then we know to continue our search 
in $[c,b]$ and continue bisecting there. We repeat 
this until the value of $f$ is within a pre-specified
distance of 0 or the interval length is below a pre-specified
threshhold.

Let's consider a simple quadratic example with
$f(x)=x^2-x-2$, $a=1$, and $b=5$. This function
is continuous on $[a,b]$ with $f(1)=-2<0$,
$f(5)=18>0$ and therefore $f(a)f(b)<0$. If
we bisect this interval at $x=3$, we find
that $f(4)=4>0$.  The new interval is thus $[1,3]$.
The next bisection step is $x=2$ and $f(2)=0$. 
Since this is the crossing point, we can stop.

"""


# ╔═╡ b61ff7cf-49f0-4a45-88a4-9f4cab7da31d
md"""
## Newton-Raphson Method

Another popular method to find the fixed point of
$f(x)=0$ is the Newton-Raphson method.
This method can be applied to the scalar problem
or to systems of equations where $x$ and $f$ are
vectors of length $n$. As with the bisection method,
we require continuity, that is, we require
derivatives $\partial f_i(x)/\partial x_j$
for all $i,j=1,\ldots, n$ that exist and are 
continuous.  

The idea of the method is obvious if you
take a first-order Taylor expansion of $f$ around an
initial guess for the solution, say $x_0$

$$\begin{equation}
   f(x) \approx f(x_0)+Df(x_0)(x-x_0) \tag{taylor}
\end{equation}$$

where the $(i,j)$ element of  $Df(x)$ 
is $\partial f_i(x)/partial x_j$. If $x_0$ is
a good guess then we can use the linear approximation of $f$ 
on the right hand side of (taylor) to find the fixed point rather
than working directly with $f$. In other words,
find $x$ that sets the linear approximation to 0:

$$\begin{equation}
   x = x_0- [Df(x_0)]^{-1}f(x_0).
\end{equation}$$

Given we know $x_0$, we can easily evaluate this,
and we   have a new and better guess.
More generally, we can continue to update the
guess by iterating on $k$ in the following 
recursion:

$$\begin{equation}
   x_{k+1} = x_k- [Df(x_k)]^{-1}f(x_k)
\end{equation}$$

until the norm $||x_{k+1}-x_k||$ is below
a pre-specified threshhold.

Let's try this with the quadratic example $f(x)=x^2-x-2$
studied above. If we start with $x_0=3$ the next guess
is $x_1=3-f(3)/f'(3)$ or  2.2. If we keep going,
we have $x_2=2.0112$, $x_3=2.000046$, $x_4=2.0000000007$.


"""



# ╔═╡ 33333333-3333-5333-8333-333333333333
md"""
## Dynamic Programming 

Most problems in quantitative macroeconomics have a dynamic
optimization problem that can be formulated recursively.
Suppose the state of the economy is summarized by 
the vector $x_0$ and the value to be optimized is 
defined over that state vector: $V(x_0)$. We will be
interested in cases
in which there is a return of $r(x_t,u_t)$ for taking
actions $u_t$ in period $t$ to maximize the infinite
sum: 

$$\begin{equation}
  V(x_0) = \max_{\{u_t\}}  \ \sum_{t=0}^\infty \beta^t r(x_t,u_t)
\end{equation}$$

where the maximization is subject to $x_{t+1}=g(x_t,u_t)$ with
$x_0$ given.
By repeating this for $V(x_1)$, it is easy to show that the
problem can be written recursively as follows:

$$\begin{equation}
  V(x_0) = \max_{u_0} \{ r(x_0,u_0) + \beta V(x_1)\} \ \ subject to\ x_1=g(x_0,u_0) \tag{bellman}
\end{equation}$$

We refer to 
(bellman) as Bellman's equation in honor 
of mathematician  Richard Bellman.
More generally, we can write the problem starting from any
state $x$ as one of finding the policy rule
$u=h(x)$ that optimizes the value function:

$$\begin{equation}
  V(x) = \max_{u} \{ r(x,u) + \beta V(g(x,u))\}. \tag{functional}\\
\end{equation}$$

We need conditions on $r$, $g$, and the constraint set 
of possible choices $u$ to ensure an optimum
exists and is unique. For example, if $r$ is concave and bounded
and the constraint set generated by $g$ is convex and compact, then 
(functional) has a unique, strictly concave solution.
It can be found by iterating on the mapping: guess an initial 
function $V$ in the class of bounded and continuous functions
defined over the domain of $x$;
solve the maximization problem on the right-hand side of 
(functional); update the guess for $V$ after substituting in 
the optimal policy; and repeat until the
old and new values of $V$ are "close" by some metric.

When solving the right-hand side of (functional), we find
$u^*$ such that 

$$\begin{equation} 
 0 = \frac{\partial r(x,u^*)}{\partial u}  + 
        \beta \frac{\partial g(x,u^*)}{\partial u}  V'(g(x,u^*)).\tag{foc}
\end{equation}$$

If conditions are such that the value function $V(x)$ is
differentiable, then we can differentiate the Bellman equation
to find: 

$$\begin{align}
  V'(x) &=  \frac{\partial r(x,u^*)}{\partial x}  + 
        \beta \frac{\partial g(x,u^*)}{\partial x}  V'(g(x,u^*))
        +\left[ \frac{\partial r(x,u^*)}{\partial u}  + 
          \beta \frac{\partial g(x,u^*)}{\partial u}  V'(g(x,u^*))\right]
          \frac{\partial u^*}{\partial x}\\
        &=  \frac{\partial r(x,u^*)}{\partial x}  + 
        \beta \frac{\partial g(x,u^*)}{\partial x}  V'(g(x,u^*)),\tag{vprime}
\end{align}$$

where we have used the first-order condition to simplify
the result.${}^{\text{FN}}$ (See Benveniste and Scheinman
for the proof of differentiability.)

Consider the following simple example with the state being
capital at time $t$, $k_t$, and the decision being capital
next period at time $t+1$, $k_{t+1}$. Suppose preferences are logarithmic,
production is Cobb-Douglas, and the capital stock depreciates
fully each period. Then, $x_t=k_t$, $u_t=k_{t+1}$, $r(k_t,k_{t+1})=$
$\log(A k_t^\theta-k_{t+1})$ and $g(k_t,k_{t+1})=k_{t+1}$. Here, $A$
and $\theta$ are known parameters.
The Bellman equation in this case is given by

$$\begin{equation}
  V(k) = \max_{k'} \{ \log(Ak^\theta-k')  + \beta V(k') \}. \tag{example}\\
\end{equation}$$

To see what happens when we guess an initial function for
$V$ and iterate, consider the simplest guess: $V(k')=0$ for all
values of $k'>0$. In the first iteration, we know that the optimum
is $k'=0$ for all $k$ because the our initial guess for $V$ 
says that the future brings no value to investment.  The
implication of this is that $V(k) = \log A+ \theta\log k$.
Plug this into the right-hand side of (example) and the
next iteration solve:

$$\begin{equation}
   \max_{k'} \{ \log(Ak^\theta-k')  + \beta(\log A + \theta\log k') \}. \tag{example}\\
\end{equation}$$

It is easy to show that the optimum is $k'=\beta\theta/(1+\beta\theta) Ak^\theta$.
If we substitute this in and derive the new guess for $V(k)$, we notice
a pattern that the value and next capital at iteration $j$---which we can denote by $V_j(k)$ and
\log k_j'(k)$, respectively---are both linear in $\log k$: 

$$\begin{align}
   V_j(k)& =a_j+b_j\log k \\
   \log k_j'(k) &= \log(\gamma_{j-1}A) +\theta \log k
\end{align}$$

with $\gamma_{j-1}=\beta b_{j-1}/(1+\beta b_{j-1})$
and $a_j$, $b_j$ found recursively as follows:

$$\begin{align}
  b_j & =\theta (1+\beta b_{j-1})\\
  a_j & = log((1-\gamma_{j-1}A)+\beta a_{j-1}+\beta b_{j-1} \log(\gamma_{j-1}A)
\end{align}

As $j\rightarrow \infty$, we find

$$\begin{align}
   \log k' & = \theta\log(\beta\theta A) \log k\\
   V(k)    & =\frac{1}{1-\beta}\left[\log (A(1-\beta\theta))+
    \frac{\beta\theta}{1-\beta\theta}\log(A\beta\theta)\right]\log k.
\end{align}$$

This essentially tells us that the optimal rule is
to consume and save constant fractions of output.

What if $A$ is stochastic? 
In this case, we need to modify the
dynamic programming problem because the value is now the 
expected present value of returns:

$$\begin{align}
  V(x_0) &= \max_{\{u_t\}}  E\left[\sum_{t=0}^\infty \beta^t r(x_t,u_t) | x_0]
         & \text{subject\ to\ } x_{t+1} = g(x_t,u_t,\epsilon_{t+1}),
\end{equation}$$

where $\epsilon_t$ is a sequence of iid random variables with cumulative
distribution function $F(\epsilon)$.
In this case we write the Bellman equation as 

$$\begin{align}
  V(x) &= \max_{u} \{ r(x,u) + \beta E[V(g(x,u,\epsilon))|x] \} \\
       &= \max_{u} \{ r(x,u) + \beta \int V(g(x,u,\epsilon))dF(\epsilon) \}.
\end{align}$$

Suppose $\log A'=\rho\log A + \epsilon'$ in the consumption-savings
problem above. For this specification, we have the
state vector $x=[k,A]$ (or possibly $x=[\log k,\log A]$ if
we work with logged variables). The continuation value
is now $E[V(k',A')|A]$. It turns out that the optimal
solution in this case is as before: save and consume constant
fractions of output and therefore $k'=\beta\theta A k^\theta$,
except that now $A$ fluctuates over time. 

"""


# ╔═╡ c61ff7cf-49f0-4a45-88a4-9f4cab7da31d
md"""
## Linear-Quadratic Dynamic Optimization

Consider the following maximization problem with quadratic
objective and linear constraints:

$$\begin{align}
    \max_{\{u_t\}_{t=0}^{\infty}}{\rm E}_0 &\sum_{t=0}^{\infty} 
           \beta^t (X_t'Q X_t+u_t'R u_t +2 X_t' W u_t)\\
   {\rm subject\ to\ \ \ } & X_{t+1}=A X_t+B u_t+C\epsilon_{t+1}\\
                           & X_0\ {\rm given}\tag{LQ control problem}
\end{align}$$

where $Q$ and $R$ symmetric.
We need to put some conditions on the matrices $Q$, $R$, $W$,
$A$, $B$, $C$ to
ensure that the optimal solution to our problem yields a
stable system (and that we are maximizing, not minimizing).
The relevant conditions are usually stated in terms of a problem
with $\beta=1$ and $W=0$.  We can reformulate the problem
in (LQ control problem)
so that there is no discounting or cross-products as follows.
Let


$$\begin{align}
{\tilde X}_t &=\beta^{t\over 2} X_t\\
{\tilde u}_t &=\beta^{t\over 2} (u_t+R^{-1}W'X_t)\\
{\tilde A}   &= \sqrt{\beta}(A-BR^{-1}W')\\
{\tilde B}   &=\sqrt{\beta}B\\
{\tilde Q}   &=Q-WR^{-1}W'.
\end{align}$$

Assume that $\tilde Q$ and $R$ are negative definite matrices
(which is an assumption that can be weakened)
and assume that there exists a matrix
$\tilde F$ such that $\tilde A-\tilde B \tilde F$ has eigenvalues
inside the unit circle.  In this case, the system is stable
and, in the language of control theorists,
 ($\tilde A,\tilde B$) is stabilizable.  The matrix $\tilde F$ that is
relevant for us is the matrix governing the optimal
solution, namely, $\tilde u_t = -\tilde F \tilde X_t$.

If the conditions above are satisfied, then the optimal policy function
for the original optimization problem is the time-invariant linear
rule:

$$\begin{align}
     u_t=-F X_t,\qquad F&=(R+\beta B' P B)^{-1} (\beta B' P A+W')\\
                        &=(R+{\tilde B}' P{\tilde B})^{-1}{\tilde B}' 
                                          P{\tilde A}+R^{-1}W'\\
                        & \tilde F + R^{-1}W'.\tag{7}\label{solution}
\end{align}$$

The matrix $P$ in \ref{solution} is the steady-state solution 
to the matrix Riccati difference equation 

$$\begin{align}
   P_t&=Q+\beta A' P_{t+1} A -(\beta A' P_{t+1} B + W)
          (R+\beta B' P_{t+1} B)^{-1} (\beta B' P_{t+1} A+W')\\
      &={\tilde Q}+{\tilde A}' P_{t+1} {\tilde A} -{\tilde A}' P_{t+1} 
                   {\tilde B} (R+{\tilde B}' P_{t+1} {\tilde B})^{-1}
                     {\tilde B}' P_{t+1} {\tilde A}\tag{8}\label{riccati}
\end{align}$$

as $t\rightarrow -\infty$, with terminal condition $P_T\leq 0$.

There have been many algorithms developed for the solution of the 
discrete-time Riccati equation. 
In all cases, we take 
as given the matrices $A$, $B$, $Q$, $R$, $W$ and scalar $\beta$
(or equivalently ${\tilde A}$, ${\tilde B}$, ${\tilde Q}$, and $R$),
tolerance criteria $\gamma_1$ and $\gamma_2$, and 
a matrix norm $\Vert\cdot\Vert$.
The simplest method is simply direct iteration.
To do this, set an initial symmetric 
Riccati matrix, $P^0\leq 0$.  Then the steps are as follows:


1.  At iteration $n$, we compute $P^{n+1}$ and ${\tilde F}^n$ to be

$$\begin{align}
P^{n+1}&={\tilde Q}+ {\tilde A}' P^n {\tilde A}-{\tilde A}'P^n {\tilde B} 
(R+{\tilde B}'P^n {\tilde B})^{-1} {\tilde B}'P^n {\tilde A}\\
{\tilde F}^n &= (R+{\tilde B}' P^n {\tilde B})^{-1} {\tilde B}' P^n {\tilde A}
\end{align}$$

2. If $\Vert P^{n+1} -P^n\Vert< \gamma_1 \Vert P^n\Vert$ and
$\Vert {\tilde F}^{n+1} -{\tilde F}^n\Vert< \gamma_2 \Vert 
{\tilde F}^n\Vert$, go to (c);
otherwise, increase $n$ by one and return to (a).

3. Set $F={\tilde F}^n+R^{-1}W'$, $P=P^n$.

With a steady-state solution to the Riccati matrix, we can use \ref{solution}
to compute $F$ and the law of motion for the state variables:

$$\begin{equation}
   X_{t+1}=(A-BF) X_t + C\epsilon_{t+1}\tag{9}\label{law of motion}
\end{equation}$$

Furthermore, given an initial condition for the states, $X_0$, and a 
realization of the shocks, $\epsilon_t,\ t\geq0$, we can generate time-series
for $X_t$ via \ref{law of motion} 
and $u_t$ via \ref{solution}. 

An alternative way to solve (LQ control problem) relies on the insights
of Vaughan (1970).  Vaughan assumes no
discounting or cross-product terms, so we will continue working with 
the variables
and coefficients to $\tilde X$, $\tilde u$, $\tilde A$, $\tilde B$, and
$\tilde Q$. Also note that because the decision function for
$u$ does not depend on the variances and covariances of $\epsilon$,
we can abstract from the uncertainty for now.

The first step to applying Vaughan's (1970) method is to derive
first-order conditions.  Writing out the Lagrangian, we have

$$\begin{equation}
{\cal L}=\sum_{t=0}^{\infty}\{ \tilde X_t' \tilde Q \tilde X_t+
\tilde u_t' R \tilde u_t
-\lambda_{t+1}'(\tilde X_{t+1}-\tilde A \tilde X_t-\tilde B \tilde u_t)\}\tag{10}\label{lagrangian2}
\end{equation}$$

Taking derivatives with respect to $\tilde u_t$, $\tilde X_{t+1}$,
and $\lambda_{t+1}$,
we obtain the following first-order conditions

$$\begin{align}
    2 R\tilde u_t +\tilde B' \lambda_{t+1}  &=0\\
    \tilde Q \tilde X_{t+1} -\lambda_{t+1} +  \tilde A'\lambda_{t+2} &=0\\
    \tilde X_{t+1} - \tilde A \tilde X_t - \tilde B\tilde u_t &=0\tag{11}\label{focs2}
\end{align}$$

for $t\geq 0$, where $\{\lambda_t\}$ is a sequence of Lagrange multipliers.
Dividing the first two equations by 2 and defining $\tilde \lambda_t=\lambda_t/2$,
we can substitute out $\tilde u_t$ and rearrange terms:

$$\begin{equation}
\begin{bmatrix}
    \tilde X_t  \\ 
    \tilde \lambda_t 
\end{bmatrix}
 = 
\begin{bmatrix}
    \tilde A^{-1} &  \tilde A^{-1} \tilde B R^{-1} \tilde B'\\
    \tilde Q \tilde A^{-1}  & \tilde Q \tilde A^{-1} \tilde B R^{-1} \tilde B' + \tilde A'
\end{bmatrix}
\begin{bmatrix}
    \tilde X_{t+1}  \\ 
    \tilde \lambda_{t+1}
\end{bmatrix}.
\end{equation}$$

Let ${\cal H}$ be the coefficient matrix on the right hand side.
Vaughan showed that this matrix can be decomposed and used
directly to obtain the Riccati matrix $P$ (and hence the solution
to the LQ problem); that is, he showed that

$$\begin{equation}
{\cal H} = 
\begin{bmatrix}
    V_{11} & V_{12}\\ 
    V_{21} & V_{22}
\end{bmatrix}
\begin{bmatrix}
    \Lambda & 0\\ 
    0 & \Lambda^{-1}
\end{bmatrix}
\begin{bmatrix}
    V_{11} & V_{12}\\ 
    V_{21} & V_{22}
\end{bmatrix}^{-1},
\end{equation}$$

where the eigenvalues of $\Lambda$ are outside of the unit
circle.  Notice that the eigenvalues come in reciprocal pairs.
This is an important property that implies a unique
stable solution, one that satisfies the transversality
condition and ensures a bounded return.

Using the fact that the Lagrange multiplier is the derivative
of the value function ($\tilde \lambda_t = P \tilde X_t$), it
is easy to figure out how to set $P$ so as to get a stationary
dynamical system for $X$.  Let $W=V^{-1}$. In this case, it
is easy to show that:

$$\begin{equation}
   \tilde X_{t+1} = 
   \{ V_{11} \Lambda^{-1} (W_{11}+W_{12}P) + V_{12}\Lambda (W_{21}+W_{22}P)\}
      \tilde X_t.
\end{equation}$$

Since $\Lambda$ has roots outside the unit circle, it must be
the case that $P=-W_{22}^{-1} W_{21}$.  Note that since $W=V^{-1}$,
this is equivalent to setting $P=V_{21} V_{11}^{-1}$.

In the case that $\tilde A$ is not invertible, we can modify the method
slightly and use generalized eigenvalues with the following alternative
system:


$$\begin{equation}
\begin{bmatrix}
     \tilde A & 0 \\ 
     -\tilde Q & I
\end{bmatrix}
\begin{bmatrix}
    \tilde X_t  \\
   \tilde \lambda_t 
\end{bmatrix}
 = 
\begin{bmatrix}
    I &  \tilde B R^{-1} \tilde B'\\
    0  & \tilde A'
\end{bmatrix}
\begin{bmatrix}
    \tilde X_{t+1}  \\
    \tilde \lambda_{t+1}
\end{bmatrix}.
\end{equation}$$

Let ${\cal H}_1$ be the coefficient matrix for the state and 
costate in $t+1$, and let 
${\cal H}_2$ be the coefficient matrix for the state and 
costate in $t$. With these assignments, we compute generalized
eigenvalues from 

$$\begin{equation}
  {\cal H}_2 v = \mu {\cal H}_1 v.
\end{equation}$$

The stable roots satisfy $|\mu|<1$.

Once we have 
a steady-state solution to the Riccati matrix, we can use the earlier
formula to compute $F$ and the law of motion for the state variables:

$$\begin{equation}
   X_{t+1}=(A-BF) X_t + C\epsilon_{t+1}\tag{12}\label{law of motion}
\end{equation}$$

Furthermore, given an initial condition for the states, $X_0$, and a
realization of the shocks, $\epsilon_t,\ t\geq0$, we can generate time-series
for $X_t$ and $u_t$.

Let's consider an example.  REDO SIMPLEST GROWTH MODEL HERE.


"""


# ╔═╡ 3d63c66c-b5dd-11f1-b766-338e58c22c81
md"""
## The Kalman Filter

The Kalman filter is a recursive algorithm for estimating a latent
state vector at a particular point in time based on data that has been 
observed up to that point. An example that will be relevant
here is the state vector taken as given by
households or firms when solving their optimization problems, but 
unobserved by the economist. The filter is used when 
estimating parameters for a dynamic model.

When deriving the Kalman Filter, it helps to remember two useful
expressions. Suppose that $X$ and $Y$ are jointly normal random
variables with means $\bar X$ and $\bar Y$, respectively.
Let the variance-covariance matrix be denoted by $\Sigma$, where

$$\begin{equation}
\Sigma = \begin{bmatrix} \Sigma_{XX} & \Sigma_{XY} \\ \Sigma_{YX} & \Sigma_{YY} \end{bmatrix}.
\end{equation}$$

In this case,  the conditional expectation of $X$ given $Y$ is

$$\begin{equation}
  E [X|Y] = \bar X + \Sigma_{XY} \Sigma_{YY}^{-1} (Y-\bar Y) \tag{mean} 
\end{equation}$$

and the conditional variance is

$$\begin{equation}
  {\rm Var}[X|Y] = E[(X-E(X|Y))^2|Y] = \Sigma_{XX} - \Sigma_{XY}\Sigma_{YY}^{-1} \Sigma_{YX}.\tag{var}
\end{equation}$$

Below, we will use these formulas to construct means
and variances of a prediction of latent state variables.

Next, assume that we have a {\it state space system}
as follows:

$$\begin{align}
   x_t & = A x_{t-1} + \eta_t \tag{transition}\\
    y_t & = C x_t + \epsilon_t \tag{measurement}
\end{align}$$

where $x$ and $\eta$ are $n\times 1$ vectors, $A$ is $n\times n$,
$y$ and $\epsilon$ are $m\times 1$ vectors, $C$ is $m\times n$, 
$E\eta_t=0$, $E\eta_t\eta_t'=Q$, $E\epsilon_t=0$, 
$E\epsilon_t\epsilon_t'=R$, and $E\epsilon_t\eta_s=0$ for all $t$, and
$s$. The variables in $x_t$ are unobserved and need to be estimated
and the variables in $y_t$ are observed and will be used to construct
estimates.  Equation (transition) is the transition equation for the 
unobserved state vector and (measurement) is the measurement or
observer equation. 

The ultimate goal here is to estimate parameters of the 
model.  To do this, we will convert the system in (transition)-(measurement)
to:

$$\begin{align}
  \hat x_{t+1|t} &= A \hat x_{t|t-1} + K_t v_t \\
   y_t &= C \hat x_{t|t-1} + v_t
\end{align}$$

where $\hat x_{t|t-1}$ is an estimate of the unobserved state vector:

$$\begin{equation}
  \hat x_{t|t-1} = E[x_t| y_0,y_1,\ldots, y_{t-1}] 
\end{equation}$$

and $v_t$ is an {\it innovation}, which is the difference between the vector
of observables and a forecast of that vector. The matrix $K_t$ is the {\it Kalman gain},
which will be derived below.  To estimate parameters, we need a time
series for the innovations and an estimate of its variance-covariance matrix.
In other words, we want estimates of parameters that make these errors small.
Those estimates will be most ``likely'' to have generated the sequence of
$\{y_t\}$ that we observe.

To get the sequence of innovations, we compute a sequence of recursions.
Suppose at time $t$ that we have an estimate of 

$$\begin{equation}
\hat x_{t-1|t-1}= E[ x_{t-1}|y_0,y_1,...,y_{t-1}]
\end{equation}$$

and the estimation error for $x_{t-1}$ is  $\Sigma_{t-1}$:

$$\begin{equation}
  \Sigma_{t-1|t-1} = E [(x_{t-1}-\hat  x_{t-1|t-1})( x_{t-1}-\hat x_{t-1|t-1})'].
\end{equation}$$

Given $\hat x_{t-1|t-1}$ and $\Sigma_{t-1|t-1}$, we can estimate $ x_t$
using (transition):

$$\begin{equation}
  \hat x_{t|t-1} = A \hat  x_{t-1|t-1} \tag{update}
\end{equation}$$

which is a function of the lagged observations.
The variance of the prediction error is

$$\begin{align}
  \Sigma_{t|t-1} &= E [(x_t-\hat  x_{t|t-1})( x_t-\hat x_{t|t-1})']\nonumber \\
            &= E [(Ax_{t-1}+\eta_t-A\hat x_{t-1|t-1})(A x_{t-1}+\eta_t-A\hat x_{t-1|t-1})']\nonumber \\
            &= E [(A(x_{t-1}-\hat x_{t-1|t-1})+\eta_t)(A( x_{t-1}-\hat x_{t-1|t-1})+\eta_t)']\nonumber \\
            &= AE [(x_{t-1}-\hat x_{t-1|t-1})( x_{t-1}-\hat x_{t-1|t-1})']A'+E\eta_t\eta_t'\nonumber \\
            &= A\Sigma_{t-1|t-1}A'+Q, \tag{Sigma}
\end{align}$$

which follows from the fact that $\eta_t$ is not correlated with $x_{t-1}-\hat x_{t-1|t-1}$.

Next, consider updating these equations after observing $y_t$.  In other words,
we update the current expectation $E[x_t|y_0,y_1,...,y_{t-1}]$ to $E[ x_t|y_0,y_1,....,y_t]$.
The best estimate for $y_t$ given $x_{t|t-1}$ is

$$\begin{equation}
   \hat y_{t|t-1} = C \hat x_{t|t-1}
\end{equation}$$

with the estimation error being the innovation we seek:

$$\begin{equation}
    v_t = y_t -\hat y_{t|t-1} = C(x_t-\hat  x_{t|t-1}) + \epsilon_t.  \tag{innovation}
\end{equation}$$

The variance of this innovation is given by

$$\begin{align}
    \Omega_t & = E v_tv_t'\nonumber \\
        & = E [ (C(x_t-\hat x_{t|t-1})+\epsilon_t)(C( x_t-\hat x_{t|t-1})+\epsilon_t)']\nonumber \\
        & = C E [ (x_t-\hat x_{t|t-1})( x_t-\hat x_{t|t-1})']C' +E\epsilon_t\epsilon_t'\nonumber \\
        & = C \Sigma_{t|t-1} C' +R \tag{innovvar}
\end{align}$$

and the covariance of the state prediction error and $v_t$:

$$\begin{align}
   \Psi_t & = E [(x_t-\hat  x_{t|t-1})v_t']\\
       &  = E [(x_t-\hat x_{t|t-1})(C(x_t-\hat x_{t|t-1})+\epsilon_t)']\\
       &  = E[(x_t-\hat x_{t|t-1})( x_t-\hat x_{t|t-1})']C'\\
       &  = \Sigma_{t|t-1}C'.
\end{align}$$


We now have everything that we need to apply the formulas in (mean)
and (var).  Assume that $x$ is like $X$ and $y$ is like $Y$, then 
the conditional mean is

$$\begin{equation}
  \underbrace{\hat x_{t|t}}_{E [X|Y]}
  = 
  \underbrace{\hat x_{t|t-1}}_{EX} 
  +\underbrace{\Sigma_{t|t-1}C'}_{\Sigma_{XY}}
  (\underbrace{C \Sigma_{t|t-1}C'+R}_{\Sigma_{YY}=\Omega_t})^{-1}
  (y_t -\underbrace{C \hat x_{t|t-1}}_{EY}) \tag{mean2}
\end{equation}$$

and the conditional variance is

$$\begin{equation}
  \underbrace{\Sigma_{t|t}}_{{\rm Var}(X|Y)} 
  = \underbrace{\Sigma_{t|t-1}}_{\Sigma_{XX}}
  -\underbrace{\Sigma_{t|t-1}C'}_{\Sigma_{XY}}
  (\underbrace{C \Sigma_{t|t-1}C'+R}_{\Sigma_{YY}})^{-1}
  \underbrace{C \Sigma_{t|t-1}}_{\Sigma_{YX}}.  \tag{var2}
\end{equation}$$

The idea here is that the new information in 
$y_t$---the observed prediction error---is used
to update the estimate of $x_t$ from $\hat  x_{t|t-1}$
to $\hat x_t$.

Multiplying both sides of (mean2) by $A$, we get

$$\begin{align}
  \hat x_{t+1|t}
   &= A\hat x_{t|t-1} +A \Sigma_{t|t-1}C' (C \Sigma_{t|t-1}C'+R)^{-1} v_t\\
   &= A\hat x_{t|t-1} +K_t v_t
\end{align}$$

where $K_t$ can also be written more succinctly as

$$\begin{equation}
  K_t = A\Sigma_{t|t-1}C'\Omega_t^{-1}.
\end{equation}$$

The Kalman algorithm can now be implemented.  Starting with
guesses for $x_0$ and $\Sigma_0$, recursively update the estimates
of the mean and variance of the state using (update), (Sigma),
(mean2) and (var2) (in that order).  Along the way,
store $v_t$ and $\Omega_t$ using  (innovation) and (innovvar).
To compute parameters, we need to maximize the log-likelihood function:

$$\begin{equation}
  \ln L= \sum_t \{ -{m\over 2} \ln 2\pi-{1\over 2} \ln |\Omega_t| -{1\over 2} 
     v_t'\Omega_t^{-1}v_t\}.
\end{equation}$$

The math behind this filter should now be familiar given our
experience with the Riccati equation.  Notice in particular
that I can use the expressions in (var2) and
(Sigma) to get a recursive formula for $\Sigma_{t+1|t}$:

$$\begin{equation}
   \Sigma_{t+1|t} = Q+ A  \Sigma_{t|t-1} A' - 
              A \Sigma_{t|t-1} C' (R+C\Sigma_{t|t-1}C')^{-1}C\Sigma_{t|t-1}A',
\end{equation}$$

For the steady-state Kalman filter, the algebraic equation becomes:

$$\begin{equation}
   \Sigma = Q+ A  \Sigma A' - 
              A \Sigma C' (R+C\Sigma C')^{-1}C\Sigma A'.  \tag{stationary}
\end{equation}$$

In stationary environments, one can replace $\Sigma_0$
with the stationary $\Sigma$ that solves (stationary)
and set $x_0$ to the unconditional mean of the state vector.

Notice that (stationary)
looks exactly like the Riccati equation if we replace
$A$ by $A'$, $C'$ by $B$, and $\Sigma$ by $P$, that is:

$$\begin{equation}
  P = Q + A'P A - A'PB(R+B'PB)^{-1} B'PA.
\end{equation}$$

Why do these recursive formulas look the same? It turns out that maximizing
the quadratic return function is
like minimizing the quadratic distance between data
and model prediction.


"""

# ╔═╡ 4d63c66c-b5dd-11f1-b766-338e58c22c81
md"""
## State Space Systems and MLE



"""




# ╔═╡ 43333333-3333-5333-8333-333333333333
md"""
## Weighted Residual Methods

Weighted residual methods will applied to the following problem: 
find $d:I\!\!R^m\rightarrow I\!\!R^n$
that satisfies a functional equation $F(d)=0$,
where $F:C_1\rightarrow C_2$ and $C_1$ and $C_2$ are function spaces.
As an example, think of $d$ as decision or policy variables
and $F$ as  first-order conditions from some maximization problem.
The goal here is to find an approximation
$d^n(x;\theta)$ on $x\in \Omega$ 
which depends on a finite-dimensional vector
of parameters $\theta=[\theta_1,\theta_2,\ldots,\theta_n]'$.
Weighted residual methods assume that $d^n$ is a finite linear combination
of known functions, $\psi_i(x)$, $i=0,\ldots,n$, called {\sl basis functions}:
\begin{equation}
d^n(x;\theta) = \psi_0(x) + \sum_{i=1}^n \theta_i \psi_i(x).\tag{approximation}
\end{equation}
The functions $\psi_i(x)$, $i=0,\ldots, n$ are typically 
simple functions.  Standard examples of basis functions include
simple polynomials (for example, $\psi_0(x)=1$, $\psi_i(x)=x^i$),
orthogonal polynomials (for example, Chebyshev polynomials), and 
piecewise linear functions.

Consider a popular example for the basis
functions, namely, 
piecewise linear approximations.
More specfically, we can use:

$$\begin{equation}
\psi_i(x) = 
   \begin{cases}
        {x-x_{i-1}\over x_i-x_{i-1}} & \text{if}\ x\in [x_{i-1},x_i] \\
        {x_{i+1}-x\over x_{i+1}-x_i} & \text{if}\ x\in [x_i,x_{i+1}] \\
        0        & \text{elsewhere}.
   \end{cases} \tag{linear fem bases}
\end{equation}$$

Note that we do not need to have the points $x_i$, $i=1,\ldots, n$ equally
spaced.  For example, if we want to represent a function 
that has large gradients or kinks in certain places -- say, because 
inequality constraints bind -- then we can cluster
points in those regions.  In regions where the function
is near-linear, we do not need many points.

The idea behind the weighted residual methods is to choose
the $\theta_i$ parameters so that functional equation $F$ is approximately satisfied.
Let $R(x;\theta)$ be the residual if we evaluate $F$ at some approximate $d^n$, that is:

$$\begin{equation}
R(x;\theta) = F(d^n(x;\theta)).
\end{equation}$$

In other words, we want to choose the vector of unknowns $\theta$
so that the residual is close to zero at all $x$.
Weighted residual methods get the residual close to zero
in the weighted integral sense.  That is, we choose $\theta$ 
so that

$$\begin{equation}
\int_\Omega \phi_i(x) R(x;\theta) dx = 0, \quad i=1,\ldots, n,
\end{equation}$$

where $\phi_i(x)$, $i=1,\ldots,n$ are {\sl weight functions}.
Note that $\phi_i(x)$ and $\psi_i(x)$ can be different functions.
Alternatively, the weighted integral can be written

$$\begin{equation}
\int_\Omega w(x) R(x;\theta) dx = 0, \tag{weighted integral}
\end{equation}$$

where $w(x)=\sum_i\omega_i\phi_i(x)$ and (weighted integral)
must hold for any nonzero weights $\omega_i$, $i=1,\ldots,n$.
Therefore, instead of setting $R(x;\theta)$ to zero for all
$x\in\Omega$, the method sets a weighted integral of $R$ to zero.

We discussed different choices of 
of weight functions, for example:
determining the coefficients $\theta_1,\ldots,\theta_n$. 


1. **Least Squares**: $\phi_i(x) = \partial R(x;\theta)/
          \partial \theta_i$.
          This set of weights can be derived by calculating the first-order
          derivatives for the following optimization problem: 
          $\min_{\theta} \int_\Omega R(x;\theta)^2 \, dx.$

2. **Collocation**: $\phi_i(x) = \delta(x-x_i)$, where $\delta$ is 
          the Dirac delta function.  This set of weights implies that the 
          residual is set to zero at $n$ points $x_1,\ldots, x_n$ 
          called the {\sl collocation points}: 
          $R(x_i;\theta)=0$, $i=1,\ldots,n$.
          If the basis functions are chosen from a set of 
          orthogonal polynomials with collocation points given as the
          roots of the $n$th polynomial in the set, the method is 
          called {\it orthogonal collocation}.

3. **Galerkin**: $\phi_i(x) = \psi_i(x)$.
          In this case, the set of weight functions is the same as the basis
          functions used to represent $d$. Thus, the Galerkin method
          forces the residual to be orthogonal to each of the basis 
          functions.   As long as the basis
          functions are chosen from a complete set of functions, then
          equation
          (approximation) represents the exact solution, given that enough
          terms are included.  The Galerkin method is motivated by
          the fact that a continuous function is zero if it is 
          orthogonal to every member of a complete set of functions.

          
To illustrate weighted residual 
methods, we worked through a a simple problem in which the
coefficients $\theta_i$, $i=1,\ldots, n$ of (approximation)
satisfy a linear system of equations (that is, $A\theta=b$, where 
$A$ and $b$ do not depend on $\theta$), namely,

$$\begin{equation}
F(d)(x) = d'(x)+d(x) = 0.  \tag{simple functional}
\end{equation}$$

If we use simple polynomials for the $d^n$, that is,
$x^i$, $i=1,\ldots,n$, then the approximation is:

$$\begin{equation}
d^n(x;\theta) = 1 + \theta_1x +\theta_2 x^2 + \theta_3 x^3 + \ldots + \theta_n x^n.  \tag{simple approximation}
\end{equation}$$

Note that $\psi_0(x)=1$ so that the boundary
condition at $x=0$ is satisfied.
The task is to find the coefficients $\theta_i$, $i=1,\ldots, n$ by applying 
a weighted residual method with one of the possible sets of weights.
In each case, we solve a linear system of equations for $\theta$, 
$A\theta=b$.

Let's start with least squares.  
In this case, the problem is to find $\theta$ that minimizes the
integral of the squared residual.  The residual can be found by 
substituting equation
(simple approximation) into equation (simple functional).  
The first-order conditions of the minimization of the squared residual
imply that $\theta_1,\ldots,\theta_n$ satisfy

$$\begin{equation}
\int_0^{\bar x} {\partial R(x;\theta)\over\partial\theta_i}
                         R(x;\theta)\, dx =0,\quad i=1,\ldots, n,
\end{equation}$$

where the residual and its derivative are given by 

$$\begin{align}
    R(x;\theta) & = 1+ \sum_{i=1}^n \theta_i \{i x^{i-1}+x^i\},\\
   {\partial R(x;\theta)\over \partial \theta_i} & = i x^{i-1}+x^i.
\end{align}$$

Suppose that $n=3$ and $\bar x=6$. Then the following system of
equations is solved for $\theta$:

$$\begin{equation}
\left\{\int_0^6
  \begin{bmatrix}
        1+x \\ 2x+x^2 \\ 3x^2+x^3
  \end{bmatrix}
  \begin{bmatrix}
        1+x  &  2x+x^2  &  3x^2+x^3
  \end{bmatrix} \, dx \right\}
  \begin{bmatrix}
        \theta_1\\ \theta_2\\ \theta_3
  \end{bmatrix}
       = -\int_0^6 
      \begin{bmatrix}
             1+x \\ 2x+x^2 \\ 3x^2+x^3
       \end{bmatrix} \,dx
\end{equation}$$

or, more simply,

$$\begin{equation}
      \begin{bmatrix}
          \hfill 114.0& \hfill   576.0& \hfill   3067.2\\
          \hfill  576.0& \hfill  3139.2& \hfill  17496.0\\
          \hfill 3067.2& \hfill 17496.0& \hfill 100643.7
      \end{bmatrix}
      \begin{bmatrix}
          \theta_1\\ \theta_2\\ \theta_3
      \end{bmatrix}
   =  \begin{bmatrix}
          \hfill -24\\ \hfill -108\\ \hfill -540
      \end{bmatrix}.
\end{equation}$$

More generally, we can use the fact that

$$\begin{equation}
R(x;\theta)=(C\vec x + e)'\theta+1,
\end{equation}$$

where $\vec x=[x,x^2,\ldots,x^n]'$, $e=[1,0,\ldots,0]'$, and

$$\begin{equation}
C = \begin{bmatrix}
          1 & 0 & 0 & \cdots & 0 & 0\\
          2 & 1 & 0 & \cdots & 0 & 0\\
          0 & 3 & 1 & \cdots & 0 & 0\\
          \vdots  & \vdots & \vdots  & \vdots & \vdots & \vdots\\
          0 & 0 & 0 & \cdots & n & 1
    \end{bmatrix}.
\end{equation}$$

Since the residual $R$ is linear in $\theta$,
the derivatives with respect to $\theta$ are given by $C\vec x+e$.  Thus, the
system of equations to be solved to compute the
coefficients $\theta$ for the least squares method is given by

$$\begin{equation}
    \left\{\int_0^{\bar x} (C\vec x+e)(C\vec x+e)'\,dx\right\}
        \theta = -\int_0^{\bar x} (C\vec x + e)\, dx
\end{equation}$$

or, more succinctly, $A\theta=b$ with

$$\begin{align}
    A &=  CMC'+ePC'+CP'e'+\bar x ee',\\
    b &= -CP'-\bar x e,
\end{align}$$

and 

$$\begin{align}
  M & = \int_0^{\bar x} \vec x\vec x'\,dx
      = \begin{bmatrix}
             \bar x^3/3 & \bar x^4/4 & \cdots & \bar x^{n+1}/(n+1)\\
             \bar x^4/4 & \bar x^5/5 & \cdots & \bar x^{n+2}/(n+2)\\
             \vdots  & \vdots & \vdots  & \vdots\\
             \bar x^{n+2}/(n+2) & \bar x^{n+3}/(n+3) & \cdots & \bar x^{2n+1}/(2n+1)
        \end{bmatrix},\\
  P & = \int_0^{\bar x} \vec x\,dx 
      = \begin{bmatrix}
             \bar x^2/2\cr \bar x^3/3\\
              \vdots\\
             \bar x^{n+1}/(n+1)
        \end{bmatrix}.
\end{align}$$

In Figure 3 of the chapter from Marimon and Scott (1999), I 
plot the approximate function $d^n$ for $n=3$ and the 
exact solution $exp(-x)$.  If I had used $n=5$, then the two lines would
be visually indistinguishable.

Next, consider collocation.
In this case, the problem is to find $\theta$ so that the residual 
is equal to 0 at $n$ points in $[0,\bar x]$: $x_1,\ldots,x_n$.
Suppose that the $x_i$ are evenly spaced on $[0,6]$ and that $n=3$,
so that $x_1 = 0$, $x_2=3$, and $x_3=6$. 
Then, $\theta$ must satisfy the following system of equations:

$$\begin{equation}
    \begin{bmatrix}
       \hfill 1& \hfill  0& \hfill   0\\
       \hfill 4& \hfill 15& \hfill  54\\
       \hfill 7& \hfill 48& \hfill 324
    \end{bmatrix}
    \begin{bmatrix}
       \theta_1\\ \theta_2\\ \theta_3
    \end{bmatrix}
    = \begin{bmatrix}
           -1 \\ -1 \\ -1
      \end{bmatrix}.
\end{equation}$$

More generally, we can solve $A\theta=b$ with $(C\vec x+e)'$ 
defined above evaluated
at $x_i$ in the $i$th row of $A$ and $b$ set to a vector of $-1$'s:

$$\begin{equation}
   \begin{bmatrix}
      (C \vec x + e)'|_{x=x_1} \\
      (C \vec x + e)'|_{x=x_2} \\
      \vdots \\
      (C \vec x + e)'|_{x=x_n}
   \end{bmatrix}\, \theta
        =
   \begin{bmatrix}
      -1\\ -1\\ \vdots\\ -1
   \end{bmatrix}.
\end{equation}$$

In Figure 4 of the chapter, 
I plot the approximate function $d^n$ and the exact
solution.  If I choose $n=5$, the two lines are nearly indistinguishable.
However, for $n=3$, the approximation is not as good as the least squares 
approximation.  

Finally, consider the Galerkin variant of the method.
In this case, the problem is to find $\theta_1,\ldots,\theta_n$
that satisfy
\begin{equation}
 \int_0^{\bar x} x^i R(x;\theta)\, dx =0,\quad i=1,\ldots, n.\tag{weighted residual galerkin}
\end{equation}
Again, consider $n=3$ and $\bar x=6$. For these choices, 
the equations in (weighted residual galerkin) are given by

$$\begin{equation}
  \left\{\int_0^6
     \begin{bmatrix}
        x \\ x^2 \\ x^3
     \end{bmatrix}
     \begin{bmatrix}
        1+x  &  2x+x^2  &  3x^2+x^3
     \end{bmatrix} \, dx \right\}
     \begin{bmatrix}
        \theta_1\\ \theta_2\\ \theta_3
     \end{bmatrix}
            = -\int_0^6 
               \begin{bmatrix}
                  x \\ x^2 \\ x^3
               \end{bmatrix}\, dx.  \tag{reduced galerkin}
\end{equation}$$

Note that we have written these equations in the form $A\theta=b$.
If we compute the integrals in equation (reduced galerkin), then the system 
of equations becomes

$$\begin{equation}
    \begin{bmatrix}
        \hfill   90.0& \hfill   468.0& \hfill   2527.2\\
        \hfill  396.0& \hfill  2203.2& \hfill  12441.6\\
        \hfill 1879.2& \hfill 10886.4& \hfill  63318.9
    \end{bmatrix}
    \begin{bmatrix}
          \theta_1\\ \theta_2\\ \theta_3
    \end{bmatrix}
   =\begin{bmatrix}
            \hfill -18\\ \hfill -72\\ \hfill -324
    \end{bmatrix}.
\end{equation}$$

For general $n$ and $\bar x$, the coefficients solve
$A\theta=b$, where $A$ and $b$ are the 
following functions: 

$$\begin{align}
   A &=  MC'+P'e'\\
   b &= -P'
\end{align}$$

with $M$, $C$, $P$, and $e$ as defined above.
In Figure 5 of the chapter, I plot the approximate function $d^n$ and the exact
solution.   The results are similar to those obtained with the 
least squares method.  Again, if I choose $n=5$, then the
approximate and exact solutions are visually indistinguishable.

Next we will work with basis functions that are nonzero
on only small regions of the domain of $x$.   The resulting
representations of $d^n$ will be piecewise functions (for example,
piecewise linear, piecewise quadratic).
In the terminology of numerical analysts, we will be applying
a {\sl finite element method}.
Finite element methods use basis
functions that are only nonzero on small regions of the domain of
$x$ (for example, the tent functions drawn in Figure 2).

The idea behind the finite element method is to break up 
the domain of $x$ into smaller pieces, use low-order polynomials 
to get good local approximations for the function $d$, and then piece 
the local approximations
together to get a good global approximation.
In effect, one can think
of the finite element method as a piecewise application
of a weighted residual method.
Thus, to apply a finite element method, we first
divide the domain into smaller nonoverlapping subdomains.  On each of
the subdomains, we construct a local approximation to 
the function $d$.  For the problem in (simple functional),
$\Omega$ is 
one-dimensional, and therefore, division of $\Omega$ means
coming up with some partition, say, $[x_1,x_2,\ldots, x_n]$ on $I\!\!R$.
Each subinterval $[x_i,x_{i+1}]$ is
called an {\it element}.

Suppose, for example, that we want to represent $d$ as a piecewise
linear function;  that is, over each element, we assume that the approximation
is of the form $a+bx$.
Suppose also that we  want the function $d$ to be continuous 
on the whole domain $\Omega$.
How would we construct basis functions $\psi_i(x)$ so that we can 
write $d^n$ as in (approximation)?

The first step is to assign {\sl nodes} on the element. 
For the finite element method, nodes are points on an element that are used
to define the geometry of the element and to uniquely define the
order of the polynomial being used to approximate the true solution
over the element.  Since we  are assuming that an element is
some interval $[x_i,x_{i+1}]$,  two nodes -- in particular,
the two endpoints $x_i$ and $x_{i+1}$ -- are needed 
to define the geometry.  And only two points are 
needed to uniquely define a linear function.  Therefore, the
nodes on a one-dimensional element with linear bases are the
two endpoints of the element.

The second step in constructing the basis functions is to 
assume that the undetermined coefficients are equal to the 
approximate solution at the nodal points.
Assume that the numbering of elements and nodes is such that
element $i$ is the interval [$x_i,x_{i+1}]$: the first element is [$x_1,x_2]$,
the second element is [$x_2,x_3]$, and so on.
Assume also that the approximate solution on element $i$, $d_i^n(x;\theta)$,
satisfies $d_i^n(x_i)=\theta_i$ and $d_i^n(x_{i+1})=\theta_{i+1}$. In
other words, assume that the
undetermined coefficients represent the solution at the nodes.
The approximation of $d$ on element $i$, $d_i^n$, 
is therefore uniquely given by 

$$\begin{equation}
    d_i^n(x;\theta) = \theta_i \psi_i(x)  + \theta_{i+1} \psi_{i+1}(x), \quad
    x\in [x_i,x_{i+1}],
\end{equation}$$

where the basis functions are given by equation
(linear fem bases) and drawn in Figure 2.
Since elements are connected to each other at nodal points on the
element boundaries, this choice of basis functions guarantees
that the approximation is continuous across elements.
Notice also that any linear function (and, hence, any continuous
piecewise linear $d^n$) can be represented with the basis functions
given in (linear fem bases).

Let the approximate solution to (simple functional)
be of the form
\begin{equation}
d^n(x;\theta) = \sum_{i=1}^n \theta_i \psi_i(x),  
\end{equation}
with $\psi_i(x)$, $i=1,\ldots, n$ given by (linear fem bases).
To impose the boundary condition $d^n(0;\theta)=1$, we need
to set $\theta_1$ to one. 
Let's apply a Galerkin method. Therefore, the weight functions are
given by the bases $\psi_i(x)$, $i=1,\ldots, n$.

Suppose that there are three elements with nodes
at 0, 1, 3, and 6.  
Then the residual equation is given by
\begin{align}
    R(x;\theta) &= \sum_{i=1}^4 \theta_i(\psi_i'(x) +\psi_i(x))\\
                &=\begin{cases}
                     \theta_1\,(-x) +\theta_2\,(1+x)  & \text{if}\ x\in [0,1]\\
                     \theta_2\,(1\,-{1\over 2}x)+\theta_3\,({1\over 2}x)  & \text{if}\ x\in [1,3]\\
                     \theta_3\,({5\over 3}-{1\over 3}x) +\theta_4\,(-{2\over 3}+{1\over 3}x)  & \text{if}\ x\in [3,6].
                  \end{cases} \tag{three element residual}
\end{align}
If we substitute the residual (three element residual) into the weighted
integral (weighted integral)
with $\phi_i(x)=\psi_i(x)$, then we get the following 
system of equations:

$$\begin{align}
      \Biggl\{      &\int_0^1
                     \begin{bmatrix}
                                  1-x\\
                                   x\\
                                   0\\
                                   0
                     \end{bmatrix}
                     \begin{bmatrix}
                         -x & 1+x & 0 & 0
                     \end{bmatrix}\, dx \\
                          +&\int_1^3
                     \begin{bmatrix}
                                0\\
                           \phantom{-}{3\over 2}-{1\over 2}x\\
                                  -{1\over 2}+{1\over 2}x\\
                                   0
                     \end{bmatrix}
                     \begin{bmatrix}
                              0 & 1-{1\over 2}x & {1\over 2}x & 0
                     \end{bmatrix}\,dx  \\
                          +&\int_3^6
                     \begin{bmatrix}
                                   0\\
                                   0\\
                                  \phantom{-}2-{1\over 3}x\\
                                  -1+{1\over 3}x 
                     \end{bmatrix}
                     \begin{bmatrix}
                               0 & 0 & {5\over 3}-{1\over 3}x & -{2\over 3}+{1\over 3}x
                     \end{bmatrix}\,dx \Biggr\}
                 \begin{bmatrix}
                      1\\ \theta_2\\ \theta_3 \\ \theta_4
                 \end{bmatrix}
                  = \begin{bmatrix}
                           0\\ 0\\ 0\\ 0
                    \end{bmatrix},
\end{align}$$

or if we compute the integrals, 

$$\begin{equation}
    \begin{bmatrix}
       \hfill -1/6& \hfill  2/3& \hfill   0& \hfill   0\\
       \hfill -1/3& \hfill    1& \hfill 5/6& \hfill   0\\
       \hfill    0& \hfill -1/6& \hfill 5/3& \hfill   1\\
       \hfill    0& \hfill    0& \hfill   0& \hfill 3/2
    \end{bmatrix}
    \begin{bmatrix}
        1\\ \theta_2\\ \theta_3 \\ \theta_4 
    \end{bmatrix}
    = \begin{bmatrix}
        0\\ 0\\ 0\\ 0
      \end{bmatrix}.  \tag{system for three elements}
\end{equation}$$

Note that we need to drop the first equation because we have
to impose that $\theta_1$ = 1 for the boundary condition to be 
satisfied.
Recall that the integral equation can be written
as in (weighted integral), where in this case, 
$w(x)=\sum_i \omega_i \psi_i(x)$.  
The function $w(x)$ must satisfy the homogeneous counterpart of the
boundary condition $d(0)=1$, that is, $w(0) = 0$. For those familiar
with the calculus of variations, $w$ is
like the variation of the solution and thus must satisfy the
homogeneous counterparts of boundary conditions for $d$. Enforcing the
condition $w(0)=0$ is equivalent to dropping the first equation in 
(system for three elements).
Therefore, the system of equations reduces to

$$\begin{equation}
   \begin{bmatrix}
       \hfill    1& \hfill 5/6& \hfill   0\\
       \hfill -1/6& \hfill 5/3& \hfill   1\\
       \hfill    0& \hfill   0& \hfill 3/2 
   \end{bmatrix}
       \begin{bmatrix}
           \theta_2\\ \theta_3\\ \theta_4 
       \end{bmatrix}
                  = 
       \begin{bmatrix}
            \hfill 1/3\\ \hfill 0\\ \hfill 0
       \end{bmatrix},
\end{equation}$$

with three equations and three unknowns.
In Figure 7 of the chapter, I plot the finite element approximation
and the exact solution. By construction, the approximate function
is piecewise linear.  

What is involved if we instead apply the method to the simplest
deterministic growth model with inelastic labor?  In that case, the
decision function is consumption $c^n(k;\theta)$ and
the residual is

$$\begin{align}
  R(k;\theta) &= 1-\beta \frac{ U(c^n(F(k)+(1-\delta)k-c^n(k;\theta)))}
                              {U(c^n(k;\theta))}\\
              & \qquad\qquad \qquad \cdot  (F_k(F(k)+(1-\delta)k-c^n(k;\theta))+1-\delta).
\end{align}$$

Unlike the problem above, the final set of equations will not turn out
to be linear but the procedure up to the point of setting up the
problem is no different.  The weighted residuals are then given by 

$$\begin{equation}
  \int \psi_i(k) R(k;\theta)dk = 0
\end{equation}$$

for $i=1,\ldots,n$, which can be stacked into a system of equations in
the vector of unknowns $\vec \theta = [\theta_1,\ldots,\theta_n]'$:

$$\begin{equation}
   G(\vec\theta) = 0
\end{equation}$$

where $G$ is $n$ dimensional.
From here, a Newton update can be applied:

$$\begin{equation}
  \vec\theta^{j+1} = \vec\theta^j-\left[ {\partial G(\vec\theta)\over \partial \vec\theta}|_{\vec \theta=\vec\theta^j}\right]^{-1} G(\vec\theta^j)
\end{equation}$$

starting from a guess of $\vec\theta^0$ based on our linear 
or log-linear approximations.



"""

# ╔═╡ 53333333-3333-5333-8333-333333333333
md"""
## Finite Element Method




### Deterministic growth model

At each date $t$, consumption, $c_t$, and investment, $x_t$,
are chosen to maximize the present value of discounted utility
subject to the resource constraint and the definition of 
investment:

$$\begin{align}
\sum_{t=0}^{\infty} & \beta^t\, u(c_t) \\
     {\rm subject\ to\ }  & c_t + x_t = f(k_t)\\
                          & x_t = k_{t+1} - (1-\delta) k_t
\end{align}$$

given initial capital $k_0$ and specifications for 
utility $u(\cdot)$, production $f(\cdot)$, and parameters $\beta$ 
and $\delta$.

This problem is well suited for the finite element method 
(and other weighted residual methods) used to solve 
functional equations. Suppose we use the intratemporal
first-order condition as the functional equation of interest
and compute an approximate consumption function.
In this case, the functional equation we want to solve is
\begin{equation}
     F(c)(k) = \beta \frac{u'(c( f(k)+(1-\delta)k-c(k))}{u'(c(k))} f'(f(k)+(1-\delta)k-c(k))-1 = 0
\end{equation}
over the state space $\Omega=[0,\bar k]$, where $\bar k$ is 
the maximal capital stock used when approximating the consumption
function (and not necessarily the feasible maximum).
When applying the finite element method, we need to specify non-overlapping
``elements'' over the domain. In the case of one-dimensional approximations,
the elements are simply non-overlapping intervals on $\Omega$.

The approximate consumption function is given by a weighted sum
of basis functions:

$$\begin{equation}
   c^n(k;\Theta) =  \sum_{l=1}^n \theta_l \psi_l(k)
\end{equation}$$

and depends on unknown coefficients $\Theta=[\theta_1,\theta_2,\ldots,\theta_n]'$
of the known basis functions $\psi_l(k)$, $l=1,\ldots,n$.  For simplicity, we will use
linear bases: 

$$\begin{equation}
   \psi_l(k) =  
    \begin{cases}
        {k-k_{l-1}\over k_l-k_{l-1}} & \text{if}\ k\in [k_{l-1},k_l] \\
        {k_{l+1}-k\over k_{l+1}-k_l} & \text{if}\ k\in [k_l,k_{l+1}] \\
        0        & \text{elsewhere}.
   \end{cases} \tag{linear fem bases}
\end{equation}$$

that imply the approximation is piecewise linear
with $c^n(k_l)=\theta_l$ at nodes $k_l$.
Applying a weighted residual method in this case means
finding $\Theta$ that satisfy
\begin{equation}
   \int_{\Omega} \omega(k) R(k;\Theta) = 0
\end{equation}
where $R(k;\Theta) = F(c^n(k;\Theta))$
and $\omega(k)$ is a weighting  function that is
also assumed to be a linear sum of the
basis functions above, that is 
\begin{equation}
   \omega(k) = \sum_{l=1}^n \varpi_l \psi_l(k)
\end{equation}
with coefficient parameters $\varpi_l$, $l=1,\ldots,n$
and basis functions defined over $\Omega$ as above.
To set the weighted residual equal to zero for any 
arbitrary weights $\varpi_l$, it must be the
case that the following is true:

$$\begin{equation}
   \int_{k_{l-1}}^{k_{l}} \left(\frac{k-k_{l-1}}{k_l-k_{l-1}}\right) R(k;\Theta) 
        + \int_{k_{l}}^{k_{l+1}}\left( \frac{k_{l+1}-k}{k_{l+1}-k_l}\right)  R(k;\Theta) =0 \tag{weighted residual}
\end{equation}$$

for $i=2,\ldots,n-1$ and, if there are no boundary conditions
imposed at the endpoints of the domain, then we add:

$$\begin{equation}
   \int_{k_1}^{k_2} \left(\frac{k_{2}-k}{k_2-k_1}\right)  R(k;\Theta) =0,\quad
   \int_{k_{n-1}}^{k_n} \left(\frac{k-k_{n-1}}{k_{n}-k_{n-1}}\right) R(k;\Theta) =0.
\end{equation}$$

to the system of equations when solving for the elements
of the vector $\Theta$.

Suppose we set $u(c)= [c^{1-\mu}-1]/(1-\mu)$ and $f(k)=Ak^\alpha$.
The residual in this case is 

$$\begin{align}
   R(k;\Theta) &= \beta \frac{c^n(\tilde k;\Theta)^{-\mu}}{c^n(k;\Theta)^{-\mu}} (\alpha A \tilde k^{\alpha-1} 
                          + 1-\delta)-1\\
               &= \beta \frac{(\sum_l\theta_l\psi_l(\tilde k))^{-\mu}}{(\sum_l\theta_l\psi_l(k))^{-\mu}} (\alpha A \tilde k^{\alpha-1} 
                          + 1-\delta)-1, 
\end{align}$$

where $\tilde k=Ak^\alpha+(1-\delta)k-\sum_l\theta_l\psi_l(k)$.
Since we are working with piecewise linear bases, we can
evaluate this residual locally on the element containing $k$.
Note that it may be the case that $\tilde k$ is located on another
element.  That means the sums $\sum_l \theta_l \psi_l(k)$
and $\sum_l\theta_l \psi_l(\tilde k)$ will be different and the particular
$\theta_l$ unknowns that are multiplying non-zero bases will be different.
Even if $k$ and $\tilde k$ are located on the same element, the 
values for consumption will differ if $k\neq\tilde k$.

### Stochastic growth model

Next, consider constructing the residual if productivity is stochastic.
The problem is the same as above except the households solve the
expected lifetime consumption and the productivity $A$
is now stochastic. Consider two Markovian specifications
for productivity. The first is a Markov chain with $I$ states:

$$\begin{equation}
   \Pi_{i,j} =Pr[A_{t+1}=A(j)|A_t=A(i)]
\end{equation}$$

for $i=1,\ldots,I$ and $j=1,\ldots,I$.
The second is the autoregressive process:

\begin{equation}
   \log A_{t+1} = \rho \log A_t + \epsilon_{t+1}, \tag{ar1}
\end{equation}

where $\epsilon_t\sim N(0,\sigma^2)$. 

The residual when productivity is a Markov chain is given by:

$$\begin{equation}
R(k,i;\Theta) = \beta \sum_{j=1}^I\Pi_{i,j}\, \frac{c^n(\tilde k,j;\Theta)^{-\mu}}{c^n(k,i;\Theta)^{-\mu}}
           (\alpha A(j)\tilde k^{\alpha-1}+1-\delta)-1,
\end{equation}$$

where $\tilde k = A(i) k^\alpha + (1-\delta)k-c^n(k,i;\Theta)$ and

$$\begin{equation}
   c^n(k,i) = \sum_{l=1} \theta_l^i \psi_l(k).
\end{equation}$$

We can use the same approximation for consumption as above.  If we set $I=1$,
we have the same residual as in the deterministic growth model.

When productivity is a continuous autoregressive process, 
we need to figure out how to deal with the 
fact that $\log A$ is in the range [$-\infty,\infty]$.
One simple ``fix'' is to make a change of variables, for example, let 

$$\begin{align} 
  z_t &= {\rm tanh}(a_t)\\
      &= \frac{\exp(a_t)- \exp(-a_t)}{\exp(a_t)+\exp(-a_t)}
\end{align}$$ 

where tanh is the hyperbolic tangent function with 
a range [$-1,1$].
If we invert this function, we get $A_t=\sqrt{(1+z_t)/(1-z_t)}$
and equation (ar1) can be replaced by

$$\begin{equation}
   z_{t+1}= {\rm tanh}(\rho {\rm tanh}^{-1}(z_t) + \epsilon_{t+1}).
\end{equation}$$

Once we have mapped the productivity process, we can
define the consumption function on a domain
$\Omega=[0,\bar k] \times [-1,1]$.
Imagine that we carve this two-dimensional space up into non-overlapping 
rectangles. In the two-dimensional space, these rectangles are the
``elements'' analagous to the intervals we were using above.
If we continue with the simple piecewise linear bases---or
in this case, piecewise \emph{bilinear} bases---then we would construct
two-dimensional bases on rectangles around node $(i,j)$ as follows:

$$\begin{equation}
   \psi_{i,j}(k,z) = \begin{cases}
      \frac{k-k_{i-1}}{k_i-k_{i-1}} 
        \cdot \frac{z-z_{j-1}}{z_j-z_{j-1}} & \text{if}\ k\in [k_{i-1},k_i],
                                                         z\in [z_{j-1},z_j]\\
      \frac{k_{i+1}-k}{k_{i+1}-k_i} 
        \cdot \frac{z-z_{j-1}}{z_j-z_{j-1}} & \text{if}\ k\in [k_i,k_{i+1}],
                                                         z\in [z_{j-1},z_j]\\
      \frac{k-k_{i-1}}{k_i-k_{i-1}} 
        \cdot \frac{z_{j+1}-z}{z_{j+1}-z_j} & \text{if}\ k\in [k_{i-1},k_i],
                                                         z\in [z_j,z_{j+1}]\\
      \frac{k_{i+1}-k}{k_{i+1}-k_i} 
        \cdot \frac{z_{j+1}-z}{z_{j+1}-z_j} & \text{if}\ k\in [k_i,k_{i+1}], 
                                                         z\in [z_j,z_{j+1}]\\
      0        & \text{elsewhere}.
     \end{cases} \tag{bilinear fem bases}
\end{equation}$$

The approximate consumption function in this case is

$$\begin{equation}
   c^n(k,z) = \sum_{i,j} \theta_{i,j} \psi_{i,j}(k,z).
\end{equation}$$

Now that we have a set of bases for $c^n$, we can write the residual function
for the two-dimensional stochastic growth model as follows:

$$\begin{equation}
R(k,z;\Theta) = \beta \int_{-\infty}^\infty
\frac{c^n(\tilde k,\tilde z)^{-\mu}}{c^n(k,z)^{-\mu}}
 \left(\alpha \sqrt{{1+\tilde z\over 1-\tilde z}}\tilde k^{\alpha-1}
    +1-\delta\right)\frac{e^{-\nu^2}}{\sqrt{\pi}} \, d\nu -1 \tag{twodim}
\end{equation}$$

where $\nu_t=\epsilon_t/(\sqrt{2}\sigma)$, which is distributed $N(0,1/2)$
and has density $\exp(-\nu^2)/\sqrt{\pi}$.
Replacing $\epsilon$ by $\nu$ makes it very convenient to
compute the expected value in the Euler equation with a standard Gaussian quadrature method.
Specifically, we can use the fact that 

$$\begin{equation}
    \int^{\infty}_{-\infty} e^{-\nu^2} g(\nu) d\nu 
        \approx \sum_{\ell=1}^m \omega_\ell g(\nu_\ell),
\end{equation}$$

where the values of $\nu_ell$ are roots of a $m^{\rm th}$ order polynomial, $H_m(x)$,
from the Hermite class and $\omega_{\ell}= 2^{m-1}m!\sqrt{\pi}/(m^2 [H_{m-1}(\nu_{\ell})]^2)$.
Given this result, we can rewrite the residual as:

$$\begin{equation}
R(k,z;\Theta) \simeq \frac{\beta}{\sqrt{\pi}} \sum_{\ell=1}^{m} 
                \frac{c^n(\tilde k,\tilde z_{\ell})^{-\mu}}{c^n(k,z)^{-\mu}} 
                \left(\alpha\tilde k^{\alpha-1}
                      \sqrt{1+\tilde z_{\ell}\over 1-\tilde z_{\ell}}
                       +1-\delta\right) \omega_{\ell}-1,
\end{equation}$$

where $\tilde z_{\ell}= {\rm tanh}(\rho\, {\rm tanh}^{-1}(z)+\sqrt{2}\sigma\nu_{\ell})$.

Once we have the residual function---whether we are solving a one-dimensional problem,
many one-dimensional problems, or a two-dimensional problem---we can use what
we learned earlier about mapping elements to a ``master element'' and writing
a standard function to fill in elements of the Jacobian matrix for the non-linear
system equations arising from choosing $\Theta$ that sets the weighted
residual to 0. In the case of 
In the case of one-dimensional piecewise linear approximations, we have

$$\begin{equation}
c^n_e(\xi,i) = {\scriptstyle{1\over 2}}(1-\xi)\, \theta_{\scriptscriptstyle 1,e}^i+ 
               {\scriptstyle{1\over 2}}(1+\xi)\, \theta_{\scriptscriptstyle 2,e}^i
\end{equation}$$

on element $e$, where $\theta_{\scriptscriptstyle 1,e}^i$ and
$\theta_{\scriptscriptstyle 2,e}^i$ are the coefficients related to the 
first and second node on element $e$, respectively, in the case that
the productivity level is $A(i)$.
In the case of two-dimensional piecewise bilinear approximations, we have
to map from $[k_i,k_{i+1}]$ $\times$ $[z_j,z_{j+1}]$
 to the master element that we will assign to $[-1,1]$ $\times$ $[-1,1]$.
In this case, $\xi(k)=(2k-k_i-k_{i+1})/(k_{i+1}-k_i)$ and 
$\eta(z)= (2z-z_j-z_{j+1})/(z_{j+1}-z_j)$. We then work with:

$$\begin{align}
c^n_e(\xi,\eta) =\  &\frac{1}{4} (1-\xi)(1-\eta)\, 
                    \theta_{\scriptscriptstyle 1,e}
                  +\frac{1}{4} (1+\xi)(1-\eta)\, 
                    \theta_{\scriptscriptstyle 2,e}\cr
                  +&\frac{1}{4} (1+\xi)(1+\eta)\, 
                    \theta_{\scriptscriptstyle 3,e}
                  +\frac{1}{4} (1-\xi)(1+\eta)\, 
                    \theta_{\scriptscriptstyle 4,e},
\end{align}$$

where $\theta_{\scriptscriptstyle l,e}$ is the coefficient
for the $l^{\rm th}$ node on element $e$.


### Aiyagari-McGrattan Model 


As with the standard growth model, the main task is to derive the residual function.
Once we have that, the problems are no different.
The consumer chooses sequences of consumption and asset holdings 
to maximize expected utility:

$$\begin{align}
     \max_{\{\tilde c_t,\tilde a_{t+1}\}} &E\bigl[ \sum_{t=0}^\infty 
            (\beta(1+g)^{1-\nu})^t \tilde c_t
                  ^{1-\nu}/(1-\nu)|\tilde a_0,e_0\bigr] \tag{inelastic objective}\\
     {\rm subject\ to\ \ } & \tilde c_t+(1+g)
             \tilde a_{t+1} \leq (1+\bar r) \tilde a_t + 
                     \bar w e_t +\chi, \tag{inelastic consumer budget}\\
               & \tilde a_t \geq 0, \tag{inelastic no borrowing}
\end{align}$$

with the after-tax interest rate $\bar r$, the after-tax 
wage rate $\bar w$, and a lump-sum transfer $\chi$ taken as 
given.  The productivity level $e_t$ is assumed to follow a Markov chain
with $E e_t=1.$  The probability of transiting from state $i$ to
state $j$ is given by $\pi_{i,j}$, $i,j=1,\ldots,m$.  
 
To incorporate the inequality constraints in (inelastic no borrowing),
we replace the objective in (inelastic objective) with

$$\begin{equation}
E \biggl[ \sum_{t=0}^\infty 
              (\beta(1+g)^{1-\nu})^t \biggl\{{\tilde c_t^{1-\nu}\over 1-\nu}
              +\frac{1}{3} \zeta \min(\tilde a_t,0)^3\biggr\} 
              | \tilde a_0,e_0\biggr], \tag{inelastic objective with penalty}
\end{equation}$$

where $\zeta$ is some positive parameter.
Note that if $\tilde a_t$ is negative, then we subtract
$-\zeta \tilde a_t^3$ from the consumer's value function. 
With this respecification, the optimization problem is as
follows: given $\zeta$, we choose sequences of consumption and
assets that are optimal
for (inelastic objective with penalty) subject to 
(inelastic consumer budget).
The parameter $\zeta$ is set so that (inelastic no borrowing) is 
approximately satisfied.  In practice, the optimization 
is done either by iterating
over a sequence  1, 10, $10^2$, etc.~for $\zeta$, until the constraints 
are satisfied to within the tolerance,  or by starting with a reasonably
large value of $\zeta$. See R. Fletcher (1987), {\it Practical
Methods of Optimization} (New York: Wiley) for a discussion
of the relationship of $\zeta$ to the Lagrange multipliers of the
constraints in (inelastic no borrowing).

Because the decision rules are stationary, we can compute the functions
$c(x,i)$ and $\alpha(x,i)$
that satisfy the following first-order conditions for $i=1,\ldots,m$
and $x\in[0,x_{max}]$:

$$\begin{align}
& (1+g) c(x,i)^{-\nu} = \beta(1+g)^{1-\nu}\{ \textstyle\sum_j \pi_{i,j} \,
    (1+\bar r) c(x',j)^{-\nu} 
    +\zeta \min(\alpha(x,i),0)^2 \}, \tag{inelastic first order one}\\
&c(x,i) +(1+g)\alpha (x,i) = (1+\bar r)x + \bar w e(i)+\chi, \tag{inelastic first order two}
\end{align}$$

where $x'=\alpha (x,i)$ and  
$e(i)$ is the  productivity level in state $i$.
Note that these conditions assume an interior
solution for $c(x,i)$.
If we substitute the expression for $c(x,i)$ in
(inelastic first order two) into (inelastic first order one),
we have a functional equation in
$\alpha $. We denote this expression by $R(x,i;\alpha)$:

$$\begin{align}
R(x,i;\alpha) & = (1+g) \{(1+\bar r)x + \bar w e(i)
                    +\chi-(1+g)\alpha(x,i)\}^{-\nu} \cr
                &\qquad 
                    -\beta(1+g)^{1-\nu} \{\textstyle\sum_j \pi_{i,j}\, \{(1+\bar r) 
                    (1+\bar r)\alpha(x,i) + \bar w e(j)\\
                &\qquad 
                    +\chi-(1+g)\alpha\bigl(\alpha(x,i),j\bigr)\}^{-\nu}
                    +\zeta \min(\alpha(x,i),0)^2 \}.  \tag{inelastic residual}
\end{align}$$

As before, the computational task is to find 
an approximation for $\alpha(x,i)$ -- say $\alpha^n(x,i)$ --
that implies $R(x,i;\alpha^n)\approx 0$ for all $x$ and $i$.  
We accomplish this task by applying a finite element method.
In particular, we do the following. 
We choose some discretization of the domain of our functions.
Since only $x$ is continuous, we need to specify some partition
of [0,$x_{max}$] where $x_{max}$ is such that no $x>x_{max}$
would be chosen by the consumer.
We refer to each subinterval of $x$ as an element.
On each element,  we choose a set of basis functions for
approximating $\alpha$; that is, we assume $\alpha^n$
can be represented as a weighted sum of basis functions,
where the weights and basis functions may be different for
each element.
In our case, we choose linear basis functions for all elements:

$$\begin{equation}
\alpha^n(x,i) = \theta_e^i \psi_e(x) +\theta_{e+1}^i \psi_{e+1}(x),\qquad 
\psi_e(x)={x_{e+1}-x\over x_{e+1}-x_e},\ \psi_{e+1}(x)={x-x_e\over x_{e+1}-x_e},
\end{equation}$$

on the element $[x_e,x_{e+1}]$.
Notice that $\alpha^n(x_e,i)=\theta_e^i$ and 
$\alpha^n(x_{e+1},i)=\theta_{e+1}^i$.  
If we consider the approximation globally, we need to compute
values for
$\psi_e^i$ for all nodes $e$ (assume there are $n$)
and for all levels of productivity $i$.
We choose these values for $\psi_e^i$ by setting the weighted
residual to zero; i.e.,

$$\begin{equation}
\int R(x,i;\alpha^n) \psi_e(x) dx = 0, \qquad i=1,\ldots, m, \ e=1,\ldots n.  \tag{system} 
\end{equation}$$

In effect, we solve a problem of the following form: find $\vec\theta$ such
that $h(\vec\theta)=0$, where $\vec\theta$ is the vector of coefficients
that we are searching over and $h$ is the system of equations in 
(system).

There are several practical points worth noting. 
The first point is that,
for parameterizations in which the no-borrowing constraint binds,
the penalty function only serves to get 
$\alpha(x,i)>-\epsilon$, where $\epsilon$ is small but positive.
Thus, if the function is truly equal to zero
for low values of $x$ and $i$, then 
the algorithm will not yield a mass point at $x=0$.
To deal with this problem, we use a two-step procedure.  
At the first step, we apply the penalty function
method and choose a sufficiently fine mesh to resolve the kink.
The kink is defined as the grid point at which the 
second derivative is maximized.
At the second step, we use the candidate solution to determine the 
boundary conditions $\alpha^n(x,i)=0$, 
$x<x^*$, where $x^*$ is the grid
point at which the second derivative of $\alpha^n(x,i)$ is highest.
These boundary constraints are imposed on the solution prior
to the final run.  The second point concerns the procedure for solving
$h(\vec \theta)=0$.  We solve this system of equations by applying
a Newton method.  Therefore,
we need to compute the derivative of $h(\vec\theta)$ with respect
to $\vec\theta$, and we need to invert it.  We calculate
analytical derivatives because it saves computing time.  
With respect to inverting the Jacobian, we can rely on the
fact that it is very sparse.  The sparseness is due to the
fact that the approximation is done element by element; thus,
the basis functions are nonzero on relatively small subdomains.
In practice, however, we only use sparse matrix routines if
the dimension of the matrix to be inverted is bigger than
2000 $\times$ 2000. 

"""



# ╔═╡ 33777777-7777-4777-8777-777777777777
md"""

---

Footnotes:

1. See the numerical methods appendix for details and Julia scripts for 
   Gaussian quadrature.

2. See the numerical methods appendix for details and Julia scripts for 
   discretizing an autoregressive process.

3. See the numerical methods appendix for details and Julia scripts for 
   the bisection method.

"""







# ╔═╡ 77777777-7777-4777-8777-777777777777
# Adjust notebook width for lecture notes.
HTML("""
<style>
  main {
    max-width: 58vw !important;
    margin-right: 25vw !important;
  }
</style>
""")

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DelimitedFiles = "8bb1440f-4735-579b-a4ab-409b98df4dab"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
Measures = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
HypertextLiteral = "~0.9.5"
Measures = "~0.3.3"
Plots = "~1.41.7"
PlutoUI = "~0.7.75"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.13.0"
manifest_format = "2.1"
project_hash = "bbbc8cfbc203f1cf0c52fce6f6af614a57e4225b"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
registries = "General"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
registries = "General"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1b96ea4a01afe0ea4090c5c8039690672dd13f2e"
registries = "General"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.9+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "1fa950ebc3e37eccd51c6a8fe1f92f7d86263522"
registries = "General"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.7+0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "b0fd3f56fa442f81e0a47815c92245acfaaa4e34"
registries = "General"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.31.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "67e11ee83a43eb71ddc950302c53bf33f0690dfe"
registries = "General"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.1"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "8b3b6f87ce8f65a2b4f857528fd8d70086cd72b1"
registries = "General"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.11.0"

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

    [deps.ColorVectorSpace.weakdeps]
    SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "37ea44092930b1811e666c3bc38065d7d87fcc74"
registries = "General"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.1"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.5.5+2"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
registries = "General"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
registries = "General"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["OrderedCollections"]
git-tree-sha1 = "b0bc6d2cad1fed8b7fd59a1551a991cb3d2809e6"
registries = "General"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.19.6"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "473e9afc9cf30814eb67ffa5f2db7df82c3ad9fd"
registries = "General"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.16.2+0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
registries = "General"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.DocStringExtensions]]
git-tree-sha1 = "7442a5dfe1ebb773c29cc2962a8980f47221d76c"
registries = "General"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.5"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a4be429317c42cfae6a7fc03c31bad1970c310d"
registries = "General"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+1"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "2bfb1e047e2ad0a5ca94365340bde8005d637568"
registries = "General"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.8.4+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "95ecf07c2eea562b5adbd0696af6db62c0f52560"
registries = "General"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.5"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libva_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "7a58e45171b63ed4782f2d36fdee8713a469e6e0"
registries = "General"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "8.1.2+0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Random", "Statistics"]
git-tree-sha1 = "59af96b98217c6ef4ae0dfe065ac7c20831d1a84"
registries = "General"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.6"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "f85dac9a96a01087df6e3a749840015a0ca3817d"
registries = "General"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.17.1+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
registries = "General"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "70329abc09b886fd2c5d94ad2d9527639c421e3e"
registries = "General"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.14.3+1"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7a214fdac5ed5f59a22c2d9a885a16da1c74bbc7"
registries = "General"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.17+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "64bbbb7d1499297751b536dd39c58b20750ab1db"
registries = "General"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.5.1+0"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "JSON", "Libdl", "LinearAlgebra", "Preferences", "Printf", "Qt6Wayland_jll", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "p7zip_jll"]
git-tree-sha1 = "4d777f73c46b46b8b5276206059cf8a195499314"
registries = "General"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.73.27"

    [deps.GR.extensions]
    IJuliaExt = "IJulia"

    [deps.GR.weakdeps]
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f8eb8f7ba13ea75083531647fc8faeda8d541f07"
registries = "General"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.73.27+0"

[[deps.GettextRuntime_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll"]
git-tree-sha1 = "45288942190db7c5f760f59c04495064eedf9340"
registries = "General"
uuid = "b0724c58-0f36-5564-988d-3bb0596ebc4a"
version = "0.22.4+0"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Zlib_jll"]
git-tree-sha1 = "38044a04637976140074d0b0621c1edf0eb531fd"
registries = "General"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.1+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "GettextRuntime_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "090526e65de8f69648ac156daae153de8b56df62"
registries = "General"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.88.3+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "69ffb934a5c5b7e086a0b4fee3427db2556fba6e"
registries = "General"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.16+0"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "9d9531a9cb63a9edc33836414e82a07e81710de2"
registries = "General"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "100.14004.0+0"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
registries = "General"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
registries = "General"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "0ee181ec08df7d7c911901ea38baf16f755114dc"
registries = "General"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "1.0.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "b2d91fe939cae05960e760110b328288867b5758"
registries = "General"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.6"

[[deps.JLFzf]]
deps = ["REPL", "Random", "fzf_jll"]
git-tree-sha1 = "82f7acdc599b65e0f8ccd270ffa1467c21cb647b"
registries = "General"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.11"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7204148362dafe5fe6a273f855b8ccbe4df8173e"
registries = "General"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.8.0"

[[deps.JSON]]
deps = ["Dates", "Logging", "Parsers", "PrecompileTools", "StructUtils", "UUIDs", "Unicode"]
git-tree-sha1 = "88352712893ec50bee3680605891eaf0e9ed6368"
registries = "General"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "1.8.0"

    [deps.JSON.extensions]
    JSONArrowExt = ["ArrowTypes"]

    [deps.JSON.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "037babc10853eeb8e585418922246cb97b8e5b74"
registries = "General"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.2.0+1"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "059aabebaa7c82ccb853dd4a0ee9d17796f7e1bc"
registries = "General"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.3+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "39bca05343661c347aae0bca57a5994a0bf4f08d"
registries = "General"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.2.0+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e5b100780d4d30d63b4618d7930d48af409c1772"
registries = "General"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "23.1.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f88f3ccef05a6a72a0cf0ed417c8fd68530f4ab2"
registries = "General"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.1"

[[deps.Latexify]]
deps = ["Format", "Ghostscript_jll", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "df7566479bd64f20bd16b09960145e70160ffb3b"
registries = "General"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.12"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"
    TectonicExt = "tectonic_jll"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"
    tectonic_jll = "d7dd28d6-a5e6-559c-9131-7eb760cdacc5"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "1.0.0"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "Zlib_jll", "Zstd_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.18.0+1"

[[deps.LibGit2]]
deps = ["LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "PCRE2_jll", "Zlib_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.9.1+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl", "OpenSSL_jll", "Zlib_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.103+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c8da7e6a91781c41a863611c7e966098d783c57a"
registries = "General"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.4.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "d36c21b9e7c172a44a10484125024495e2625ac0"
registries = "General"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.1+1"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "be484f5c92fad0bd8acfef35fe017900b0b73809"
registries = "General"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.18.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cc3ad4faf30015a3e8094c9b5b7f19e85bdf2386"
registries = "General"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.42.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "aebd334d06cee9f24cea70bd19a39749daf73881"
registries = "General"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.3+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d620582b1f0cbe2c72dd1d5bd195a9ce73370ab1"
registries = "General"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.42.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.13.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "bba2d9aa057d8f126415de240573e86a8f39d2a1"
registries = "General"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "1.0.1"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
registries = "General"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.MacroTools]]
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
registries = "General"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.Measures]]
git-tree-sha1 = "b513cedd20d9c914783d8ad83d08120702bf2c77"
registries = "General"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.3"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
registries = "General"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2026.8.13"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "dbd2e8cd2c1c27f0b584f6661b4309609c5a685e"
registries = "General"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.4"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6aa4566bb7ae78498a5e68943863fa8b5231b59"
registries = "General"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.6+0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.30+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.7+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.6+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e2bb57a313a74b8104064b7efd01406c0a50d2ff"
registries = "General"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.6.1+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "94ba93778373a53bfd5a0caaf7d809c445292ff4"
registries = "General"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.2"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.46.0+0"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1912a9f1b9ca55005b03ba075f8e19993583e237"
registries = "General"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.58.2+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools"]
git-tree-sha1 = "663e8b48b789916221e0765393b289ca6c88f24e"
registries = "General"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "3.0.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "e4a6721aa89e62e5d4217c0b21bd714263779dda"
registries = "General"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.46.4+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "Zstd_jll", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.13.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "41031ef3a1be6f5bbbf3e8073f210556daeae5ca"
registries = "General"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.3.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Reexport", "Statistics"]
git-tree-sha1 = "f20e945b895d2009c6c28d8bbf40a5cd846f7c2f"
registries = "General"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.5.0"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "TOML", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "83bd514e8ff16b5858ac54c53fa0bcf6002a3b00"
registries = "General"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.41.7"

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Downloads", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "db8a06ef983af758d285665a0398703eb5bc1d66"
registries = "General"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.75"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "edbeefc7a4889f528644251bdb5fc9ab5348bc2c"
registries = "General"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.3.4"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "8b770b60760d4451834fe79dd483e318eee709c4"
registries = "General"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.5.2"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.PtrArrays]]
git-tree-sha1 = "4fbbafbc6251b883f4d2705356f3641f3652a7fe"
registries = "General"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.4.0"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "144895f6166994730ee7ff8113b981fc360638f1"
registries = "General"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.10.2+2"

[[deps.Qt6Declarative_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6ShaderTools_jll", "Qt6Svg_jll"]
git-tree-sha1 = "159d253ab126d5b29230cf53521899bea4ef4648"
registries = "General"
uuid = "629bc702-f1f5-5709-abd5-49b8460ea067"
version = "6.10.2+2"

[[deps.Qt6ShaderTools_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "4d85eedf69d875982c46643f6b4f66919d7e157b"
registries = "General"
uuid = "ce943373-25bb-56aa-8eca-768745ed7b5a"
version = "6.10.2+1"

[[deps.Qt6Svg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "81587ff5ff25a4e1115ce191e36285ede0334c9d"
registries = "General"
uuid = "6de9746b-f93d-5813-b365-ba18ad4a9cf3"
version = "6.10.2+0"

[[deps.Qt6Wayland_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6Declarative_jll"]
git-tree-sha1 = "672c938b4b4e3e0169a07a5f227029d4905456f2"
registries = "General"
uuid = "e99dba38-086e-5de3-a5b1-6e4c66e897c3"
version = "6.10.2+1"

[[deps.REPL]]
deps = ["Base64", "Dates", "FileWatching", "InteractiveUtils", "JuliaSyntaxHighlighting", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
registries = "General"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
registries = "General"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
registries = "General"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
registries = "General"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
registries = "General"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "1.0.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "9b81b8393e50b7d4e6d0a9f14e192294d3b7c109"
registries = "General"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.3.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Showoff]]
deps = ["Dates"]
git-tree-sha1 = "8238217340ad0aaabe11afe39c1098b5bc9f4c8e"
registries = "General"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.1.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "13cd91cc9be159e3f4d95b857fa2aa383b53772a"
registries = "General"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.3"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.13.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "e2b53ce13a53367e96601081e33d34746b571bad"
registries = "General"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.5"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "178ed29fd5b2a2cfc3bd31c13375ae925623ff36"
registries = "General"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.8.0"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "IrrationalConstants", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "adb9da019510162e67a4493fc235c23203d8b09e"
registries = "General"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.13"

[[deps.StructUtils]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "2d0fc55c61321ba245c47be599570d11bac50303"
registries = "General"
uuid = "ec057cc2-7a8d-4b58-b3b3-92acb9f63b42"
version = "2.8.5"

    [deps.StructUtils.extensions]
    StructUtilsMeasurementsExt = ["Measurements"]
    StructUtilsStaticArraysCoreExt = ["StaticArraysCore"]
    StructUtilsTablesExt = ["Tables"]

    [deps.StructUtils.weakdeps]
    Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tables = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.10.1+0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
registries = "General"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.Tricks]]
git-tree-sha1 = "311349fd1c93a31f783f977a71e8b062a57d4101"
registries = "General"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.13"

[[deps.URIs]]
git-tree-sha1 = "908fec9df6c5de98548ead82a468c95ccf6cd263"
registries = "General"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.7.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
registries = "General"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
registries = "General"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Vulkan_Loader_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXrandr_jll", "xkbcommon_jll"]
git-tree-sha1 = "2f0486047a07670caad3a81a075d2e518acc5c59"
registries = "General"
uuid = "a44049a8-05dd-5a78-86c9-5fde0876e88c"
version = "1.3.243+0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "96478df35bbc2f3e1e791bc7a3d0eeee559e60e9"
registries = "General"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.24.0+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e52eca002a11c30a858185efdfb15311e1c7a6bf"
registries = "General"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.8.4+0"

[[deps.Xorg_libICE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a3ea76ee3f4facd7a64684f9af25310825ee3668"
registries = "General"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.1.2+0"

[[deps.Xorg_libSM_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libICE_jll"]
git-tree-sha1 = "9c7ad99c629a44f81e7799eb05ec2746abb5d588"
registries = "General"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.6+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "808090ede1d41644447dd5cbafced4731c56bd2f"
registries = "General"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.13+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aa1261ebbac3ccc8d16558ae6799524c450ed16b"
registries = "General"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.13+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "6c74ca84bbabc18c4547014765d194ff0b4dc9da"
registries = "General"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.4+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "52858d64353db33a56e13c341d7bf44cd0d7b309"
registries = "General"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.6+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "1a4a26870bf1e5d26cd585e38038d399d7e65706"
registries = "General"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.8+0"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "75e00946e43621e09d431d9b95818ee751e6b2ef"
registries = "General"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "6.0.2+0"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "dcb316b3ce0941f195537dda56bea4517fcd3ff5"
registries = "General"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.8.4+0"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll"]
git-tree-sha1 = "0ba01bc7396896a4ace8aab67db31403c71628f4"
registries = "General"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.7+0"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "6c174ef70c96c76f4c3f4d3cfbe09d018bcd1b53"
registries = "General"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.6+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "7ed9347888fac59a618302ee38216dd0379c480d"
registries = "General"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.12+0"

[[deps.Xorg_libpciaccess_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "58972370b81423fc546c56a60ed1a009450177c3"
registries = "General"
uuid = "a65dc6b1-eb27-53a1-bb3e-dea574b5389e"
version = "0.19.0+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXau_jll", "Xorg_libXdmcp_jll"]
git-tree-sha1 = "bfcaf7ec088eaba362093393fe11aa141fa15422"
registries = "General"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.1+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "ed756a03e95fff88d8f738ebc2849431bdd4fd1a"
registries = "General"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.2.0+0"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "9750dc53819eba4e9a20be42349a6d3b86c7cdf8"
registries = "General"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.6+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "f4fc02e384b74418679983a97385644b67e1263b"
registries = "General"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll"]
git-tree-sha1 = "68da27247e7d8d8dafd1fcf0c3654ad6506f5f97"
registries = "General"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "44ec54b0e2acd408b0fb361e1e9244c60c9c3dd4"
registries = "General"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "5b0263b6d080716a02544c55fdff2c8d7f9a16a0"
registries = "General"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.10+0"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "f233c83cad1fa0e70b7771e0e21b061a116f2763"
registries = "General"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.2+0"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "801a858fc9fb90c11ffddee1801bb06a738bda9b"
registries = "General"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.7+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "2e59214e017a55cb87474a00fa76035c82ac0e17"
registries = "General"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.47.0+2"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a63799ff68005991f9d9491b6e95bd3478d783cb"
registries = "General"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.6.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.3.1+2"

[[deps.Zstd_jll]]
deps = ["CompilerSupportLibraries_jll", "Libdl"]
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+1"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c3b0e6196d50eab0c5ed34021aaa0bb463489510"
registries = "General"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.14+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6a34e0e0960190ac2a4363a1bd003504772d631"
registries = "General"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.61.1+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "ef17c47d22224aaecc76e597ab21a072e025cf7b"
registries = "General"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.14.1+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "cb007192783c56d8249db4cf0e3495001edfe414"
registries = "General"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.17.5+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.libdecor_jll]]
deps = ["Artifacts", "Dbus_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pango_jll", "Wayland_jll", "xkbcommon_jll"]
git-tree-sha1 = "9bf7903af251d2050b467f76bdbe57ce541f7f4f"
registries = "General"
uuid = "1183f4f0-6f2a-5f1a-908b-139f9cdfea6f"
version = "0.2.2+0"

[[deps.libdrm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libpciaccess_jll"]
git-tree-sha1 = "28e57478e8a160d346a19c28b3fffb9273bcc9c2"
registries = "General"
uuid = "8e53e030-5e6c-5a89-a30b-be5b7263a166"
version = "2.4.134+0"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "56d643b57b188d30cccc25e331d416d3d358e557"
registries = "General"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.13.4+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "646634dd19587a56ee2f1199563ec056c5f228df"
registries = "General"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.4+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "91d05d7f4a9f67205bd6cf395e488009fe85b499"
registries = "General"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.28.1+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "e51150d5ab85cee6fc36726850f0e627ad2e4aba"
registries = "General"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.58+0"

[[deps.libva_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll", "Xorg_libXfixes_jll", "libdrm_jll"]
git-tree-sha1 = "7dbf96baae3310fe2fa0df0ccbb3c6288d5816c9"
registries = "General"
uuid = "9a156e7d-b971-5f62-b2c9-67348b8fb97c"
version = "2.23.0+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll"]
git-tree-sha1 = "11e1772e7f3cc987e9d3de991dd4f6b2602663a5"
registries = "General"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.8+0"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b4d631fd51f2e9cdd93724ae25b2efc198b059b1"
registries = "General"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.7+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.67.1+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.8.2+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "14cc7083fc6dff3cc44f2bc435ee96d06ed79aa7"
registries = "General"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "10164.0.1+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e7b67590c14d487e734dcb925924c5dc43ec85f3"
registries = "General"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "4.1.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "a1fc6507a40bf504527d0d4067d718f8e179b2b8"
registries = "General"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.13.0+0"

[registries.General]
url = "https://github.com/JuliaRegistries/General.git"
uuid = "23338594-aafe-5451-b93e-139f81909106"
"""

# ╔═╡ Cell order:
# ╟─11111111-1111-4111-8111-111111111111
# ╟─66666666-6666-4666-8666-666666666666
# ╟─22222222-2222-4222-8222-222222222222
# ╠═42244444-4444-4444-8444-444444444444
# ╠═9bb36982-4d4f-4446-a7b7-8904e4daea7e
# ╠═618d7424-efa6-4bbd-a18f-3ecf3320283a 
# ╠═44444444-4444-4444-8444-444444444444
# ╠═7e508426-a228-4962-8a2a-bf456c1c37c9
# ╠═a61ff7cf-49f0-4a45-88a4-9f4cab7da31d
# ╠═b61ff7cf-49f0-4a45-88a4-9f4cab7da31d
# ╠═33333333-3333-5333-8333-333333333333
# ╠═c61ff7cf-49f0-4a45-88a4-9f4cab7da31d
# ╠═3d63c66c-b5dd-11f1-b766-338e58c22c81
# ╠═4d63c66c-b5dd-11f1-b766-338e58c22c81
# ╠═43333333-3333-5333-8333-333333333333
# ╠═53333333-3333-5333-8333-333333333333
# ╠═33777777-7777-4777-8777-777777777777
# ╠═77777777-7777-4777-8777-777777777777
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002

