### A Pluto.jl notebook ###
# v0.20.21

using Markdown
using InteractiveUtils

# ╔═╡ 11111111-1111-1111-1111-111111111111
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
U.S.~GDP and components are summarized in the upper panel
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

# ╔═╡ 22222222-2222-2222-2222-222222222222
md"""

**Table: GDP and GDI, 2024 (\$ Billions)**
"""

# ╔═╡ 33333333-3333-3333-3333-333333333333
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

# ╔═╡ 44444444-4444-4444-4444-444444444444
md"""
## Model Economy 
"""

# ╔═╡ 55555555-5555-5555-5555-555555555555
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
which we  denote by $G_t$, to get $Y_t$.

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

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.5"
manifest_format = "2.0"
project_hash = "71853c6197a6a7f222db0f1978c7cb232b87c5ee"

[deps]
"""

# ╔═╡ Cell order:
# ╟─11111111-1111-1111-1111-111111111111
# ╟─22222222-2222-2222-2222-222222222222
# ╟─33333333-3333-3333-3333-333333333333
# ╟─44444444-4444-4444-4444-444444444444
# ╟─55555555-5555-5555-5555-555555555555
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
