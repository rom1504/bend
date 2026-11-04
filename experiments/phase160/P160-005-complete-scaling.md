# P160-005 — execution headroom must survive full self-compilation work

The UNBOX=0 cross-build passes the original complete QBE oracle on Map and on
the real182KB checker source. First observations are1.157/2.953s and
10.689/24.117s for C/QBE respectively. This does not justify projecting2.3×
onto full source.

Run the exact3,085,157-byte qualified compiler source through the same original
request branch and require all118,227,421 independent QBE bytes. The C image
retains source checking, all optimizer passes, final verifier, rendering and
writing. Image acquisition and post-return byte checking remain separate.

The full C request is explicitly allowed6GiB RSS, compared with the ordinary
2GiB limit: smaller complete requests used228/681MiB, and the input increases
to3.085MB. Keep16GiB host availability,5GiB disk reserve, oneCPU3 lane,
300s child deadline and128MiB declared artifacts. The QBE request retains2GiB.
These are limits, not equal-memory guarantees. Full C completed at167.602s
with4074.7MiB peak child RSS and exact QBE, motivating one physical full-request
profile rather than assuming the smaller speed ratios transfer.

Compare with a fresh QBE request. Use the maintained worker-complete sampler
on the successful C image and full input, first at8ms; reject loss/overruns or
insufficient thread coverage. Diagnostic output is redirected through
/dev/stdout into a regular file and still matches the complete oracle; its time
is not pooled into clean named-file timing. Physical leaves do not establish
inclusive caller/stage cost. If one runtime mechanism dominates, a second
targeted observer/ablation is justified; otherwise preserve the broader
implementation/representation question without inventing an explanation.

Do not acquire another full compiler image, change production selection, or
run the45-program suite merely to measure this execution comparison. A second
clean full pair is optional only if the observed difference is small enough
that order/noise changes the architectural decision.
