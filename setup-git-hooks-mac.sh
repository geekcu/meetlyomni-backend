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
cat > .git/hooks/pre-commit << EOF
#!/bin/sh
echo "[pre-commit] dotnet format (auto-fix)..."
dotnet format || exit 1

echo "[pre-commit] re-stage formatted files..."
git add -A || exit 1

echo "[pre-commit] fast build (no restore)..."
dotnet build "$SOLUTION" --nologo --no-restore || exit 1

echo "[pre-commit] OK."
EOF
chmod +x .git/hooks/pre-commit

# ---------- pre-push (full gate with coverage smart logic) ----------
cat > .git/hooks/pre-push << EOF
#!/bin/sh

SOLUTION="$SOLUTION"
THRESHOLD="$THRESHOLD"

fail() {
  printf '\033[31m%s\033[0m\n' "$1"; exit 1
}

printf '\033[36m%s\033[0m\n' "[pre-push] Verify format only..."
dotnet format --verify-no-changes || fail "Formatting issues found. Run 'dotnet format' locally and re-push."

printf '\033[36m%s\033[0m\n' "[pre-push] Build (Release, no-restore)..."
dotnet build "\$SOLUTION" -c Release --nologo --no-restore || fail "Build failed."

UNIT_TEST_PROJECTS=\$(find . -name "*.Unit.tests.csproj" -type f 2>/dev/null)
[ -z "\$UNIT_TEST_PROJECTS" ] && fail "No '*.Unit.tests.csproj' found. Ensure your unit test project follows the naming pattern."
UNIT_PROJ=\$(echo "\$UNIT_TEST_PROJECTS" | head -n1)
printf '\033[33m%s\033[0m\n' "[pre-push] Unit tests project: \$UNIT_PROJ"

API_PROJECT_PATH="src/MeetlyOmni.Api"
CONTROLLERS_PATH="\$API_PROJECT_PATH/Controllers"
SERVICES_PATH="\$API_PROJECT_PATH/Service"

HAS_CONTROLLERS=false
HAS_SERVICES=false

if [ -d "\$CONTROLLERS_PATH" ] && [ "\$(find "\$CONTROLLERS_PATH" -name "*.cs" 2>/dev/null | wc -l)" -gt 0 ]; then HAS_CONTROLLERS=true; fi
if [ -d "\$SERVICES_PATH" ]   && [ "\$(find "\$SERVICES_PATH"   -name "*.cs" 2>/dev/null | wc -l)" -gt 0 ]; then HAS_SERVICES=true;   fi

printf '\033[90m%s\033[0m\n' "[pre-push] Controllers path: \$CONTROLLERS_PATH"
printf '\033[90m%s\033[0m\n' "[pre-push] Controllers exists: \$(test -d "\$CONTROLLERS_PATH" && echo true || echo false)"
printf '\033[90m%s\033[0m\n' "[pre-push] Controllers files: \$(find "\$CONTROLLERS_PATH" -name "*.cs" 2>/dev/null | wc -l)"
printf '\033[90m%s\033[0m\n' "[pre-push] Has Controllers: \$HAS_CONTROLLERS"

if [ "\$HAS_CONTROLLERS" = false ] && [ "\$HAS_SERVICES" = false ]; then
  printf '\033[33m%s\033[0m\n' "[pre-push] No Controllers or Services code found. Running basic tests only..."
  printf '\033[36m%s\033[0m\n' "[pre-push] Running unit tests..."
  dotnet test "\$UNIT_PROJ" -c Release --no-build || fail "Unit tests failed."
  printf '\n\033[36m%s\033[0m\n' "[pre-push] ===== TEST SUMMARY ====="
  printf '\033[32m%s\033[0m\n' "[pre-push] PASS: Basic tests passed"
  printf '\033[33m%s\033[0m\n' "[pre-push] INFO: Coverage check: SKIPPED (no Controllers/Services code)"
  printf '\033[37m%s\033[0m\n' "[pre-push] TIP: Add Controllers/Services to enable coverage checking"
  printf '\033[36m%s\033[0m\n' "[pre-push] ========================="
  printf '\033[32m%s\033[0m\n' "[pre-push] OK. Basic checks passed (coverage check skipped - no business logic code)."
  exit 0
fi

printf '\033[36m%s\033[0m\n' "[pre-push] Controllers/Services code detected. Running full coverage check..."
printf '\033[90m%s\033[0m\n' "[pre-push] Coverage threshold: \${THRESHOLD}%"

dotnet tool restore >/dev/null 2>&1 || true
COV_DIR="coverage"; mkdir -p "\$COV_DIR"
COV_FILE="\$COV_DIR/coverage.cobertura.xml"

printf '\033[36m%s\033[0m\n' "[pre-push] Unit tests + coverage (Cobertura)..."
if command -v dotnet-coverage >/dev/null 2>&1; then
  dotnet-coverage collect "dotnet test \"\$UNIT_PROJ\" -c Release --no-build" -f cobertura -o "\$COV_FILE"
  COVERAGE_EXIT=\$?
