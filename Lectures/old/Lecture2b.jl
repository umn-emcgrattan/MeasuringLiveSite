### A Pluto.jl notebook ###
# v0.20.21

using Markdown
using InteractiveUtils

# ╔═╡ b1111111-1111-1111-1111-111111111111
md"# Comparing Data and Theory

In this course, we will develop tools that allow us
to compare predictions of theory to comparable statistics
in data. It is important to keep in mind that statistics
from data should not be deemed “facts,”
but instead should be considered responses or reports of some sort
from a particular set of people,
gathered at a particular time,
and for a particular purpose.
We will try to collect the same sorts of statistics
and use inference to identify key parameters in our
models in order to ready them for
quantitative use in research and policy analysis.
There will be much discussion of the sources
of our economic data and their main uses.
For example, we will be interested to know if
the data was collected for administrative purposes
(say, for tax collections or population censuses) or for research
and policy analysis (say, from household surveys).

In today's lecture, I will start with our national accounts
compiled by the Bureau of Economic Analysis (BEA)
as it will be most relevant for what we do next.
I will briefly describe the main table that is referred to
as the national income and product account (NIPA)
that relates gross domestic income and gross domestic product.
I will then compare “data” drawn from a simple model
economy to the NIPA table.

## NIPA Tables

We will start with NIPA data for the latest year available
downloaded from Table 1.1.5 (Gross Domestic Product)
and Table 1.10 (Gross Domestic Income),
both reported in billions of dollars in Table 1.
U.S. GDP and components are summarized in the upper panel
while GDI is in the lower panel.

The main component of GDP is personal consumption expenditures,
at a roughly two-thirds share. The main consumption category
is now services at roughly two-thirds share. The remaining categories
are nondurable and durable goods.
Gross private domestic investment is next and includes nonresidential
and residential fixed investment. The main category of nonresidential
investment is a relatively new one: intellectual property products.
This category was introduced in 2013 when the BEA conducted a
comprehensive revision to include estimated investment in
research and development, entertainment, literary, and artistic
originals. They added these estimates to investment in software,
which had been added in 1999.
"

# ╔═╡ b2222222-2222-2222-2222-222222222222
md"""
**Table: GDP and GDI, 2024 (\$ Billions)**
"""

