# P195-002 — compose existing verified table lookups into x86

Fresh ray64 profiles assign22.78% CPU to four selector helper leaves. QBE already
replaces those calls with canonical4–64-entry tables; x86 retains calls and
caller spills. Test the existing p126 semantic certificate before allocation,
unsigned full-word clamp and raw-word table loads. No benchmark-name selection.

Version1 source checking refused argument scrutiny order before target execution;
version2 reorders that helper binder. Current exact checked API/ordinary tests
will establish integration separately from helper controls. Do not claim the
leaf23% share is all removable or predicts whole-suite parity.
