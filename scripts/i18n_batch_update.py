#!/usr/bin/env python3
"""
Batch update QML files to use I18n.tr() instead of qsTr() for Chinese translations.
Adds 'import qs.utils' to files that use qsTr() and replaces qsTr() with I18n.tr().
"""

import os
import re
import sys

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def process_file(filepath):
    """Add import and replace qsTr() with I18n.tr() in a QML file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Skip files that already use I18n.tr
    if 'I18n.tr(' in content:
        return False
    
    # Check if file uses qsTr
    if 'qsTr(' not in content:
        return False
    
    # Add import qs.utils if not present
    has_utils_import = 'import qs.utils' in content or 'import qs\.utils' in content
    
    # Replace qsTr() with I18n.tr()
    # Be careful to only replace the function call, not the arguments
    modified = content.replace('qsTr(', 'I18n.tr(')
    
    if not has_utils_import:
        # Find the last import line and add import qs.utils after it
        import_lines = re.findall(r'^import .*$', modified, re.MULTILINE)
        if import_lines:
            last_import = import_lines[-1]
            modified = modified.replace(last_import, last_import + '\nimport qs.utils', 1)
        else:
            # No imports at all, add at the beginning
            lines = modified.split('\n')
            # Find first non-pragma, non-comment line
            insert_pos = 0
            for i, line in enumerate(lines):
                if line.strip() and not line.startswith('//') and not line.startswith('/*'):
                    insert_pos = i
                    break
            lines.insert(insert_pos, 'import qs.utils')
            modified = '\n'.join(lines)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(modified)
    
    return True

def main():
    updated = []
    skipped = []
    
    for root_dir, dirs, files in os.walk(BASE_DIR):
        # Skip build directories and .git
        if 'build' in root_dir.split(os.sep) or '.git' in root_dir.split(os.sep):
            continue
        
        for f in files:
            if f.endswith('.qml'):
                filepath = os.path.join(root_dir, f)
                try:
                    if process_file(filepath):
                        updated.append(os.path.relpath(filepath, BASE_DIR))
                except Exception as e:
                    skipped.append((os.path.relpath(filepath, BASE_DIR), str(e)))
    
    print(f"Updated {len(updated)} files:")
    for f in updated:
        print(f"  - {f}")
    
    if skipped:
        print(f"\nSkipped {len(skipped)} files with errors:")
        for f, err in skipped:
            print(f"  - {f}: {err}")

if __name__ == '__main__':
    main()
