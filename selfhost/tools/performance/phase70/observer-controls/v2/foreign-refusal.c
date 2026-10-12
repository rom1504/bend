/* Unknown user foreign access must disable the global observer permission,
   even though this particular effect happens to return its scalar argument. */
static Term outside_echo_run(Env e, Term* fields, IoWork* work) {
  (void)e;
  (void)work;
  return fields[0];
}

static void __attribute__((constructor)) outside_echo_use(void) {
  io_eff(CID(outside.echo), outside_echo_run);
}
