# Ordinary generic-to-complete bridge control

`manifest01.json` freezes one ordinary source candidate and independent literal
complete stdout. The control author did not run a compiler or target. Use the
existing Phase114 frontend preflight and `controls/prepare-jobs-v2.py --manifest
... --all` for parent-run source and complete native observation gates.

`caller` dynamically applies a closure while retaining two owning Strings, then
calls the known `target` returning a scalar. Its true branch weights the first
characters by 1000 and 1, so swapped arguments have distinct results. Its false
branch drops the entire unused String. Character extraction drops the selected
String tail. External aliases survive both branches, swapped calls and repeated
observations; empty strings and allocated Unicode strings are included.

The literal numeric oracle uses Unicode code points A=65, Z=90 and beta=946:
`65*1000+946=65946` and `946*1000+65=946065`. These values were computed without
candidate execution. Correct output alone does not establish the bridge was
used: inspect the generic caller's actual continuation and the admitted public
complete worker separately. No runtime ABI or failure probes are introduced.
