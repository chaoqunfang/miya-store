// 使用 Node.js 抓取所有商品
const https = require('https');
const fs = require('fs');

const categories = [
    {name: "Breitling Watch", url: "https://www.yupoovendor.ru/collections/breitling-watch-yupoo"},
    {name: "Rolex Watch", url: "https://www.yupoovendor.ru/collections/rolex"},
    {name: "T-Shirts", url: "https://www.yupoovendor.ru/collections/yupoo-t-shirts"},
    {name: "Jeans", url: "https://www.yupoovendor.ru/collections/yupoo-jeans"},
    {name: "Sweatershirt", url: "https://www.yupoovendor.ru/collections/yupoo-sweatershirt"},
    {name: "Moncler", url: "https://www.yupoovendor.ru/collections/yupoo-moncler"},
    {name: "Moncler Down Jackets", url: "https://www.yupoovendor.ru/collections/yupoo-moncler-down-jackets"},
    {name: "Nike Air Jordan 4", url: "https://www.yupoovendor.ru/collections/yupoo-nike-air-jordan-4-aj4"},
    {name: "CP Company", url: "https://www.yupoovendor.ru/collections/yupoo-cp-company-t-shirts"},
    {name: "Gucci Women Shoes", url: "https://www.yupoovendor.ru/collections/yupoo-gucci-women-shoes"}
];

function fetch(url) {
    return new Promise((resolve, reject) => {
        https.get(url, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => resolve(data));
        }).on('error', reject);
    });
}

function extractProducts(html, category) {
    const products = [];
    const regex = /<a[^>]+href="(\/products\/[^"]+)"[^>]*>[\s\S]*?<img[^>]+src="([^"]+)"[^>]*>/g;
    let match;
    
    while ((match = regex.exec(html)) !== null) {
        const url = 'https://www.yupoovendor.ru' + match[1];
        const img = match[2];
        
        if (img.includes('product')) {
            // Extract title from nearby text
            const titleRegex = new RegExp(`href="${match[1].replace(/\//g, '\\/')}"[^>]*>([\\s\\S]*?)</a>`, 'i');
            const titleMatch = html.match(titleRegex);
            let title = titleMatch ? titleMatch[1].replace(/<[^>]+>/g, '').trim() : '';
            title = title.replace(/Inquire Now/gi, '').replace(/Yupoo/gi, '').replace(/DM WHATSAPP.*/gi, '').trim();
            
            if (title && title.length > 5) {
                products.push({ category, url, img, title });
            }
        }
    }
    
    return products;
}

(async () => {
    const allProducts = [];
    const seen = new Set();
    
    for (const cat of categories) {
        console.log(`Fetching: ${cat.name}...`);
        
        try {
            const html = await fetch(cat.url);
            const products = extractProducts(html, cat.name);
            
            products.forEach(p => {
                if (!seen.has(p.url)) {
                    seen.add(p.url);
                    allProducts.push(p);
                }
            });
            
            console.log(`  Found: ${products.length} products`);
        } catch (err) {
            console.log(`  Error: ${err.message}`);
        }
    }
    
    console.log(`\nTotal: ${allProducts.length} unique products`);
    
    fs.writeFileSync('all-products.json', JSON.stringify(allProducts, null, 2));
    console.log('Saved to all-products.json');
})();
