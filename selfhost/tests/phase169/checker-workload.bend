# Actual loader/checker work from the ten nonempty, parse-success Phase156
# publication fixtures. Empty and duplicate-parser-refusal cases are excluded.
# Exact historical paths retain the independently captured source ranges.
type P169CFixture is Data:
  P169CFixture{+name: String, +expected_error: String, +source: String}

type P169CResult is Data:
  P169CParsed{+book: List<&2,KDef>, +checked: DChecking}
  P169CParseError{+error: String}

type P169CAcc is Data:
  P169CAcc{+cases: U32, +accepted: U32, +rejected: U32, +mismatches: U32,
    +records: U32, +hash: U32, +second: U32}

def p169c_fixtures() -> List<&2,P169CFixture>:
  [P169CFixture{"consecutive-adts","","type Bit is Data:\n  Off{}\n  Onn{}\ntype Other is Data:\n  Else{}\ndef keep() -> Bit:\n  Off{}\n"},
   P169CFixture{"dirty-flush-clean-run","","type Bit is Data:\n  Off{}\ndef keep() -> Bit:\n  Off{}\ntype A is Data:\n  Aa{}\ntype B is Data:\n  Bb{}\ndef last() -> B:\n  Bb{}\n"},
   P169CFixture{"clean-type-failure","bad: type mismatch","type Bit is Data:\n  Off{}\ntype Other is Data:\n  Else{}\ndef bad() -> Bit:\n  Other\n"},
   P169CFixture{"dirty-type-failure","bad: type mismatch","type Bit is Data:\n  Off{}\ndef good() -> Bit:\n  Off{}\ndef bad() -> Bit:\n  Bit\n"},
   P169CFixture{"template-clean-entry-success","","type Bit is Data:\n  Off{}\ndef ident(~A: Type, x: A) -> A:\n  x\ntype Barrier is Data:\n  Stop{}\ndef use() -> Bit:\n  ident(~Bit, Off{})\ntype After is Data:\n  End{}\ntype Final is Data:\n  Last{}\n"},
   P169CFixture{"template-failure-after-instantiation","bad: type mismatch","type Bit is Data:\n  Off{}\ndef early() -> Bit:\n  Off{}\ndef ident(~A: Type, x: A) -> A:\n  x\ndef use() -> Bit:\n  ident(~Bit, Off{})\ntype Barrier is Data:\n  Stop{}\ndef bad() -> Bit:\n  Bit\n"},
   P169CFixture{"template-body-failure-clean-entry","bad: type mismatch","type Bit is Data:\n  Off{}\ntype Barrier is Data:\n  Stop{}\ndef bad(~A: Type, x: A) -> Bit:\n  x\n"},
   P169CFixture{"law-fill","","type Bit is Data:\n  Off{}\nlaw f: Bit -> Bit\ntype Barrier is Data:\n  Stop{}\ndef f(x): x\ndef use() -> Bit:\n  f(Off{})\n"},
   P169CFixture{"open-law","","type Bit is Data:\n  Off{}\nlaw f: Bit -> Bit\n"},
   P169CFixture{"post-body-adt","","type Bit is Data:\n  Off{}\ndef choose() -> Bit:\n  Off{}\ntype Other is Data:\n  Else{}\n"}]

@unsafe
def p169c_loaded(trace: FLoadTrace) -> P169CResult:
  match trace:
    case FLoadTrace{FResult{+book,+error,imports},done,sources}:
      nt_choose(P169CResult,String.is_empty(error),
        u => P169CParsed{book,p143cp_check(book,True{})},
        u => P169CParseError{error})

@unsafe
def p169c_fixture(fixture: P169CFixture) -> P169CResult:
  match fixture:
    case P169CFixture{name,expected_error,source}:
      +path = "/phase156/" ++ name ++ ".bend"
      p169c_loaded(f_load_graph_trace(path,[FSource{path,path,source}]))

@unsafe
def p169c_at(+index: U32, fixtures: List<&2,P169CFixture>) -> P169CResult:
  match fixtures:
    case Nil{}: P169CParseError{"unknown checker fixture"}
    case Con{head,rest}:
      nt_choose(P169CResult,U32.is_eq(index,0),u => p169c_fixture(head),
        u => p169c_at(U32.sub(index,1),rest))

@unsafe
def p169c_result(index: U32) -> P169CResult:
  p169c_at(index,p169c_fixtures())

# All-field DChecking consumer; p163r_scan handles complete KDef/KTerm payloads.
# Extra explicit tags delimit the other product, sum and list fields.
@unsafe
def p169c_memo(memo: List<&2,KSpecMemo>) -> List<&2,P163RWork>:
  match memo:
    case Nil{}: [P163RWord{80}]
    case Con{KSpecMemo{template,key,name,active},rest}:
      nt_append(P163RWork,[P163RWord{81},P163RText{template},P163RText{key},
        P163RText{name},P163RWord{Bool.to_u32(active)}],p169c_memo(rest))

