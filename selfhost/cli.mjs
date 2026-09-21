#!/usr/bin/env node
// Public command shell; compiler algorithms execute the generated Bend API.
import {main} from './tools/typed-driver.mjs';
main(process.argv.slice(2)).catch(error=>{console.error(error.message);process.exitCode=1;});
