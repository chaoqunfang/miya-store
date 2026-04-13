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
        
        if ($html -match 'window\.pageData\s*=\s*(\{[^;]+\});') {
            $data = $Matches[1] | ConvertFrom-Json
            
            if ($data.productList.coll) {
                $count = 0
                foreach ($p in $data.productList.coll) {
                    $url = $p.url
                    if (-not $seen.ContainsKey($url)) {
                        $seen[$url] = $true
                        $imgUrl = $p.image.src
                        if ($imgUrl -notmatch '^https') {
                            $imgUrl = "https://www.yupoovendor.ru/media" + $imgUrl
                        }
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
                Write-Host "  Found: $count products" -ForegroundColor Green
            }
        }
    } catch {
        Write-Host "  Error: $_" -ForegroundColor Red
    }
}

Write-Host "`nTotal: $($allProducts.Count)" -ForegroundColor Yellow
$allProducts | ConvertTo-Json -Depth 3 | Out-File "C:\Users\Administrator\.qclaw\workspace\miya-store\all-products.json" -Encoding UTF8
Write-Host "Saved!" -ForegroundColor Green