@unsafe
def p169c_fresh(fresh: KWorldFresh) -> List<&2,P163RWork>:
  match fresh:
    case KFreshKnown{next}: [P163RWord{90},P163RWord{next}]
    case KFreshDeferred{roots}: [P163RWord{91},P163RTerms{roots}]

@unsafe
def p169c_expr(expr: DExpr) -> List<&2,P163RWork>:
  match expr:
    case DText{text}: [P163RWord{100},P163RText{text}]
    case DTerm{term}: [P163RWord{101},P163RTerm{term}]

@unsafe
def p169c_span(span: DSpan) -> List<&2,P163RWork>:
  match span:
    case DNoSpan{}: [P163RWord{110}]
    case DSpan{source,begin,end}: [P163RWord{111},P163RText{source},P163RWord{begin},P163RWord{end}]

@unsafe
def p169c_diagnostic(diagnostic: DDiagnostic) -> List<&2,P163RWork>:
  match diagnostic:
    case DDiagnostic{expected,observed,has_observed,context,definition,span,note,trail}:
      nt_append(P163RWork,[P163RWord{120}],nt_append(P163RWork,p169c_expr(expected),
        nt_append(P163RWork,p169c_expr(observed),nt_append(P163RWork,
          [P163RWord{Bool.to_u32(has_observed)},P163RTerms{context},P163RText{definition}],
          nt_append(P163RWork,p169c_span(span),[P163RText{note},P163RTerms{trail}])))))

@unsafe
def p169c_world(world: KWorld) -> List<&2,P163RWork>:
  match world:
    case KWorld{book,memo,fresh,checked}:
      nt_append(P163RWork,[P163RWord{130},P163RDefs{book}],nt_append(P163RWork,
        p169c_memo(memo),nt_append(P163RWork,p169c_fresh(fresh),[P163RDefs{checked}])))

@unsafe
def p169c_work(checked: DChecking) -> List<&2,P163RWork>:
  match checked:
    case DChecking{KChecking{term,typ,uses,error,world,consumed},diagnostic}:
      nt_append(P163RWork,[P163RWord{140},P163RTerm{term},P163RTerm{typ},P163RTerms{uses},
        P163RText{error},P163RWord{consumed}],
        nt_append(P163RWork,p169c_world(world),p169c_diagnostic(diagnostic)))

@unsafe
def p169c_error(checked: DChecking) -> String:
  match checked:
    case DChecking{result,diagnostic}: ce(result)

@unsafe
def p169c_digest_done(cases: U32, accepted: U32, rejected: U32, mismatches: U32,
    digest: List<&2,U32>) -> P169CAcc:
  match digest:
    case Con{records,Con{hash,Con{second,Nil{}}}}:
      P169CAcc{cases,accepted,rejected,mismatches,records,hash,second}
    case _: P169CAcc{cases,accepted,rejected,U32.inc(mismatches),0,0,0}

@unsafe
def p169c_consume(expected: String, result: P169CResult, acc: P169CAcc) -> P169CAcc:
  match result acc:
    case P169CParsed{book,+checked} P169CAcc{cases,accepted,rejected,mismatches,records,hash,second}:
      +error = p169c_error(checked)
      +success = String.is_empty(error)
      p169c_digest_done(U32.inc(cases),U32.add(accepted,Bool.to_u32(success)),
        U32.add(rejected,Bool.to_u32(Bool.not(success))),
        U32.add(mismatches,Bool.to_u32(Bool.not(String.eq(error,expected)))),
        p163r_scan(Con{P163RDefs{book},p169c_work(checked)},hash,second,records))
    case P169CParseError{error} P169CAcc{cases,accepted,rejected,mismatches,records,hash,second}:
      p169c_digest_done(U32.inc(cases),accepted,rejected,U32.inc(mismatches),
        p163r_scan([P163RWord{999},P163RText{error}],hash,second,records))

@unsafe
def p169c_round(fixtures: List<&2,P169CFixture>, acc: P169CAcc) -> P169CAcc:
  match fixtures:
    case Nil{}: acc
    case Con{+fixture,rest}:
      match fixture:
        case P169CFixture{name,expected_error,source}:
          p169c_round(rest,p169c_consume(expected_error,p169c_fixture(fixture),acc))

@unsafe
def p169c_loop(+rounds: U32, +acc: P169CAcc) -> P169CAcc:
  nt_choose(P169CAcc,U32.is_eq(rounds,0),u => acc,
    u => p169c_loop(U32.sub(rounds,1),p169c_round(p169c_fixtures(),acc)))

def p169c_output(acc: P169CAcc) -> List<&2,U32>:
  match acc:
    case P169CAcc{cases,accepted,rejected,mismatches,records,hash,second}:
      [cases,accepted,rejected,mismatches,records,hash,second]

@unsafe
def p169c_run(rounds: U32) -> List<&2,U32>:
  p169c_output(p169c_loop(rounds,P169CAcc{0,0,0,0,0,2166136261,5381}))
