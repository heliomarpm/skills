#!/usr/bin/env python3
"""Validador estrutural e de qualidade para o catalogo de skills sk-*."""

from __future__ import annotations

import glob
import os
import re
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SKILLS_DIR = os.path.join(REPO_ROOT, "skills")
MAX_DESC_CHARS = 360

CIRCUIT_BREAKER_REQUIRED = {
    "sk-debug",
    "sk-refactor",
    "sk-testing",
    "sk-devops",
    "sk-ai-engineering",
}


def strip_non_prose_links(md: str) -> str:
    """Remove code blocks, inline code and quoted illustrative strings before checking links."""
    md = re.sub(r"````.*?````", "", md, flags=re.S)
    md = re.sub(r"```.*?```", "", md, flags=re.S)
    md = re.sub(r"`[^`\n]+`", "", md)
    md = re.sub(r'"[^"\n]*\[[^\]]+\]\([^)]+\)[^"\n]*"', "", md)
    return md


def parse_frontmatter(text: str) -> tuple[dict[str, str], str] | None:
    match = re.match(r"^---\n(.*?)\n---\n(.*)$", text, re.S)
    if not match:
        return None
    fm_raw, body = match.group(1), match.group(2)
    fm: dict[str, str] = {}
    for line in fm_raw.splitlines():
        if ":" in line:
            k, v = line.split(":", 1)
            fm[k.strip()] = v.strip().strip('"').strip("'")
    return fm, body


def split_h2_sections(body: str) -> list[tuple[str, str]]:
    """Return list of (heading_text, section_content) for top-level ## headings."""
    body_no_fences = re.sub(r"````.*?````", "", body, flags=re.S)
    body_no_fences = re.sub(r"```.*?```", "", body_no_fences, flags=re.S)
    matches = list(re.finditer(r"^##\s+(.+)$", body_no_fences, re.M))
    sections: list[tuple[str, str]] = []
    for idx, m in enumerate(matches):
        start = m.end()
        end = matches[idx + 1].start() if idx + 1 < len(matches) else len(body_no_fences)
        sections.append((m.group(1).strip(), body_no_fences[start:end].strip()))
    return sections


def check_eol_and_bom(paths: list[str], errors: list[str]) -> None:
    for fp in sorted(set(paths)):
        with open(fp, "rb") as f:
            raw = f.read()
        rel = os.path.relpath(fp, REPO_ROOT).replace("\\", "/")
        if raw.startswith(b"\xef\xbb\xbf"):
            errors.append(f"[BOM] {rel} contem UTF-8 BOM.")
        if b"\r\n" in raw:
            errors.append(f"[EOL] {rel} contem CRLF; esperado LF.")


