#!/bin/bash
# Enhanced Code Coverage Check Script for Controllers and Services
# This script runs coverage checks specifically for Controllers and Services
# with baseline tracking and regression prevention

set -e

# Default values
MIN_THRESHOLD=80
SKIP_REGRESSION_CHECK=false
UPDATE_BASELINE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --min-threshold)
            MIN_THRESHOLD="$2"
            shift 2
            ;;
        --skip-regression-check)
            SKIP_REGRESSION_CHECK=true
            shift
            ;;
        --update-baseline)
            UPDATE_BASELINE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --min-threshold N        Minimum coverage threshold (default: 80)"
            echo "  --skip-regression-check  Skip regression check"
            echo "  --update-baseline        Update the baseline coverage"
            echo "  -h, --help              Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "Running enhanced code coverage check for Controllers and Services..."

# Create coverage directory if it doesn't exist
mkdir -p coverage
mkdir -p coverage/baseline

# Note: Filtering is now done via reportgenerator parameters instead of filter file

# Run tests with coverage for specific assemblies
echo "Running tests with coverage for Controllers and Services..."
dotnet test MeetlyOmni.sln --collect:"XPlat Code Coverage" --results-directory coverage --verbosity normal --filter "Category!=Integration"

if [ $? -ne 0 ]; then
    echo "Tests failed. Coverage check aborted."
    exit 1
fi

# Generate coverage report
echo "Generating coverage report..."
reportgenerator -reports:coverage/*/coverage.cobertura.xml -targetdir:coverage/report -reporttypes:Html -assemblyfilters:"+MeetlyOmni.Api.Controllers*;+MeetlyOmni.Api.Service*" -classfilters:"+*Controllers*;+*Service*"

# Extract current coverage percentage
COVERAGE_FILE=$(find coverage -name "coverage.cobertura.xml" | head -1)

if [ -n "$COVERAGE_FILE" ]; then
    CURRENT_COVERAGE=$(grep -o 'line-rate="[0-9.]*"' "$COVERAGE_FILE" | grep -o '[0-9.]*' | head -1)
    CURRENT_COVERAGE_PERCENT=$(echo "$CURRENT_COVERAGE * 100" | bc -l | cut -d. -f1)
    
    echo "Current coverage for Controllers and Services: ${CURRENT_COVERAGE_PERCENT}%"
    
    # Check minimum threshold
    if [ "$CURRENT_COVERAGE_PERCENT" -lt "$MIN_THRESHOLD" ]; then
        echo "Coverage below minimum threshold of ${MIN_THRESHOLD}%"
        echo "Current coverage: ${CURRENT_COVERAGE_PERCENT}%"
        echo "Detailed report: coverage/report/index.html"
        exit 1
    fi
    
    # Handle baseline update
    if [ "$UPDATE_BASELINE" = true ]; then
        BASELINE_FILE="coverage/baseline/coverage.txt"
        echo "$CURRENT_COVERAGE" > "$BASELINE_FILE"
        echo "Baseline updated to: ${CURRENT_COVERAGE_PERCENT}%"
        exit 0
    fi
    
    # Check for regression (unless skipped)
    if [ "$SKIP_REGRESSION_CHECK" = false ]; then
        echo "Checking coverage regression..."
        
        # Get baseline coverage
        BASELINE_FILE="coverage/baseline/coverage.txt"
        BASELINE_COVERAGE=0
        
        if [ -f "$BASELINE_FILE" ]; then
            BASELINE_COVERAGE=$(cat "$BASELINE_FILE")
            BASELINE_COVERAGE_PERCENT=$(echo "$BASELINE_COVERAGE * 100" | bc -l | cut -d. -f1)
            echo "Baseline coverage: ${BASELINE_COVERAGE_PERCENT}%"
            
            if [ "$CURRENT_COVERAGE_PERCENT" -lt "$BASELINE_COVERAGE_PERCENT" ]; then
                DIFFERENCE=$((BASELINE_COVERAGE_PERCENT - CURRENT_COVERAGE_PERCENT))
                echo "Coverage regression detected!"
                echo "Baseline: ${BASELINE_COVERAGE_PERCENT}%"
                echo "Current: ${CURRENT_COVERAGE_PERCENT}%"
                echo "Difference: -${DIFFERENCE}%"
                echo "Detailed report: coverage/report/index.html"
                echo "To update baseline, run: $0 --update-baseline"
                exit 1
            fi
        else
            echo "No baseline found. Creating initial baseline..."
            echo "$CURRENT_COVERAGE" > "$BASELINE_FILE"
            echo "Initial baseline set to: ${CURRENT_COVERAGE_PERCENT}%"
        fi
    fi
    
    echo "Coverage check passed!"
    echo "Current coverage: ${CURRENT_COVERAGE_PERCENT}%"
    echo "Detailed report: coverage/report/index.html"
else
    echo "No coverage file found"
    exit 1
fi 