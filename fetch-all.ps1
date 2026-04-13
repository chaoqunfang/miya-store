# 所有分类 URL
$categories = @(
    @{name="Breitling Watch"; url="https://www.yupoovendor.ru/collections/breitling-watch-yupoo"},
    @{name="Rolex Watch"; url="https://www.yupoovendor.ru/collections/rolex"},
    @{name="T-Shirts"; url="https://www.yupoovendor.ru/collections/yupoo-t-shirts"},
    @{name="Jeans"; url="https://www.yupoovendor.ru/collections/yupoo-jeans"},
    @{name="Sweatershirt"; url="https://www.yupoovendor.ru/collections/yupoo-sweatershirt"},
    @{name="Moncler"; url="https://www.yupoovendor.ru/collections/yupoo-moncler"},
    @{name="Moncler Down Jackets"; url="https://www.yupoovendor.ru/collections/yupoo-moncler-down-jackets"},
    @{name="Nike Air Jordan 4"; url="https://www.yupoovendor.ru/collections/yupoo-nike-air-jordan-4-aj4"},
    @{name="CP Company T-Shirts"; url="https://www.yupoovendor.ru/collections/yupoo-cp-company-t-shirts"},
    @{name="Gucci Women Shoes"; url="https://www.yupoovendor.ru/collections/yupoo-gucci-women-shoes"}
)

$allProducts = @()

foreach ($cat in $categories) {
    Write-Host "Fetching: $($cat.name) ..."
    
    # 获取第一页
    $url = $cat.url
    $page = 1
    
    while ($url) {
        try {
            $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 30
            $html = $response.Content
            
            # 提取商品
            $regex = '<a[^>]+href="([^"]+/products/[^"]+)"[^>]*>.*?<img[^>]+src="([^"]+)"[^>]*>'
            $matches = [regex]::Matches($html, $regex, 'Singleline')
            
            foreach ($m in $matches) {
                $productUrl = $m.Groups[1].Value
                $imgUrl = $m.Groups[2].Value
                
                if ($imgUrl -match 'product.*\.(jpg|png|jpeg)') {
                    # 提取标题
                    $titleMatch = [regex]::Match($html, "href=`"$([regex]::Escape($productUrl))`"[^>]*>([^<]+)</a>")
                    $title = if ($titleMatch.Success) { $titleMatch.Groups[1].Value.Trim() } else { "" }
                    $title = $title -replace 'Yupoo\s*', '' -replace 'Inquire Now', '' -replace 'DM WHATSAPP.*', ''
                    
                    if ($title -and $title.Length -gt 5) {
                        $allProducts += @{
                            category = $cat.name
                            title = $title.Trim()
                            url = $productUrl
                            img = $imgUrl
                        }
                    }
                }
            }
            
            Write-Host "  Page $page : found $($matches.Count) products"
            
            # 检查下一页
            $nextMatch = [regex]::Match($html, 'href="([^"]+page=' + ($page + 1) + '[^"]*)"')
            if ($nextMatch.Success) {
                $url = "https://www.yupoovendor.ru" + $nextMatch.Groups[1].Value
                $page++
                Start-Sleep -Milliseconds 500
            } else {
                $url = $null
            }
        } catch {
            Write-Host "  Error: $_"
            $url = $null
        }
    }
}

# 去重
$uniqueProducts = $allProducts | Group-Object url | ForEach-Object { $_.Group[0] }

Write-Host "`nTotal unique products: $($uniqueProducts.Count)"

# 保存
$uniqueProducts | ConvertTo-Json -Depth 3 | Out-File "C:\Users\Administrator\.qclaw\workspace\miya-store\all-products.json" -Encoding UTF8
Write-Host "Saved to all-products.json"
