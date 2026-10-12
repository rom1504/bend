# P75-013: branch-boundary layout falsifier

Common function sizes stay equal but addresses change. Function-only alignment is insufficient; check whether keeping branch instructions within32-byte blocks recovers the loss. Use Clang x86 flag -mbranches-within-32B-boundaries plus WL_FN aligned64 on saved candidate09 C. This is platform-specific diagnostic evidence, never parity evidence or a portable source rule.
