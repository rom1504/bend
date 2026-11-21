# Guard the distributed map on the repeat count

Apply this optional overlay last to a compiler containing Phase205's checked repeat-hoist pass. It also recognizes the optional native-unfold pass. The compiler's original equation matcher, restriction to already evaluated delimiter/separator atoms, kernel body recheck, code layout check, and original-body fallback continue to apply.

```sh
python3 -B research/phase205/zero/wire.py PATH/TO/COMPILER/compiler.bend FRESH_OUTPUT_DIRECTORY
```

A successful match emits two ordinary, ordered checked lets. Their right-hand sides contain the original count and block expressions, once each. The direct native let lowerer evaluates the first binding before lowering the rest (`p112_liveness_terms`, `p113dl_let`). An annotated `Nat -> String` case function then consumes the saved count. The zero arm returns `SNil{}`. The successor arm reconstructs `Succ{pred}` in constant work and invokes the original checked repeat on the mapped block. Only this arm contains the split/join calls. Zero still evaluates the original block expression. Both dynamic expressions can reference the surrounding source scope.

The count, block, predecessor, and temporary function-type binder receive four distinct IDs above `norm_book_bound`. A high bound declines the edit. Each proposal updates the book bound before kernel checking. Each accepted text or unfold edit updates the bound passed to the next owner from the checked declaration, including any binder IDs retained by annotation. The final layout receives a context stamped with the bound of the accepted edit index. Its nodes expose both child branches, and its leaves expose every definition in their buckets. The optional one-pass helper pass executes only on the no-edits branch. Validation cost is proportional to changed declaration size, plus O(1) cached bound checks along the ordinary path.

`two-repeat-owners.bend` exercises a direct site and a let-bound site, computed count and block expressions, distinct separators, and zero and positive inputs. Its exact stdout begins with two empty lines. The existing packet fixture additionally gives a long precomputed block at runtime count zero. A native or hosted check should verify acceptance for both named owners and inspect the guarded request before interpreting performance. Output equality alone cannot distinguish a declined rewrite. The physical lane belongs to the parent campaign.