# ╔═╡ b3333333-3333-3333-3333-333333333333
html"""
<table>
<tr><th style="text-align:left;">Category</th><th style="text-align:right;">Value</th></tr>
<tr><td><b>Gross domestic product</b></td><td align="right">29,298</td></tr>
<tr><td style="padding-left:20px;">Personal consumption expenditures</td><td align="right">19,896</td></tr>
<tr><td style="padding-left:40px;">Services</td><td align="right">13,635</td></tr>
<tr><td style="padding-left:40px;">Nondurable goods</td><td align="right">4,083</td></tr>
<tr><td style="padding-left:40px;">Durable goods</td><td align="right">2,178</td></tr>
<tr><td style="padding-left:20px;">Gross private domestic investment</td><td align="right">5,259</td></tr>
<tr><td style="padding-left:40px;">Fixed investment</td><td align="right">5,206</td></tr>
<tr><td style="padding-left:60px;">Nonresidential</td><td align="right">4,023</td></tr>
<tr><td style="padding-left:80px;">Intellectual property products</td><td align="right">1,604</td></tr>
<tr><td style="padding-left:80px;">Equipment</td><td align="right">1,484</td></tr>
<tr><td style="padding-left:80px;">Structures</td><td align="right">935</td></tr>
<tr><td style="padding-left:60px;">Residential</td><td align="right">1,183</td></tr>
<tr><td style="padding-left:40px;">Change in private inventories</td><td align="right">54</td></tr>
<tr><td style="padding-left:20px;">Net exports of goods and services</td><td align="right">-899</td></tr>
<tr><td style="padding-left:40px;">Exports</td><td align="right">3,215</td></tr>
<tr><td style="padding-left:60px;">Goods</td><td align="right">2,058</td></tr>
<tr><td style="padding-left:60px;">Services</td><td align="right">1,157</td></tr>
<tr><td style="padding-left:40px;">Imports</td><td align="right">4,114</td></tr>
<tr><td style="padding-left:60px;">Goods</td><td align="right">3,267</td></tr>
<tr><td style="padding-left:60px;">Services</td><td align="right">847</td></tr>
<tr><td><b>Gross domestic income</b></td><td align="right">29,002</td></tr>
<tr><td style="padding-left:20px;">Compensation of employees</td><td align="right">15,049</td></tr>
<tr><td style="padding-left:40px;">Wages and salaries</td><td align="right">12,410</td></tr>
<tr><td style="padding-left:40px;">Supplements to wages and salaries</td><td align="right">2,639</td></tr>
<tr><td style="padding-left:20px;">Taxes on production and imports</td><td align="right">1,955</td></tr>
<tr><td style="padding-left:20px;">Less: Subsidies</td><td align="right">94</td></tr>
<tr><td style="padding-left:20px;">Net operating surplus</td><td align="right">7,295</td></tr>
<tr><td style="padding-left:40px;">Net interest</td><td align="right">611</td></tr>
<tr><td style="padding-left:40px;">Business current transfer payments</td><td align="right">286</td></tr>
<tr><td style="padding-left:40px;">Proprietors' income</td><td align="right">2,023</td></tr>
<tr><td style="padding-left:40px;">Rental income</td><td align="right">1,078</td></tr>
<tr><td style="padding-left:40px;">Corporate profits</td><td align="right">3,344</td></tr>
<tr><td style="padding-left:60px;">Taxes on corporate income</td><td align="right">680</td></tr>
<tr><td style="padding-left:60px;">Net dividends</td><td align="right">1,880</td></tr>
<tr><td style="padding-left:60px;">Undistributed profits</td><td align="right">784</td></tr>
<tr><td style="padding-left:40px;">Current surplus of government enterprises</td><td align="right">-48</td></tr>
<tr><td style="padding-left:20px;">Consumption of fixed capital</td><td align="right">4,797</td></tr>
<tr><td><b>Statistical discrepancy</b></td><td align="right">296</td></tr>
</table>
"""

# ╔═╡ b4444444-4444-4444-4444-444444444444
md"""
## Model Economy
"""

# ╔═╡ b5555555-5555-5555-5555-555555555555
md"
Consider the simplest version of a model that we could
match up to these NIPA data---where, by simple, I mean one
that does not include taxes, different types of capital incomes, or trade.
(Later, we will introduce these factors and repeat the exercise
of comparing the data and model).
Assume that households choose paths
for per capita consumption $c_t$ and leisure $\ell_t$ to  solve:

$$\begin{align*}
\max_{\{c_t,\ell_t,s_{t+1}\}}
 E_0 \sum_{t=0}^\infty & \beta^t U(c_t,\ell_t) N_t\\
{\rm subject\ to } &
\sum_{t=0}^\infty p_t\{c_{t}+v_{t}(s_{t+1}-s_{t})\}
     \leq \sum_{t=0}^\infty p_{t}\{d_{t}s_{t}+w_{t}h_{t}+\kappa_t\}
\end{align*}$$

where  
$N_t=(1+\gamma_n)^t$ is the size of the population,
$v_t$ is the price of firm shares,
$s_t$ is the quantity of shares held,
$d_t$ is the amount of per capita distributions paid per share to the shareholders
(which in this case is our households),
$w_t$ is the wage rate paid to labor,
$h_t=1-\ell_t$, and
$\kappa_t$ is government transfers less lump-sum taxes.
The price used when summing expenditures and incomes is
$p_t$, which is the Arrow-Debreu price (and equal to the household
marginal utility in equilibrium and the rate at which firms
discount future distributions).

