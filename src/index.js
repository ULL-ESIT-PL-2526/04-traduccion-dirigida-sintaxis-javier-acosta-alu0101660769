#!/usr/bin/env node
const parse = require("./parser.js").parse;

if (process.argv.length >2) {
    console.log(parse(process.argv[2]));
    process.exit(0);
}
console.log(parse("1 - 2"));        // -1
console.log(parse("10 - 4 - 3"));   // 3
console.log(parse("7 - 5 - 1"));    // 1