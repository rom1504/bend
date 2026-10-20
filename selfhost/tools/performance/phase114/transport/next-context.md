# Explicit emission context: audited, deferred

The fixed frame/pop/get candidate does not need program-dependent state. Inline
jump/return would need a typed context derived once from the same verified
`P111Program` used for descriptor emission:

```
P114EmitContext{registerWidth: U32, resultWidth: U32, transportWidth: U32}
transportWidth = max(registerWidth,resultWidth,2)
registerWidth = p111q_width(segments,False,2)
resultWidth   = p111q_width(segments,True,1)
```

The frozen runtime binds exactly these widths, bounded by physical256. Do not
encode width into `N111Ids`, mutate global compiler state or infer it from a local
function's arity. The census `context-census01.json` finds broad45 widths5–19;
37 programs fit8 and41 fit16. Its5,800 jump and15,181 return calls are static
counts. The full compiler has a larger width, so unconditional clear unrolling
would significantly grow its already large emitted program.

The narrow implementation path would thread context through final public chunk
selection, not all semantic lowering. Derive it in the admitted bundle emitter,
pass it through the registered/public-chunks facade, then lower helper calls in
already chosen generic, `P112TailPlan`, and `P112WorkerStmt` bodies immediately
before rendering. Keep all original planners on the unmodified owning graph.
Generic `p111q_segment` needs a body mapper; tail plans need a mapper of scalar
leaves; public worker plans need one plus a context-aware public-call finish.
Private Term-returning complete workers do not use the generic jump/return ABI.

Concrete entry paths to cover are `p113a_admitted_chunks` → enabled/ordinary
bundle → `p113a_registered` or `p113e_registered` → `p113e_public_chunks` →
complete/R/G/generic selection. The no-complete-functions path through
`p112s_chunks` must receive the same context. Existing raw-string wrappers
`p113e_public`, `p114r_public` and `p112w_call_finish(public=True)` need explicit
structured return templates; a `p111q_stmt` override alone does not reach them.
R/G unwind stack operations are a separate fixed-ABI matter.

For exact supported scratch transfers, snapshot all count source words before
writing the bank, then write registers0..count−1 and zero count..W−1. This
preserves `memmove` behavior under the admitted disjoint scratch origin without
changing physical slots W..255. Jump writes `rn=0`, `next=knownFID`, and returns
zero. Return writes `rn=count`, decrements sp once, loads the low32 FID into
`next`, and returns zero. Both retain their original descriptor/count premises;
unsupported pointers/counts/large widths keep the helper. A small initial W≤8
bound would qualify most corpus programs while limiting code growth.

This removes helper calls and exposes stores, but retains the bank roundtrip and
dispatcher. Replacing a known jump with a machine call to an arbitrary public
segment would risk unbounded native stack growth and mishandle the dispatcher's
STOP reset. Removing bank writes requires a stronger no-observation argument,
not merely known successor identity.

That stronger argument already exists for admitted complete private functions:
they cannot observe register-bank/rn/next transport and have a closed bounded
private call graph. The residual generic→complete bridge therefore takes
priority. It skips the temporary handoff bank while keeping the unchanged final
`rt_return`. Its actual census spans34 corpus families, and its code change is
smaller than threading context through all public emitters. Width-context
implementation is postponed pending that bridge's ordinary qualification and
measurement. No jump/return expansion or new bank ABI has been implemented.
