#!/usr/bin/env node
/**
 * Gera variaveis CSS e bloco @theme inline (Tailwind v4) ou mapa Tailwind v3
 * a partir de um JSON de tokens em 3 camadas (DTCG).
 *
 * Uso:
 *   node generate-tokens.cjs --config tokens.json -o tokens.css
 *   node generate-tokens.cjs --config tokens.json --format tailwind-v4 -o tokens.css
 *   node generate-tokens.cjs --config tokens.json --format tailwind
 */

'use strict';

const fs = require('node:fs');
const path = require('node:path');

function parseArgs(argv) {
  const options = {
    config: null,
    output: null,
    format: 'css',
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === '--config' || arg === '-c') {
      options.config = argv[++i];
    } else if (arg === '--output' || arg === '-o') {
      options.output = argv[++i];
    } else if (arg === '--format' || arg === '-f') {
      options.format = argv[++i];
    } else if (arg === '--help' || arg === '-h') {
      console.log(
        [
          'Usage: node generate-tokens.cjs --config <tokens.json> [options]',
          '',
          'Options:',
          '  -c, --config <file>   Arquivo JSON DTCG com tokens (obrigatorio)',
          '  -o, --output <file>   Arquivo de saida (padrao: stdout)',
          '  -f, --format <type>   css | tailwind-v4 | tailwind (padrao: css)',
          '  -h, --help            Mostra esta ajuda',
        ].join('\n')
      );
      process.exit(0);
    } else {
      console.error(`Opcao desconhecida: ${arg}`);
      process.exit(1);
    }
  }

  return options;
}

function toCssVarName(parts) {
  return `--${parts.join('-').replace(/\./g, '-')}`;
}

function refToCssVar(rawValue, tokens) {
  if (typeof rawValue !== 'string' || !rawValue.startsWith('{') || !rawValue.endsWith('}')) {
    return rawValue;
  }
  const refPath = rawValue.slice(1, -1).split('.');
  let node = tokens;
  for (const key of refPath) {
    node = node && typeof node === 'object' ? node[key] : undefined;
  }
  if (!node || node.$value === undefined) {
    return rawValue;
  }
  if (refPath[0] === 'semantic') {
    return `var(${toCssVarName(refPath.slice(1))})`;
  }
  return `var(${toCssVarName(refPath)})`;
}

function resolveLiteral(rawValue, tokens, depth = 0) {
  if (depth > 10 || typeof rawValue !== 'string' || !rawValue.startsWith('{') || !rawValue.endsWith('}')) {
    return rawValue;
  }
  const refPath = rawValue.slice(1, -1).split('.');
  let node = tokens;
  for (const key of refPath) {
    node = node && typeof node === 'object' ? node[key] : undefined;
  }
  if (node && node.$value !== undefined) {
    return resolveLiteral(node.$value, tokens, depth + 1);
  }
  return rawValue;
}

function flattenTokens(obj, tokens, prefix, useCssVarRefs, result = {}) {
  if (!obj || typeof obj !== 'object') {
    return result;
  }
  for (const [key, value] of Object.entries(obj)) {
    if (key === '$schema') {
      continue;
    }
    const currentPath = [...prefix, key];
    if (value && typeof value === 'object') {
      if (value.$value !== undefined) {
        const cssVar = toCssVarName(currentPath);
        result[cssVar] = useCssVarRefs
          ? refToCssVar(value.$value, tokens)
          : resolveLiteral(value.$value, tokens);
      } else {
        flattenTokens(value, tokens, currentPath, useCssVarRefs, result);
      }
    }
  }
  return result;
}

function formatBlock(selector, vars) {
  const entries = Object.entries(vars);
  if (entries.length === 0) {
    return '';
  }
  const lines = entries.map(([k, v]) => `  ${k}: ${v};`);
  return `${selector} {\n${lines.join('\n')}\n}\n`;
}

function generateCSS(tokens, includeTailwindV4Theme) {
  const primitive = flattenTokens(tokens.primitive, tokens, ['primitive'], false);
  const semantic = flattenTokens(tokens.semantic, tokens, [], true);
  const component = flattenTokens(tokens.component, tokens, [], true);
  const darkSemantic = flattenTokens(tokens.dark && tokens.dark.semantic, tokens, [], true);

  const chunks = [
    '/* Design Tokens - gerado automaticamente (nao editar direto; ajuste o JSON) */',
    '',
    '/* === 1. Primitivos === */',
    formatBlock(':root', primitive),
    '/* === 2. Semanticos (tema claro) === */',
    formatBlock(':root', semantic),
    '/* === 3. Componentes === */',
    formatBlock(':root', component),
  ];

  if (Object.keys(darkSemantic).length > 0) {
    chunks.push('/* === Tema escuro === */');
    chunks.push(formatBlock('.dark,\n[data-theme="dark"]', darkSemantic));
  }

  if (includeTailwindV4Theme) {
    const themeMap = {};
    for (const key of Object.keys(semantic)) {
      if (key.startsWith('--color-') || key.startsWith('--spacing-')) {
        themeMap[key] = `var(${key})`;
      }
    }
    chunks.push('/* === Tailwind CSS v4 @theme inline === */');
    chunks.push(formatBlock('@theme inline', themeMap));
  }

  return chunks.filter((c) => c !== '').join('\n') + '\n';
}

function generateTailwindV3(tokens) {
  const semantic = flattenTokens(tokens.semantic, tokens, [], true);
  const colors = {};
  for (const key of Object.keys(semantic)) {
    if (key.startsWith('--color-')) {
      const name = key.slice('--color-'.length);
      colors[name] = `var(${key})`;
    }
  }
  return [
    '// Config de cores para Tailwind v3 - adicione em theme.extend.colors',
    `module.exports = {\n  colors: ${JSON.stringify(colors, null, 2)},\n};`,
    '',
  ].join('\n');
}

function main() {
  const options = parseArgs(process.argv.slice(2));
  if (!options.config) {
    console.error('Erro: informe --config <arquivo.json>');
    process.exit(1);
  }
  if (!['css', 'tailwind-v4', 'tailwind'].includes(options.format)) {
    console.error(`Formato invalido: '${options.format}'. Use css, tailwind-v4 ou tailwind.`);
    process.exit(1);
  }

  const configPath = path.resolve(process.cwd(), options.config);
  if (!fs.existsSync(configPath)) {
    console.error(`Arquivo nao encontrado: ${configPath}`);
    process.exit(1);
  }

  const tokens = JSON.parse(fs.readFileSync(configPath, 'utf-8'));
  const output =
    options.format === 'tailwind'
      ? generateTailwindV3(tokens)
      : generateCSS(tokens, options.format === 'tailwind-v4');

  if (options.output) {
    const outPath = path.resolve(process.cwd(), options.output);
    fs.mkdirSync(path.dirname(outPath), { recursive: true });
    fs.writeFileSync(outPath, output, 'utf-8');
    console.log(`Generated: ${outPath}`);
  } else {
    process.stdout.write(output);
  }
}

main();
