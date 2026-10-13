# P85-001: generated SCC size and V8 tiers

Status: registered; investigation only. [Design](../../design/phase85/v8-compiler-execution.md).

Hypothesis: hot generated SCC dispatchers exceed V8 bytecode/inlining limits or
have unstable shared argument-slot feedback. Actual bytecode, optimization,
deoptimization and CPU attribution must identify the same functions. Static
source length alone is insufficient. A cap change is allowed only as a labelled
diagnostic, with exact C and memory controls, if a hot function actually crosses
the relevant threshold. Reject size as a main cause if the measured hot functions
fit and optimize. Do not port superseded descriptor-runtime fixes blindly.

Inputs: frozen Phase82 genuine B2, pinned upstream0592662, Phase83 prepared
Base and per-role C oracles. Serial CPU3, heap1GiB/RSS2GiB. Evidence will live
under `selfhost/build/phase85`, then be archived and linked by the report.
