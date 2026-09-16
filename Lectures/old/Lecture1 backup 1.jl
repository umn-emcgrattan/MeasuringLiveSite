### A Pluto.jl notebook ###
# v0.20.21

using PlutoUI

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

| Category | Value |
|:-----------------------------------------------|------:|
| **Gross domestic product** | 29,298 |
| &nbsp;&nbsp;Personal consumption expenditures | 19,896 |
| &nbsp;&nbsp;&nbsp;&nbsp;Services | 13,635 |
| &nbsp;&nbsp;&nbsp;&nbsp;Nondurable goods | 4,083 |
| &nbsp;&nbsp;&nbsp;&nbsp;Durable goods | 2,178 |
| &nbsp;&nbsp;Gross private domestic investment | 5,259 |
| &nbsp;&nbsp;&nbsp;&nbsp;Fixed investment | 5,206 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nonresidential | 4,023 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Intellectual property products | 1,604 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Equipment | 1,484 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Structures | 935 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Residential | 1,183 |
| &nbsp;&nbsp;&nbsp;&nbsp;Change in private inventories | 54 |
| &nbsp;&nbsp;Net exports of goods and services | -899 |
| &nbsp;&nbsp;&nbsp;&nbsp;Exports | 3,215 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Goods | 2,058 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Services | 1,157 |
| &nbsp;&nbsp;&nbsp;&nbsp;Imports | 4,114 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Goods | 3,267 |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Services | 847 |
"""
