$git = 'C:\Program Files\Git\bin\git.exe'

# 配置 Git
& $git config --global user.name "chaoqunfang"
& $git config --global user.email "chaoqunfang510@gmail.com"

Write-Host "Git configured:"
& $git config --global user.name
& $git config --global user.email

# 进入项目目录
Set-Location 'C:\Users\Administrator\.qclaw\workspace\miya-store'

# 初始化仓库
& $git init
& $git add .
& $git commit -m "Initial commit: Miya Store with 155 products"

Write-Host "`nRepository initialized!"
