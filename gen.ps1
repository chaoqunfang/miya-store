Add-Type -AssemblyName System.Web

$products = Get-Content 'C:\Users\Administrator\.qclaw\workspace\miya-store\all-products.json' | ConvertFrom-Json
$categories = $products | Group-Object category | Sort-Object Count -Descending

Write-Host "Categories: $($categories.Count)"
foreach ($c in $categories) {
    Write-Host "  $($c.Name): $($c.Count)"
}

$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Miya Store - Luxury Watches, Shoes & More</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #1a1a1a; color: #fff; }
    .header { background: #111; padding: 15px 0; border-bottom: 1px solid #333; position: sticky; top: 0; z-index: 100; }
    .header-content { max-width: 1400px; margin: 0 auto; padding: 0 20px; display: flex; justify-content: space-between; align-items: center; }
    .logo { font-size: 24px; font-weight: bold; color: #fff; text-decoration: none; letter-spacing: 2px; }
    .logo span { color: #c9a227; }
    .nav { display: flex; gap: 25px; }
    .nav a { color: #aaa; text-decoration: none; font-size: 13px; }
    .nav a:hover { color: #fff; }
    .banner { background: linear-gradient(135deg, #2a2a2a 0%, #1a1a1a 100%); padding: 50px 20px; text-align: center; }
    .banner h1 { font-size: 36px; margin-bottom: 10px; color: #c9a227; }
    .banner p { color: #888; font-size: 14px; }
    .category-section { max-width: 1400px; margin: 0 auto; padding: 40px 20px; }
    .category-title { font-size: 22px; color: #c9a227; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px solid #333; }
    .products-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 20px; }
    .product-card { background: #222; border-radius: 8px; overflow: hidden; transition: transform 0.3s; }
    .product-card:hover { transform: translateY(-5px); box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
    .product-image { width: 100%; aspect-ratio: 1; object-fit: cover; }
    .product-info { padding: 12px; }
    .product-title { font-size: 12px; color: #ddd; line-height: 1.4; margin-bottom: 10px; height: 34px; overflow: hidden; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; }
    .inquire-btn { display: block; width: 100%; padding: 8px; background: #c9a227; color: #000; text-align: center; text-decoration: none; font-weight: bold; font-size: 12px; border-radius: 4px; }
    .inquire-btn:hover { background: #d4af37; }
    .footer { background: #111; padding: 40px 20px; margin-top: 60px; border-top: 1px solid #333; }
    .footer-content { max-width: 1400px; margin: 0 auto; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 40px; }
    .footer-section h3 { color: #c9a227; font-size: 14px; margin-bottom: 15px; text-transform: uppercase; }
    .footer-section a { display: block; color: #888; text-decoration: none; font-size: 13px; margin-bottom: 8px; }
    .footer-section a:hover { color: #fff; }
    .footer-bottom { max-width: 1400px; margin: 30px auto 0; padding-top: 20px; border-top: 1px solid #333; text-align: center; color: #666; font-size: 12px; }
    .whatsapp-float { position: fixed; bottom: 30px; right: 30px; width: 60px; height: 60px; background: #25D366; border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 20px rgba(37, 211, 102, 0.4); z-index: 1000; }
    .whatsapp-float:hover { transform: scale(1.1); }
    .whatsapp-float svg { width: 35px; height: 35px; fill: white; }
    @media (max-width: 768px) { .nav { display: none; } .banner h1 { font-size: 24px; } .products-grid { grid-template-columns: repeat(2, 1fr); gap: 12px; } }
  </style>
</head>
<body>
  <header class="header">
    <div class="header-content">
      <a href="/" class="logo">MIYA <span>STORE</span></a>
      <nav class="nav">
        <a href="https://wa.me/8615759948239" target="_blank">WhatsApp Contact</a>
      </nav>
    </div>
  </header>
  <div class="banner">
    <h1>MIYA STORE</h1>
    <p>Luxury Watches, Designer Shoes, Premium Clothing - WhatsApp: +86 157 5994 8239</p>
  </div>
"@

$idx = 0
foreach ($cat in $categories) {
    $html += "<div class=`"category-section`"><h2 class=`"category-title`">$($cat.Name) ($($cat.Count))</h2><div class=`"products-grid`">"
    
    foreach ($p in $cat.Group) {
        $imgFile = "images/product-{0:D3}.jpg" -f ($idx + 1)
        $title = $p.title -replace '"', '&quot;'
        $waMsg = [System.Web.HttpUtility]::UrlEncode("Hi, I'm interested in: $($p.title)")
        
        $html += "<div class=`"product-card`"><img src=`"$imgFile`" alt=`"$title`" class=`"product-image`"><div class=`"product-info`"><div class=`"product-title`">$title</div><a href=`"https://wa.me/8615759948239?text=$waMsg`" target=`"_blank`" class=`"inquire-btn`">Inquire Now</a></div></div>"
        $idx++
    }
    
    $html += "</div></div>"
}

$html += @"
<footer class="footer">
  <div class="footer-content">
    <div class="footer-section"><h3>Contact</h3><a href="https://wa.me/8615759948239" target="_blank">WhatsApp: +86 157 5994 8239</a></div>
    <div class="footer-section"><h3>Support</h3><a href="#">Delivery</a><a href="#">Returns</a><a href="#">Payment</a></div>
  </div>
  <div class="footer-bottom">2025 Miya Store. All rights reserved.</div>
</footer>
<a href="https://wa.me/8615759948239" target="_blank" class="whatsapp-float"><svg viewBox="0 0 24 24"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.100-.583-.073-.78.088-.198.158-.988.957-1.154 1.126-.166.169-.424.185-.608.058-.185-.127-1.424-.727-2.625-1.827-.993-.88-1.662-1.966-1.855-2.312-.192-.346-.023-.528.126-.677.131-.131.294-.327.443-.493.149-.166.199-.298.298-.497.100-.199.066-.424-.033-.627-.099-.198-.867-2.09-1.188-2.862-.301-.723-.607-.617-.827-.617-.21 0-.432-.017-.653-.017-.221 0-.583.088-.895.437-.312.349-1.193 1.166-1.193 2.84s1.22 3.28 1.39 3.508c.17.229 2.392 3.654 5.798 5.127 2.587 1.072 3.392.886 4.048.627.657-.259 1.424-.957 1.624-1.827.199-.87.099-1.597-.033-1.827-.131-.229-.424-.349-.721-.499zm-5.472 10.618c-2.77 0-5.336-.889-7.432-2.396l-5.328 1.536 1.728-5.128c-1.667-2.166-2.656-4.876-2.656-7.812 0-7.18 5.82-13 13-13s13 5.82 13 13-5.82 13-13 13z"/></svg></a>
</body>
</html>
"@

$outputPath = "C:\Users\Administrator\.qclaw\workspace\miya-store\index.html"
[System.IO.File]::WriteAllText($outputPath, $html, [System.Text.Encoding]::UTF8)
Write-Host "Generated: $outputPath ($(($html.Length / 1KB).ToString('F1')) KB)" -ForegroundColor Green
