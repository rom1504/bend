// Exact reviewed Boolean matcher specialization in the private compiler only.
// Reuse the two pure partial handlers; preserve first-argument demand order.
import {createHash} from 'node:crypto';
import {tokenize} from '../../private-compiler/tokens.mjs';
import {specializeCompiler} from '../../private-compiler/transform.mjs';
const reviewed = {
  'Bool.and': 'b703a8d778eb794e44cf38a981a8808328d4af9431d75c922638bd3bc9e9bdd1',
  'Bool.not': '195007f2b143de13d2dc029919780874cba46ebb9b0e2ab16dbd76380ebb3d89',
};
export function privateBooleans(source, exports) {
  for (const [name, hash] of Object.entries(reviewed)) {
    const lines = source.split('\n').filter(line => line.startsWith('G[' + JSON.stringify(name) +']='));
    if (lines.length !== 1 || createHash('sha256').update(lines[0]).digest('hex') !== hash)
      throw Error('Unreviewed Boolean matcher: ' + name);
  }
  for (const name of ['True', 'False'])
    if (!source.includes('constructorNative[' + JSON.stringify(name) + ']=true;')) throw Error('Boolean constructor representation differs');
  const result = specializeCompiler(source, exports), counts = {'Bool.and': 0, 'Bool.not': 0};
  const transformed = result.source.split('\n').map(line => {
    if (!/^G\[|^function privateWorker/.test(line)) return line;
    const tokens = tokenize(line), edits = [];
    for (let i = 0; i < tokens.length; i++) {
      if (!['call', 'jump'].includes(tokens[i].text) || tokens.slice(i + 1, i + 6).map(t => t.text).join(' ') !== '( get ( G ,') continue;
      let name; try { name = JSON.parse(tokens[i + 6]?.text); } catch { continue; }
      if (!Object.hasOwn(counts, name) || tokens[i + 7]?.text !== ')' || tokens[i + 8]?.text !== ',' || tokens[i + 9]?.text !== '[') continue;
      const end = tokens[i + 9].close;
      if (end + 1 !== tokens[i + 1].close) continue;
      let j = i + 10;
      if (j === end || tokens[j].text === '.') continue;
      while (j < end && tokens[j].text !== ',') j = tokens[j].close === undefined ? j + 1 : tokens[j].close + 1;
      if (j < end && j + 1 !== end) continue;
      const helper = name === 'Bool.and' ? 'privateBooleanAndFirst' : 'privateBooleanNot';
      edits.push({start: tokens[i].start, end: tokens[i + 9].end, text: helper + '('}, {start: tokens[end].start, end: tokens[end].end, text: ''});
      counts[name]++;
    }
    for (const edit of edits.sort((a, b) => b.start - a.start)) line = line.slice(0, edit.start) + edit.text + line.slice(edit.end);
    return line;
  }).join('\n');
  const helpers = `
const privateBooleanTrueHandler=fn(1,a=>a[0]);
const privateBooleanFalseHandler=fn(1,a=>false);
for(const value of [privateBooleanTrueHandler,privateBooleanFalseHandler]){Object.freeze(value.bound);Object.freeze(value);}
function privateBooleanAndFirst(value){if(value===true)return privateBooleanTrueHandler;if(value===false)return privateBooleanFalseHandler;return call(get(G,"Bool.and"),[value]);}
function privateBooleanNot(value){if(typeof value==='boolean')return !value;return call(get(G,"Bool.not"),[value]);}
`;
  return {source: transformed + helpers, stats: {...result.stats, booleans: {counts, reviewed,
    scope: 'Private immutable function objects only; exact matcher bodies/native Boolean layout; first argument evaluated before second; non-Boolean first arguments use original call at the same demand point.'}}};
}
