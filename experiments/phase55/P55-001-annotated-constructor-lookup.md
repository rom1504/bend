# P55-001: reuse annotated constructor ownership during arity recovery

Hypothesis: existing checked matcher annotations can remove repeated whole-book
constructor searches in jd_raise without changing raised arity or generated code.
Domain: checked, specialized, annotated direct emission; unannotated/unknown-type
queries retain the old fallback, and common j_find_ctor is unchanged.
Falsifiers: a valid checked ambiguous constructor, wrong local annotation/type,
changed arity or emitted bytes, semantic failure, or no useful end-to-end effect.
[Design](../../design/phase55/direct-compiler-image-throughput.md).

Inspect checker uniqueness and annotator invariants before implementation.
Validate local owner queries and fallback independently; then checked B1, fixed
Phase54 full77 subject, full-image execution and retained user-program semantics.
