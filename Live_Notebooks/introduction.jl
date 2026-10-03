### A Pluto.jl notebook ###
# v0.20.21

using Markdown
using InteractiveUtils

# ╔═╡ 17396a4e-e404-4d3f-9fe6-39719dae2c72
begin
	using PlutoUI
	TableOfContents()
end

# ╔═╡ 1ba6aed6-65d2-421a-9e51-706e58f60e84
md"""
# Introduction
"""

# ╔═╡ dea0aea7-da34-4f40-a4e4-e1e481615187
html"""
<blockquote>
  <p style="font-size: 1.5em"><em>Our measurement and observation tools are becoming increasingly inadequate in the context of our changing economy.</em></p>
  <p style="text-align: right;"><a href="https://www.jstor.org/stable/2117968" target="_blank">- Zvi Griliches (1994)</a></p>
</blockquote>

"""

# ╔═╡ 38cf0000-b8ca-11f0-a3c7-098a3812f68c
md""" This website provides a set of lectures on measuring business productivity and value. Each lecture is designed to allow you to download the associated data and accompanying code, as well as make edits and upload your own data. **Please read through the entire introduction before proceeding to the lectures.**

# Setup

## 1 Installing Julia and Pluto.jl

Before proceeding to the lectures, install the following software and package(s) onto your device.

### 1.1 Julia

All code on this site is written in [Julia](https://julialang.org/), a high-performance, open-source dynamic programming language. If you are unfamiliar with the Julia language, several learning tools and resources for the Julia language exist, [including those focused on its applications in quantitative economics](https://julia.quantecon.org/intro.html).

You can install Julia directly through a terminal by enterting the following lines:

**Windows**
```
winget install julia -s msstore
```

**MacOS/Linux**
```
curl -fsSL https://install.julialang.org
```

You can also manually install Julia from its [download page](https://julialang.org/downloads/).

Once installed, you can open the Julia REPL (Read-Eval-Print Loop) by entering `julia` into the terminal.

### 1.2 Pluto.jl

Each page on this site is built using [Pluto.jl](https://plutojl.org/), a Julia package and programming environment designed for creating interactive and reproducible work. Each Pluto "notebook" exists as its own .jl file, and is easily exportable to PDF or HTML format in Pluto's built-in code editor. Once Julia is installed on your device, installing Pluto.jl is as simple as entering the following line into the Julia REPL: 

```
import Pkg; Pkg.add("Pluto")
```

For a brief introduction to working with Pluto, consult the [official documentation](https://plutojl.org/en/docs/).

## 2 Downloading Data and Code Files

> **Quick Setup for Experienced Users**   If you already have experience with Julia, Pluto.jl and Git, you can
> * Get all notebook and code files using `git clone https://github.com/IsaiahDal/isaiahdal.github.io/tree/main`, which will provide you with all code files in the expected configuration. Specifically:
>   * All Pluto notebook files are located in a subdirectory called "notebooks".
>   * All data used in the lectures are located in a subdirectory called "DATA".
> * Open, run, and edit any of the lecture files in Pluto's code editor.
> At this point, you can proceed directly to the lectures.

### 2.1 Data

You can download a ZIP file of all data used throughout the lectures by clicking the "Download Data" button located near the top left of your screen. Then, you can extract the data files into a directory called "DATA" by using the following shell commands in the directory where the ZIP file is located:

**Windows**
```
Expand-Archive -Path MeasurementData-main.zip -DestinationPath DATA
```

**MacOS/Linux**
```
mkdir -p DATA
unzip MeasurementData-main.zip -d DATA
```

Alternatively, you can download individual files from [this repository](https://github.com/IsaiahDal/isaiahdal.github.io/tree/main/DATA). 

### 2.2 Code

To download the Pluto notebook for any lecture, simply click the "**Edit** or **run** this notebook" button located at the top right corner of each lecture. A small window will appear, giving you the option to run the notebook **In the cloud** or **On your computer**. Follow step 1 under **On your computer**, which will download the lecture to your device as "notebook.jl". To avoid confusion, rename the notebook using your file explorer, or using the following shell commands in the directory where the notebook is located:

**Windows**
```
Rename-Item "notebook.jl" "newname.jl"
```

**MacOS/Linux**
```
mv notebook.jl newname.jl
```

### 2.3 Organization

As it is currently written, all code in the lectures assumes the following organizational structure:

* All data is in a directory called "DATA".
* All code is in a single directory. While this directory does not need to have a specific name, assume it is called "notebooks" for the duration of this example.
* Both the "DATA" and "notebooks" directories are at located the top level of the SAME directory.

Ensure that your files are organized as such before proceeding, using a terminal or file explorer to move files if necessary. _Alternatively, you may choose to edit the lines of code that load the data to reflect the relative location of the data as is. This approach is not recommended, as it requires updating each affected line of code individually._

# 3 Running the Lectures

Each lecture is designed to be interactive, allowing you to not only read the code but also run it yourself. Assuming all setup steps have been followed, you can open and run the code for any lecture using the following steps.

i. Open the Julia REPL by entering `julia` into a terminal

ii. Paste the following line into the REPL to open Pluto's code editor:


```
using Pluto; Pluto.run()
```

After a few seconds, a tab should open in your browser that reads **_welcome to_ Pluto**.jl.

iii. Enter the path to the file into the box located below **Open a notebook** and click "Open".

* By default, Pluto will interpret the path relative to your current working directory.

* You may also copy and paste the absolute path to the file. This may help avoid any confusion as to the file's location.

If successful, a fully interactive version of the notebook will open in a new tab.

"""

