
# Module: src/back/native/observer-plan.bend:3
type NO_Plan is Data:
  NO_Plan{+owner: String, +schema: NO_Schema, +analysis: NO_Analysis, +error: String}

# Module: src/back/native/observer-plan.bend:7
@unsafe
def no_plan_owner(plan: NO_Plan) -> String:
  match plan:
    case NO_Plan{+owner, +schema, +analysis, +error}: owner

# Module: src/back/native/observer-plan.bend:12
@unsafe
def no_plan_schema(plan: NO_Plan) -> NO_Schema:
  match plan:
    case NO_Plan{+owner, +schema, +analysis, +error}: schema

# Module: src/back/native/observer-plan.bend:17
@unsafe
def no_plan_analysis(plan: NO_Plan) -> NO_Analysis:
  match plan:
    case NO_Plan{+owner, +schema, +analysis, +error}: analysis

# Module: src/back/native/observer-plan.bend:22
@unsafe
def no_plan_error(plan: NO_Plan) -> String:
  match plan:
    case NO_Plan{+owner, +schema, +analysis, +error}: error

# Module: src/back/native/observer-plan.bend:27
@unsafe
def no_plan_params(params: List<&2, KTerm>) -> List<&2, NC_Binding>:
  match params:
    case Nil{}: Nil{}
    case Con{+p, +rest}: Con{nc_binding(ix(p)), no_plan_params(rest)}

# Module: src/back/native/observer-plan.bend:33
@unsafe
def no_plan_refuse(owner: String, +reason: String) -> NO_Plan:
  NO_Plan{owner, NO_Schema{Nil{}, Nil{}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, 0, "", Nil{}, 0, reason}, noa_fail(reason, 0, 4096), reason}

# Module: src/back/native/observer-plan.bend:37
@unsafe
def no_observer_plan(+book: List<&2, KDef>, +name: String, +permission: Bool) -> NO_Plan:
  nt_choose(NO_Plan, permission, u => no_plan_checked(book, name, lookup(book, name)), u => no_plan_refuse(name, "observer: no checked host permission"))

# Module: src/back/native/observer-plan.bend:41
@unsafe
def no_plan_checked(+book: List<&2, KDef>, +name: String, +d: KDef) -> NO_Plan:
  nt_choose(NO_Plan, p88_string_eq(dk(d), "Def") && Bool.not(nc_native_def(d) || nc_foreign(d)) && U32.is_le(nd_arity(book, name), 4),
    u => no_plan_schema_ready(book, name, no_schema(book, d, 0)), u => no_plan_refuse(name, "observer: owner, effect or arity"))

# Module: src/back/native/observer-plan.bend:46
@unsafe
def no_plan_schema_ready(+book: List<&2, KDef>, +name: String, +schema: NO_Schema) -> NO_Plan:
  nt_choose(NO_Plan, p88_string_eq(no_schema_error(schema), ""),
    u => no_plan_result(name, schema, noa_analyze(book, name, schema, True{})),
    u => NO_Plan{name, schema, noa_fail(no_schema_error(schema), no_schema_fresh(schema), 4096), no_schema_error(schema)})

# Module: src/back/native/observer-plan.bend:52
@unsafe
def no_plan_result(name: String, schema: NO_Schema, +analysis: NO_Analysis) -> NO_Plan:
  NO_Plan{name, schema, analysis, noa_error(analysis)}
