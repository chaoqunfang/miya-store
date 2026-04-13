# 存储所有商品
$allProducts = @()
$seen = @{}

# 分类列表
$categories = @(
    "https://www.yupoovendor.ru/collections/breitling-watch-yupoo",
    "https://www.yupoovendor.ru/collections/rolex",
    "https://www.yupoovendor.ru/collections/yupoo-t-shirts",
    "https://www.yupoovendor.ru/collections/yupoo-jeans",
    "https://www.yupoovendor.ru/collections/yupoo-sweatershirt",
    "https://www.yupoovendor.ru/collections/yupoo-moncler",
    "https://www.yupoovendor.ru/collections/yupoo-moncler-down-jackets",
    "https://www.yupoovendor.ru/collections/yupoo-nike-air-jordan-4-aj4",
    "https://www.yupoovendor.ru/collections/yupoo-cp-company-t-shirts",
    "https://www.yupoovendor.ru/collections/yupoo-gucci-women-shoes"
)

foreach ($url in $categories) {
    Write-Host "Fetching: $url"
    
    try {
        $html = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 30 | Select-Object -ExpandProperty Content
        
        # 提取商品 - 使用更宽松的正则
        $imgPattern = 'src="(https://www\.yupoovendor\.ru/media/cache/400x0/product/[^"]+)"'
        $linkPattern = 'href="(/products/[^"]+)"'
        
        $imgs = [regex]::Matches($html, $imgPattern) | ForEach-Object { $_.Groups[1].Value }
        $links = [regex]::Matches($html, $linkPattern) | ForEach-Object { "https://www.yupoovendor.ru" + $_.Groups[1].Value }
        
        # 提取标题
        $titlePattern = 'alt="([^"]+)"'
        $titles = [regex]::Matches($html, $titlePattern) | ForEach-Object { $_.Groups[1].Value -replace 'Yupoo', '' -replace 'Inquire Now', '' }
        
        Write-Host "  Images: $($imgs.Count), Links: $($links.Count), Titles: $($titles.Count)"
        
        # 配对
        $min = [Math]::Min($imgs.Count, [Math]::Min($links.Count, $titles.Count))
        for ($i = 0; $i -lt $min; $i++) {
            $link = $links[$i]
            if (-not $seen.ContainsKey($link)) {
                $seen[$link] = $true
                $allProducts += @{
                    url = $link
                    img = $imgs[$i]
                    title = $titles[$i].Trim()
                }
            }
        }
    } catch {
        Write-Host "  Error: $_"
    }
}

Write-Host "`nTotal: $($allProducts.Count) products"

# 保存
$allProducts | ConvertTo-Json -Depth 3 | Out-File "C:\Users\Administrator\.qclaw\workspace\miya-store\all-products.json" -Encoding UTF8
Write-Host "Saved!"
