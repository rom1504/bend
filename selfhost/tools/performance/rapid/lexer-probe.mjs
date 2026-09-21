// Diagnostic experiment only: swaps generated workers in memory; never rewrites
// compiler artifacts. The cursor implementation preserves the existing Bend
// lexer contract, including its comment/quoted-newline column conventions.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';

const alpha = c => c >= 65 && c <= 90 || c >= 97 && c <= 122;
const digit = c => c >= 48 && c <= 57;
const ident = c => alpha(c) || digit(c) || c === 95 || c === 46;
const pairs = new Set(['->', '=>', '<-', '++', '<>', '==', '!=', '<=', '>=', '&&', '||', '<<', '>>']);
const triples = new Set(['.&.', '.|.', '.^.', '<&>']);
const worker = (arity, code) => ({arity, code, env: null, bound: []});
const hash = value => crypto.createHash('sha256').update(value).digest('hex');

export function installLexerExperiment(module, variant, counters = {}) {
  const {G, call, ctor, list} = module;
  const saved = new Map();
  const replace = (name, value) => { saved.set(name, G[name]); G[name] = value; };
  const originalLex = G.f_lex;
  if (variant === 'direct-head-tail') {
    replace('f_head', worker(1, ([s]) => s.length ? s.codePointAt(0) : 0));
    replace('f_tail', worker(1, ([s]) => s.slice(s.codePointAt(0) > 65535 ? 2 : 1)));
  } else if (variant === 'cursor') {
    replace('f_lex', worker(5, ([s, line, col, depth, acc]) => {
      // Runtime checked-Char failures have evaluation-order-sensitive behavior.
      // Reuse the complete original lexer for malformed UTF-16 instead of
      // pretending a whole-string prevalidation has equivalent semantics.
      if (!s.isWellFormed()) {
        counters.malformedFallbacks = (counters.malformedFallbacks || 0) + 1;
        G.f_lex = originalLex;
        try { return call(originalLex, [s, line, col, depth, acc]); }
        finally { G.f_lex = replacement; }
      }
      const tokens = [];
      for (let xs = acc; xs.$ === 'Con'; xs = xs.a[1]) tokens.push(xs.a[0]);
      tokens.reverse();
      const push = (text, kind = 0) => tokens.push(ctor('FToken', [text, line, col, kind]));
      const previous = () => tokens.length ? tokens.at(-1).a : ['<eof>', 0, 0, 0];
      let pos = 0;
      const cp = p => s.codePointAt(p) ?? 0;
      const next = p => Math.min(s.length, p + (cp(p) > 65535 ? 2 : 1));
      while (pos < s.length) {
        const ch = cp(pos);
        if (ch === 10) {
          if (depth === 0) push('\n');
          pos++; line = (line + 1) >>> 0; col = 0; continue;
        }
        if (ch === 32 || ch >= 9 && ch <= 13) { pos++; col = (col + 1) >>> 0; continue; }
        if (ch === 35) { while (pos < s.length && cp(pos) !== 10) pos = next(pos); continue; }
        if (ch === 34 || ch === 39) {
          const start = pos; let size = 1; let closed = false; pos++;
          while (pos < s.length) {
            const c = cp(pos);
            if (c === ch) { pos++; size++; closed = true; break; }
            if (c === 92) { pos = next(next(pos)); size += 2; }
            else { pos = next(pos); size++; }
          }
          if (!closed) { push('unterminated string', 3); break; }
          push(s.slice(start, pos), 2); col = (col + size) >>> 0; continue;
        }
        const triple = s.slice(pos, pos + 3);
        if (triples.has(triple)) { push(triple); pos += 3; col = (col + 3) >>> 0; continue; }
        if (ident(ch)) {
          const start = pos;
          do { pos++; } while (ident(cp(pos)) || ((cp(pos) === 43 || cp(pos) === 45) && (s[pos - 1] === 'e' || s[pos - 1] === 'E') && digit(cp(pos + 1))));
          push(s.slice(start, pos), 1); col = (col + pos - start) >>> 0; continue;
        }
        const prev = previous();
        const previousEnd = (prev[2] + Array.from(prev[0]).length) >>> 0;
        const adjacentNat = prev[0].endsWith('n') && col === previousEnd;
        const pair = s.slice(pos, pos + 2);
        if (pairs.has(pair) && !(pair === '++' && adjacentNat)) {
          push(pair === '>>' && col > previousEnd ? '>>op' : pair);
          pos += 2; col = (col + 2) >>> 0; continue;
        }
        push(ch === 43 && alpha(cp(next(pos))) && !adjacentNat ? '+bind' : ch === 62 && col > previousEnd ? '>op' : String.fromCodePoint(ch));
        if (ch === 40 || ch === 91 || ch === 123) depth = (depth + 1) >>> 0;
        if (ch === 41 || ch === 93 || ch === 125) depth = (depth - 1) >>> 0;
        pos = next(pos); col = (col + 1) >>> 0;
      }
      return list(tokens);
    }));
    var replacement = G.f_lex;
  } else if (variant === 'counts') {
    for (const name of ['f_head', 'f_tail', 'f_two', 'f_three', 'f_scan_word', 'f_scan_quote', 'f_scan_comment', 'String.reverse', 'String.length']) {
      const old = G[name];
      replace(name, worker(old.arity, args => { counters[name] = (counters[name] || 0) + 1; return call(old, args); }));
    }
  } else if (variant !== 'control') throw Error(`Unknown lexer variant ${variant}`);
  return () => { for (const [name, value] of saved) G[name] = value; };
}

