# P99-002: calls between already certified scalar observers

Status: source03 passes finite/native controls; a 10m-call retained-root equality
benchmark takes 0.93236× baseline time. Native compiler qualification is in progress;
not promoted. See the [report](../../implementation/phase99/README.md).

The [audit](../../implementation/phase99/borrowed-tags.md) establishes why B2
cannot borrow the term-tag projection or public equality wrapper. Upstream has
general per-parameter ownership propagation. The own observer language currently
cannot retain calls to a different recursive observer. Three non-nullary KTerm
variants and heterogeneous fields independently prevent term-tag admission.

Start with public String equality, keeping the existing root schema and owning
adapter. Add only calls to already admitted scalar observers, with exact argument
types/arity, live caller-root ancestry, scalar-only results and explicit dependency
admission. Unsupported calls, unknown origins, cycles and virtual aggregates
must fall back. Do not remove retains by editing generated C or special-casing
compiler helper names.

Falsifiers: no actual borrowed wrapper route; incorrect aliases/full values;
fallback or dependency-boundary failures; no native micro improvement; planning
overhead outweighing savings on actual compiler requests. General term projection
and literal specialization are deferred until this smaller boundary is measured.
