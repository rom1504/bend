law nc_erase_value:
  for +book: List<&2,KDef>
  for +t: KTerm
  KTerm

law nc_erase_list_value:
  for +book: List<&2,KDef>
  for +ts: List<&2,KTerm>
  List<&2,KTerm>

law nc_erase_args_value:
  for +book: List<&2,KDef>
  for +tel: KTerm
  for +xs: List<&2,KTerm>
  List<&2,KTerm>

law nc_erase_mat_value:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +adt: KTerm
  KTerm

law nc_erase_annotated_value:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +ty: KTerm
  KTerm

law nc_erase_app_value:
  for +book: List<&2,KDef>
  for +t: KTerm
  KTerm

law nc_definition_value:
  for +book: List<&2,KDef>
  for +d: KDef
  for +n: U32
  KTerm

law nr_visit_product:
  for +book: List<&2,KDef>
  for +name: String
  for +todo: List<&2,String>
  for +done: List<&2,String>
  for +facts: List<&2,KDef>
  for +seen: KDef
  for +d: KDef
  NR_Closure

law nr_visit_unindexed_product:
  for +book: List<&2,KDef>
  for +name: String
  for +todo: List<&2,String>
  for +done: List<&2,String>
  for +facts: List<&2,KDef>
  for +d: KDef
  NR_Closure

law nr_incremental_product:
  for +book: List<&2,KDef>
  for +name: String
  for todo: List<&2,String>
  for done: List<&2,String>
  for facts: List<&2,KDef>
  for analysis: P140OAnalysis
  for seen: KDef
  for previous: List<&2,P140OEEntry>
  for entries: List<&2,P140OEEntry>
  for hits: U32
  for misses: U32
  for +d: KDef
  P140OEResult