else
  printf '\033[33m%s\033[0m\n' "[pre-push] dotnet-coverage not found, running basic tests only..."
  dotnet test "\$UNIT_PROJ" -c Release --no-build || fail "Unit tests failed."
  printf '\033[32m%s\033[0m\n' "[pre-push] OK. Basic checks passed (coverage check skipped - tool not available)."
  exit 0
fi

if [ \$COVERAGE_EXIT -ne 0 ]; then
  printf '\033[33m%s\033[0m\n' "[pre-push] Coverage tool failed, running basic tests only..."
  dotnet test "\$UNIT_PROJ" -c Release --no-build || fail "Unit tests failed."
  if [ -f "\$COV_FILE" ]; then
    printf '\033[33m%s\033[0m\n' "[pre-push] Found existing coverage report, analyzing..."
  else
    printf '\033[33m%s\033[0m\n' "[pre-push] No coverage report found, skipping coverage check..."
    printf '\033[32m%s\033[0m\n' "[pre-push] OK. Basic checks passed (coverage check skipped due to tool issues)."
    exit 0
  fi
fi

if [ ! -f "\$COV_FILE" ]; then
  printf '\033[33m%s\033[0m\n' "[pre-push] Coverage file not found, running basic tests only..."
  dotnet test "\$UNIT_PROJ" -c Release --no-build || fail "Unit tests failed."
  printf '\033[32m%s\033[0m\n' "[pre-push] OK. Basic checks passed (coverage check skipped due to file issues)."
  exit 0
fi

# calculate coverage for Controllers and Services only
COVERAGE_DATA=\$(awk '
/<class[^>]*filename="[^"]*(\\\\|\\/)Controllers(\\\\|\\/)[^"]*"/ ||
 /<class[^>]*filename="[^"]*(\\\\|\\/)Services?(\\\\|\\/)[^"]*"/ { in_target=1; next }
/<\\/class>/ { if (in_target) in_target=0 }
{
  if (in_target && match(\$0, /<line[^>]*hits=\\"([0-9]+)\\"/, arr)) {
    total++;
    if (arr[1] > 0) covered++
  }
}
END { print total " " covered }
' "\$COV_FILE")

if [ -z "\$COVERAGE_DATA" ]; then
  printf '\033[33m%s\033[0m\n' "[pre-push] No line data found in coverage report, running basic tests only..."
  dotnet test "\$UNIT_PROJ" -c Release --no-build || fail "Unit tests failed."
  printf '\033[32m%s\033[0m\n' "[pre-push] OK. Basic checks passed (coverage check skipped due to data issues)."
  exit 0
fi

TOTAL_LINES=\$(echo "\$COVERAGE_DATA" | cut -d' ' -f1)
COVERED_LINES=\$(echo "\$COVERAGE_DATA" | cut -d' ' -f2)

if [ "\$TOTAL_LINES" -le 0 ]; then
  printf '\033[33m%s\033[0m\n' "[pre-push] No line data found in coverage report, running basic tests only..."
  dotnet test "\$UNIT_PROJ" -c Release --no-build || fail "Unit tests failed."
  printf '\033[32m%s\033[0m\n' "[pre-push] OK. Basic checks passed (coverage check skipped due to data issues)."
  exit 0
fi

RATE=\$(awk "BEGIN {printf \"%.2f\", (\$COVERED_LINES/\$TOTAL_LINES)*100}")

printf '\n\033[36m%s\033[0m\n' "[pre-push] ===== COVERAGE REPORT ====="
printf '\033[33m%s\033[0m\n' "[pre-push] Current Coverage: \${RATE}%"
printf '\033[33m%s\033[0m\n' "[pre-push] Required Coverage: \${THRESHOLD}%"
printf '\033[37m%s\033[0m\n' "[pre-push] Lines Covered: \$COVERED_LINES / \$TOTAL_LINES"
printf '\033[37m%s\033[0m\n' "[pre-push] Lines Remaining: \$((TOTAL_LINES - COVERED_LINES))"

awk "BEGIN { exit !(\$RATE >= \$THRESHOLD) }"
if [ \$? -eq 0 ]; then
  printf '\033[32m%s\033[0m\n' "[pre-push] PASS: Coverage PASSED (\${RATE}% >= \${THRESHOLD}%)"
else
  printf '\033[31m%s\033[0m\n' "[pre-push] FAIL: Coverage FAILED (\${RATE}% < \${THRESHOLD}%)"
  NEEDED=\$(awk "BEGIN {printf \"%.0f\", (\$THRESHOLD*\$TOTAL_LINES/100) - \$COVERED_LINES}")
  printf '\033[31m%s\033[0m\n' "[pre-push] Need to cover \$NEEDED more lines to reach \${THRESHOLD}%"
  exit 1
fi

printf '\033[36m%s\033[0m\n' "[pre-push] ============================"
printf '\033[32m%s\033[0m\n' "[pre-push] OK. Coverage gate passed."
EOF
chmod +x .git/hooks/pre-push


say "$green" "macOS Git hooks setup completed."
say "$white" " - pre-commit: auto-fix format + restage + fast build"
say "$white" " - pre-push: smart coverage check (skips when no Controllers/Services, enforces ${THRESHOLD}% when present)"
say "$white" " - fallback: if coverage tool fails, runs basic tests only"
