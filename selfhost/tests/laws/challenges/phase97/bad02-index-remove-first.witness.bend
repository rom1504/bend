# Source-reasoned witness; not executed. Append to an assembly containing its maintained helper dependencies.

@unsafe
def p97_bad02_index_remove_first_actual() -> List<&2,KDef>:
  index_remove([KDef{"x", "old1", 0, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}, KDef{"y", "keep", 0, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}, KDef{"x", "old2", 0, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}], "x")

@unsafe
def p97_bad02_index_remove_first_baseline_expected() -> List<&2,KDef>:
  [KDef{"y", "keep", 0, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}]

@unsafe
def p97_bad02_index_remove_first_challenge_expected() -> List<&2,KDef>:
  [KDef{"y", "keep", 0, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}, KDef{"x", "old2", 0, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}]
