'use strict';

const fs = require('node:fs');
const path = require('node:path');

/**
 * Fix favicon icon path in shortcuts.js file
 * Replaces www/favicon.ico with adminWww/favicon.ico
 */
function fixFaviconPath() {
    try {
        // Try different possible locations for shortcuts.js
        const possiblePaths = [
            path.join(process.cwd(), 'install', 'windows', 'shortcuts.js'),
            path.join(process.cwd(), 'node_modules', 'iobroker', 'install', 'windows', 'shortcuts.js'),
            path.join(process.cwd(), 'lib', 'install', 'windows', 'shortcuts.js')
        ];
        
        let fixed = false;
        
        for (const shortcutsPath of possiblePaths) {
            if (!fs.existsSync(shortcutsPath)) {
                continue;
            }
            
            let content = fs.readFileSync(shortcutsPath, 'utf8');
            
            // Replace the old favicon path with the new one
            const oldPath = 'www/favicon.ico';
            const newPath = 'adminWww/favicon.ico';
            
            if (content.includes(oldPath)) {
                content = content.replace(new RegExp(oldPath.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g'), newPath);
                fs.writeFileSync(shortcutsPath, content, 'utf8');
                console.log(`Fixed favicon path: ${oldPath} -> ${newPath} in ${shortcutsPath}`);
                fixed = true;
            } else {
                console.log(`No favicon path fix needed in ${shortcutsPath}`);
            }
        }
        
        if (!fixed) {
            console.log('shortcuts.js file not found in any expected location, favicon path fix skipped');
        }
        
    } catch (error) {
        console.error('Error fixing favicon path:', error.message);
    }
}

// Run the fix if this script is executed directly
if (require.main === module) {
    fixFaviconPath();
}

module.exports = { fixFaviconPath };