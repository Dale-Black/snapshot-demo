### A Pluto.jl notebook ###
# v0.20.28

#> [frontmatter]
#> title = "A static report"

using Markdown
using InteractiveUtils

# ╔═╡ cc000005-0000-4000-8000-000000000005
using PlutoUI

# ╔═╡ cc000006-0000-4000-8000-000000000006
TableOfContents(title = "On this page")

# ╔═╡ cc000001-0000-4000-8000-000000000001
md"""
# A static report

Not every notebook needs to be interactive. This one just **computes some numbers and
shows them** — a clean, read-only page. Snapshot labels it **`static`** in the sidebar
(it uses no `@bind`), and it still runs the real Julia to produce the values below.

The floating panel on the right is a `PlutoUI.TableOfContents()` — it builds itself
from the markdown headers in the notebook.
"""

# ╔═╡ cc000007-0000-4000-8000-000000000007
md"## The data"

# ╔═╡ cc000002-0000-4000-8000-000000000002
data = [4, 8, 15, 16, 23, 42]

# ╔═╡ cc000003-0000-4000-8000-000000000003
stats = (
    n    = length(data),
    sum  = sum(data),
    mean = round(sum(data) / length(data); digits = 2),
    min  = minimum(data),
    max  = maximum(data),
)

# ╔═╡ cc000008-0000-4000-8000-000000000008
md"## Summary"

# ╔═╡ cc000004-0000-4000-8000-000000000004
md"""
**Summary of `data` = $(data):**

| metric | value |
|:------ | -----:|
| count  | $(stats.n)    |
| sum    | $(stats.sum)  |
| mean   | $(stats.mean) |
| min    | $(stats.min)  |
| max    | $(stats.max)  |

Computed when this notebook was published — then frozen as static HTML.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised
julia_version = "1.12.6"
manifest_format = "2.0"
project_hash = "0000000000000000000000000000000000000000"
"""

# ╔═╡ Cell order:
# ╠═cc000005-0000-4000-8000-000000000005
# ╟─cc000006-0000-4000-8000-000000000006
# ╟─cc000001-0000-4000-8000-000000000001
# ╟─cc000007-0000-4000-8000-000000000007
# ╠═cc000002-0000-4000-8000-000000000002
# ╠═cc000003-0000-4000-8000-000000000003
# ╟─cc000008-0000-4000-8000-000000000008
# ╟─cc000004-0000-4000-8000-000000000004
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
