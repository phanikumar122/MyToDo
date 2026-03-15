const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, '../config/firebase-service-account.json');

try {
  if (!fs.existsSync(filePath)) {
    console.error('❌ Error: firebase-service-account.json not found in backend/config/');
    process.exit(1);
  }

  const content = fs.readFileSync(filePath, 'utf8');
  const json = JSON.parse(content);
  const minified = JSON.stringify(json);

  console.log('\n--- COPY THE LINE BELOW ---');
  console.log(minified);
  console.log('--- END OF LINE ---\n');
  console.log('✅ Instructions:');
  console.log('1. Copy the entire line above.');
  console.log('2. Go to Render > Dashboard > Environment Variables.');
  console.log('3. Paste it as the value for FIREBASE_SERVICE_ACCOUNT_JSON.');
} catch (err) {
  console.error('❌ Error reading or parsing JSON:', err.message);
}
