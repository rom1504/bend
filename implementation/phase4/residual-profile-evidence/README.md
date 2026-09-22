# Bounded residual profiles

The manifest records both complete instrumented observations and all captured
file identities. All 25 content-addressed gzip objects were decompressed and
compared with their original bytes during archival; inputs were rehashed after
archival. The archive contains 28 file entries and 4,029,395 packed bytes.
Node's platform executable is identified by hash as an external prerequisite.

| Compiler | Report | Raw profile | Exact output | Launch |
| --- | --- | --- | --- | --- |
| B1 | [Report](objects/f427f15cd1315c1c38914f2f0a18717f161616469458d4b82aa566bd1e0c1d08.gz) | [Raw profile](objects/efee6e38db46c75b7c6d9b0d0f34bc368d578fb878770020d3e574409d1e60e6.gz) | [Exact output](objects/016a5cedeb7e285adeabdad19388d99d3d9070668c15776ccc10fab8ea7b7186.gz) | [Launch](objects/61408dd15e00c93c737de49bb86aa420aab521e3ffaa5c2311f4547c69a27ec9.gz) |
| Private | [Report](objects/8910b9d768f7141833e5df0693cfb1a94d0d70308577a2747c44265e33090d10.gz) | [Raw profile](objects/f1f59fb95a67b7ab2f3f22377d3d117606f5468b0113506cfd8b8b6d6c1ab224.gz) | [Exact output](objects/016a5cedeb7e285adeabdad19388d99d3d9070668c15776ccc10fab8ea7b7186.gz) | [Launch](objects/17efb94694b70e0f03560bb748870adbf675f4e975aef3da8065ef3372a35b69.gz) |

Every link in the table is gzip-compressed. Decompress it before reading the
JSON, JavaScript or V8 CPU profile. `manifest.json` records the raw SHA-256,
length, packed SHA-256 and original absolute path for each object. The original
paths are historical provenance; the archive is not a relocated compiler build
or a newly checked bootstrap. Original input/tool bytes are preserved as objects,
including the exact B1 and private APIs, host, Base, runtime and profiler.

The permanent archiver is
[`residual-profile-archive.py`](../../../selfhost/tools/performance/phase4/residual-profile-archive.py).
It requires both exact selected images, the shared input/configuration, complete
checked success, equal actual emitted bytes and unchanged inputs. It refuses an
existing destination and retains an incomplete manifest on later failure.

These profiles use warmed discovery and instrumentation. Their elapsed durations
are not paired compiler benchmarks. See the [analysis](../residual-profile.md)
and [experiment record](../../../experiments/phase4/P4-022-residual-private-profile.md).
