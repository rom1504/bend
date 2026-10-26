# General native profiler

See the [usage and interpretation guide](../../../docs/self_hosted/PROFILING.md).

`freeze.py` pins independent workloads; `run.py` captures clean timing, CPU samples
and optional runtime events; `compare.py` pools compatible observations with
quality gates. `analyze.py` decodes ELF leaf samples. `owners.py` and `attribute.py`
add authenticated segment/definition attribution. `unwind.py` provides bounded
physical callers. `runtime.py`/`build-runtime.py` create reversible diagnostic
runtime links; `build-sampler.py` builds the native collector.

`render.py` makes comparison summaries readable; `timeline.py` exposes changing
physical/context hotspots from existing sample order. `check-runtime.py` checks
hooks against frozen independent ABI fixtures. `deduplicate.py` preserves exact
completed outputs as immutable hardlinks when large compiler requests consume
disk. Counter timings, context-only timings and clean timings remain separate.

All target execution belongs in a resource guard. The offline tools never run
the target. Installed compiler selections and historical evidence are untouched.

Versioned [exact stage observations](STAGES.md) add data-defined FID/order/
multiplicity plans and delivered-sample ordinal association. Preparation and
observation are offline; generic runtime packaging still needs a small native
output gate before deployment. Historical collectors and captures stay intact.
