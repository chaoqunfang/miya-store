$html = (Invoke-WebRequest -Uri 'https://www.yupoovendor.ru/collections/breitling-watch-yupoo' -UseBasicParsing).Content

if ($html -match 'window\.pageData\s*=\s*(\{[^;]+\});') {
    $data = $Matches[1] | ConvertFrom-Json
    
    Write-Host "Product count: $($data.productList.Count)"
    
    foreach ($p in $data.productList | Select-Object -First 5) {
        Write-Host "---"
        Write-Host "Title: $($p.title)"
        Write-Host "Image: $($p.image)"
        Write-Host "URL: $($p.handle)"
    }
    
    # 保存所有商品
    $data.productList | ConvertTo-Json -Depth 5 | Out-File "C:\Users\Administrator\.qclaw\workspace\miya-store\breitling-products.json" -Encoding UTF8
    Write-Host "`nSaved $($data.productList.Count) products to breitling-products.json"
}
