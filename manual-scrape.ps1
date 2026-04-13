# 自动抓取所有分类商品
$categories = @(
    @{name="Breitling Watch"; url="https://www.yupoovendor.ru/collections/breitling-watch-yupoo"},
    @{name="Rolex Watch"; url="https://www.yupoovendor.ru/collections/rolex"},
    @{name="T-Shirts"; url="https://www.yupoovendor.ru/collections/yupoo-t-shirts"},
    @{name="Jeans"; url="https://www.yupoovendor.ru/collections/yupoo-jeans"},
    @{name="Sweatershirt"; url="https://www.yupoovendor.ru/collections/yupoo-sweatershirt"},
    @{name="Moncler"; url="https://www.yupoovendor.ru/collections/yupoo-moncler"},
    @{name="Moncler Down"; url="https://www.yupoovendor.ru/collections/yupoo-moncler-down-jackets"},
    @{name="Nike AJ4"; url="https://www.yupoovendor.ru/collections/yupoo-nike-air-jordan-4-aj4"},
    @{name="CP Company"; url="https://www.yupoovendor.ru/collections/yupoo-cp-company-t-shirts"},
    @{name="Gucci Shoes"; url="https://www.yupoovendor.ru/collections/yupoo-gucci-women-shoes"}
)

$allProducts = @()
$seen = @{}

# 输出 JavaScript 抓取代码
$jsCode = @'
(() => {
  const products = [];
  const items = document.querySelectorAll('li');
  items.forEach(li => {
    const a = li.querySelector('a[href*="/products/"]');
    const img = li.querySelector('img');
    if (a && img && img.src && img.src.includes('product')) {
      let title = li.textContent.trim()
        .replace(/Inquire Now/gi,'')
        .replace(/Yupoo/gi,'')
        .replace(/DM WHATSAPP BUTTON FOR INFO/gi,'')
        .replace(/\s+/g,' ').trim();
      if (title.length > 5) {
        products.push({ url: a.href, img: img.src, title: title });
      }
    }
  });
  return products;
})()
'@

Write-Host "请在浏览器中依次打开以下链接，按 F12 打开控制台，粘贴以下代码执行：" -ForegroundColor Cyan
Write-Host ""
Write-Host "JavaScript 代码：" -ForegroundColor Yellow
Write-Host $jsCode
Write-Host ""
Write-Host "分类列表：" -ForegroundColor Green

foreach ($cat in $categories) {
    Write-Host "  [$($cat.name)] $($cat.url)"
}
