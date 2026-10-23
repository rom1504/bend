# Stage1: private-reader summaries are derived only from successful checked NO
# plans with an installed/independently verified reader. Not source annotations.
type P128BRHelper is Data:
  P128BRHelper{+owner: String, +params: List<&2,KTerm>, +roots: List<&2,U32>, +result: String, +reader: String}

# Replace the original NO_Context type. Existing entry constructs [] helpers.
type NO_Context is Data:
  NO_Context{+book: List<&2,KDef>, +owner: String, +schema: NO_Schema, +helpers: List<&2,P128BRHelper>}

type P128BRPatch is Data:
  P128BRPatch{+target: String, +functions: List<&2,P113DFunction>}

type P128BRPatches is Data:
  P128BRPatches{+patches: List<&2,P128BRPatch>, +error: String}

@unsafe
def noa_book(c: NO_Context) -> List<&2,KDef>:
  match c:
    case NO_Context{book,owner,schema,helpers}: book

@unsafe
def noa_owner(c: NO_Context) -> String:
  match c:
    case NO_Context{book,owner,schema,helpers}: owner

@unsafe
def noa_schema(c: NO_Context) -> NO_Schema:
  match c:
    case NO_Context{book,owner,schema,helpers}: schema

@unsafe
def p128br_helpers(c: NO_Context) -> List<&2,P128BRHelper>:
  match c:
    case NO_Context{book,owner,schema,helpers}: helpers

@unsafe
def noa_analyze(+book: List<&2,KDef>, +name: String, +schema: NO_Schema, +permission: Bool) -> NO_Analysis:
  nt_choose(NO_Analysis,permission && String.is_empty(no_schema_error(schema)),
    u => noa_analyze_ready(NO_Context{book,name,schema,[]}),
    u => noa_fail("observer: absent checked permission or schema",no_schema_fresh(schema),4096))