Businesses maximize the present value of aggregate
distributions $D_t=N_td_ts_t$
to households:

$$\begin{align*}
E_0 \sum_{t=0}^\infty\, & p_t D_t \\
{\rm s.t.}\ \  &  K_{t+1} = (1-\delta)K_t + X_t\\
               &  D_t = F(K_t,Z_t H_t)-w_tH_t-X_t
\end{align*}$$

where, again,
$p_t$, is the discount factor for the firm shareholders,
$K_t$ is the capital stock,
$X_t$ is gross investment,
$H_t$ is the total labor input, and
$Z_t=z_t (1+\gamma_z)^t$ is the technology parameter with

$$\begin{equation}
 \log z_{t+1} = \rho \log z_t +\epsilon_{t+1}
\end{equation}$$

and $\epsilon\sim N(0,\sigma^2)$.

In the aggregate, we compare business output to
the sum of private and public consumption and investment.
Let $Y_t=F(K_t,Z_tH_t)$ be the total business output.
If we assume this output is produced by both private and public
enterprises, we can compare this to gross domestic product.
Let $C_t$ be the sum of private consumption of households,
namely, $C_t=N_tc_t$. 
Because I have not modeled durable consumption like
motor vehicles or home furniture purchased by households, 
the $C_t$ in this
model would be comparable to NIPA nondurable goods and services.
I have also abstracted at this point from taxes, including those
on retail sales, but the NIPA records transactions at purchaser's
prices so they are inclusive of taxes on consumption.
Thus, there is another inconsistency between model and data,
which will be rectified when we include taxation.
To consumption, we add investment by businesses $X_t$
and government consumption expenditures and gross investment,
which we denote by $G_t$, to get $Y_t$.

To make sure we have it right, we add up the income side.
There are payments to labor $w_tH_t$, which are comparable to
NIPA compensation of employees. Payments to capital are
distributions to shareholders, which we denote by $D_t$, and
reinvestments in the firm, which are the sum of net investment in capital
$K_{t+1}-K_t$ and consumption of fixed capital $\delta K_t$.
If we consider the non-tax and non-subsidy items under NIPA net operating surplus,
we can include corporate net dividends, proprietors' income, net interest,
and rental income with distributed payments $D_t$ and
undistributed corporate and noncorporate profits with $K_{t+1}-K_t$.
The remaining category is consumption of fixed capital $\delta K_t$.
Adding it up, we have

$$\begin{align*}
Y_t &= w_tH_t + D_t + K_{t+1}-K_t+\delta K_t\\
    &= w_tH_t + F(K_t,Z_tH_t )-w_tH_t-X_t  + K_{t+1}-K_t+\delta K_t\\
    &= F(K_t,Z_tH_t ),
\end{align*}$$

which checks out.
We can also add up the per-period household budgets, assuming a fixed total
supply of shares equal to 1 (without loss of generality):

$$\begin{align}
C_t &= D_t + w_t H_t +N_t\kappa_t\\
    &= Y_t - X_t - G_t,
\end{align}$$

which holds as long as total lump-sum taxes net of transfers $-N_t \kappa_t$
is equal to total government spending $G_t$.
"

# ╔═╡ b6666666-6666-6666-6666-666666666666
md"""
## Computing Equilibria
"""

# ╔═╡ b7777777-7777-7777-7777-777777777777
md"
The first lesson in computing equilibria is learning how to set
up one's problem so that computation is as easy as possible.
In the model above, we have mulitple optimization problems 
and require price functions that economic agents are assumed to 
take as given.  But I have purposely chosen an easy first
model because I abstracted from taxation and other distortions.
The allocation in this model is efficient and can be
found by maximizing preferences of the stand-in household 
subject to the aggregate resource constraint.
More specifically, we can compute the allocations using
the following:

