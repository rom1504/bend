#ifndef P199_SCAN_H
#define P199_SCAN_H
#include <stdint.h>
/* SysV x86-64: RDI=data, RSI=mask, RDX=fuel, RCX=index, R8=carry; RAX=result.
 * data is the resolved, exclusively owned packed U32 array payload.
 * mask=(1ULL<<class)-1, class<=31, with at least mask+1 writable U32 cells.
 * No ownership is transferred; no allocation, runtime state or global is used.
 * Zero fuel preserves all carry bits and never dereferences data.
 * Nonzero fuel uses low32 index/carry; fuel itself is never narrowed.
 */
uint64_t p199_rt_u32_scan4(uint32_t *data, uint64_t mask, uint64_t fuel,
                         uint64_t index, uint64_t carry);
#endif
