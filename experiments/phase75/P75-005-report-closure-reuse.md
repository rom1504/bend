# P75-005: reuse completed safe trust closures

The single report query still explores the same Base dependency closure from
every user declaration. A traversal that finishes without unsafe/foreign code
proves all visited names safe in the immutable request book. Reuse only those
positive safety facts across roots. When traversal finds unsafe code, keep the
original root result and discard the partial visited set. Preserve name order,
first-definition lookup and the previous public report APIs as an exact oracle.
Test cyclic safe/unsafe graphs, false-path-before-unsafe, constructors, duplicate
declarations and unresolved names, then all selected checked source reports.
