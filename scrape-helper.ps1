# 浏览器抓取脚本 - 输出 JavaScript 代码让用户在浏览器控制台执行

Write-Host @"
在浏览器中打开 https://www.yupoovendor.ru/collections/breitling-watch-yupoo
然后按 F12 打开控制台，粘贴以下代码执行：

"@

$jsCode = @'
// 抓取当前页面所有商品
function scrapePage() {
    const products = [];
    const items = document.querySelectorAll('li');
    
    items.forEach(li => {
        const a = li.querySelector('a[href*="/products/"]');
        const img = li.querySelector('img');
        
        if (a && img && img.src && img.src.includes('product')) {
            let title = li.textContent.trim();
            title = title.replace(/Inquire Now/gi, '')
                        .replace(/Yupoo\s*/gi, '')
                        .replace(/DM WHATSAPP BUTTON FOR INFO/gi, '')
                        .replace(/\s+/g, ' ')
                        .trim();
            
            if (title.length > 5) {
                products.push({
                    url: a.href,
                    img: img.src,
                    title: title
                });
            }
        }
    });
    
    return products;
}

// 执行并输出 JSON
const products = scrapePage();
console.log('Found ' + products.length + ' products:');
console.log(JSON.stringify(products, null, 2));
'@

Write-Host $jsCode -ForegroundColor Yellow
Write-Host "`n复制上面的 JSON 结果给我，我会继续抓取其他分类。" -ForegroundColor Cyan
