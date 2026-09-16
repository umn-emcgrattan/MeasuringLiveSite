### A Pluto.jl notebook ###
# v0.20.21

using Markdown
using InteractiveUtils

# ╔═╡ 11111111-1111-1111-1111-111111111111
md"""
# Comparing Theory and Data

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
"""

# ╔═╡ 22222222-2222-2222-2222-222222222222
md"""
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
"""

# ╔═╡ 33333333-3333-3333-3333-333333333333
md"""

**Table: GDP and GDI, 2024 (\$ Billions)**
"""

# ╔═╡ 33333333-3333-3333-3333-333333333331
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


# ╔═╡ 08e50dde-b685-11f0-adeb-bdcc51244b10
md"# The Basic Neoclassical Growth Model

Our starting point is the basic growth model used in the study of business cycles. This model abstracts from intangible investment. In the standard one-sector growth model, given the initial capital stock $k_0$, the problem for the stand-in household is to choose consumption $c$, investment $x$, and hours $h$ to maximize

$$E\sum_{t=0}^{\infty} \beta^{t}U(c_{t},h_{t})N_{t},$$

subject to the constraints

$$\begin{align*}
c_t+x_t&=r_tk_t+w_th_t-\tau_{ct}c_t-\tau_{ht}w_th_t-\tau_{kt}k_t-\tau_{pt}(r_tk_t-\delta k_t-\tau_{kt}k_t)\\
    &{\quad}-\tau_{dt}\{r_tk_t-x_t-\tau_{kt}k_t-\tau_{pt}(r_tk_t-\delta k_t-\tau_{kt}k_t)\}\\
    k_{t+1} &= [(1-\delta)k_t+x_t]/(1-\eta),
\end{align*}$$

where variables are written in per capita terms and $N_{t} = N_{0}(1+\eta)^{t}$ is the population in $t$. Capital is paid rent $r_{t}$, and labor is paid wage $w_{t}$. Households discount future utility at rate $\beta$, and capital depreciates at rate $\delta$. Taxes are levied on consumption at rate $\tau_{c}$, on labor income at rate $\tau_{h}$, tangible capital at rate $\tau_{k}$, profits at rate $\tau_{p}$, and distributions at rate $\tau_{d}$.
"

# ╔═╡ 44444444-4444-4444-4444-444444444444
md"# Model Economy

Consider the simplest version of a model that we could
match up to these NIPA data---where, by simple, I mean one
that does not include taxes, different types of capital incomes, or trade.
(Later, we will introduce these factors and repeat the exercise
of comparing the data and model).
Assume that households choose paths
for per capita consumption $c_t$ and leisure $\ell_t$ to  solve:

$$\begin{align*}
Y &= C + I + G \\
C &= C(Y - T)
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
# ╟─33333333-3333-3333-3333-333333333331
# ╟─08e50dde-b685-11f0-adeb-bdcc51244b10
# ╟─44444444-4444-4444-4444-444444444444
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
