const fs = require('fs');
const path = require('path');

function walk(dir) {
  let results = [];
  const list = fs.readdirSync(dir);
  list.forEach(function(file) {
    file = path.join(dir, file);
    const stat = fs.statSync(file);
    if (stat && stat.isDirectory()) { 
      results = results.concat(walk(file));
    } else { 
      if (file.endsWith('.dart')) results.push(file);
    }
  });
  return results;
}

const libDir = path.resolve(process.cwd(), 'lib');
const files = walk(libDir);
let changedCount = 0;

files.forEach(file => {
  const content = fs.readFileSync(file, 'utf8');
  let newContent = content.replace(/\.withOpacity\((.*?)\)/g, '.withValues(alpha: $1)');
  
  if (content !== newContent) {
    fs.writeFileSync(file, newContent, 'utf8');
    console.log('Fixed opacity in ' + file);
    changedCount++;
  }
});
console.log('Total fixed: ' + changedCount);
