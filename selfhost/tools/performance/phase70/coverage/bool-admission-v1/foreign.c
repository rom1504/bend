// Canonical return on purpose: even a well-behaved arbitrary foreign producer
// must withhold the checked whole-program array representation permission.
Term coin_run(Env e, Term* fields, IoWork* work) {
  return (Term)((u32)fields[0] != 0);
}

static void __attribute__((constructor)) coin_use(void) {
  io_eff(CID(coin), coin_run);
}
