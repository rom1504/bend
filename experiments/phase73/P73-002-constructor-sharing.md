# P73-002: constructor sharing facts

Measured excess wrapper allocations per16-input cycle: list5606,BST4254,
Array.map16368. Saved-C cold-store probe: list650→341ms(upstream302),
BST638→409(317),Array.map561→457(298). These are diagnostic interventions,
not compiler-generated correctness evidence.

Implementation scans reachable checked annotations for actual duplicated runtime
variables. It heats their complete instantiated datatypes and transitive live
constructor fields. Trusted immediate scalars need no heap protocol. Unknown
annotations, open/dependent types, malformed telescopes and exhausted budgets
refuse by heating everything. Raw, device and unsupported effects keep the old
representation. Base constructors are included; array-free is not equivalent to
unshared. Constructor identities retain Base/user provenance. Type visitation
uses exact instantiated syntax keys, not only datatype names.

Compiler01/02 conservatively refused all benchmark programs because U32's theory
expands through Word; compiler03 recognizes the trusted immediate native scalar
representation. Refused attempts and measurements are retained, not counted as
wins. Next: generated-code check, shared-container controls and integration gates.
