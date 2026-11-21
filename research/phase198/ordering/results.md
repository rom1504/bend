# Selecting an Ord constructor directly

The Phase197 x86 backend calls a general runtime dispatcher to compare two words and return an Ord constructor. Inlining that operation saved 2.87% of Unicode text time, 3.31% of Map/set time and 1.12% of generic edit-row time. These measurements use the Phase197 source and runtime. The change was tested separately from the qualified portfolio.

| Program | Candidate / original x86 | Candidate / mature Bend C |
|---|---:|---:|
| Unicode text 64 | 0.9713 | 2.5240 |
| Map/set operations | 0.9669 | 2.8214 |
| Generic edit row 32 | 0.9888 | 3.2373 |

The existing API checked the modified compiler. Thirty admission controls exercised the selector. Independently assembled text and direct ELF objects each passed 30,098 full-width comparison cases in the C oracle. The program timing driver checked two additional inputs per workload and six timed observations per role. Inlining the comparison addresses only part of each residual deficit. The emit and timing receipts identify all source, object, compiler and runtime inputs. [Raw receipts](evidence/) · [Selection requirements](plan.md)

To reproduce, run `ordering/prepare.py --out selfhost/build/phase198/order-source02` (the script is under `research/phase198`); use the checked API queue with `order-api01:order-source02`, then the commands recorded in the controls, emission and timing artifacts. All commands run from the repository root, with one timing lane on CPU 3.
