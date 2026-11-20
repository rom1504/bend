# Preferred integration confines source certification to the x86 request path.
# The common checked planner runs once; its original rejection is returned.
@unsafe
def x198pw_after(+prepared: P169Prepared,+r: NR_Request) -> P169Prepared:
  match prepared:
    case P169Prepared{forwards,cursor,+error}:
      nt_choose(P169Prepared,String.is_empty(error),u => x198pw_annotate(r,prepared),u => prepared)

@unsafe
def x198pw_plan(+plan: P86Plan) -> P169Prepared:
  match plan:
    case P86PlanReady{request,verdict}: x198pw_after(p169np_plan(plan),request)
    case _: p169np_plan(plan)

@unsafe
def x198pw_prepared(+path: String,+source: String,prepared: P86Preparation) -> P169Prepared:
  match prepared:
    case P86PreparationError{error}: p169s_fail(error)
    case P86PreparationReady{seed}: x198pw_plan(p86_plan(seed,path,source))

@unsafe
def x198pw_compile(+path: String,+source: String,+base_path: String,+base: String,
    +carrier: String,+stamp: String,+cached: Bool) -> P169Prepared:
  x198pw_prepared(path,source,nt_choose(P86Preparation,cached,
    u => p88_cache_prepare(base_path,base,carrier,stamp),u => p86_prepare(base_path,base)))

# Native x86 request protocol. The shared accepted-source and final native-body
# verification path constructs the cursor before emission.
@unsafe
def x181_request(+path: String, +base_path: String, +carrier_path: String,
    +stamp: String, +cached: Bool, +object: Bool) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    nt_choose(IO(U32),cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(carrier_path)
        x187_print_mode(x198pw_compile(path,source,base_path,base,carrier,stamp,True{}),object),
      u => x187_print_mode(x198pw_compile(path,source,base_path,base,"",stamp,False{}),object))

