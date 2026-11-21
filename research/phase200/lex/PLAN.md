# Certified static-template token folding

This source-level semantic candidate targets work elimination beyond Phase198's
character-stream fusion. That earlier lexer ceiling measured 0.91× its baseline
and 2.42× mature C; sequentialized streaming reached 0.69× baseline and 1.83× C.
Those historical images differ from the actual Phase199 N1 used here. The
current ordinary lexer is still above twice mature C; a classifier instruction
tweak alone cannot plausibly reach the requested 0.5× C target.

The pure producer has known output classes: identifiers are nonempty lowercase
runs, numbers are nonempty decimal runs, operators are punctuation. For a static
template with no adjacent equal word-class expansions or literal word characters,
the consumer closes each generated run as one complete token. Specialization
can compute its FNV hash or decimal payload directly, then mix that token. It
omits generated Strings, template traversal, per-character Cls/Mode/product
state and salts whose results would be discarded by literal slots. Every
required PRNG step, character remainder, arithmetic wrap, salt position and
ordered token checksum remains. This is neither output memoization nor a
lookup table of benchmark answers.

`prepare.py` implements a template-general certificate and source generator;
uncertified templates emit the original `lex(gen(...),...)` path. The candidate
kernel is real Bend compiled by the actual Phase199 integrated N1. This is not
yet a generic compiler recognizer: deriving the producer/consumer semantics from
arbitrary checked IR would be separate work. The generator currently knows the
specified pure template language and token-fold algebra. No maintained compiler
or original fixture is changed.

At the ordinary256-line input, the independent original-algorithm interpreter
counts15,403 generated characters,9,984 template steps and6,912 discarded literal
salts. It retains7,211 letter/digit PRNG updates and5,120 output-token mixes.
These are source-level semantic counts, not measured hardware counters.

The first physical prospect tests unchanged ordinary input and harness against
freshly timed actual Phase199 baseline and mature C, using the same live-plus-scan
runtime for the candidate and baseline. Prediction: eliminating the closed
producer/consumer state can plausibly reach0.5× C; if it does not, retain the
measured gap instead of relabeling the target. Six rotated rounds target150ms,
with a strict100ms floor. An independent integer/character interpreter plus
unchanged C checks seven complete-program inputs, including U32 wrap. A separate
native program compares old and specialized algorithms on five templates and
five seeds, including empty, Unicode, adjacent mixed classes and refused
adjacent equal classes. Controls run before candidate build or timing.

The initial guarded source attempt failed in0.52s: the zero accumulator needed
an explicit U32 ascription. No object or executable existed. Offline review also
corrected the control-only final IO.pure type argument before a second launch.
The ready retry is `argv-v3.json`,30s/2MiB, with the unchanged5GiB reserve.
`freeze.json` and original files retain the first failure; v2 was never run;
`freeze-v3.json` binds the corrected inputs. Target jobs require root's shared
CPU3 grant; no independent launches or large builds are permitted.
