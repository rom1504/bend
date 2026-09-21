// Diagnostic transform of generated JavaScript, not a compiler pass.
// Original function values and ABI stay intact. Exact calls can invoke a second
// positional worker only while the captured function object/code/ABI still match.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';

function tokenize(source) {
  const tokens = [];
  for (let i = 0; i < source.length;) {
    if (/\s/.test(source[i])) { i++; continue; }
    if (source.startsWith('//', i)) break;
    if (source.startsWith('/*', i)) { const end = source.indexOf('*/', i + 2); if (end < 0) throw Error('Unclosed comment'); i = end + 2; continue; }
    const start = i, c = source[i];
    if (c === '"' || c === "'") { for (i++; i < source.length; i++) { if (source[i] === '\\') { i++; continue; } if (source[i] === c) { i++; break; } } }
    else if (/[A-Za-z_$]/.test(c)) { while (i < source.length && /[\w$]/.test(source[i])) i++; }
    else if (/[0-9]/.test(c)) { while (i < source.length && /[\w.]/.test(source[i])) i++; }
    else if (c === '`') throw Error('Template literal unsupported in generated definitions');
    else i++;
    tokens.push({text: source.slice(start, i), start, end: i});
  }
  const stack = [];
  for (let i = 0; i < tokens.length; i++) {
    const text = tokens[i].text;
    if ('([{'.includes(text) && text.length === 1) stack.push(i);
    if (')]}'.includes(text) && text.length === 1) {
      const open = stack.pop();
      if (open === undefined || '([{'.indexOf(tokens[open].text) !== ')]}'.indexOf(text)) throw Error('Unbalanced generated definition');
      tokens[open].close = i;
    }
  }
  if (stack.length) throw Error('Unbalanced generated definition');
  return tokens;
}
function edited(source, edits) {
  for (const edit of edits.sort((a, b) => b.start - a.start)) source = source.slice(0, edit.start) + edit.text + source.slice(edit.end);
  return source;
}
function positionalBody(body, arity) {
  const tokens = tokenize(body), edits = [];
  if (tokens.some(t => ['this', 'arguments', 'eval', 'rapidPos'].includes(t.text))) return null;
  for (let i = 0; i < tokens.length; i++) {
    if (tokens[i].text === 'function') {
      const parameters = tokens[i + 1]?.text === '(' ? i + 1 : i + 2;
      const end = tokens[parameters]?.close;
      if (end !== undefined && tokens.slice(parameters + 1, end).some(t => t.text === 'a') && tokens[end + 1]?.text === '{') {
        i = tokens[end + 1].close; continue;
      }
    }
    if (tokens[i].text !== 'a') continue;
    const index = Number(tokens[i + 2]?.text);
    if (tokens[i + 1]?.text !== '[' || tokens[i + 3]?.text !== ']' || !/^\d+$/.test(tokens[i + 2]?.text || '') || index >= arity) return null;
    edits.push({start: tokens[i].start, end: tokens[i + 3].end, text: `rapidPosArg${index}`}); i += 3;
  }
  return edited(body, edits);
}

