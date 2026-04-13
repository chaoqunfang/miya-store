
$products = Get-Content 'C:\Users\Administrator\.qclaw\workspace\miya-store\products.json' | ConvertFrom-Json
$outDir = 'C:\Users\Administrator\.qclaw\workspace\miya-store\images'

for ($i = 0; $i -lt $products.Count; $i++) {
    $p = $products[$i]
    $ext = if ($p.img -match '\.jpg') { '.jpg' } elseif ($p.img -match '\.png') { '.png' } else { '.jpg' }
    $filename = "product-{0:D2}{1}" -f ($i + 1), $ext
    $outPath = Join-Path $outDir $filename
    
    Write-Host "Downloading $filename ..."
    try {
        Invoke-WebRequest -Uri $p.img -OutFile $outPath -UseBasicParsing
        Write-Host "  OK"
    } catch {
        Write-Host "  FAILED: $_"
    }
}

Write-Host "`nDone! Downloaded $i images."
