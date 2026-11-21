# Training and specializing the existing runtime

The experiment completed on all six evaluation programs. Training used four different programs. Every runtime passed 44 valid/invalid ABI controls, two foreign descriptor-mutation tests, ten runtime fixtures and the extra C-oracle inputs. Candidate semantics were evaluated at full program boundaries. The repeated measurements used the exact same generated program objects for each arm.

| Evaluation program | Early shared release | Inline fixed arities | Host runtime PGO |
|---|---:|---:|---:|
| lexer | 1.0039× | 0.9798× | 0.9811× |
| coverage-unicode-text-64 | 1.0172× | 1.0138× | 0.9836× |
| coverage-record-aggregation-256 | 0.9918× | 1.0173× | 1.0184× |
| test-rle-roundtrip | 0.9987× | 1.0052× | 0.9702× |
| test-morning-program | 1.0064× | 1.0000× | 1.0224× |
| local-fold | 1.0033× | 1.0000× | 1.0067× |
| Geometric time / live runtime | 1.0035× | 1.0026× | 0.9969× |

General release specialization was flat overall. Profile feedback changed the direction on different applications. Its geometric difference of 0.31% on this single four-round session gives insufficient evidence to adopt the extra PGO toolchain or change the qualified runtime. The profiles trained GCC on edge frequencies inside the C runtime. They do not model time inside the Bend-generated caller. [Raw samples, flags, tool identities, training observations and signed-off job status](evidence.json.gz)