$$\begin{align}
\max_{\{c_t,\ell_t,x_t\}}
E_0 \sum_{t=0}^\infty & \beta^t U(c_t,\ell_t) N_t\\
{\rm subject\ to }\ \ 
& c_t + x_t = F(k_t,(1+\gamma_z)^t z_t h_t)\\
& N_{t+1} k_{t+1} = [(1-\delta) k_t+x_t] N_t\\
& \log z_t = \rho \log z_{t-1} + \epsilon_t, \epsilon\sim N(0,\sigma^2)\\
& h_t + \ell_t = 1\\
& c_t, x_t \geq 0 \quad {\rm in\ all\ states}.
\end{align}$$

Notice that here we do not get into discussions
about transactions and ownership.  Instead, we
solve for allocations and then use the solution
to construct dividends and firm valuations.

Let's consider three methods to solve this.

*Method 1.* The first method is a ``brute force'' method
to compute a value function that satisfies the
following Bellman equation:

$$\begin{equation}
V(\hat k_t,z_t) = \max_{\hat c_t,h_t,\hat k_{t+1}} 
  \{ U(\hat c_t,1-h_t) + \beta(1+\gamma_n) E_t V(\hat k_{t+1},z_{t+1} ),
\end{equation}$$

where the maximization is subject to

$$\begin{align}
 \hat c_t + \hat x_t &= \hat k_t^\theta (z_th_t)^{1-\theta}\\
 \hat k_{t+1} &= [(1-\delta)\hat k_t+\hat x_t]/[(1+\gamma_z)(1+\gamma_n)]\\
 \log z_{t+1} &= \rho \log z_t + \epsilon_{t+1}
\end{align}$$

Lower-case letters are used to indicate that the variable 
is per capita and the hat further indicates that it 
has been divided by the growth in technology (e.g, 
$k_t =K_t/N_t$, $\hat k_t=k_t/(1+\gamma_z)^t$). Here, I am 
assuming that the choice of utility function is consistent
with balanced growth so that I can replace $c_t$ by $\hat c_t$
without consequence.

Consider two ways to deal with the expectation 
operator.  The first is to treat $z_t$ as a continuous state variable
and use a quadrature method to compute the integral related
to the expectation of $z$ next period:

$$\begin{align}
  E [V(\hat k',z')| z] 
        &   = \int V(\hat k',\rho z+\epsilon) f(\epsilon) d\epsilon\\
        &   \approx \sum_i \omega_i V(\hat k',\rho z+\epsilon_i) f(\epsilon_i)
\end{align}$$

where $f(\cdot)$ is the density function of a normally distributed random
variable. The second is to treat $z_t$ as a Markov chain and
replace the expectation with a sum:

$$\begin{equation}
  E [V(\hat k',z_j)| z_i] \approx \sum_j {\rm prob}(z_j|z_i) V(\hat k',z_j)
\end{equation}$$

where $z_i$ and $z_j$ are the exogenous states today and tomorrow,
respectively.

An easy (but extremely tedious) way to compute
an approximate solution for the value
function and policy functions is to guess an initial function $V$
(say, a piecewise linear or bi-linear function over a grid for the 
states), solve the right hand side maximization problem for all possible
states $(\hat k,z)$---say, by checking all possible triplets of
$\hat c,h,\hat k'$ until a maximum value is found---and then updating
the guess for $V$. 

*Method 2.* We turn next to a near-linear method that relies importantly on
mapping our non-linear problem to a standard LQ problem with linear constraints and a
quadratic objective.  Before doing the mapping, consider a general maximization problem
with state vector $X$ and control vector $u$:

$$\begin{align}
    \max_{\{u_t\}_{t=0}^{\infty}}{\rm E} & \left[
            \sum_{t=0}^{\infty} \beta^t r(X_t,u_t)\ |\, X_0\, \right]\\
   {\rm subject\ to\ \ \ } & X_{t+1}=g(X_t,u_t,\epsilon_{t+1})\\
                           & X_0\ {\rm given}.
\end{align}$$

Here, $r$ is the objective
function which is known, $g$ governs the evolution of the state vector
and is also known, and $\epsilon$ is a vector of shocks affecting this evolution
which we'll assume to be iid.
During class, we considered a nested version of Homework 1
with inelastic labor and full depreciation of capital so that we
could get very concrete about what we are trying to do.

We can approximate the nonlinear prototype problem with a near-linear related
problem:

$$\begin{align}
    \max_{\{u_t\}_{t=0}^{\infty}}{\rm E}_0 &\sum_{t=0}^{\infty} 
           \beta^t (X_t'Q X_t+u_t'R u_t +2 X_t' W u_t)\\
   {\rm subject\ to\ \ \ } & X_{t+1}=A X_t+B u_t+C\epsilon_{t+1}\\
                           & X_0\ {\rm given}
\eqref{LQ control problem}
\end{align}$$

where

$$\begin{align}
    r(X_t,u_t)                &\simeq X_t'Q X_t+u_t'R u_t +2 X_t' W u_t\\
    g(X_t,u_t,\epsilon_{t+1}) &\simeq A X_t +B u_t + C\epsilon_{t+1},
\label{r and g}
\end{align}$$

with $Q$ and $R$ symmetric.
That is, we solve a problem with a quadratic objective function and
linear constraints.  Note that implicit in our formulation of \ref{LQ control
problem} are the assumptions that $X_t$ is contained in the agents' 
information sets at time $t$ and that the agents know the objective function 
and transition functions for all variables.

To obtain the functions in \ref{r and g}, we take a second
and first-order Taylor expansion of the corresponding nonlinear functions 
around the steady state of the system.  Thus, when evaluated at
the stationary point, the original and approximated functions have the
same value.

To find the steady state of the system, we first set the disturbance term
$\epsilon_t$ to its unconditional mean. Without loss of generality, assume
the mean is zero.  We then find the first order conditions of the resulting
nonstochastic version of the model: 

$$\begin{align}
   \max_{\{u_t\}_{t=0}^{\infty} } 
          &\sum_{t=0}^{\infty}\beta^t r(X_t,u_t)\\
              {\rm subject\ to\ \ \ } & X_{t+1}=g(X_t,u_t,0)
\label{nonstochastic problem}
\end{align}$$

and $X_0$ given.  Formulating the Lagrangian:

$$\begin{equation}
{\cal L}=\sum_{t=0}^{\infty}\beta^t\{ r(X_t,u_t)-\lambda_{t+1}'
                            (X_{t+1}-g(X_t,u_t,0))\}
\label{lagrangian}
\end{equation}$$

and taking derivatives with respect to $u_t$ and $X_{t+1}$,
we obtain the following first-order conditions

$$\begin{align}
   {\partial r(X_t,u_t)\over \partial u_t} +{\partial 
           g(X_t,u_t,0)\over \partial u_t}'\lambda_{t+1} &=0\\
   \beta {\partial r(X_{t+1},u_{t+1})\over \partial X_{t+1}} 
            -\lambda_{t+1}+ \beta {\partial g(X_{t+1},u_{t+1},0)
                                   \over \partial X_{t+1}}'\lambda_{t+2}
                                                         &=0
\label{focs}
\end{align}$$

for $t\geq 0$, where $\{\lambda_t\}$ is a sequence of Lagrange multipliers.
Eliminating time subscripts from \ref{focs} and the constraint in 
\ref{nonstochastic problem},
we then get the following set of nonlinear equations:

$$\begin{align}
           {\partial r(X,u)\over \partial u} +{\partial 
                g(X,u,0)\over \partial u}'\lambda &=0\\
             \beta {\partial r(X,u)\over \partial X} -\lambda+
             \beta {\partial g(X,u,0)\over \partial X}'\lambda&=0\\
              X-g(X,u,0)&=0
\label{nonlinear eqns}
\end{align}$$

This is a set of $2m+n$ equations with $2m+n$ unknowns, $X,u,\lambda$.
The fixed point of this system is the steady state, say ${\bar X},{\bar 
u},{\bar \lambda}$, around which we take first and second-order Taylor
expansions of $g$ and $r$.  Thus, we have the problem given by 
\ref{LQ control problem}.

Thus far, we have derived the first order conditions for the original
nonlinear problem that imply a set of equations for finding the
steady state (or more precisely, the balanced growth path).
We take a second order Taylor expansion of the objective function
($r(X,u)$) around the steady state to get matrices $Q$, $R$, and
$W$.  We take a first-order Taylor expansion of the constraints
($g(X,u,\epsilon)$) around the steady state to get $A$, $B$, $C$.

Next, we need to put some conditions on these matrices to
ensure that the optimal solution to our problem yields a
 stable system (and that we are maximizing, not minimizing).
The relevant conditions are usually stated in terms of a problem
with $\beta=1$ and $W=0$.  We can reformulate our problem 
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
                        & \tilde F + R^{-1}W'.
\label{solution}
\end{align}$$

The matrix $P$ in \ref{solution} is the steady-state solution 
to the matrix Riccati difference equation 

$$\begin{align}
   P_t&=Q+\beta A' P_{t+1} A -(\beta A' P_{t+1} B + W)
          (R+\beta B' P_{t+1} B)^{-1} (\beta B' P_{t+1} A+W')\\
      &={\tilde Q}+{\tilde A}' P_{t+1} {\tilde A} -{\tilde A}' P_{t+1} 
                   {\tilde B} (R+{\tilde B}' P_{t+1} {\tilde B})^{-1}
                     {\tilde B}' P_{t+1} {\tilde A}
\label{riccati}
\end{align}$$

\noindent as $t\rightarrow -\infty$, with terminal condition $P_T\leq 0$.

There have been many algorithms developed for the solution of the 
discrete-time Riccati equation. 
In all cases, we take 
as given the matrices $A$, $B$, $Q$, $R$, $W$ and scalar $\beta$
(or equivalently ${\tilde A}$, ${\tilde B}$, ${\tilde Q}$, and $R$),
tolerance criteria $\gamma_1$ and $\gamma_2$, and 
a matrix norm $\Vert\cdot\Vert$.
The simplest method is simply direct iteration.
To do this, set an initial symmetric 
Riccati matrix, $P^0\leq 0$. 
\begin{itemize}
\item[a] At iteration $n$, we compute $P^{n+1}$ and ${\tilde F}^n$ to be
\begin{align}
P^{n+1}&={\tilde Q}+ {\tilde A}' P^n {\tilde A}-{\tilde A}'P^n {\tilde B} 
(R+{\tilde B}'P^n {\tilde B})^{-1} {\tilde B}'P^n {\tilde A}\\
{\tilde F}^n &= (R+{\tilde B}' P^n {\tilde B})^{-1} {\tilde B}' P^n {\tilde A}
\end{align}
\item[b]
If $\Vert P^{n+1} -P^n\Vert< \gamma_1 \Vert P^n\Vert$ and
$\Vert {\tilde F}^{n+1} -{\tilde F}^n\Vert< \gamma_2 \Vert 
{\tilde F}^n\Vert$, go to (c);
otherwise, increase $n$ by one and return to (a).
\item[c] Set $F={\tilde F}^n+R^{-1}W'$, $P=P^n$.
\end{itemize}

With a steady-state solution to the Riccati matrix, we can use \ref{solution}
to compute $F$ and the law of motion for the state variables:

$$\begin{equation}
   X_{t+1}=(A-BF) X_t + C\epsilon_{t+1}.
\label{law of motion}
\end{equation}$$

Furthermore, given an initial condition for the states, $X_0$, and a 
realization of the shocks, $\epsilon_t,\ t\geq0$, we can generate time-series
for $X_t$ via \ref{law of motion} 
and $u_t$ via \ref{solution}. 

*Method 3.* We next use the insights of Vaughan (1970) to 
exploit certain properties of the first-order conditions of the
LQ problem defined above. 
Vaughan assumes no
discounting or cross-product terms, so we'll map the variables
and coefficients to $\tilde X$, $\tilde u$, $\tilde A$, $\tilde B$, and
$\tilde Q$ as shown earlier. Also note that because the solution
does not depend on the variances and covariances of $\epsilon$,
we can abstract from the uncertainty for now.
Writing out the Lagrangian, we have

$$\begin{equation}
{\cal L}=\sum_{t=0}^{\infty}\{ \tilde X_t' \tilde Q \tilde X_t+
\tilde u_t' R \tilde u_t
-\lambda_{t+1}'(\tilde X_{t+1}-\tilde A \tilde X_t-\tilde B \tilde u_t)\}
\label{lagrangian2}
\end{equation}$$

Taking derivatives with respect to $\tilde u_t$, $\tilde X_{t+1}$,
and $\lambda_{t+1}$,
we obtain the following first-order conditions

$$\begin{align}
    2 R\tilde u_t +B' \lambda_{t+1}  &=0\\
    \tilde Q \tilde X_{t+1} -\lambda_{t+1} +  \tilde A'\lambda_{t+2} &=0\\
    \tilde X_{t+1} - \tilde A \tilde X_t - \tilde B\tilde u_t &=0
\label{focs2}
\end{align}$$

for $t\geq 0$, where $\{\lambda_t\}$ is a sequence of Lagrange multipliers.
Eliminating $\tilde u_t$ and letting $\tilde \lambda_t=1/2 \lambda_t$,
we have:

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
costate in $t$. Then, instead of taking eigenvalues of
${\cal H}$ as above, we take generalized eigenvalues with the
pair (${\cal H}_1$, ${\cal H}_2)$.

Once we have 
a steady-state solution to the Riccati matrix, we can use the earlier
formula to compute $F$ and the law of motion for the state variables:

$$\begin{equation}
   X_{t+1}=(A-BF) X_t + C\epsilon_{t+1}
\label{law of motion}
\end{equation}$$

Furthermore, given an initial condition for the states, $X_0$, and a
realization of the shocks, $\epsilon_t,\ t\geq0$, we can generate time-series
for $X_t$ and $u_t$.
"


# ╔═╡ b8888888-8888-8888-8888-888888888888
md"""
## Checking our Codes
"""

# ╔═╡ b9999999-9999-9999-9999-999999999999
md"

Here, we discuss a problem that 
we can do by hand, namely:

$$\begin{align}
  \max_{\{c_t,k_{t+1}\}}  & E\,\sum_{t=0}^\infty \beta^t 
          \, \log(c_t) \\
\noalign{\medskip}
{\rm subj.\ to}\ \ 
 &  c_t+ k_{t+1} = z_t k_t^\theta \\
 & \log z_t=\rho\log z_{t-1}+\epsilon_t, \quad \epsilon\sim N(0,\sigma_\epsilon^2).
\end{align}$$

This problem has a known solution: consume
and save a constant fraction of output. 
So why put it on the computer?
The answer to this is because we can use
it to test our codes.  

Another check on the codes is a simple method of 
undetermined coefficients. This method involves linearizing
first order conditions, guessing the form of the solution with unknown
coefficients, substituting this into the first-order conditions,
and then figuring out what the coefficients have to be to make the
conditions hold exactly.
For the problem above, we have a first-order condition
of the form:

$$\begin{equation}
  {1\over z_t k_t^\theta-k_{t+1}} = {\beta \theta k_{t+1}^{\theta-1} \over z_{t+1}k_{t+1}^\theta-k_{t+2}}. 
$$\end{equation}

If we log-linearize this equation, it has the form:

$$\begin{equation}
  0= E_t\{ a_2 \hat k_{t+2} + a_1 \hat k_{t+1}+ a_0 \hat k_t + b_1 \hat z_{t+1} + b_0\hat z_t\}
\end{equation}$$

where $\hat k=\log(k/k_ss)$ and the coefficients are known functions
of parameters.
Guess a solution of the form:

$$\begin{equation}
  \hat k_{t+1} = \gamma_1 \hat k_t + \gamma_2\hat z_t,
\end{equation}$$

which we substitute into the linearized equation along with the equation for 
$\hat z_t$. From that, we get two equations in two unknows: $\gamma_1$, $\gamma_2$.

What are these equations? They are the coefficients on $\hat k_t$ and $\hat z_t$
after plugging in our guess and taking expectations.
Let's try doing this:

$$\begin{align*}
  0 &= E_t\{ a_2 \hat k_{t+2} + a_1 \hat k_{t+1}+ a_0 \hat k_t + b_1 \hat z_{t+1} + b_0\hat z_t\}  \\
    &= E_t\{ a_2 (\gamma_1\hat k_{t+1}+\gamma_2\hat z_{t+1})  + a_1 (\gamma_1 \hat k_t + \gamma_2\hat z_t)
           + a_0 \hat k_t + b_1 (\rho\hat z_t + \epsilon_{t+1})  + b_0\hat z_t\}\\
    &= E_t\{ a_2 (\gamma_1(\gamma_1\hat k_t+\gamma_2\hat z_t)+\gamma_2(\rho \hat z_t+\epsilon_{t+1}))  \\
    &\qquad\qquad + a_1 (\gamma_1 \hat k_t + \gamma_2\hat z_t)+ a_0 \hat k_t + b_1 (\rho\hat z_t + \epsilon_{t+1})  + b_0\hat z_t\}\\
    &= a_2 (\gamma_1(\gamma_1\hat k_t+\gamma_2\hat z_t)+\gamma_2\rho \hat z_t)  \\
    &\qquad\qquad + a_1 (\gamma_1 \hat k_t + \gamma_2\hat z_t)+ a_0 \hat k_t + b_1 \rho\hat z_t+ b_0\hat z_t\} \\
    &= (a_2 \gamma_1^2+ a_1 \gamma_1 + a_0) \hat k_t 
       +(a_2\gamma_1 \gamma_2 +a_2 \gamma_2\rho + a_1\gamma_2 + b_1 \rho + b_0)\hat z_t.
\end{align*}$$

For this to hold for any $\hat k_t$ and $\hat z_t$, the coefficients must be 0
and that gives us the two equations in two unknowns:

$$\begin{align}
   0 &= a_2 \gamma_1^2+ a_1 \gamma_1 + a_0 \cr
   0 &= a_2\gamma_1 \gamma_2 +a_2 \gamma_2\rho + a_1\gamma_2 + b_1 \rho + b_0.\cr
\end{align}$$

Notice that the first equation is a quadratic in $\gamma_1$. Try computing this
and compare the two roots: they should be recipricols of each other (if $\beta=1$).
Once we solve that equation, the second equation is is linear in $\gamma_2$.
We will see that the nature of this problem never changes. More generally,
the coefficients on endogenous terms will solve a quadratic equation and
the coefficients on the exogenous terms will solve a linear equation.
"



# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.6"
manifest_format = "2.0"
project_hash = "71853c6197a6a7f222db0f1978c7cb232b87c5ee"

[deps]
"""

# ╔═╡ Cell order:
# ╟─b1111111-1111-1111-1111-111111111111
# ╟─b2222222-2222-2222-2222-222222222222
# ╟─b3333333-3333-3333-3333-333333333333
# ╟─b4444444-4444-4444-4444-444444444444
# ╟─b5555555-5555-5555-5555-555555555555
# ╟─b6666666-6666-6666-6666-666666666666
# ╠═b7777777-7777-7777-7777-777777777777
# ╠═b8888888-8888-8888-8888-888888888888
# ╠═b9999999-9999-9999-9999-999999999999
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
