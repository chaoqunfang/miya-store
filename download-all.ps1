$products = Get-Content 'C:\Users\Administrator\.qclaw\workspace\miya-store\all-products.json' | ConvertFrom-Json
$outDir = 'C:\Users\Administrator\.qclaw\workspace\miya-store\images'

Write-Host "Total products: $($products.Count)"

for ($i = 0; $i -lt $products.Count; $i++) {
    $p = $products[$i]
    $ext = if ($p.img -match '\.jpg') { '.jpg' } elseif ($p.img -match '\.png') { '.png' } else { '.jpg' }
    $filename = "product-{0:D3}{1}" -f ($i + 1), $ext
    $outPath = Join-Path $outDir $filename
    
    if (-not (Test-Path $outPath)) {
        Write-Host "[$($i+1)/$($products.Count)] Downloading $filename ..."
        try {
            Invoke-WebRequest -Uri $p.img -OutFile $outPath -UseBasicParsing -TimeoutSec 30
        } catch {
            Write-Host "  FAILED: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "[$($i+1)/$($products.Count)] $filename exists, skip"
    }
}

Write-Host "`nDone!" -ForegroundColor Green
