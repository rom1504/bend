# Phase91: current source, support and image census

The [read-only census](census01.json) verifies 392 file identities before and
after counting. Every one of the 132 active Bend modules matches both the
genuinely checked Phase90 compiler07 snapshot and the installed release's
`checkout` hashes and lengths. All installed release files are rehashed too.
No compiler, test or benchmark was executed by this audit.

The rules are unchanged from [Phase66](../phase66/simplicity.md): count only
manifest-listed Bend modules; use UTF-8 `splitlines`; exclude blank and
first-nonspace `#` lines for code lines; declarations are line-start `def`, `law`
and `type` followed by whitespace. Generated images, Base, host/runtime sources,
tests and experiment tooling remain outside this Bend series.

| Maintained Bend source | Current installed Phase90 |
|---|---:|
| Modules | 132 |
| Physical lines | 32,692 |
| Code lines | 26,693 |
| Definitions / laws / types | 3,876 / 658 / 146 |
| UTF-8 bytes | 1,531,764 |

Phase90 grew by 101 physical lines from its 32,591-line baseline, approximately
0.31%. This is not a line-count reduction. The active manifest SHA-256 is
`d1de057f17bc04efdda460108145b98108812cb468f39674ab007385864b1d8b`.

| Separate maintained support boundary | Files | Physical lines |
|---|---:|---:|
| Established host helpers: driver, Base graph, workflow, release | 4 | 1,851 |
| Five ordinary JS fragments plus direct runtime | 6 | 1,282 |
| JS effect providers | 35 | 859 |
| Native C runtime | 1 | 3,134 |
| Native effect providers | 45 | 3,829 |
| Public native launcher | 1 | 83 |

These groups are explicit boundaries, not an exhaustive repository-wide support
total. The generated ordinary JS runtime is not counted again alongside its
fragments. Historical provenance, restoration and experimental tools are also
real maintenance costs, but are not compiler algorithms or generated output.

| Actual image role | SHA-256 prefix | Bytes |
|---|---|---:|
| Raw checked JS B1 | `cc481763…` | 2,287,938 |
| Selected derived JS B1 | `6bf8e093…` | 2,307,495 |
| Genuine self-emitted and installed JS B2 | `284f6e9b…` | 4,745,566 |
| Native07 executable | `d7c7a479…` | 16,913,416 |

The census retains every complete image hash and source identity. Native07's
38,614,882-byte C identity comes from its authenticated admission; this census
does not regenerate or freshly compare that C. Image bytes are not authored
source lines or semantic concepts.

The 132-module series describes the maintained compiler. Native07 instead runs
the separately frozen `d04ad79c…` source profile: its Phase90 assembly receipt
records fourteen exact, reversible edits over the preceding native assembly.
That generated assembly repeats compiler/Base/entry code and is not counted a
second time as authored compiler lines. Its native substitutions, transport and
cache ABI, restricted host entry, source-to-image binding and admission rules
remain additional maintenance contracts; the manifest count does not measure
or eliminate them.

## Source continuity and concepts

Against Phase82, 125 of 132 modules are byte-identical and no module is added or
removed. The seven changes are all native backend modules: text, tables, emit,
flat, static, observer-analysis and observer-integration. Thus every non-native
Bend module is unchanged from Phase82. Against Phase66, 97 current modules match,
18 existing modules changed and 17 were added. Source identity is useful
explanatory evidence; it is not a new full-suite conformance run or a proof that
the larger generated compiler behaves identically.

There is no established numerical semantic-concept series. The Phase66 eight-area
ledger is a responsibility checklist, not a measurement of eight concepts;
Phase52's seven direct-backend
mechanisms and Phase7's roughly fourteen shared compiler responsibilities are
architectural descriptions. Definitions, laws and types are structural proxies.

Phase90 replaces repeated prefix construction and list searching with chunks and
indexed lookup, makes large traversals stack-safe, and removes the final
character-by-character indentation pass. It also introduces a large-table
runtime dispatch boundary and native image/admission responsibilities. Existing
representations and compatibility paths remain. These changes solve scaling and
self-hosting problems; the evidence does not establish fewer overall concepts,
50%/75% simplification, or an equivalent-scope complexity ratio to TypeScript.

Reproduce into a fresh report, on the same selected release:

```sh
taskset -c 0 python3 -B implementation/phase91/census.py --output /tmp/phase91-census-recheck.json
```

The script rejects changed source, checked-image, installed-image and snapshot
bindings. It never rewrites source or an existing report.
