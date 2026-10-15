# Generated-program continuity: current release versus timed artifacts

This gate refreshes the historical generated-program metric, not compiler
latency. Phase66's timed JavaScript corpus has 23 sources and 45 observer points;
Phase78's native timing corpus has twelve batch fixtures. Phase90's 45 catalog
wrappers do not substitute for the twelve native fixtures.

Freeze the current installed-release receipt, checked B1, genuine B2, source,
runtime and driver before any target. Reuse the ordinary compiler07 frozen
project with its API-specific Base preparation; no new compiler build, alternate
semantic implementation or copied project is needed. Run the B1 and B2 workers
serially under the existing 180-second / 2-GiB / CPU3 guard.

Each worker freshly emits all 23 JavaScript modules and compares every byte with
the Phase66 qualified module, requiring identical Base and JavaScript runtime
bytes. It also freshly emits the twelve actual native batch fixtures and compares
the complete CPU preprocessor output with the qualified Phase78 C. Use the actual
historical `-std=c11 -O3` Clang flags, identical regular-file stdin filename,
environment and prebound header closure. Preserve raw source differences. The
only anticipated changes are final C whitespace and the separately qualified
runtime guard/accessor edits; all twelve old/current tables must remain below
4096 entries, so optimized dispatch remains direct. No arbitrary token rewriting
or exclusion of functions is allowed.

Matching preprocessor files are hashed, fully byte-compared and then removed;
current JS/C outputs and reports remain. Expected retained source outputs total
about 11 MiB for both roles; one pair of temporary preprocessor outputs is bounded
to 16 MiB each. Methods require at least 64 MiB free before starting. No old files
are deleted. Root owns target execution, and the preparation command is data-only.

Acceptance requires all 46 JS module comparisons and all 24 C comparisons across
both roles, with unchanged inputs. Report scoped failures and retain differing
products. Exact output continuity can carry forward dated measured program
behavior under the same runtime/toolchain/invocation; it is not fresh timing,
ELF identity, GPU qualification or a guarantee of unchanged machine-code layout.
If a complete C comparison fails, inspect the whole difference before deciding
whether a new execution/timing campaign is necessary. Do not substitute the
six-source compiler-host speed screen for this gate.
