# 批量抓取 yupoovendor.ru 所有分类商品

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
        $response = Invoke-WebRequest -Uri $cat.url -UseBasicParsing -TimeoutSec 30
        $html = $response.Content
        
        # 提取商品链接和图片
        $pattern = 'href="(/products/[^"]+)"[^>]*>[\s\S]*?src="([^"]+)"'
        $matches = [regex]::Matches($html, $pattern)
        
        $count = 0
        foreach ($m in $matches) {
            $productUrl = "https://www.yupoovendor.ru" + $m.Groups[1].Value
            $imgUrl = $m.Groups[2].Value
            
            if ($imgUrl -match 'product' -and -not $seen.ContainsKey($productUrl)) {
                $seen[$productUrl] = $true
                
                # 提取标题
                $titlePattern = 'href="' + [regex]::Escape($m.Groups[1].Value) + '"[^>]*>([\s\S]*?)</a>'
                $titleMatch = [regex]::Match($html, $titlePattern)
                $title = if ($titleMatch.Success) { 
                    $titleMatch.Groups[1].Value -replace '<[^>]+>', '' -replace 'Yupoo', '' -replace 'Inquire Now', '' -replace 'DM WHATSAPP.*', ''
                } else { "" }
                $title = $title.Trim()
                
                if ($title.Length -gt 5) {
                    $allProducts += @{
                        category = $cat.name
                        title = $title
                        url = $productUrl
                        img = $imgUrl
                    }
                    $count++
                }
            }
        }
        
        Write-Host "  Found: $count products" -ForegroundColor Green
    } catch {
        Write-Host "  Error: $_" -ForegroundColor Red
    }
    
    Start-Sleep -Milliseconds 300
}

Write-Host "`nTotal unique products: $($allProducts.Count)" -ForegroundColor Yellow

# 保存
$outputPath = "C:\Users\Administrator\.qclaw\workspace\miya-store\all-products.json"
$allProducts | ConvertTo-Json -Depth 3 | Out-File $outputPath -Encoding UTF8
Write-Host "Saved to: $outputPath" -ForegroundColor Green
