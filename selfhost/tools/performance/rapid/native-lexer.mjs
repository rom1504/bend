// Prepare the real Bend lexer with runtime file input and a timed Bend token
// digest/count. Compile with native-component.mjs and run native-lexer-measure.mjs.
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {assemble} from '../../assemble.mjs';
const [sourceRoot, outputDirectory, inputFile] = process.argv.slice(2);
if (!sourceRoot || !outputDirectory) throw Error('usage: node native-lexer.mjs SOURCE_ROOT OUTPUT_DIRECTORY [INPUT.bend]');
const root = path.resolve(sourceRoot);
const directory = path.resolve(outputDirectory);
const input = path.resolve(inputFile || path.join(import.meta.dirname, '../../../.bootstrap/upstream/bend2/base.bend'));
const source = fs.readFileSync(input, 'utf8');
const lexer = fs.readFileSync(path.join(root, 'src/front/lexer.bend'), 'utf8');
fs.mkdirSync(path.join(directory, 'sources'), {recursive: true});
fs.writeFileSync(path.join(directory, 'sources/lexer.bend'), lexer);
const probe = `import Base

law rapid_probe_word:
  for +s: String
  for +hash: U32
  U32

law rapid_probe_tokens:
  for +tokens: List<&2, FToken>
  for +hash: U32
  U32

@unsafe
def rapid_probe_word(s, hash):
  match s:
    case SNil{}:
      U32.mul(U32.xor(hash, 0), 16777619)
    case SCon{head, tail}:
      rapid_probe_word(tail, U32.mul(U32.xor(hash, Char.to_u32(head)), 16777619))

@unsafe
def rapid_probe_tokens(tokens, hash):
  match tokens:
    case Nil{}:
      hash
    case Con{FToken{text, line, col, kind}, tail}:
      rapid_probe_tokens(tail, rapid_probe_word(text, U32.mul(U32.xor(U32.mul(U32.xor(U32.mul(U32.xor(hash, line), 16777619), col), 16777619), kind), 16777619)))

@unsafe
def rapid_probe_report(digest: U32, count: Nat, elapsed: Nat) -> IO(U32):
  do IO<U32>:
    Unit <- IO.print(U32.show(digest))
    Unit <- IO.print(Nat.show(count))
    Unit <- IO.print(Nat.show(elapsed))
    return 0

@unsafe
def rapid_probe_finish(+tokens: List<&2, FToken>, before: Nat) -> IO(U32):
  digest = rapid_probe_tokens(tokens, 2166136261)
  count = List.length(&2, FToken, tokens)
  do IO<U32>:
    after : Nat <- IO.now()
    rapid_probe_report(digest, count, Nat.sub(after, before))

@unsafe
def rapid_probe_go(source: String) -> IO(U32):
  do IO<U32>:
    before : Nat <- IO.now()
    tokens : List<&2, FToken> = f_lex(source, 1, 0, 0, Nil{})
    rapid_probe_finish(tokens, before)

@unsafe
def rapid_probe_read(pair: File & Result<&1, &1, U32 & String, String>) -> IO(U32):
  (file, result) = pair
  do IO<U32>:
    Unit <- File.close(file)
    source : String <- IO.pass(String, result)
    rapid_probe_go(source)

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    file : File <- IO.try(File, File.open(${JSON.stringify(input)}, "r"))
    pair : File & Result<&1, &1, U32 & String, String> <- File.read(file, ${Buffer.byteLength(source) + 1})
    rapid_probe_read(pair)
`;
fs.writeFileSync(path.join(directory, 'sources/probe.bend'), probe);
assemble(['lexer.bend', 'probe.bend'], path.join(directory, 'lexer.bend'), {root: path.join(directory, 'sources')});
const hash = bytes => createHash('sha256').update(bytes).digest('hex');
fs.writeFileSync(path.join(directory, 'preparation.json'), JSON.stringify({input, inputSha256: hash(source),
  lexerSha256: hash(lexer), probeSha256: hash(probe), assembledSha256: hash(fs.readFileSync(path.join(directory, 'lexer.bend'))),
  inputBytes: Buffer.byteLength(source), output: ['U32 token digest', 'token count', 'lexer plus complete Bend digest/count elapsed monotonic milliseconds'],
  method: 'Same Bend lexer and token digest; input File.read and close precede first clock; complete token digest/count precede second clock; output follows second clock. Process wall and compilation measured separately.'}, null, 2) + '\n');
console.log(path.join(directory, 'lexer.bend'));
