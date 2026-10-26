# Direct range controls never execute an enormous original freshness loop.
# Large-left cases check explicit expected membership, not a sampled surrogate.
@unsafe
def p143ot_interval(+id: U32, +n: U32, +left: U32, +expected: Bool) -> Bool:
  p134v_bool(p143o_in_range(id,n,left),expected)

@unsafe
def p143o_range_controls() -> List<&2,String>:
  [p114st_row("range-zero-excludes-first",p143ot_interval(4294967295,0,0,False{})),
   p114st_row("range-single-includes-first",p143ot_interval(4294967295,0,1,True{})),
   p114st_row("range-single-excludes-next",p143ot_interval(4294967294,0,1,False{})),
   p114st_row("range-max-count-excludes-zero",p143ot_interval(0,0,4294967295,False{})),
   p114st_row("range-max-count-includes-one",p143ot_interval(1,0,4294967295,True{})),
   p114st_row("range-max-count-includes-max",p143ot_interval(4294967295,0,4294967295,True{})),
   p114st_row("range-shifted-max-excludes-one",p143ot_interval(1,4294967295,4294967295,False{})),
   p114st_row("range-shifted-max-includes-zero",p143ot_interval(0,4294967295,4294967295,True{})),
   p114st_row("range-shifted-max-includes-two",p143ot_interval(2,4294967295,4294967295,True{})),
   p114st_row("range-wrap64-first",p143ot_interval(1,4294967294,64,True{})),
   p114st_row("range-wrap64-last",p143ot_interval(4294967234,4294967294,64,True{})),
   p114st_row("range-wrap64-after",p143ot_interval(4294967233,4294967294,64,False{})),
   p114st_row("range-highbit-first",p143ot_interval(2147483647,2147483648,2,True{})),
   p114st_row("range-highbit-before",p143ot_interval(2147483648,2147483648,2,False{}))]
