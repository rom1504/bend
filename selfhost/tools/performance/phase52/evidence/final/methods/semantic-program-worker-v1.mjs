// Exact upstream js_book CLI host: supply its CommonJS require, preserve module bytes.
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {pathToFileURL} from 'node:url';
const [moduleFile,...args]=process.argv.slice(2);assert(moduleFile);
globalThis.require=createRequire(pathToFileURL(moduleFile));
process.argv=[process.execPath,moduleFile,...args];
await import(pathToFileURL(moduleFile));
