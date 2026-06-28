const fs = require('fs');
const html = fs.readFileSync('fabbit_homepage.html', 'utf8');

// Use regex to find all img tags and print src and alt
const imgRegex = /<img[^>]+src="([^"]+)"[^>]*>/g;
let match;
const images = [];

while ((match = imgRegex.exec(html)) !== null) {
  const src = match[1];
  // extract alt attribute if present
  const altMatch = /alt="([^"]*)"/.exec(match[0]);
  const alt = altMatch ? altMatch[1] : '';
  images.push({ src, alt });
}

console.log(`Found ${images.length} images:`);
images.forEach((img, i) => {
  if (img.src.includes('files/') || img.src.includes('products/')) {
    console.log(`[${i}] ALT: "${img.alt}" | SRC: "${img.src}"`);
  }
});
