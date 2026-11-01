# Isolated scalar spellings of two closed, fixed-result U32 tables.
# Literal values become scalar equality operands, never literal patterns.
# A finite safe chooser retains p112fp_binary safety and lazy result selection.
def p151_choose(-A: Type, +b: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match b:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

@unsafe
def p151_roles(+tag: U32) -> List<&2,U32>:
  p151_choose(List<&2,U32>,U32.is_eq(tag,1),u => [13,14],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,2),u => [3,3,1,1,6,8,1,1],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,3),u => [3,1,1,6,8,1,1,2],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,4),u => [3,1,3,1,1],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,5),u => [3,3,1,1,4,4,7,2,2],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,6),u => [1,7],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,7),u => [1,1,5,5],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,8),u => [1,1,1,7,2],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,9),u => [1,2],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,10),u => [9,7,7,7,7,7,1,1],u =>
  p151_choose(List<&2,U32>,U32.is_eq(tag,11),u => [5,5,1,2],u => [])))))))))))

def p151_binary(+id: U32) -> String:
  p151_choose(String,U32.is_eq(id,26),u => "add",u =>
  p151_choose(String,U32.is_eq(id,27),u => "sub",u =>
  p151_choose(String,U32.is_eq(id,28),u => "mul",u =>
  p151_choose(String,U32.is_eq(id,29),u => "div",u =>
  p151_choose(String,U32.is_eq(id,30),u => "ceqs",u =>
  p151_choose(String,U32.is_eq(id,31),u => "cnes",u =>
  p151_choose(String,U32.is_eq(id,32),u => "clts",u =>
  p151_choose(String,U32.is_eq(id,33),u => "cles",u =>
  p151_choose(String,U32.is_eq(id,34),u => "cgts",u =>
  p151_choose(String,U32.is_eq(id,35),u => "cges",u => "INVALID_P112_FLOAT_OPERATION"))))))))))
