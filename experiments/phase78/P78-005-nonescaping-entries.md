# P78-005: omit unreachable closure factories

A checked host-only request currently creates curried closure factory chains even
for admitted direct workers whose references occur only in exactly saturated
non-bang calls. Classify escapes once over the complete erased runtime closure.
Partial, overapplied, bang, bare and higher-order references retain the factory.
Only an already admitted ordinary worker with positive checked arity may omit it.
The no-bang/known-effect permission remains mandatory; raw/device paths stay intact.

This is a whole-program syntactic escape proof, independent of benchmark names.
Expected savings span generic lowering, identifier construction, validation and
rendering. Budget 10–25% request time, measured rather than assumed. C text changes
and native execution must be checked. Include partial/application and function
value controls, custom foreign effects and threading. Roll back if the global
scan or generated-program regressions outweigh compilation gains.
