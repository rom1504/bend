// Upstream executes js_book as CommonJS (.cjs). Compile identical bytes with that host.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import Module from 'node:module';
const [argument,...args]=process.argv.slice(2);assert(argument);
const file=fs.realpathSync(argument);process.argv=[process.execPath,file,...args];
const program=new Module(file);program.filename=file;program.paths=Module._nodeModulePaths(path.dirname(file));
program._compile(fs.readFileSync(file,'utf8'),file);
