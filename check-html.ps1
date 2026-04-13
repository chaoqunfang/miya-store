$html = (Invoke-WebRequest -Uri 'https://www.yupoovendor.ru/collections/breitling-watch-yupoo' -UseBasicParsing).Content
Write-Host "HTML Length: $($html.Length)"

# 检查是否有商品图片
if ($html -match 'cache/400x0/product') {
    Write-Host "Found product images!"
} else {
    Write-Host "No product images found"
}

# 提取图片
$pattern = 'src="(https://[^"]+product[^"]+\.jpg)"'
$matches = [regex]::Matches($html, $pattern)
Write-Host "Images found: $($matches.Count)"

foreach ($m in $matches | Select-Object -First 5) {
    Write-Host "  $($m.Groups[1].Value)"
}
