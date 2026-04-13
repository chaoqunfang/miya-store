const categories = [
    {name: "Breitling Watch", url: "https://www.yupoovendor.ru/collections/breitling-watch-yupoo"},
    {name: "Rolex Watch", url: "https://www.yupoovendor.ru/collections/rolex"},
    {name: "T-Shirts", url: "https://www.yupoovendor.ru/collections/yupoo-t-shirts"},
    {name: "Jeans", url: "https://www.yupoovendor.ru/collections/yupoo-jeans"},
    {name: "Sweatershirt", url: "https://www.yupoovendor.ru/collections/yupoo-sweatershirt"},
    {name: "Moncler", url: "https://www.yupoovendor.ru/collections/yupoo-moncler"},
    {name: "Moncler Down Jackets", url: "https://www.yupoovendor.ru/collections/yupoo-moncler-down-jackets"},
    {name: "Nike Air Jordan 4", url: "https://www.yupoovendor.ru/collections/yupoo-nike-air-jordan-4-aj4"},
    {name: "CP Company T-Shirts", url: "https://www.yupoovendor.ru/collections/yupoo-cp-company-t-shirts"},
    {name: "Gucci Women Shoes", url: "https://www.yupoovendor.ru/collections/yupoo-gucci-women-shoes"}
];

const allProducts = [];

for (const cat of categories) {
    console.log(`Fetching: ${cat.name}`);
    
    // Navigate to category
    await page.goto(cat.url, { waitUntil: 'networkidle', timeout: 30000 });
    await page.waitForTimeout(2000);
    
    // Scroll to load all products
    for (let i = 0; i < 5; i++) {
        await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
        await page.waitForTimeout(1000);
    }
    
    // Extract products
    const products = await page.evaluate(() => {
        const items = [];
        const links = document.querySelectorAll('a[href*="/products/"]');
        const seen = new Set();
        
        links.forEach(link => {
            const url = link.href;
            if (seen.has(url)) return;
            seen.add(url);
            
            const img = link.querySelector('img');
            if (!img || !img.src || !img.src.includes('product')) return;
            
            let title = link.textContent.trim();
            title = title.replace(/Inquire Now/gi, '').replace(/Yupoo\s*/gi, '').replace(/DM WHATSAPP.*/gi, '').trim();
            
            if (title && title.length > 5) {
                items.push({ url, img: img.src, title });
            }
        });
        
        return items;
    });
    
    console.log(`  Found: ${products.length} products`);
    
    products.forEach(p => {
        allProducts.push({ ...p, category: cat.name });
    });
}

// Deduplicate
const seen = new Set();
const unique = allProducts.filter(p => {
    if (seen.has(p.url)) return false;
    seen.add(p.url);
    return true;
});

console.log(`\nTotal unique products: ${unique.length}`);

// Save
const fs = require('fs');
fs.writeFileSync('C:/Users/Administrator/.qclaw/workspace/miya-store/all-products.json', JSON.stringify(unique, null, 2));
console.log('Saved!');
