# Replace only main in owned-decomposition-workload.bend for balanced timing.
# All output fields contribute to the final digest; full values have their own gate.
def main() -> U32:
  p173odw_digest(p173odw_repeat(10000n,p173odw_make(128n,7)))
