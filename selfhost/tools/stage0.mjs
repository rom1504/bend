import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const upstream = process.env.BEND_UPSTREAM || path.resolve(import.meta.dirname, '../.bootstrap/upstream');
const B = await import(pathToFileURL(path.join(upstream,'bend2/bend.ts')));
const C = await import(pathToFileURL(path.join(upstream,'bend2/comp.ts')));
try {
  const book = B.book_nil();
  await B.book_load(book,path.resolve(process.argv[2]),'',new Map());
  B.book_valid(book); C.book_owned(book,C.SYNTH);
  if (book.hols+book.open) throw new Error('Unresolved holes or laws');
  if (process.argv[3]) fs.writeFileSync(process.argv[3], C.js_book(book));
  console.error('Stage 0: upstream checking succeeded');
} catch(e) {console.error(e?.$ === 'Err' ? B.err_show(e) : e); process.exitCode=1;}
