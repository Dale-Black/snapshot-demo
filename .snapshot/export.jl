#!/usr/bin/env julia
# Snapshot v0 — island export driver. Runs inside the PlutoIslands.jl project.
#
#   julia --project=PlutoIslands.jl export.jl <repo_dir> <stage_dir> [notebook ...]
#
# Compiles each Pluto notebook found in <repo_dir> to a self-contained WasmGC
# island bundle (<name>.html + <name>.islands/) under <stage_dir>/<slug>/, and
# writes <stage_dir>/manifest.json describing each notebook + its honest
# cell-level coverage. Per-notebook failures are recorded, not fatal — the run
# only fails if EVERY notebook fails.

using PlutoIslands
using JSON
using Dates

const PLUTO_MAGIC = "### A Pluto.jl notebook ###"

function is_pluto_notebook(path)
    endswith(path, ".jl") || return false
    try
        return startswith(open(readline, path), PLUTO_MAGIC)
    catch
        return false
    end
end

function find_notebooks(repo_dir)
    nbs = String[]
    for (root, _dirs, files) in walkdir(repo_dir)
        occursin(r"(^|/)\.git($|/)", root) && continue
        for f in files
            p = joinpath(root, f)
            is_pluto_notebook(p) && push!(nbs, p)
        end
    end
    return sort!(nbs)
end

slugify(s) = strip(replace(lowercase(s), r"[^a-z0-9]+" => "-"), '-')

function main()
    repo_dir  = abspath(get(ARGS, 1, "."))
    stage_dir = abspath(get(ARGS, 2, joinpath(pwd(), "_snapshot_stage")))
    explicit  = length(ARGS) > 2 ? abspath.(ARGS[3:end]) : String[]
    samples   = parse(Int, get(ENV, "SNAPSHOT_ORACLE_SAMPLES", "5"))
    # Every island is wasm-opt'd via WasmTarget.optimize so artifacts stay small.
    # size (-Os, default) | speed (-O3) | debug (-O1) | off.
    optenv    = get(ENV, "SNAPSHOT_OPTIMIZE", "size")
    optimize  = optenv == "off" ? false : Symbol(optenv)

    isdir(stage_dir) && rm(stage_dir; recursive=true)
    mkpath(stage_dir)

    notebooks = isempty(explicit) ? find_notebooks(repo_dir) : explicit
    @info "snapshot export" repo_dir stage_dir count=length(notebooks)

    used = Set{String}()
    results = Vector{Dict{String,Any}}()
    for nb in notebooks
        rel  = relpath(nb, repo_dir)
        base = slugify(splitext(basename(nb))[1])
        slug = isempty(base) ? "notebook" : base
        i = 1
        while slug in used
            slug = "$(base)-$(i)"; i += 1
        end
        push!(used, slug)
        out = joinpath(stage_dir, slug)
        mkpath(out)

        entry = Dict{String,Any}("notebook" => rel, "slug" => slug)
        try
            @info "▶ export" rel
            t = @elapsed html = export_notebook(nb; output_dir=out, verify=true,
                                                oracle_samples=samples, optimize=optimize)
            index = basename(html)
            stem  = splitext(index)[1]
            covpath = joinpath(out, stem * ".islands", "coverage.json")
            entry["status"]    = "success"
            entry["index"]     = index
            entry["elapsed_s"] = round(t; digits=1)
            entry["coverage"]  = isfile(covpath) ? JSON.parsefile(covpath) : nothing
        catch e
            @error "✗ export failed" rel exception=(e, catch_backtrace())
            entry["status"] = "failed"
            entry["error"]  = first(split(sprint(showerror, e), '\n'))
        end
        push!(results, entry)
    end

    manifest = Dict("generated_at" => string(now()), "notebooks" => results)
    open(joinpath(stage_dir, "manifest.json"), "w") do io
        JSON.print(io, manifest, 2)
    end

    ok = count(r -> r["status"] == "success", results)
    @info "snapshot export done" ok total=length(results)
    if ok == 0 && !isempty(results)
        @error "every notebook failed to export"
        exit(1)
    end
end

main()
