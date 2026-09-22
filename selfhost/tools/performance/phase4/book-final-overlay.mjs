// Isolated Bend overlay for exact final-definition selection.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';

const [baselineArgument, outputArgument] = process.argv.slice(2);
if (!outputArgument) throw Error('Usage: book-final-overlay.mjs BASELINE NEW_OVERLAY');
const baseline = fs.realpathSync(baselineArgument), out = path.resolve(outputArgument);
fs.mkdirSync(out, {recursive: false});
function write(relative, transform) {
  const before = fs.readFileSync(path.join(baseline, relative), 'utf8');
  const after = transform(before);
  assert.notEqual(after, before);
  const destination = path.join(out, relative); fs.mkdirSync(path.dirname(destination), {recursive: true});
  fs.writeFileSync(destination, after);
}
write('src/core/index.bend', text => text + `

# Exact final-definition selection. Short event lists use the original scan.
# Marker values distinguish even the empty name from an unsuccessful lookup.
law book_final_fast:
  for +book: List<&2,KDef>
  for +done: List<&2,KDef>
  List<&2,KDef>

law book_final_large:
  for +book: List<&2,KDef>
  for +remaining: U32
  Bool

law book_final_reverse:
  for +book: List<&2,KDef>
  for +done: List<&2,KDef>
  List<&2,KDef>

law book_final_scan:
  for +book: List<&2,KDef>
  for +seen: KDef
  for +kept: List<&2,KDef>
  for +done: List<&2,KDef>
  List<&2,KDef>

law book_final_step:
  for +d: KDef
  for +rest: List<&2,KDef>
  for +seen: KDef
  for +kept: List<&2,KDef>
  for +done: List<&2,KDef>
  for +hash: U32
  List<&2,KDef>

law book_final_filter:
  for +done: List<&2,KDef>
  for +seen: KDef
  List<&2,KDef>

law book_final_seen:
  for +seen: KDef
  for +name: String
  for +hash: U32
  Bool

law book_final_legacy:
  for +book: List<&2,KDef>
  for +done: List<&2,KDef>
  List<&2,KDef>

@unsafe
def book_final_large(book, remaining):
  kc(Bool, U32.is_eq(remaining, 0), u => True{}, u =>
    match book:
      case Nil{}: False{}
      case Con{h, rest}: book_final_large(rest, U32.sub(remaining, 1)))

@unsafe
def book_final_fast(book, done):
  kc(List<&2,KDef>, book_final_large(book, 64),
    u => book_final_scan(book_final_reverse(book, Nil{}), missing(), Nil{}, done),
    u => book_final_legacy(book, done))

@unsafe
def book_final_reverse(book, done):
  match book:
    case Nil{}: done
    case Con{d, rest}: book_final_reverse(rest, Con{d, done})

@unsafe
def book_final_seen(seen, name, hash):
  String.eq(dk(index_find(seen, name, hash, 32)), "$final.seen")

@unsafe
def book_final_scan(book, seen, kept, done):
  match book:
    case Nil{}: book_final_reverse(kept, book_final_filter(done, seen))
    case Con{d, rest}:
      book_final_step(d, rest, seen, kept, done, index_hash(dn(d), 2166136261))

@unsafe
def book_final_step(d, rest, seen, kept, done, hash):
  kc(List<&2,KDef>, book_final_seen(seen, dn(d), hash),
    u => book_final_scan(rest, seen, kept, done),
    u => book_final_scan(rest,
      index_set(seen, KDef{dn(d), "$final.seen", 0, 0, atom("Absent"), atom("Absent"), Nil{}, True{}, False{}}, hash, 32),
      Con{d, kept}, done))

@unsafe
def book_final_filter(done, seen):
  match done:
    case Nil{}: Nil{}
    case Con{d, rest}:
      kc(List<&2,KDef>, book_final_seen(seen, dn(d), index_hash(dn(d), 2166136261)),
        u => book_final_filter(rest, seen),
        u => Con{d, book_final_filter(rest, seen)})

@unsafe
def book_final_legacy(book, done):
  match book:
    case Nil{}: done
    case Con{d, rest}: book_final_legacy(rest, Con{d, book_without(done, dn(d))})
`);
write('src/driver/api.bend', text => {
  const before = 'def driver_final(book, done):\n  match book:\n    case Nil{}: done\n    case Con{d, rest}: driver_final(rest, Con{d, book_without(done, dn(d))})';
  assert.equal(text.split(before).length, 2);
  return text.replace(before, 'def driver_final(book, done):\n  book_final_fast(book, done)');
});
write('src/check/specialize.bend', text => {
  const before = 'def sp_canonical(book, done):\n  match book:\n    case Nil{}:\n      done\n    case Con{h, rest}:\n      sp_canonical(rest, Con{h, book_without(done, dn(h))})';
  assert.equal(text.split(before).length, 2);
  return text.replace(before, 'def sp_canonical(book, done):\n  book_final_fast(book, done)');
});
console.log(JSON.stringify({baseline, overlay: out}));
