const fs = require('fs');
const path = require('path');

const rootDir = process.cwd();

// Define replacement rules
const replacements = [
    { old: '\u201C', new: '"', desc: 'Left double quote (")' },
    { old: '\u201D', new: '"', desc: 'Right double quote (")' },
    { old: '\u2018', new: "'", desc: 'Left single quote (\')' },
    { old: '\u2019', new: "'", desc: 'Right single quote (\')' },
    { old: '\u2013', new: '-', desc: 'En-dash (\u2013)' },
    { old: '\u2014', new: '-', desc: 'Em-dash (\u2014)' },
    { old: '\uFFFD', new: ' ', desc: 'Replacement character (U+FFFD)' },
    { old: '\u00A0', new: ' ', desc: 'Non-breaking space (nbsp)' }
];

function getAllFiles(dir, exts = ['.html', '.js']) {
    let results = [];
    const files = fs.readdirSync(dir);
    
    for (const file of files) {
        const filelPath = path.join(dir, file);
        const stat = fs.statSync(filelPath);
        
        if (stat.isDirectory() && !file.startsWith('.')) {
            results = results.concat(getAllFiles(filelPath, exts));
        } else if (stat.isFile() && exts.some(ext => file.endsWith(ext))) {
            results.push(filelPath);
        }
    }
    
    return results;
}

console.log('════════════════════════════════════════');
console.log('  PERBAIKAN ENCODING KARAKTER SEMUA FILE');
console.log('════════════════════════════════════════\n');

let totalFilesProcessed = 0;
let totalReplacements = 0;

const files = getAllFiles(rootDir);

for (const filepath of files) {
    try {
        let content = fs.readFileSync(filepath, 'utf-8');
        const originalContent = content;
        let fileReplacements = 0;
        
        for (const replacement of replacements) {
            const oldStr = replacement.old;
            const newStr = replacement.new;
            
            // Count occurrences
            const regex = new RegExp(oldStr.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g');
            const matches = content.match(regex) || [];
            
            if (matches.length > 0) {
                content = content.split(oldStr).join(newStr);
                fileReplacements += matches.length;
                console.log(`  ✓ ${path.basename(filepath)}: ${replacement.desc} (${matches.length})`);
            }
        }
        
        if (fileReplacements > 0) {
            fs.writeFileSync(filepath, content, 'utf-8');
            totalFilesProcessed++;
            totalReplacements += fileReplacements;
        }
    } catch (err) {
        console.error(`  ✗ Error processing ${filepath}: ${err.message}`);
    }
}

console.log('\n════════════════════════════════════════');
console.log('✅ SELESAI!');
console.log(`  • Total file diproses: ${totalFilesProcessed}`);
console.log(`  • Total perbaikan karakter: ${totalReplacements}`);
console.log('════════════════════════════════════════');
