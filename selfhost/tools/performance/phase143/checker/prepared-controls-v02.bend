# These controls take the real authenticated Base seed from the host harness.
# They do not fabricate a ready state or bypass prepared-world admission.

@unsafe
def p143cbc_checked(+prepared: KBasePreparedWorld, +load: FPrefixLoad) -> Bool:
  p140ce_checked(p143cb_check_load(prepared,load,False{}),base_prefix_check_world_load(prepared,load)) &&
    p140ce_checked(p143cb_check_load(prepared,load,True{}),base_prefix_check_world_load(prepared,load)) &&
    p140ce_result(p143cb_program(load,[],prepared,True{}),check_program_diagnostic_world(load,[],prepared))

@unsafe
def p143cbc_unready(load: FPrefixLoad) -> FPrefixLoad:
  match load:
    case FPrefixLoad{trace,prefix,suffix,ready}: FPrefixLoad{trace,prefix,suffix,False{}}

@unsafe
def p143cbc_loaded(+prepared: KBasePreparedWorld, loaded: P140PLoadResult, force_fallback: Bool) -> Bool:
  match loaded:
    case P140PLoadReady{+load,cache,hit}:
      nt_choose(Bool,force_fallback,
        u => p143cbc_checked(prepared,p143cbc_unready(load)),
        u => p143cbc_checked(prepared,load))
    case P140PLoadError{error,cache}: False{}

@unsafe
def p143cbc_case(+seed: P86Seed, text: String, force_fallback: Bool) -> Bool:
  match seed:
    case P86Seed{base,book,fresh,ready,world}:
      p143cbc_loaded(world,p140pl_load(seed,"/phase143/prepared.bend",text,None{},0),force_fallback)

@unsafe
def p143cbc_controls(+seed: P86Seed) -> List<&2,String>:
  [p131u_row(p143cbc_case(seed,"import Base\n",False{}),"prepared-empty-suffix-exact-state"),
   p131u_row(p143cbc_case(seed,"import Base\ndef early() -> U32:\n  3\ndef main() -> U32:\n  early\n",False{}),"prepared-body-publication"),
   p131u_row(p143cbc_case(seed,"import Base\ndef early() -> U32:\n  3\ndef main() -> U32:\n  True{}\n",False{}),"prepared-failed-world-and-diagnostic"),
   p131u_row(p143cbc_case(seed,"import Base\ndef early() -> U32:\n  3\ndef ident(~A: Type, x: A) -> A:\n  x\ndef main() -> U32:\n  ident(~U32, 7)\n",False{}),"prepared-template-state"),
   p131u_row(p143cbc_case(seed,"import Base\ndef early() -> U32:\n  3\ndef ident(~A: Type, x: A) -> A:\n  x\ndef use() -> U32:\n  ident(~U32, 7)\ndef main() -> U32:\n  True{}\n",False{}),"prepared-failure-after-template"),
   p131u_row(p143cbc_case(seed,"import Base\ndef main() -> U32:\n  7\n",True{}),"unready-exact-full-check-fallback")]
