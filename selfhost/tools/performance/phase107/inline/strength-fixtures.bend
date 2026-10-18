# The product helper exposes the full width. U64 main compares its complete
# result with a supplied expected U64; controls also pass a wrong high-half value.
def nx_sr_fixture_type(+width: U32) -> NxType:
  nx_choose(NxType, U32.is_eq(width, 32), u => NxU32{},
    u => nx_choose(NxType, U32.is_eq(width, 64), u => NxU64{}, u => NxBad{}))

def nx_sr_fixture_mul(+typ: NxType, +factor: U32, +left: Bool, +atom: NxExpr) -> NxExpr:
  nx_choose(NxExpr, left, u => NxBin{"mul", NxConst{typ, factor}, atom},
    u => NxBin{"mul", atom, NxConst{typ, factor}})

def nx_sr_fixture_main(+typ: NxType) -> NxFunction:
  nx_choose(NxFunction, nx_type_equal(typ, NxU32{}),
    u => NxFunction{"main", [NxParam{"x", typ}], NxU32{}, [], [NxReturn{NxCall{"product", [NxVar{"x"}]}}]},
    u => NxFunction{"main", [NxParam{"x", typ}, NxParam{"expected", typ}], NxU32{}, [NxParam{"actual", typ}],
      [NxSet{"actual", NxCall{"product", [NxVar{"x"}]}}, NxReturn{NxBin{"eq", NxVar{"actual"}, NxVar{"expected"}}}]})

def nx_sr_fixture_at(+typ: NxType, +factor: U32, +left: Bool) -> NxProgram:
  NxProgram{"main", [NxFunction{"product", [NxParam{"x", typ}], typ, [],
    [NxReturn{nx_sr_fixture_mul(typ, factor, left, NxVar{"x"})}]}, nx_sr_fixture_main(typ)]}

def nx_sr_fixture(width: U32, factor: U32, left: Bool) -> NxProgram:
  nx_sr_fixture_at(nx_sr_fixture_type(width), factor, left)

def nx_sr_nonatom() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [NxParam{"x", NxU32{}}], NxU32{}, [],
    [NxReturn{nx_sr_fixture_mul(NxU32{}, 33, False{}, NxBin{"add", NxVar{"x"}, NxConst{NxU32{}, 1}})}]}]}

def nx_sr_nested() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [NxParam{"x", NxU32{}}], NxU32{}, [],
    [NxReturn{NxBin{"xor", nx_sr_fixture_mul(NxU32{}, 17, False{}, NxVar{"x"}), NxConst{NxU32{}, 4294967295}}}]}]}

def nx_sr_invalid() -> NxProgram:
  NxProgram{"main", [NxFunction{"main", [NxParam{"x", NxU32{}}], NxU32{}, [],
    [NxReturn{nx_sr_fixture_mul(NxU64{}, 33, False{}, NxVar{"x"})}]}]}

def nx_sr_fixture_extra(+name: String) -> Maybe<&2, NxProgram>:
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "nonatom"), u => Some{nx_sr_nonatom()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "nested"), u => Some{nx_sr_nested()}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "invalid_width"), u => Some{nx_sr_fixture(16, 33, False{})}, u =>
  nx_choose(Maybe<&2, NxProgram>, String.eq(name, "invalid_mixed"), u => Some{nx_sr_invalid()}, u => None{}))))
