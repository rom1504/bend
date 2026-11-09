/* Header-only observer contract. This does not replace or link a runtime.
 * Phase181's retained C observer uses a 2088-byte state canary; compile this
 * beside it so that the assumption is checked against the maintained ABI.
 */
#include "runtime.h"
#include "primitives.h"

_Static_assert(P111_ABI_VERSION == UINT64_C(11102), "current native semantic ABI");
_Static_assert(sizeof(P111State) == 2088, "retained observer state canary width");
_Static_assert(sizeof(P111Program) == 192, "emitted descriptor width");
_Static_assert(offsetof(P111Program, segments) == 96, "segment pointer slot");
_Static_assert(offsetof(P111Program, effects) == 184, "effect pointer slot");
_Static_assert(P182_OP_F32_FROM_NAT == 86, "full-width Nat conversion opcode");
_Static_assert(P111_OP_LIMIT == 87, "append-only primitive boundary");
