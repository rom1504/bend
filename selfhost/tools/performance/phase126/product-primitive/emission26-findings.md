# Observer26: actual routing and comparison closure

The corrected integrated path adds8 private functions for record aggregation
(37→45), and7 each for evening (53→60) and map churn (44→51), relative to the
retained Phase125 artifacts. Every case gains public-direct Map.bit/at, product
Map.bit.at/go, and String.cmp.fin/is_le/order; record additionally gains String.eq.
These are function counts, not hotness or speed claims. They show transfer
beyond the new product adapter itself.

`evidence26/report.json` pins all three pairs and exact decoded Map workers.
`evidence26/machine.json` also pins existing record binaries and actual objdump
excerpts. The parent is Phase125, while26 also includes the preceding Phase126
changes; root's matched ablation remains the authority for speed attribution.

The active Map route is now:

```
public Map.bit entry -> private Map.bit
  boxed Nat.divmod -> private Map.bit.at
    take Tuple -> product Map.bit.go -> unchanged borrowed reader
    construct owning result Tuple
```

Both old scheduler jumps between bit/at/go are absent from this private chain.
The original generic public segments are retained as ordinary entry adapters.
The source's quotient/remainder operation is not changed by this experiment.

The **allocation limit matters**: Nat.divmod still creates its Tuple and at
still takes it. The result Tuple construction moves from the old public go
adapter into private at; it does not disappear from this active route. The new
product at has no take/constructor, but private bit still calls boxed at because
the primitive result has no QBE-local shape. A future primitive projection
would make that flat path available; it is not a measured current result.

For record, private bit is22 native instructions with a generic-op call and a
direct at call, versus26 instructions in the old generic bit segment with a
generic-op call and scheduler jump. Private at is43 instructions with take2,
product-go and ctor2 calls; the old generic at is45 with take2 and scheduler
jump. Product go is20 instructions with one borrowed-reader call and two output
stores. These bodies are not interchangeable accounting units: the candidate
also has a29-instruction public bit adapter with two reg_get calls and return,
and direct call/return work must be counted across the complete route. Static
instruction totals therefore cannot predict the timing gain.

No new allocation/RFC semantics, native helper ABI or divide instruction was
introduced. The genuinely removed category is scheduler transport at two
internal edges; root's clean timing must determine whether those savings exceed
the additional direct ABI/output-buffer traffic. The repeated candidate scan
and full catalogue check also remain explicit compiler costs.