# ╔═╡ 4bbce35c-42db-4a0c-a9fc-8653277cf994
begin
	HTML("""
	<style>
	  main {
	    max-width: 58vw !important;
	    margin-right: 25vw !important;
	  }
	</style>
	""")
end

# ╔═╡ 718a5417-b38b-473f-a06e-d960e0eedaf3
html"""
<script>
document.querySelectorAll('a[href]').forEach(a => {
    a.setAttribute('target', '_blank');
    a.setAttribute('rel', 'noopener noreferrer');
});
</script>
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.73"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.2"
manifest_format = "2.0"
project_hash = "9eac10d740c80cc8d467c10ea0b43b3d78a6c531"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "67e11ee83a43eb71ddc950302c53bf33f0690dfe"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.1"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.0+1"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "0ee181ec08df7d7c911901ea38baf16f755114dc"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "1.0.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.15.0+0"

[[deps.LibGit2]]
deps = ["LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.9.0+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "OpenSSL_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.3+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.12.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2025.5.20"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.4+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "7d2f8f21da5db6a806faf7b9b292296da42b2810"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.3"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.12.0"

    [deps.Pkg.extensions]
    REPLExt = "REPL"

    [deps.Pkg.weakdeps]
    REPL = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Downloads", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "3faff84e6f97a7f18e0dd24373daa229fd358db5"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.73"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "07a921781cab75691315adc645096ed5e370cb77"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.3.3"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "0f27480397253da18fe2c12a4ba4eb9eb208bf3d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.5.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.Tricks]]
git-tree-sha1 = "311349fd1c93a31f783f977a71e8b062a57d4101"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.13"

[[deps.URIs]]
git-tree-sha1 = "bef26fb046d031353ef97a82e3fdb6afe7f21b1a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.6.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.3.1+2"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.64.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.7.0+0"
"""

# ╔═╡ Cell order:
# ╟─1ba6aed6-65d2-421a-9e51-706e58f60e84
# ╟─dea0aea7-da34-4f40-a4e4-e1e481615187
# ╟─38cf0000-b8ca-11f0-a3c7-098a3812f68c
# ╟─4bbce35c-42db-4a0c-a9fc-8653277cf994
# ╟─17396a4e-e404-4d3f-9fe6-39719dae2c72
# ╟─718a5417-b38b-473f-a06e-d960e0eedaf3
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
