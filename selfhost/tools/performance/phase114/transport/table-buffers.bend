# Exact bounded H-emitter allocation names, not a general prefix certificate.
@unsafe
def p114t_table_buffer_at(+name: String, +index: U32) -> Bool:
  nt_choose(Bool,U32.is_ge(index,8),u => False{},u =>
    nt_choose(Bool,String.eq(name,p112f_name(p114h_prefix(index),"scratch")),
      v => True{},v => p114t_table_buffer_at(name,U32.inc(index))))

@unsafe
def p114t_table_buffer(+name: String) -> Bool:
  nt_choose(Bool,String.starts_with(name,"p114h_case_"),
    u => p114t_table_buffer_at(name,0),u => False{})

@unsafe
def p114t_buffer(+name: String) -> Bool:
  p113j_buffer_origin(name,True{}) || p114t_fusion_buffer(name,0) || p114t_table_buffer(name)

# The original verifier checks definitions before emission. Original graphs
# cannot claim these names; only the authenticated H rewrite introduces them.
@unsafe
def p114t_local_name(+name: String) -> Bool:
  Bool.not(String.starts_with(name,"p114t_") || p114t_table_buffer(name))