// Iterative serialization avoids JSON's recursion limit on long linked lists.
export function tokenRows(tokens) {
  const result = [];
  while (tokens.$ === 'Con') { result.push(tokens.a[0].a); tokens = tokens.a[1]; }
  assert.equal(tokens.$, 'Nil');
  return result;
}

export async function runProbe({apiPath, sourcePath, repetitions = 3, operation = 'lex'}) {
  assert(['lex', 'parse'].includes(operation));
  const module = await import(pathToFileURL(path.resolve(apiPath)));
  const source = fs.readFileSync(sourcePath, 'utf8');
  const run = () => operation === 'lex' ? tokenRows(module.default.f_lex(source, 1, 0, 0, module.ctor('Nil', []))) : module.default.f_parse(source);
  const serialize = output => JSON.stringify(output, (_, value) => typeof value === 'bigint' ? `${value}n` : value);
  const expected = hash(serialize(run()));
  const rows = [];
  for (let repetition = 0; repetition < repetitions; repetition++) {
    const variants = ['control', 'direct-head-tail', 'cursor'];
    if (repetition % 2) variants.reverse();
    for (const variant of variants) {
      const counters = {}; const restore = installLexerExperiment(module, variant, counters);
      try {
        const start = performance.now(); const output = run(); const milliseconds = performance.now() - start;
        const outputHash = hash(serialize(output)); assert.equal(outputHash, expected);
        rows.push({variant, repetition, milliseconds, outputHash, counters});
      } finally { restore(); }
    }
  }
  const counters = {}; const restore = installLexerExperiment(module, 'counts', counters);
  try { assert.equal(hash(serialize(run())), expected); } finally { restore(); }
  return {kind: 'diagnostic-lexer-probe', operation, node: process.version, apiPath, apiSha256: hash(fs.readFileSync(apiPath)), sourcePath, sourceSha256: hash(source), bytes: Buffer.byteLength(source), method: 'Single process, one untimed control validation; alternating order, exact serialized output equality. Counts collected in separate untimed instrumented pass. Cursor is a host-language prototype, not a compiler implementation.', rows, counters};
}

if (process.argv[1] && path.resolve(process.argv[1]) === import.meta.filename) {
  const [apiPath, sourcePath, outputPath, repetitions = '3', operation = 'lex'] = process.argv.slice(2);
  if (!apiPath || !sourcePath || !outputPath) throw Error('Usage: node lexer-probe.mjs API SOURCE OUTPUT [REPETITIONS=3] [lex|parse]');
  const report = await runProbe({apiPath, sourcePath, repetitions: Number(repetitions), operation});
  fs.writeFileSync(outputPath, JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify(report));
}
