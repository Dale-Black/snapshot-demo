# snapshot-demo

A one-notebook test bed for [Snapshot](https://github.com/GroupTherapyOrg/snapshot)
— the notary for frozen, verifiable, interactive Julia notebooks.

`demo.jl` is a Pluto notebook with a slider-bound `x` and a live `y = x²`. On
push, the `notary-export.yml` workflow compiles it to a self-contained
WebAssembly island (`wasm-opt`'d small, verified byte-exact), attaches a
build-provenance attestation, and publishes it to Snapshot's host — where it
runs interactively in the browser with **no Julia server**.
