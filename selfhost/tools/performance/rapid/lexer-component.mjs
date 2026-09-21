// Prepare a real Bend lexer component with declarations ordered by the existing
// assembler. Compilation remains an explicit, separately measurable command.
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {assemble} from '../../assemble.mjs';

const [sourceRoot, outputDir, reference = 'dist/phase1/bootstrap-api.mjs'] = process.argv.slice(2);
if (!sourceRoot || !outputDir) throw Error('usage: node lexer-component.mjs SOURCE_ROOT OUTPUT_DIR [CONTROL_API]');
const root = path.resolve(sourceRoot), output = path.resolve(outputDir);
const file = 'src/front/lexer.bend', source = fs.readFileSync(path.join(root, file), 'utf8');
const digest = value => createHash('sha256').update(value).digest('hex');
fs.mkdirSync(path.join(output, 'sources/src/front'), {recursive: true});
fs.writeFileSync(path.join(output, 'sources', file), source);
fs.writeFileSync(path.join(output, 'lexer.bend'), source);
assemble([file], path.join(output, 'component.bend'), {root: path.join(output, 'sources')});
const original = fs.readFileSync(reference, 'utf8');
let control = original;
if (/^export \{G,call,list,ctor\};$/m.test(original)) {
  if (!original.includes('G["f_lex"]=')) throw Error('Missing self-emitted reference lexer');
} else {
  if (!original.includes('function $f_lex$(')) throw Error('Missing checked upstream-emitted reference lexer');
  control += '\nexport const rapidLexerControl = {f_lex: run_lib($f_lex$, 5)};\n';
}
fs.writeFileSync(path.join(output, 'control.mjs'), control);
const report = {scope: 'lexer source preparation; no compilation or bootstrap proof', sourceRoot: root,
  modules: [{file, sha256: digest(source)}], componentSha256: digest(fs.readFileSync(path.join(output, 'component.bend'))),
  reference: path.resolve(reference), referenceSha256: digest(original), controlSha256: digest(control),
  apiExports: ['f_lex'],
  buildInstructions: [
    'Upstream component: node tools/stage0-library.mjs OUTPUT_DIR/component.bend OUTPUT_DIR/api.mjs f_lex',
    'Differential: BEND_LEXER_CONTROL=OUTPUT_DIR/control.mjs BEND_LEXER_CANDIDATE=OUTPUT_DIR/api.mjs BEND_LEXER_REPORT=OUTPUT_DIR/differential.json node --stack_size=4096 tools/performance/rapid/lexer-component.test.mjs',
    'Bend-emitted component: BEND_TYPED_API=ABS_BOOTSTRAP_API node --stack_size=4096 tools/typed-driver.mjs OUTPUT_DIR/component.bend --library -o OUTPUT_DIR/self-emitted.mjs',
    'Capsule: node tools/performance/rapid/component-capsule.mjs dist/phase1/selfhost-api.mjs OUTPUT_DIR/self-emitted.mjs OUTPUT_DIR/lexer.bend OUTPUT_DIR/capsule.mjs',
  ]};
fs.writeFileSync(path.join(output, 'preparation.json'), JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify(report));
