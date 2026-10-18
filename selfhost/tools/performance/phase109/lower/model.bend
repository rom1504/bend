# Ownership is explicit here; NxU64 is only the final machine representation.
# The input must be an authenticated NativeErasedBody from nr_prepare_annotated.
type NxoCtor is Data:
  NxoCtor{+name: String, +cid: U32, +arity: U32}

type NxoOp is Data:
  NxoKeep{+word: String}
  NxoSink{+word: String}
  NxoBuild{+dest: String, +cid: U32, +fields: List<&2, String>}
  NxoTake{+word: String, +fields: List<&2, String>}
  NxoBranch{+word: String, +cid: U32, +yes: List<&2, NxoOp>, +no: List<&2, NxoOp>}
  NxoReturn{+word: String}
  NxoTail{+words: List<&2, String>}
  NxoFail{+code: U32}

type NxoBinding is Data:
  NxoBinding{+id: U32, +word: String}

type NxoUse is Data:
  NxoUse{+id: U32, +word: String, +left: U32}

type NxoCode is Data:
  NxoCode{+body: List<&2, NxoOp>, +next: U32, +error: String}

type NxoValue is Data:
  NxoValue{+body: List<&2, NxoOp>, +word: String, +uses: List<&2, NxoUse>, +next: U32, +error: String}

type NxoValues is Data:
  NxoValues{+body: List<&2, NxoOp>, +words: List<&2, String>, +uses: List<&2, NxoUse>, +next: U32, +error: String}

type NxoResult is Data:
  NxoResult{+function: NxFunction, +ownership: List<&2, NxoOp>, +error: String}
