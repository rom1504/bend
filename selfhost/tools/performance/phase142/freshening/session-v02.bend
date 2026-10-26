# The immutable producer-owned seed and freshening capability travel together.
# All checking, raw lowering, optimization and final verification remain original.
type P142FreshSession is Data:
  P142FreshSession{+seed: P86Seed, +compiler: P140SCache, +fresh: P142FFCache}

type P142FreshResult is Data:
  P142FreshResult{+emission: P111Emission, +session: P142FreshSession, +stats: List<&2,U32>, +fresh_stats: List<&2,U32>}

def p142fs_begin(seed: P86Seed) -> P142FreshSession:
  P142FreshSession{seed,p140s_empty(),P142FFEmpty{}}

@unsafe
def p142fs_request(+previous: P142FreshSession, path: String, text: String, hint: U32, owner: String) -> P142FreshResult:
  match previous:
    case P142FreshSession{+seed,+compiler,fresh}:
      p142fs_loaded(previous,owner,p142fl_load(seed,path,text,p142fs_parser(compiler),hint,fresh))

def p142fs_parser(compiler: P140SCache) -> Maybe<&2,P140PCache>:
  match compiler:
    case P140SCache{P140FCache{parser,checker,owners},raw,back}: parser

@unsafe
def p142fs_loaded(+previous: P142FreshSession, owner: String, loaded: P142FLResult) -> P142FreshResult:
  match previous loaded:
    case P142FreshSession{+seed,+compiler,old} P142FLResult{result,fresh,stats}:
      p142fs_front(previous,fresh,stats,p140f_named_loaded(seed,p142fs_front_cache(compiler),owner,result))

def p142fs_front_cache(compiler: P140SCache) -> P140FCache:
  match compiler:
    case P140SCache{front,raw,back}: front

@unsafe
def p142fs_front(+previous: P142FreshSession, fresh: P142FFCache, stats: List<&2,U32>, front: P140FResult) -> P142FreshResult:
  match previous:
    case P142FreshSession{seed,compiler,old}:
      p142fs_finished(previous,fresh,stats,p140s_front(compiler,front))

@unsafe
def p142fs_finished(+previous: P142FreshSession, +fresh: P142FFCache, +fresh_stats: List<&2,U32>, result: P140SResult) -> P142FreshResult:
  match previous result:
    case P142FreshSession{seed,old_compiler,old_fresh} P140SResult{+emission,cache,stats}:
      match emission:
        case P111Emission{chunks,+error}:
          P142FreshResult{emission,nt_choose(P142FreshSession,String.is_empty(error),
            u => P142FreshSession{seed,cache,fresh},u => previous),stats,fresh_stats}
        case P134Planned{plan}:
          P142FreshResult{emission,P142FreshSession{seed,cache,fresh},stats,fresh_stats}
