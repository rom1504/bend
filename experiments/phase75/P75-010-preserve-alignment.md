# P75-010: preserve-ABI alignment

WL-only hot/alignment and bank stability failed to recover Array.map. Inspecting assembly shows runtime transition functions (corpus_eval, pool_open) also move, including unaligned preserve_all bodies. Test aligned(64) on PRESERVE ABI functions; unchanged functions and workers, all programs under same rule. Broader twelve required before any adoption.