def validate() -> int:
    errors: list[str] = []

    sk_dirs = sorted(
        d
        for d in os.listdir(SKILLS_DIR)
        if d.startswith("sk-") and os.path.isdir(os.path.join(SKILLS_DIR, d))
    )
    if not sk_dirs:
        print("Nenhuma skill sk-* encontrada.")
        return 1

    sk_set = set(sk_dirs)
    tech_skills = {s for s in sk_dirs if s.startswith("sk-tech-")}
    incoming_refs: dict[str, set[str]] = {s: set() for s in sk_dirs}

    eol_targets = [
        os.path.join(REPO_ROOT, "README.md"),
        os.path.join(REPO_ROOT, "CHANGELOG.md"),
        os.path.join(REPO_ROOT, ".gitattributes"),
        os.path.join(REPO_ROOT, "scripts", "validate_skills.py"),
        os.path.join(REPO_ROOT, ".github", "workflows", "validate-skills.yml"),
    ]
    eol_targets.extend(glob.glob(os.path.join(REPO_ROOT, "docs", "*.md")))

    total_lines = 0
    total_desc_chars_all = 0
    total_desc_chars_implicit = 0
    implicit_count = 0

    for skill in sk_dirs:
        sdir = os.path.join(SKILLS_DIR, skill)
        skill_md = os.path.join(sdir, "SKILL.md")
        if not os.path.isfile(skill_md):
            errors.append(f"[{skill}] SKILL.md ausente.")
            continue

        # Collect markdown files inside this sk-* folder for EOL/BOM check
        for root, _, files in os.walk(sdir):
            for fn in files:
                if fn.endswith(".md"):
                    eol_targets.append(os.path.join(root, fn))

        with open(skill_md, "r", encoding="utf-8") as f:
            text = f.read()

        total_lines += len(text.splitlines())

        # Check cargo commands prohibition
        if "cargo " in text:
            errors.append(f"[{skill}] Ainda contem comando 'cargo ' em SKILL.md.")

        # 1. Frontmatter validation
        parsed = parse_frontmatter(text)
        if not parsed:
            errors.append(f"[{skill}] Frontmatter YAML invalido ou nao inicia com ---\\n.")
            continue
        fm, body = parsed

        if fm.get("name") != skill:
            errors.append(f"[{skill}] Campo 'name' ({fm.get('name')!r}) diverge da pasta.")

        desc = fm.get("description", "")
        if not desc:
            errors.append(f"[{skill}] Campo 'description' vazio.")
        elif len(desc) > MAX_DESC_CHARS:
            errors.append(
                f"[{skill}] description excede {MAX_DESC_CHARS} chars ({len(desc)} chars)."
            )

        total_desc_chars_all += len(desc)
        is_explicit = fm.get("disable-model-invocation", "").lower() == "true"
        if not is_explicit:
            total_desc_chars_implicit += len(desc)
            implicit_count += 1
        elif "ATIVAÇÃO EXPLÍCITA:" not in desc:
            errors.append(
                f"[{skill}] Possui disable-model-invocation: true mas falta 'ATIVAÇÃO EXPLÍCITA:' na description."
            )

        # 2. Rules & Signature check
        sections = split_h2_sections(body)
        if not sections or not sections[0][0].startswith("0. Regras de operação"):
            errors.append(f"[{skill}] Deve iniciar com '## 0. Regras de operação'.")

        expected_sig = f"> 🧠 **Skill Ativada**: `{skill}`"
        if expected_sig not in body:
            errors.append(f"[{skill}] Assinatura obrigatoria ausente: {expected_sig}")

        # 3. Last 3 sections order: Integracoes -> Armadilhas -> Padrao de entrega
        if len(sections) < 3:
            errors.append(f"[{skill}] Menos de 3 secoes ## encontradas.")
        else:
            last_three = sections[-3:]
            h_int, _ = last_three[0]
            h_arm, c_arm = last_three[1]
            h_ent, c_ent = last_three[2]

            if "Integraç" not in h_int:
                errors.append(
                    f"[{skill}] Antepenultima secao deve ser 'Integrações', encontrado: '{h_int}'."
                )
            if "Armadilhas" not in h_arm:
                errors.append(
                    f"[{skill}] Penultima secao deve ser 'Armadilhas', encontrado: '{h_arm}'."
                )
            elif re.search(r"^\|[\s:|-]+\|$", c_arm, re.M):
                errors.append(
                    f"[{skill}] Secao 'Armadilhas' nao deve usar tabela Markdown (use bullet list)."
                )
            if "Padrão de entrega" not in h_ent:
                errors.append(
                    f"[{skill}] Ultima secao deve ser 'Padrão de entrega', encontrado: '{h_ent}'."
                )
            elif not re.search(r"^1\.\s+Assinatura\b", c_ent, re.M):
                errors.append(
                    f"[{skill}] Item 1 de 'Padrão de entrega' deve iniciar mencionando 'Assinatura'."
                )

        # 4. Circuit Breaker check
        if skill in tech_skills or skill in CIRCUIT_BREAKER_REQUIRED:
            if not re.search(r"Circuit Breaker", text, re.I):
                errors.append(f"[{skill}] Regra de Circuit Breaker obrigatoria ausente.")

        # 5. Relative links inside SKILL.md
        prose = strip_non_prose_links(body)
        for link in re.findall(r"\[[^\]]+\]\(([^)]+)\)", prose):
            if link.startswith(("http://", "https://", "#", "mailto:")):
                continue
            target = link.split("#")[0]
            if not target:
                continue
            resolved = os.path.normpath(os.path.join(sdir, target))
            if not os.path.exists(resolved):
                errors.append(f"[{skill}] Link relativo quebrado em SKILL.md: {link}")

        # 6. Zero orphan files in references/, templates/, examples/
        for sub in ("references", "templates", "examples"):
            subdir = os.path.join(sdir, sub)
            if os.path.isdir(subdir):
                for root, _, files in os.walk(subdir):
                    for fn in files:
                        rel_sub = os.path.relpath(os.path.join(root, fn), sdir).replace("\\", "/")
                        if rel_sub not in text:
                            errors.append(
                                f"[{skill}] Arquivo orfao em {sub}/ nao referenciado no SKILL.md: {rel_sub}"
                            )

        # 7. Graph references check
        refs = set(re.findall(r"\bsk-[a-z][a-z0-9-]*\b", text))
        has_tech_wildcard = "sk-tech-*" in text
        for ref in refs:
            if ref == skill or ref == "sk-tech":
                continue
            if ref not in sk_set:
                errors.append(f"[{skill}] Referencia desconhecida: '{ref}'.")
            else:
                incoming_refs[ref].add(skill)
        if has_tech_wildcard:
            for ts in tech_skills:
                if ts != skill:
                    incoming_refs[ts].add(skill)

    # Check README.md relative links
    readme_path = os.path.join(REPO_ROOT, "README.md")
    with open(readme_path, "r", encoding="utf-8") as f:
        readme_prose = strip_non_prose_links(f.read())
    for link in re.findall(r"\[[^\]]+\]\(([^)]+)\)", readme_prose):
        if link.startswith(("http://", "https://", "#", "mailto:")):
            continue
        target = link.split("#")[0]
        if not target:
            continue
        resolved = os.path.normpath(os.path.join(REPO_ROOT, target))
        if not os.path.exists(resolved):
            errors.append(f"[README.md] Link relativo quebrado: {link}")

    # Check zero-island constraint
    for skill, callers in sorted(incoming_refs.items()):
        if not callers:
            errors.append(f"[{skill}] Ilha no grafo: nenhuma outra skill sk-* a referencia.")

    # 8. EOL & BOM check
    existing_eol_targets = [p for p in eol_targets if os.path.exists(p)]
    check_eol_and_bom(existing_eol_targets, errors)

    # Metrics output
    est_tokens_implicit = round(total_desc_chars_implicit / 3.7)
    est_tokens_all = round(total_desc_chars_all / 3.7)
    print(f"Skills sk-* validadas: {len(sk_dirs)} ({implicit_count} implicitas, {len(sk_dirs) - implicit_count} explicitas)")
    print(f"Total de linhas em SKILL.md: {total_lines}")
    print(f"Custo fixo description (implicitas): {total_desc_chars_implicit} chars (~{est_tokens_implicit} tokens)")
    print(f"Custo fixo description (todas 34):   {total_desc_chars_all} chars (~{est_tokens_all} tokens)")

    if errors:
        print(f"\nFALHAS DE VALIDACAO ({len(errors)}):")
        for err in errors:
            print(f" - {err}")
        return 1

    print("\nALL CHECKS PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(validate())
