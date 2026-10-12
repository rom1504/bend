# P75-008: host scheduler ABI after dead-body elimination

Alignment recovers tree (288ms old,296ms unaligned,289.5ms aligned), but not
Array.map (457/477/476.5ms). Inspection finds that body removal shrinks the latter
logical register bank from7 to4; its closure-apply machine function changes
from402 to269 bytes. Tree keeps its7-register bank. Smaller is not always faster.

Test the general host ABI policy minimum7 logical registers, combined with the
64-byte host-entry alignment, on saved C. Preserve return width and bang metadata.
No source-name selection. If useful, check all twelve families before committing
the actual policy; avoid changing the device's register policy. More registers
are a performance experiment, not a semantic requirement or claimed universal win.
