// Direct program output is ESM and binds its own createRequire prologue.
// Execute unchanged bytes; do not inject CommonJS globals into the direct backend.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {pathToFileURL} from 'node:url';
const [argument,...args]=process.argv.slice(2);assert(argument);
const file=fs.realpathSync(argument);process.argv=[process.execPath,file,...args];
await import(pathToFileURL(file));
