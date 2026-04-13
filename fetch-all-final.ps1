# 批量抓取所有分类商品
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

foreach ($cat in $categories) {
    Write-Host "Fetching: $($cat.name) ..." -ForegroundColor Cyan
    
    try {
        $html = Invoke-WebRequest -Uri $cat.url -UseBasicParsing -TimeoutSec 30 | Select-Object -ExpandProperty Content
        
        # 提取 window.pageData
        if ($html -match 'window\.pageData\s*=\s*(\{[^;]+\});') {
            $data = $Matches[1] | ConvertFrom-Json
            
            if ($data.productList.coll) {
                $count = 0
                foreach ($p in $data.productList.coll) {
                    $url = $p.url
                    if (-not $seen.ContainsKey($url)) {
                        $seen[$url] = $true
                        
                        # 构建完整图片 URL
                        $imgUrl = $p.image.src
                        if ($imgUrl -notmatch '^https') {
                            $imgUrl = "https://www.yupoovendor.ru/media" + $imgUrl
                        }
                        
                        # 清理标题
                        $title = $p.title -replace 'Yupoo\s*', '' -replace 'DM WHATSAPP.*', ''
                        
                        $allProducts += @{
                            category = $cat.name
                            title = $title.Trim()
                            url = $url
                            img = $imgUrl
                        }
                        $count++
                    }
                }
                Write-Host "  Found: $count products (total: $($data.productList.count))" -ForegroundColor Green
            } else {
                Write-Host "  No productList.coll" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  pageData not found" -ForegroundColor Red
        }
    } catch {
        Write-Host "  Error: $_" -ForegroundColor Red
    }
    
    Start-Sleep -Milliseconds 200
}

Write-Host "`nTotal unique products: $($allProducts.Count)" -ForegroundColor Yellow

# 保存
$outputPath = "C:\Users\Administrator\.qclaw\workspace\miya-store\all-products.json"
$allProducts | ConvertTo-Json -Depth 3 | Out-File $outputPath -Encoding UTF8
Write-Host "Saved to: $outputPath" -ForegroundColor Green
