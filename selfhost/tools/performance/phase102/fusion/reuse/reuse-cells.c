/* Experimental private cache of one uniquely transferred constructor cell.
 * ctr_take's returned cell has no remaining owner. Its fields have already
 * moved to ordinary local Terms. Shared inputs return zero; static inputs
 * may return a read-only location below HEAP_OFF and must never be cached.
 * The public wrapper frees any unused cell before publishing its result.
 */
INLINE void p102_trmc_keep_cell(Env e, Term* state, Cls cls, Loc cell) {
  if (cell < HEAP_OFF) return;
  if (state[2]) spare_free(e, (Cls)state[3], (Loc)state[2]);
  state[2] = cell;
  state[3] = cls;
}

INLINE Loc p102_trmc_take_cell(Env e, Term* state, Cls cls) {
  if (state[2] && state[3] == cls) {
    Loc cell = (Loc)state[2];
    state[2] = 0;
    return cell;
  }
  return heap_alloc(e, cls);
}
