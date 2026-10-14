# Phase86: qualify native hosting before more V8 tuning

The current compiler is written in Bend but executes as JavaScript, including
when emitting C. Phase85 measured substantial first-use V8 compilation cost.
Test whether compiling the same compiler through the pinned upstream C backend
removes enough cost to justify a native host. This is an investigation, not a
default-host migration or a native self-hosting claim.

## Hypotheses and discriminators

1. The current semantic compiler can execute natively without a JavaScript
   semantic bridge. Assemble unchanged manifest modules with a small experimental
   Bend entry and fully check it with upstream0592662 before C emission.
2. Native execution can improve first-request time. Compare the identical Bend
   entry compiled to upstream JS and native C, with equal source, Base and runtime
   preparation. Record preparation, request, process wall and C build separately.
   Cold Base work must not masquerade as an execution-backend difference.
3. Integration can preserve the existing fast path: prepare immutable Base in
   Bend, retain its checked prefix/world, and reuse current native request APIs.
   The first pilot may restrict imports to Base and explicit foreign files;
   document every difference from the installed host and do not promote it.

Start with small scalar/functions cases, then Numeric/Map/Lexer if acquisition
and output checks succeed. Compare complete emitted C with a sibling JS entry
and the installed compiler where the pipeline contracts match. Include positive
and negative controls before interpreting timing. Existing upstream timings are
context only until a contemporaneous matched run is made. A material (~15%+)
request win supports broader host work; a build/runtime blocker or clear slowdown
calls for diagnosis and a scoped recommendation, not automatic migration.

## Method and limits

Reuse algorithms, not the obsolete native wrapper's pipeline. The host supplies
bytes and effects; loading, checking, reports, layouts, foreign conversion and
C emission stay Bend. Preserve successful and failed attempts, exact module and
tool hashes, generated C/JS, commands, exit status, time and memory. Bootstrap
through upstream is native B1; native B2 and reproduction are later milestones.
Do not edit upstream or production Bend modules/installed images.

Two bounded agents inspect host boundaries/build risks; root alone runs targets.
One guarded process tree,2GiB RSS/4GiB available-memory floor,Node1GiB heap and
4MiB stack. Build feasibility starts with a180s checked-emission bound and a
300s optimized-Clang bound; revise only from recorded evidence. Runtime screens
start at30s and remain serial. Check disk before acquisition (initial free space
~740MiB); avoid duplicated large artifacts and cap individual outputs. Use fresh
attempt directories and preserve rejected work. No full benchmark, default switch,
PR comment or native self-reproduction unless the pilot justifies that scope.

## Deliverables

- Current native-host dependency/feasibility notes.
- Reproducible bounded experiment with retained evidence.
- Report distinguishing demonstrated behavior, timing and migration work.
- Updated experiment frontier and native-compilation documentation; commit/push
  investigation artifacts under the standing session authorization.
