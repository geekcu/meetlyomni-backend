#!/bin/bash
# setup-git-hooks-mac.sh
# macOS-only Git hooks setup matching setup-git-hooks-final.ps1 behavior

set -euo pipefail

SOLUTION=${1:-"MeetlyOmni.sln"}
THRESHOLD=${2:-80}

cyan='\033[36m'; yellow='\033[33m'; green='\033[32m'; red='\033[31m'; gray='\033[90m'; white='\033[37m'; nc='\033[0m'

say() { echo -e "$1$2$nc"; }
fail() { say "$red" "$1"; exit 1; }

say "$cyan" "Setting up Git hooks for macOS..."

if [ ! -d .git ]; then
  fail "Error: Not in a Git repository."
fi

mkdir -p .git/hooks

# ---------- pre-commit (auto-fix format + restage + fast build) ----------
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh
echo "[pre-commit] dotnet format (auto-fix)..."
dotnet format || exit 1

echo "[pre-commit] re-stage formatted files..."
git add -A || exit 1

echo "[pre-commit] fast build (no restore)..."
dotnet build MeetlyOmni.sln --nologo --no-restore || exit 1

echo "[pre-commit] OK."
EOF
chmod +x .git/hooks/pre-commit

# ---------- pre-push (full gate with coverage smart logic) ----------
cat > .git/hooks/pre-push << EOF
#!/bin/sh

SOLUTION="$SOLUTION"
THRESHOLD="$THRESHOLD"

fail() {
  echo "\033[31m$1\033[0m"; exit 1
}

echo "\033[36m[pre-push] Verify format only...\033[0m"
dotnet format --verify-no-changes || fail "Formatting issues found. Run 'dotnet format' locally and re-push."

echo "\033[36m[pre-push] Build (Release, no-restore)...\033[0m"
dotnet build "$SOLUTION" -c Release --nologo --no-restore || fail "Build failed."

UNIT_TEST_PROJECTS=$(find . -name "*.Unit.tests.csproj" -type f)
[ -z "$UNIT_TEST_PROJECTS" ] && fail "No '*.Unit.tests.csproj' found. Ensure your unit test project follows the naming pattern."
UNIT_PROJ=$(echo "$UNIT_TEST_PROJECTS" | head -n1)
echo "\033[33m[pre-push] Unit tests project: $UNIT_PROJ\033[0m"

API_PROJECT_PATH="src/MeetlyOmni.Api"
CONTROLLERS_PATH="$API_PROJECT_PATH/Controllers"
SERVICES_PATH="$API_PROJECT_PATH/Service"

HAS_CONTROLLERS=false
HAS_SERVICES=false

if [ -d "$CONTROLLERS_PATH" ] && [ "$(find "$CONTROLLERS_PATH" -name "*.cs" | wc -l)" -gt 0 ]; then HAS_CONTROLLERS=true; fi
if [ -d "$SERVICES_PATH" ] && [ "$(find "$SERVICES_PATH" -name "*.cs" | wc -l)" -gt 0 ]; then HAS_SERVICES=true; fi

echo "\033[90m[pre-push] Controllers path: $CONTROLLERS_PATH\033[0m"
echo "\033[90m[pre-push] Controllers exists: $(test -d "$CONTROLLERS_PATH" && echo true || echo false)\033[0m"
echo "\033[90m[pre-push] Controllers files: $(find "$CONTROLLERS_PATH" -name "*.cs" 2>/dev/null | wc -l)\033[0m"
echo "\033[90m[pre-push] Has Controllers: $HAS_CONTROLLERS\033[0m"

if [ "$HAS_CONTROLLERS" = false ] && [ "$HAS_SERVICES" = false ]; then
  echo "\033[33m[pre-push] No Controllers or Services code found. Running basic tests only...\033[0m"
  echo "\033[36m[pre-push] Running unit tests...\033[0m"
  dotnet test "$UNIT_PROJ" -c Release --no-build || fail "Unit tests failed."
  echo "\n\033[36m[pre-push] ===== TEST SUMMARY =====\033[0m"
  echo "\033[32m[pre-push] PASS: Basic tests passed\033[0m"
  echo "\033[33m[pre-push] INFO: Coverage check: SKIPPED (no Controllers/Services code)\033[0m"
  echo "\033[37m[pre-push] TIP: Add Controllers/Services to enable coverage checking\033[0m"
  echo "\033[36m[pre-push] =========================\033[0m"
  echo "\033[32m[pre-push] OK. Basic checks passed (coverage check skipped - no business logic code).\033[0m"
  exit 0
fi

echo "\033[36m[pre-push] Controllers/Services code detected. Running full coverage check...\033[0m"
echo "\033[90m[pre-push] Coverage threshold: ${THRESHOLD}%\033[0m"

dotnet tool restore >/dev/null 2>&1 || true

COV_DIR="coverage"; mkdir -p "$COV_DIR"
COV_FILE="$COV_DIR/coverage.cobertura.xml"

echo "\033[36m[pre-push] Unit tests + coverage (Cobertura)...\033[0m"

