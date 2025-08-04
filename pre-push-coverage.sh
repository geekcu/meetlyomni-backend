#!/bin/bash
# Pre-push Coverage Hook for Controllers and Services
# This script runs before git push and enforces coverage requirements

set +e # Disable automatic exit on error for explicit handling

echo "Running pre-push coverage check for Controllers and Services..."

# Create coverage directory if it doesn't exist
mkdir -p coverage
mkdir -p coverage/baseline

# Note: Filtering is now done via reportgenerator parameters instead of filter file

# Run tests with coverage for specific assemblies
echo "Running tests with coverage for Controllers and Services..."
dotnet test MeetlyOmni.sln --collect:"XPlat Code Coverage" --results-directory coverage --verbosity normal --filter "Category!=Integration"

if [ $? -ne 0 ]; then
    echo "Tests failed. Push blocked."
    exit 1
fi

# Generate coverage report
echo "Generating coverage report..."
reportgenerator -reports:coverage/*/coverage.cobertura.xml -targetdir:coverage/report -reporttypes:Html -assemblyfilters:"+MeetlyOmni.Api.Controllers*;+MeetlyOmni.Api.Service*" -classfilters:"+*Controllers*;+*Service*"

# Extract current coverage percentage
COVERAGE_FILE=$(find coverage -name "coverage.cobertura.xml" -type f -print0 | xargs -0 ls -t | head -1)

if [ -n "$COVERAGE_FILE" ]; then
    CURRENT_COVERAGE=$(grep -o 'line-rate="[0-9.]*"' "$COVERAGE_FILE" | grep -o '[0-9.]*' | head -1)
    CURRENT_COVERAGE_PERCENT=$(awk "BEGIN {printf \"%.0f\", $CURRENT_COVERAGE * 100}")
    
    echo "Current coverage for Controllers and Services: ${CURRENT_COVERAGE_PERCENT}%"
    
    # Check minimum threshold (80%)
    if [ "$CURRENT_COVERAGE_PERCENT" -lt 80 ]; then
        echo "Coverage below minimum threshold of 80%"
        echo "Current coverage: ${CURRENT_COVERAGE_PERCENT}%"
        echo "Detailed report: coverage/report/index.html"
        echo "Push blocked due to insufficient coverage."
        exit 1
    fi
    
    # Check for regression against baseline
    echo "Checking coverage regression..."
    
    # Get baseline coverage
    BASELINE_FILE="coverage/baseline/coverage.txt"
    BASELINE_COVERAGE=0
    
    if [ -f "$BASELINE_FILE" ]; then
        BASELINE_COVERAGE=$(cat "$BASELINE_FILE")
        # Validate baseline is a valid number
        if ! echo "$BASELINE_COVERAGE" | grep -qE '^[0-9]+\.?[0-9]*$'; then
            echo "Warning: Invalid baseline coverage value. Creating new baseline..."
            echo "$CURRENT_COVERAGE" > "$BASELINE_FILE"
            echo "Initial baseline set to: ${CURRENT_COVERAGE_PERCENT}%"
            exit 0
        fi
        BASELINE_COVERAGE_PERCENT=$(awk "BEGIN {printf \"%.0f\", $BASELINE_COVERAGE * 100}")
        echo "Baseline coverage: ${BASELINE_COVERAGE_PERCENT}%"
        
        if [ "$CURRENT_COVERAGE_PERCENT" -lt "$BASELINE_COVERAGE_PERCENT" ]; then
            DIFFERENCE=$((BASELINE_COVERAGE_PERCENT - CURRENT_COVERAGE_PERCENT))
            echo "Coverage regression detected!"
            echo "Baseline: ${BASELINE_COVERAGE_PERCENT}%"
            echo "Current: ${CURRENT_COVERAGE_PERCENT}%"
            echo "Difference: -${DIFFERENCE}%"
            echo "Detailed report: coverage/report/index.html"
            echo "Push blocked due to coverage regression."
            echo "To update baseline, run: ./check-coverage-enhanced.sh --update-baseline"
            exit 1
        fi
    else
        echo "No baseline found. Creating initial baseline..."
        echo "$CURRENT_COVERAGE" > "$BASELINE_FILE"
        echo "Initial baseline set to: ${CURRENT_COVERAGE_PERCENT}%"
    fi
    
    echo "Coverage check passed!"
    echo "Current coverage: ${CURRENT_COVERAGE_PERCENT}%"
    echo "Detailed report: coverage/report/index.html"
else
    echo "No coverage file found"
    echo "Push blocked due to missing coverage data."
    exit 1
fi 