# Final independent source gate

Three new first-order scalar source families pass the fixed Phase107 native
frontend and QBE backend in both raw and fast modes: **six complete builds and
196 exact full-output checks**. The [completed receipt](../../selfhost/build/phase107/heldout01/report.json)
records all 202 subprocesses returning 0. Its SHA-256 is
`d33025b99f6617b83769c9ff2a3a7427c167a471f9bfab532c22b07745b173b7`.

The [external guard](../../selfhost/build/phase107/heldout01-guard/process.json)
completed in 4.331787s, with 86,753,280 bytes peak process-tree RSS. The harness
recorded 4.245778s. These are total campaign costs including authentication,
compilation and validation; no runtime or compilation speedup is inferred.

The [sources, expectations and method](../../selfhost/tools/performance/phase107/heldout/README.md)
were committed as `8b3fba0` before any compiler execution on these sources.
No source, expected answer, method or optimization policy changed after the
freeze. The gate had no exclusion or adaptation path: unsupported source,
lowering, compilation or output outcomes would fail it.

| New source family | Independent mathematical model | Input vectors | Outputs across two policies |
| --- | --- | ---: | ---: |
| Bounded subtraction GCD | `math.gcd(n % 1024, seed % 1024)` | 18 | 36 |
| Non-tail triangular recursion | `((k*(k+1)//2)+seed) % 2**32`, `k=n % 1024` | 56 | 112 |
| Saturating addition and piecewise helpers | `min(n+seed, 2**32-1)` followed by integer branches | 24 | 48 |

The fixed vectors cover zero, operand reversal/equality, the 1023/1024 bound,
unsigned high bits, wrapping addition, saturation and both sides of branch
thresholds. Runtime results require exact decimal stdout plus one LF and empty
stderr. The recursive source definitions use explicit bounds; the triangular
call remains non-tail. This is finite dynamic evidence, not a proof for every
U32 argument or a full-language admission claim.

The [frozen manifest](../../selfhost/tools/performance/phase107/heldout/manifest.json)
binds all 23 execution inputs, including native image04 source, binary,
acquisition, Base/carrier, driver/helper, tools and fixtures. Its SHA-256 is
`a22c5fad35b29e27e92f981318c303fdb180fc6cd8cf3f03fec39ef704536f78`.
The harness verifies those pins before and after execution and binds every child
receipt to the exact image, source, policy, tools and unchanged runner ABI. A
subsequent read-only audit also matched all 23 inputs, retained products and full
logs to their recorded pins. No source or tool changes were needed for the gate.

These three sources extend the eight previously admitted source families to
eleven. The earlier six refusal controls remain separate evidence; this gate did
not rerun or enlarge that refusal set. These are new final held-out correctness
cases, introduced after the earlier optimization investigation. They do not
retroactively establish held-out coverage for its policy search, supply new
performance ratios, or qualify the entire compiler.
