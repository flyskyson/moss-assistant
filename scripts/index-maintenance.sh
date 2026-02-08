#!/bin/bash

# Knowledge Base Index Maintenance Script v3
# Purpose: Verify index.md consistency and detect new files
# Usage: ./index-maintenance.sh
# Cron: 0 22 * * * /Users/lijian/clawd/scripts/index-maintenance.sh

set -e

# Configuration
INDEX_FILE="/Users/lijian/clawd/index.md"
LOG_FILE="/Users/lijian/clawd/logs/index-maintenance.log"
BASE_DIR="/Users/lijian/clawd"

# Directories to check (relative to BASE_DIR)
CHECK_DIRS=("docs" "projects" "scripts" "memory" "skills" "config" "areas")

# Exclude patterns (files that shouldn't be tracked)
EXCLUDE_PATTERNS=(
    "node_modules"
    ".git"
    ".gitignore"
    "outputs"
    "logs"
    "tmp"
)

# Initialize log
echo "========================================" > "$LOG_FILE"
echo "Index Maintenance Run: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"

MISSING_FILES=0
NEW_FILES=0
IGNORED_MISSING=0

echo "🔍 Checking index.md file references..." >> "$LOG_FILE"

# Extract and check all markdown links from index.md
# Match patterns like [filename](path)
grep -oE '\[[^]]+\]\([^)]+\)' "$INDEX_FILE" | while read -r link; do
    # Extract the path from (path)
    path="${link##*(}"
    path="${path%%)*}"
    
    # Skip external URLs
    if [[ "$path" =~ ^http ]]; then
        continue
    fi
    
    # Skip "待创建" (to be created) files
    if [[ "$link" =~ 待创建 ]]; then
        ((IGNORED_MISSING++))
        continue
    fi
    
    # Convert to absolute path
    if [[ "$path" =~ ^/ ]]; then
        full_path="$path"
    else
        full_path="$BASE_DIR/$path"
    fi
    
    # Check if file exists
    if [ ! -f "$full_path" ]; then
        echo "❌ Missing: $full_path" >> "$LOG_FILE"
        ((MISSING_FILES++))
    fi
done

echo "" >> "$LOG_FILE"
echo "🔍 Scanning for new files..." >> "$LOG_FILE"
echo "   (Excluding: ${EXCLUDE_PATTERNS[*]})" >> "$LOG_FILE"

# Function to check if should exclude
should_exclude() {
    local file="$1"
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        if [[ "$file" == *"/$pattern/"* ]] || [[ "$file" == *"/$pattern" ]] || [[ "$file" == "$pattern" ]]; then
            return 0
        fi
    done
    return 1
}

# Scan directories for new files not in index.md
for dir in "${CHECK_DIRS[@]}"; do
    check_dir="$BASE_DIR/$dir"
    if [ -d "$check_dir" ]; then
        # Find markdown and shell files
        while IFS= read -r file; do
            # Skip excluded patterns
            if should_exclude "$file"; then
                continue
            fi
            
            # Get relative path from BASE_DIR
            rel_path="${file#$BASE_DIR/}"
            
            # Check if this file is referenced in index.md
            if ! grep -q "($rel_path)" "$INDEX_FILE" 2>/dev/null; then
                echo "📄 New file: $rel_path" >> "$LOG_FILE"
                ((NEW_FILES++))
            fi
        done < <(find "$check_dir" -type f \( -name "*.md" -o -name "*.sh" \) 2>/dev/null | sort)
    fi
done

# Summary
echo "" >> "$LOG_FILE"
echo "📊 Summary:" >> "$LOG_FILE"
echo "   Missing files: $MISSING_FILES" >> "$LOG_FILE"
echo "   Ignored (待创建): $IGNORED_MISSING" >> "$LOG_FILE"
echo "   New files detected: $NEW_FILES" >> "$LOG_FILE"
echo "✅ Maintenance completed at $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Output summary
echo "✅ Index maintenance completed!"
echo "   Missing files: $MISSING_FILES"
echo "   Ignored (待创建): $IGNORED_MISSING"
echo "   New files detected: $NEW_FILES"
echo "   Log: $LOG_FILE"

# Exit with appropriate code (1 if issues found)
if [ $MISSING_FILES -gt 0 ]; then
    exit 1
else
    exit 0
fi