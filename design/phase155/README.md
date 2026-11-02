# Phase155 — twenty cheap, competing compilation-speed experiments

Starting point `c9de3ee`, qualified Phase152 N2 and unchanged production source.
The user requests twenty distinct ideas, as parallel and efficient as practical.
Phase154 demonstrated why one representation experiment and repeated broad
qualification are not an efficient search strategy. This phase widens the search
while keeping actual measurements bounded and comparable.

Seven agents prepare disjoint small prototypes and source-level falsifications.
Root integrates, independently checks and measures in one resource-controlled
CPU3 lane. No competing full-compiler rewrites, no uncontrolled parallel compiler
processes and no production changes merely to create an experiment.

## Registered hypotheses

| ID | Distinct idea | First discriminator |
| --- | --- | --- |
| 01 | Scalar fact query instead of returning an owned cell | Complete changing fact consumer, machine access |
| 02 | Query value and version in one traversal | Same observations and updates, one versus two walks |
| 03 | Retain a hash through related fact operations | Charge hash production, reuse and final cleanup |
| 04 | Publish fact and predicate metadata together | One versus multiple record reconstructions |
| 05 | Carry canonical-world state through publications | Exact final worlds, mixed events and first errors |
| 06 | Batch initial declaration overlay | Full overlay and dependency/order semantics |
| 07 | Reuse constructor membership at publication | Charge index build/update; duplicate/error controls |
| 08 | Fuse semantic lookup with its field consumer | Actual KDef/KTerm query and full result consumption |
| 09 | Hold the root while immediately observing a descendant | Compare ownership and direct-worker feasibility |
| 10 | Carry located constructor metadata to several consumers | Avoid repeated scans, charge complete consumer |
| 11 | Fuse byte/constructor-name production with rendering | Actual captured names, exact rendered output |
| 12 | Bounded destination/chunk emission | Reject if already implemented or prior negative still applies |
| 13 | Render a local spelling once per owner | Actual occurrence stream, charge cache construction |
| 14 | Avoid guaranteed-unused candidate lowering | Establish whether active route still repeats the work |
| 15 | Share use/live analysis across keep and environment consumers | Actual active flat-binding seam |
| 16 | Fuse clean/size/stack body analysis | All original decision fields must agree |
| 17 | Fuse lexer and parser token consumption | Preserve rewind, lookbehind, contexts and diagnostics |
| 18 | Fuse identifier validation scans | Real lexer token stream, full predicate controls |
| 19 | Directly built dense numeric facts | Array transport plus full construction/destruction charged |
| 20 | Sorted sparse facts with batch merge | Merge versus individual trie updates, complete results |

An already-fixed or semantically invalid idea is a source-grounded rejection,
not an executed performance test. Preserve it and count it explicitly rather
than fabricating a benchmark win. Small witnesses are screens, not whole-build
measurements. Different sizes of one kernel do not count as different ideas.

## Efficient decision ladder

1. Each agent spends roughly 15–20 minutes on source inspection and bounded
   prototype preparation. Use existing research and Phase153/154 profiles;
   no new broad literature survey or full profiling campaign.
2. Extract the union of needed current declarations plus private Bend candidates.
   Prefer shared checked API/native images over one build for every hypothesis.
   Freeze each plan before execution. Host code only assembles, transports,
   measures and compares; compiler algorithms remain Bend.
3. Check baseline/candidate outputs at zero, small and changing counts. Preserve
   independent literal expectations and rejected semantic assumptions where
   available. Failure of one candidate must not erase the other results.
4. Native timing uses the same executable for old/new, alternating pairs and
   complete consumed outputs. Calibrate short signals, account for startup and
   teardown, cap repetitions and execution time. Keep failed attempts and noise.
5. Only the strongest transferable positive screens earn wider actual compiler
   inputs or machine inspection. No full self-build just to qualify a weak idea.
   Any production promotion would need its separately justified independent
   verification/output and appropriate native integration gates.

Report all twenty outcomes, not only winners. Separate source rejection,
correctness rejection, insufficient timing signal, measured loss/neutral/win,
and actual full-region transfer. Do not add overlapping percentage gains.
Keep generated-program quality distinct from compiler execution and experiment
cost; source-checking or exact finite output is not a BendTT theorem.

## Resource and evidence policy

One root-owned target lane, serial native runtime, GPU off. New jobs use maintained
disk/process guards, explicit fresh roots, 2GiB RSS and 16GiB available floor,
default 5GiB disk reserve. Disk begins at about 6.7GiB free: avoid full images and
duplicate bulky artifacts. Record acquisition, controls, measurements and failed
jobs separately; agent effort is not equivalent to guarded target seconds.
Close and preserve every executed guard, without automatic pruning. Keep all
qualified compilers, installed selections and unrelated workspace edits intact.
Commit and push design, code, evidence and the candid report; no PR comments.
