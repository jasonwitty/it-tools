#!/usr/bin/env node
import { readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

const [,, outDirToVar, outVarToCat, outDirToPath] = process.argv;
if (!outDirToVar || !outVarToCat || !outDirToPath) {
  console.error('Usage: node scripts/generate-it-tools-maps.mjs <dir_to_var.tsv> <var_to_cat.tsv> <dir_to_path.tsv>');
  process.exit(1);
}

const srcPath = resolve(process.cwd(), 'src/tools/index.ts');
const src = readFileSync(srcPath, 'utf8');

// Build dir -> var mapping from import lines
const dirVarPairs = [];
{
  const re = /import\s+\{\s*tool\s+as\s+([A-Za-z0-9_]+)\s*\}\s+from\s+'\.\/([^']+)'\s*;?/g;
  let m;
  while ((m = re.exec(src))) {
    dirVarPairs.push([m[2], m[1]]);
  }
}
dirVarPairs.sort((a, b) => a[0].localeCompare(b[0]));

// Build var -> category mapping from toolsByCategory blocks
const varToCat = new Map();
{
  const catBlockRe = /\{\s*name:\s*'([^']+)'\s*,\s*components:\s*\[([\s\S]*?)\]/g;
  let m;
  while ((m = catBlockRe.exec(src))) {
    const cat = m[1];
    const list = m[2];
    const ids = list
      .split(',')
      .map(s => s.trim())
      .filter(Boolean)
      .map(s => s.replace(/\s+.*/, '')) // drop trailing comments or extra tokens
      .filter(s => /^[A-Za-z_][A-Za-z0-9_]*$/.test(s));
    for (const id of ids) varToCat.set(id, cat);
  }
}

// Write outputs
const dirToVarLines = dirVarPairs.map(([dir, v]) => `${dir}\t${v}`).join('\n') + '\n';
writeFileSync(outDirToVar, dirToVarLines, 'utf8');

const varToCatLines = Array.from(varToCat.entries())
  .sort((a, b) => a[0].localeCompare(b[0]))
  .map(([v, cat]) => `${v}\t${cat}`)
  .join('\n') + '\n';
writeFileSync(outVarToCat, varToCatLines, 'utf8');

// Build dir -> route path mapping by reading each tool's index.ts
const dirToPath = [];
for (const [dir] of dirVarPairs) {
  const p = resolve(process.cwd(), `src/tools/${dir}/index.ts`);
  try {
    const code = readFileSync(p, 'utf8');
    const m = code.match(/path\s*:\s*['"]([^'\"]+)['"]/);
    if (m && m[1]) dirToPath.push([dir, m[1]]);
  } catch {}
}
dirToPath.sort((a, b) => a[0].localeCompare(b[0]));
const dirToPathLines = dirToPath.map(([d, pth]) => `${d}\t${pth}`).join('\n') + '\n';
writeFileSync(outDirToPath, dirToPathLines, 'utf8');
