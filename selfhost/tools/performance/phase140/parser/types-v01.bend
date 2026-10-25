# Private in-process experimental parser state; never accept untrusted snapshots.
type P140PStop is Data:
  P140PDone{+raw: FRawResult}
  P140PCut{+input: FInput, +book: List<&2,KDef>, +imports: List<&2,KTerm>, +unsafe: Bool, +scope: FParseScope}

type P140PCache is Data:
  P140PCache{+source: String, +initial: FParseScope, +start: U32, +token: FToken, +previous: FToken, +context: FParseContext, +book: List<&2,KDef>, +imports: List<&2,KTerm>, +unsafe: Bool, +scope: FParseScope}

type P140PParsed is Data:
  P140PParsed{+result: FResult, +cache: Maybe<&2,P140PCache>, +hit: Bool}

type P140PMatch is Data:
  P140PMatch{+tail: String, +same: Bool}

@unsafe
def p140p_result(book: List<&2,KDef>, error: KTerm, imports: List<&2,KTerm>) -> P140PStop:
  P140PDone{f_result(book,error,imports)}
