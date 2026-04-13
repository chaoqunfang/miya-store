$products = Get-Content 'C:\Users\Administrator\.qclaw\workspace\miya-store\all-products.json' | ConvertFrom-Json
Write-Host "Total: $($products.Count)"
$products | Group-Object category | Format-Table Name, Count