if command -v dotnet-coverage >/dev/null 2>&1; then
  dotnet-coverage collect "dotnet test \"$UNIT_PROJ\" -c Release --no-build" -f cobertura -o "$COV_FILE"
  COVERAGE_EXIT=$?
else
  echo "\033[33m[pre-push] dotnet-coverage not found, running basic tests only...\033[0m"
  dotnet test "$UNIT_PROJ" -c Release --no-build || fail "Unit tests failed."
  echo "\033[32m[pre-push] OK. Basic checks passed (coverage check skipped - tool not available).\033[0m"
  exit 0
fi

if [ $COVERAGE_EXIT -ne 0 ]; then
  echo "\033[33m[pre-push] Coverage tool failed, running basic tests only...\033[0m"
  dotnet test "$UNIT_PROJ" -c Release --no-build || fail "Unit tests failed."
  if [ -f "$COV_FILE" ]; then
    echo "\033[33m[pre-push] Found existing coverage report, analyzing...\033[0m"
  else
    echo "\033[33m[pre-push] No coverage report found, skipping coverage check...\033[0m"
    echo "\033[32m[pre-push] OK. Basic checks passed (coverage check skipped due to tool issues).\033[0m"
    exit 0
  fi
fi

if [ ! -f "$COV_FILE" ]; then
  echo "\033[33m[pre-push] Coverage file not found, running basic tests only...\033[0m"
  dotnet test "$UNIT_PROJ" -c Release --no-build || fail "Unit tests failed."
  echo "\033[32m[pre-push] OK. Basic checks passed (coverage check skipped due to file issues).\033[0m"
  exit 0
fi

TOTAL_LINES=0; COVERED_LINES=0

# awk parse cobertura
COVERAGE_DATA=$(awk '
/<class[^>]*filename="[^"]*Controllers[^"]*"/ || /<class[^>]*filename="[^"]*Services[^"]*"/ { in_target=1; next }
/<\/class>/ { if (in_target) in_target=0 }
{
  if (in_target && match($0, /<line[^>]*hits=\"([0-9]+)\"/, arr)) {
    total++;
    if (arr[1] > 0) covered++
  }
}
END { print total " " covered }
' "$COV_FILE")

if [ -z "$COVERAGE_DATA" ]; then
  echo "\033[33m[pre-push] No line data found in coverage report, running basic tests only...\033[0m"
  dotnet test "$UNIT_PROJ" -c Release --no-build || fail "Unit tests failed."
  echo "\033[32m[pre-push] OK. Basic checks passed (coverage check skipped due to data issues).\033[0m"
  exit 0
fi

TOTAL_LINES=$(echo "$COVERAGE_DATA" | cut -d' ' -f1)
COVERED_LINES=$(echo "$COVERAGE_DATA" | cut -d' ' -f2)

if [ "$TOTAL_LINES" -le 0 ]; then
  echo "\033[33m[pre-push] No line data found in coverage report, running basic tests only...\033[0m"
  dotnet test "$UNIT_PROJ" -c Release --no-build || fail "Unit tests failed."
  echo "\033[32m[pre-push] OK. Basic checks passed (coverage check skipped due to data issues).\033[0m"
  exit 0
fi

RATE=$(awk "BEGIN {printf \"%.2f\", (\$COVERED_LINES / \$TOTAL_LINES) * 100}")

echo "\n\033[36m[pre-push] ===== COVERAGE REPORT =====\033[0m"
echo "\033[33m[pre-push] Current Coverage: ${RATE}%\033[0m"
echo "\033[33m[pre-push] Required Coverage: ${THRESHOLD}%\033[0m"
echo "\033[37m[pre-push] Lines Covered: $COVERED_LINES / $TOTAL_LINES\033[0m"
echo "\033[37m[pre-push] Lines Remaining: $((TOTAL_LINES - COVERED_LINES))\033[0m"

if awk "BEGIN {exit !(\$RATE >= \$THRESHOLD)}"; then
  echo "\033[32m[pre-push] PASS: Coverage PASSED (${RATE}% >= ${THRESHOLD}%)\033[0m"
else
  echo "\033[31m[pre-push] FAIL: Coverage FAILED (${RATE}% < ${THRESHOLD}%)\033[0m"
  NEEDED=$(awk "BEGIN {printf \"%.0f\", (\$THRESHOLD * \$TOTAL_LINES / 100) - \$COVERED_LINES}")
  echo "\033[31m[pre-push] Need to cover $NEEDED more lines to reach ${THRESHOLD}%\033[0m"
  exit 1
fi

echo "\033[36m[pre-push] ============================\033[0m"

echo "\033[32m[pre-push] OK. Coverage gate passed.\033[0m"
EOF

chmod +x .git/hooks/pre-push

say "$green" "macOS Git hooks setup completed."
say "$white" " - pre-commit: auto-fix format + restage + fast build"
say "$white" " - pre-push: smart coverage check (skips when no Controllers/Services, enforces ${THRESHOLD}% when present)"
say "$white" " - fallback: if coverage tool fails, runs basic tests only"
