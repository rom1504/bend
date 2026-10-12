# P75-003: one native closure and erasure per checked request

Create a private Bend-owned native request product after checked annotation.
Retain its source context, ordered runtime closure, erased non-foreign bodies,
foreign paths and scope. Reuse it for scalar/sharing certificates, static-body
preparation and lowering. Raw APIs still clear caller-supplied native facts and
use the original validation path. Validate source IDs before consulting prepared
bodies; those are different domains. Preserve full output relative to P75-002.
The host only transports this product between Bend entry points. It contains no
cross-request cache and does not weaken source/effect identity checks.
