#!/usr/bin/env bash
# verify-skills.sh — Praxis Skills 形式合规校验
# Usage: bash scripts/verify-skills.sh
# Exit code: 0 = pass, 1 = failures found

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$PROJECT_ROOT/skills"
RULES_DIR="$PROJECT_ROOT/rules"
RESOLVER="$SKILLS_DIR/RESOLVER.md"

PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); echo "  ✓ $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  ✗ $1"; }

# 每个 SKILL.md 必需的 sections
REQUIRED_SECTIONS=(
  "## When to invoke"
  "## Inputs required"
  "## Goal"
  "## Hard constraints"
  "## Output contract"
)

# 默认归档 (有 ## Artifact section + docs/praxis/<skill>/ 路径) 的 skill
ARTIFACT_SKILLS=("think" "plan" "read" "design-ui" "learn")

echo "==> Verify Praxis Skills"

# ---------- [1/6] 跨 skill 基础设施 ----------
echo
echo "[1/6] Cross-skill infrastructure"

if [ -f "$RULES_DIR/anti-patterns.md" ]; then
  pass "rules/anti-patterns.md exists"
else
  fail "rules/anti-patterns.md missing"
fi

if [ -f "$RESOLVER" ]; then
  pass "skills/RESOLVER.md exists"
else
  fail "skills/RESOLVER.md missing"
fi

# ---------- [2/6] 每个 SKILL.md 结构 ----------
echo
echo "[2/6] SKILL.md structure (frontmatter + required sections)"

for SKILL_DIR in "$SKILLS_DIR"/*/; do
  SKILL_NAME=$(basename "$SKILL_DIR")
  SKILL_FILE="$SKILL_DIR/SKILL.md"

  if [ ! -f "$SKILL_FILE" ]; then
    fail "$SKILL_NAME: SKILL.md missing"
    continue
  fi

  # frontmatter 起始
  FIRST_LINE=$(head -1 "$SKILL_FILE")
  if [ "$FIRST_LINE" != "---" ]; then
    fail "$SKILL_NAME: first line not '---' (no frontmatter)"
    continue
  fi

  # name 字段跟目录名一致
  if ! grep -q "^name: $SKILL_NAME$" "$SKILL_FILE"; then
    fail "$SKILL_NAME: frontmatter 'name:' does not match directory name"
  fi

  # description 字段存在
  if ! grep -q "^description:" "$SKILL_FILE"; then
    fail "$SKILL_NAME: frontmatter missing 'description:'"
    continue
  fi

  # 必需 sections
  MISSING=()
  for SECTION in "${REQUIRED_SECTIONS[@]}"; do
    grep -qF "$SECTION" "$SKILL_FILE" || MISSING+=("$SECTION")
  done

  if [ ${#MISSING[@]} -eq 0 ]; then
    pass "$SKILL_NAME: structure complete (frontmatter + 5 sections)"
  else
    fail "$SKILL_NAME: missing sections: ${MISSING[*]}"
  fi
done

# ---------- [3/6] description 长度 ----------
echo
echo "[3/6] description length (sweet spot 60-300 chars)"

for SKILL_DIR in "$SKILLS_DIR"/*/; do
  SKILL_NAME=$(basename "$SKILL_DIR")
  SKILL_FILE="$SKILL_DIR/SKILL.md"
  [ ! -f "$SKILL_FILE" ] && continue

  DESC=$(grep "^description:" "$SKILL_FILE" | head -1 | sed 's/^description: //')
  LEN=${#DESC}

  if [ "$LEN" -lt 60 ]; then
    fail "$SKILL_NAME: description too short ($LEN chars; min 60 — touches trigger reliability)"
  elif [ "$LEN" -gt 300 ]; then
    fail "$SKILL_NAME: description too long ($LEN chars; max 300 — model loses key signals)"
  else
    pass "$SKILL_NAME: description $LEN chars"
  fi
done

# ---------- [4/6] Artifact skills 归档完整 ----------
echo
echo "[4/6] Artifact skills (think/plan/read/design-ui/learn)"

for SKILL_NAME in "${ARTIFACT_SKILLS[@]}"; do
  SKILL_FILE="$SKILLS_DIR/$SKILL_NAME/SKILL.md"

  if [ ! -f "$SKILL_FILE" ]; then
    fail "$SKILL_NAME: SKILL.md missing"
    continue
  fi

  if ! grep -qF "## Artifact" "$SKILL_FILE"; then
    fail "$SKILL_NAME: missing '## Artifact' section"
    continue
  fi

  if grep -qF "docs/praxis/$SKILL_NAME/" "$SKILL_FILE"; then
    pass "$SKILL_NAME: Artifact uses docs/praxis/$SKILL_NAME/"
  else
    fail "$SKILL_NAME: Artifact does not reference docs/praxis/$SKILL_NAME/"
  fi
done

# ---------- [5/6] RESOLVER 引用了所有 skill ----------
echo
echo "[5/6] RESOLVER consistency"

if [ -f "$RESOLVER" ]; then
  for SKILL_DIR in "$SKILLS_DIR"/*/; do
    SKILL_NAME=$(basename "$SKILL_DIR")
    if grep -qF "\`$SKILL_NAME\`" "$RESOLVER"; then
      pass "$SKILL_NAME: referenced in RESOLVER"
    else
      fail "$SKILL_NAME: NOT referenced in RESOLVER"
    fi
  done
fi

# ---------- [6/6] references/ 链路完整 ----------
echo
echo "[6/6] references/ link integrity"

REFERENCED_FILES_FOUND=0
for SKILL_DIR in "$SKILLS_DIR"/*/; do
  SKILL_NAME=$(basename "$SKILL_DIR")
  SKILL_FILE="$SKILL_DIR/SKILL.md"
  [ ! -f "$SKILL_FILE" ] && continue

  # 提取 SKILL.md 里所有 `references/<...>.md` 模式
  REFS=$(grep -oE '`references/[a-zA-Z0-9_/.-]+\.md`' "$SKILL_FILE" | tr -d '`' | sort -u)

  [ -z "$REFS" ] && continue

  while IFS= read -r REF; do
    REFERENCED_FILES_FOUND=$((REFERENCED_FILES_FOUND + 1))
    REF_PATH="$SKILL_DIR$REF"
    if [ -f "$REF_PATH" ]; then
      pass "$SKILL_NAME: $REF exists"
    else
      fail "$SKILL_NAME: $REF referenced but file missing"
    fi
  done <<< "$REFS"
done

if [ "$REFERENCED_FILES_FOUND" -eq 0 ]; then
  pass "no references/ links to verify"
fi

# ---------- 总结 ----------
echo
echo "==> Result: $PASS pass, $FAIL fail"

if [ $FAIL -gt 0 ]; then
  echo "FAILED"
  exit 1
fi

echo "PASSED"
exit 0
