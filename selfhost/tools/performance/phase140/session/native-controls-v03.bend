# Pure guards, transport arithmetic and cache selection; no file IO here.
# Canonical parse and bound probes use the exact expressions in native-v02.
def p140nn_parsed(text: String, parsed: Maybe<&2,U32>) -> Bool:
  match parsed:
    case None{}: False{}
    case Some{value}: String.eq(text,U32.show(value))

def p140nn_canonical(+text: String) -> Bool:
  p140nn_parsed(text,U32.read(text))

def p140nn_bounds(+begin: U32, +relative: U32, a: U32, b: U32) -> Bool:
  U32.is_le(relative,a) && U32.is_le(relative,b) && U32.is_le(relative,U32.sub(4294967295,begin))

def p140nn_empty(cache: P140NCache) -> Bool:
  match cache:
    case P140NCache{session,P140GCache{passes},render}: List.is_empty(&2,P140GPass,passes)
    case P140NCache{session,P140GMetadata{passes,p,n,a,l,i,x,t},render}: List.is_empty(&2,P140GPass,passes)

@unsafe
def p140n_controls() -> List<&2,String>:
  +marker: P140NCache = P140NCache{p140s_empty(),P140GCache{[P140GPass{missing(),missing(),1,[]}]},P140REmpty{}}
  [p131u_row(p140n_paths("/a","/b","/base","/carrier","/oa","/ob","warm","owner"),"native-warm-paths"),
   p131u_row(p140n_paths("/a","/b","/base","/carrier","/oa","/ob","cold","owner"),"native-cold-paths"),
   p131u_row(Bool.not(p140n_paths("a","/b","/base","/carrier","/oa","/ob","warm","owner")),"native-relative-input"),
   p131u_row(Bool.not(p140n_paths("/a","/b","/base","/carrier","oa","/ob","warm","owner")),"native-relative-output"),
   p131u_row(Bool.not(p140n_paths("/a","/b","/base","/carrier","/oa","/oa","warm","owner")),"native-output-alias"),
   p131u_row(Bool.not(p140n_paths("/a","/b","/base","/carrier","/a","/ob","warm","owner")),"native-overwrite-input"),
   p131u_row(Bool.not(p140n_paths("/a","/b","/base","/carrier","/oa","/ob","other","owner")),"native-unknown-mode"),
   p131u_row(Bool.not(p140n_paths("/a","/b","/base","/carrier","/oa","/ob","warm","")),"native-empty-owner"),
   p131u_row(p140nn_canonical("0"),"native-hint-zero"),
   p131u_row(p140nn_canonical("37"),"native-hint-number"),
   p131u_row(p140nn_canonical("4294967295"),"native-hint-maximum"),
   p131u_row(Bool.not(p140nn_canonical("")),"native-hint-empty"),
   p131u_row(Bool.not(p140nn_canonical("037")),"native-hint-noncanonical"),
   p131u_row(Bool.not(p140nn_canonical("4294967296")),"native-hint-overflow"),
   p131u_row(p140nn_bounds(10,5,5,5),"native-bound-inclusive"),
   p131u_row(Bool.not(p140nn_bounds(10,6,5,7)),"native-bound-source"),
   p131u_row(Bool.not(p140nn_bounds(4294967295,1,1,1)),"native-bound-add-overflow"),
   p131u_row(p140nn_bounds(4294967295,0,0,0),"native-bound-maximum-zero"),
   p131u_row(p140nn_empty(p140n_select(False{},marker)),"native-cold-clears-cache"),
   p131u_row(Bool.not(p140nn_empty(p140n_select(True{},marker))),"native-warm-keeps-cache")]
