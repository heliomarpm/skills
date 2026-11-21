#!/usr/bin/env node
/**
 * Audita o codigo-fonte buscando valores visuais hardcoded (#hex, rgb(), classes
 * arbitrarias Tailwind bg-[#...] e px/rem fora dos arquivos de definicao de tokens).
 *
 * Uso:
 *   node validate-tokens.cjs --dir src/
 *   node validate-tokens.cjs --dir src/ --ignore stories
 */

'use strict';

const fs = require('node:fs');
const path = require('node:path');

function parseArgs(argv) {
  const options = {
    dir: null,
    ignore: ['node_modules', '.git', 'dist', 'build', '.next', '.nuxt', 'coverage'],
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === '--dir' || arg === '-d') {
      options.dir = argv[++i];
    } else if (arg === '--ignore' || arg === '-i') {
      options.ignore.push(argv[++i]);
    } else if (arg === '--help' || arg === '-h') {
      console.log(
        [
          'Usage: node validate-tokens.cjs --dir <path> [options]',
          '',
          'Options:',
          '  -d, --dir <path>     Diretorio alvo para auditoria (obrigatorio)',
          '  -i, --ignore <dir>   Subdiretorio adicional a ignorar',
          '  -h, --help           Mostra esta ajuda',
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

const CODE_EXTENSIONS = new Set(['.css', '.scss', '.tsx', '.jsx', '.ts', '.js', '.vue', '.svelte']);
const STYLE_EXTENSIONS = new Set(['.css', '.scss']);

const SKIP_PATTERNS = [
  /\.min\.(css|js)$/i,
  /tailwind\.config\./i,
  /(^|[\\/])(globals|theme|tokens)\.(css|scss|json)$/i,
];

const PATTERNS = [
  {
    name: 'tailwindArbitraryColor',
    regex: /\b(?:bg|text|border|ring|fill|stroke)-\[#[0-9A-Fa-f]{3,8}\]/g,
    message: 'Classe arbitraria Tailwind com cor hex',
    suggestion: 'Mapeie a cor no @theme inline / token semantico',
    cssOnly: false,
  },
  {
    name: 'hexColor',
    regex: /#(?:[0-9A-Fa-f]{8}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})\b/g,
    message: 'Cor hex hardcoded',
    suggestion: 'Use var(--color-*) ou utilitario semantico de tema',
    cssOnly: false,
  },
  {
    name: 'rgbColor',
    regex: /rgba?\(\s*\d+\s*,\s*\d+\s*,\s*\d+/gi,
    message: 'Cor RGB/RGBA hardcoded',
    suggestion: 'Use token semantico de cor/opacidade',
    cssOnly: false,
  },
  {
    name: 'pixelValue',
    regex: /:\s*\d{2,}px\b/g,
    message: 'Valor em px hardcoded em CSS',
    suggestion: 'Use var(--space-*) ou var(--radius-*)',
    cssOnly: true,
  },
  {
    name: 'remValue',
    regex: /:\s*\d+(?:\.\d+)?rem\b/g,
    message: 'Valor em rem hardcoded em CSS',
    suggestion: 'Use token de espacamento ou tipografia',
    cssOnly: true,
  },
];

function collectFiles(dir, ignoreList, out = []) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (!ignoreList.includes(entry.name)) {
        collectFiles(fullPath, ignoreList, out);
      }
    } else if (entry.isFile()) {
      if (CODE_EXTENSIONS.has(path.extname(entry.name).toLowerCase())) {
        out.push(fullPath);
      }
    }
  }
  return out;
}

function shouldSkip(filePath) {
  return SKIP_PATTERNS.some((rx) => rx.test(filePath));
}

function scanFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf-8');
  const lines = content.split(/\r?\n/);
  const ext = path.extname(filePath).toLowerCase();
  const isStyle = STYLE_EXTENSIONS.has(ext);
  const findings = [];

  lines.forEach((line, idx) => {
    const trimmed = line.trim();
    if (trimmed.startsWith('//') || trimmed.startsWith('/*') || trimmed.startsWith('*') || trimmed.startsWith('--')) {
      return;
    }

    for (const rule of PATTERNS) {
      if (rule.cssOnly && !isStyle) {
        continue;
      }
      const matches = line.match(rule.regex);
      if (!matches) {
        continue;
      }
      for (const m of matches) {
        if (rule.name === 'hexColor' && ['#000', '#FFF', '#000000', '#FFFFFF'].includes(m.toUpperCase())) {
          continue;
        }
        if (rule.name === 'hexColor' && trimmed.includes(`-[#${m.slice(1)}]`)) {
          continue;
        }
        findings.push({
          file: filePath,
          line: idx + 1,
          value: m,
          message: rule.message,
          suggestion: rule.suggestion,
          context: trimmed.slice(0, 90),
        });
      }
    }
  });

  return findings;
}

function main() {
  const options = parseArgs(process.argv.slice(2));
  if (!options.dir) {
    console.error('Erro: informe --dir <caminho>');
    process.exit(1);
  }

  const targetDir = path.resolve(process.cwd(), options.dir);
  if (!fs.existsSync(targetDir)) {
    console.error(`Diretorio nao encontrado: ${targetDir}`);
    process.exit(1);
  }

  const files = collectFiles(targetDir, options.ignore).filter((f) => !shouldSkip(f));
  const violations = [];
  for (const file of files) {
    violations.push(...scanFile(file));
  }

  if (violations.length === 0) {
    console.log(`OK: nenhuma violacao de tokens encontrada (${files.length} arquivos verificados).`);
    process.exit(0);
  }

  console.log(`WARN: ${violations.length} valor(es) hardcoded encontrado(s) em ${files.length} arquivo(s):\n`);
  for (const v of violations) {
    console.log(`- ${v.file}:${v.line} | ${v.message}: '${v.value}' -> ${v.suggestion}`);
  }
  process.exit(1);
}

main();
