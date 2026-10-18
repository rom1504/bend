# Exact additive replacement: an owned call may target only an actual worker.
@unsafe
def nx110rt_verify(+library: Nx110RtLibrary) -> Bool:
  match library:
    case Nx110RtLibrary{workers,exports}:
      nx110rt_workers_ok(workers) && nx110rt_calls_ok(workers,nx110rt_callees(workers)) &&
      nx110rt_machine_ok(nx110rt_machine(library))