export function transformPositionalWorkers(source) {
  if (source.includes('rapidPosWorker')) throw Error('Positional-worker transform already applied or reserved identifier present');
  const lines = source.split('\n'), workers = new Map();
  const stats = {workers: 0, calls: 0, skippedDefinitions: 0, byName: {}};
  for (const line of lines) {
    const match = /^G\[("(?:\\.|[^"\\])*")\]=fn\((\d+),function\(a\)\{/.exec(line);
    if (!match || !line.endsWith('});')) continue;
    const arity = Number(match[2]); if (arity === 0) continue;
    const definitionTokens = tokenize(line);
    const bodyOpen = definitionTokens.findIndex(token => token.start === match[0].length - 1);
    const bodyClose = definitionTokens[bodyOpen].close;
    // No explicit factory environment/bound arguments may be copied into a
    // standalone worker, even if its body happens not to mention `this`.
    if (definitionTokens[bodyClose + 1]?.text !== ')' || definitionTokens[bodyClose + 2]?.text !== ';' || bodyClose + 3 !== definitionTokens.length) { stats.skippedDefinitions++; continue; }
    const body = positionalBody(line.slice(match[0].length, -3), arity);
    if (body === null) { stats.skippedDefinitions++; continue; }
    const name = JSON.parse(match[1]);
    if (workers.has(name)) throw Error(`Duplicate generated global ${name}`);
    workers.set(name, {arity, body, id: stats.workers++, name});
  }
  const rewriteCalls = line => {
    const tokens = tokenize(line), edits = [];
    for (let i = 0; i < tokens.length; i++) {
      if (tokens[i].text !== 'call' || tokens[i + 1]?.text !== '(' || tokens[i + 2]?.text !== 'get' || tokens[i + 3]?.text !== '(' || tokens[i + 4]?.text !== 'G' || tokens[i + 5]?.text !== ',' || tokens[i + 7]?.text !== ')' || tokens[i + 8]?.text !== ',' || tokens[i + 9]?.text !== '[') continue;
      let name; try { name = JSON.parse(tokens[i + 6].text); } catch { continue; }
      const worker = workers.get(name); if (!worker) continue;
      const arrayEnd = tokens[i + 9].close, callEnd = tokens[i + 1].close;
      if (arrayEnd + 1 !== callEnd) continue;
      let count = 0, valid = true;
      for (let j = i + 10; j < arrayEnd;) {
        count++;
        if (tokens[j].text === '.' && tokens[j + 1]?.text === '.' && tokens[j + 2]?.text === '.') { valid = false; break; }
        while (j < arrayEnd && tokens[j].text !== ',') j = tokens[j].close === undefined ? j + 1 : tokens[j].close + 1;
        if (j < arrayEnd) j++;
      }
      if (!valid || count !== worker.arity) continue;
      edits.push({start: tokens[i].start, end: tokens[i].end, text: `rapidPosCall${worker.id}`});
      edits.push({start: tokens[i + 9].start, end: tokens[i + 9].end, text: ''});
      edits.push({start: tokens[arrayEnd].start, end: tokens[arrayEnd].end, text: ''});
      stats.calls++; stats.byName[name] = (stats.byName[name] || 0) + 1;
    }
    return edited(line, edits);
  };
  // Only deferred function bodies: eager initializers run before the captures
  // below exist and must remain untouched.
  let result = lines.map(line => /^G\["(?:\\.|[^"\\])*"\]=fn\(\d+,function\(a\)\{/.test(line) ? rewriteCalls(line) : line).join('\n');
  for (const {id, name, arity, body} of workers.values()) {
    const args = Array.from({length: arity}, (_, i) => `rapidPosArg${i}`).join(',');
    result += `\nconst rapidPosOriginal${id}=G[${JSON.stringify(name)}],rapidPosCode${id}=rapidPosOriginal${id}.code;`;
    result += `\nfunction rapidPosWorker${id}(${args}){${rewriteCalls(body)}}`;
    result += `\nfunction rapidPosCall${id}(f,${args}){if(f===rapidPosOriginal${id}&&f.code===rapidPosCode${id}&&f.env===null&&f.arity===${arity}&&f.bound.length===0&&!f.io&&!f.typeName)return force(rapidPosWorker${id}(${args}));return call(f,[${args}]);}\n`;
  }
  return {source: result, code: result, stats};
}

if (process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href) {
  const [input, output] = process.argv.slice(2);
  if (!input || !output || path.resolve(input) === path.resolve(output)) throw Error('Usage: node positional-workers.mjs INPUT.mjs DISTINCT_OUTPUT.mjs');
  const result = transformPositionalWorkers(fs.readFileSync(input, 'utf8'));
  fs.mkdirSync(path.dirname(output), {recursive: true}); fs.writeFileSync(output, result.source);
  fs.writeFileSync(output + '.transform.json', JSON.stringify(result.stats, null, 2) + '\n');
  console.log(JSON.stringify(result.stats));
}
