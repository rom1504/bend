# General native profiler

See the [usage and interpretation guide](../../../docs/self_hosted/PROFILING.md).

`freeze.py` pins independent workloads; `run.py` captures clean timing, CPU samples
and optional runtime events; `compare.py` pools compatible observations with
quality gates. `analyze.py` decodes ELF leaf samples. `owners.py` and `attribute.py`
add authenticated segment/definition attribution. `unwind.py` provides bounded
physical callers. `runtime.py`/`build-runtime.py` create reversible diagnostic
runtime links; `build-sampler.py` builds the native collector.

All target execution belongs in a resource guard. The offline tools never run
the target. Installed compiler selections and historical evidence are untouched.
