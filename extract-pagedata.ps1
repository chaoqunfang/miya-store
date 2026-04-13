$html = (Invoke-WebRequest -Uri 'https://www.yupoovendor.ru/collections/breitling-watch-yupoo' -UseBasicParsing).Content

# 提取 window.pageData
if ($html -match 'window\.pageData\s*=\s*(\{[^;]+\});') {
    $jsonStr = $Matches[1]
    Write-Host "Found pageData!"
    Write-Host "JSON length: $($jsonStr.Length)"
    
    # 保存原始 JSON
    $jsonStr | Out-File "C:\Users\Administrator\.qclaw\workspace\miya-store\pagedata-raw.json" -Encoding UTF8
    
    # 尝试解析
    try {
        $data = $jsonStr | ConvertFrom-Json
        Write-Host "Parsed successfully!"
        Write-Host "Keys: $($data.PSObject.Properties.Name -join ', ')"
    } catch {
        Write-Host "Parse error: $_"
    }
} else {
    Write-Host "pageData not found"
    
    # 尝试其他方式
    if ($html -match 'window\.pageData\s*=\s*') {
        Write-Host "Found window.pageData but regex didn't match full JSON"
        
        # 找到起始位置
        $startIdx = $html.IndexOf('window.pageData')
        Write-Host "Start index: $startIdx"
        
        # 提取从 startIdx 开始的 5000 字符
        $snippet = $html.Substring($startIdx, [Math]::Min(5000, $html.Length - $startIdx))
        $snippet | Out-File "C:\Users\Administrator\.qclaw\workspace\miya-store\pagedata-snippet.txt" -Encoding UTF8
        Write-Host "Saved snippet"
    }
}
