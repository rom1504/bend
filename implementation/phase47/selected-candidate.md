# Array04 selection gates

Provisional candidate only; qualification and broad timing are in progress.
The checked build and focused strict gate passed. Source normalization now
admits the existing local-pair region, with one private raw-array root in its
emitted module. Local-fold also has one; scalar-region has none.

The maintained source delta from Phase45 worker23 is 206 physical Bend lines:
23,007 → 23,213, with 19,147 code lines, 2,617 definitions and 86 manifest modules.
The new module supplies one private representation contract, a bounded admission
audit, consistent normalization, and ordered-write emission. Two runtime/source
mirror files contain the same 13-line guard addition; count the assembled runtime
separately rather than summing it with its fragment.

The local-row emitted library grows to 148,609 bytes because the new private
helpers coexist with the exact old fallback. This is a deliberate initial
size/safety tradeoff, not simplification credit. The corpus and compiler-cost
measurements must determine whether it is useful enough to retain.

The array04 API/runtime, exact source metrics, controls and timing receipts are
under `selfhost/build/phase47/`; final durable evidence and installation status
will be linked from the phase report. No checked array01–03 observation is
silently attributed to array04. Source helper normalization deliberately keeps
only the current Mat helper's self call in its existing form, preserving tail
loop lowering while directing other known calls to the private representation.
