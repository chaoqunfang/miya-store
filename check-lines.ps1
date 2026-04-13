$html = (Invoke-WebRequest -Uri 'https://www.yupoovendor.ru/collections/breitling-watch-yupoo' -UseBasicParsing).Content

# 查找包含 product 的行
$lines = $html -split "`n"
$productLines = $lines | Where-Object { $_ -match 'product.*\.jpg' }

Write-Host "Lines with product images: $($productLines.Count)"
foreach ($line in $productLines | Select-Object -First 5) {
    Write-Host "---"
    Write-Host $line.Substring(0, [Math]::Min(200, $line.Length))
}
