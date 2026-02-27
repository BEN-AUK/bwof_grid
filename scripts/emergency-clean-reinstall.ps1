# ============================================================
# Next.js 15 急救：清理僵尸缓存与依赖后重装
# 在项目根目录 d:\bwof_grid 下用 PowerShell 执行
# ============================================================

# 第一步：清理
Write-Host "Step 1: Removing node_modules, .next, package-lock.json..." -ForegroundColor Yellow
if (Test-Path "node_modules") { Remove-Item -Recurse -Force "node_modules" }
if (Test-Path ".next")        { Remove-Item -Recurse -Force ".next" }
if (Test-Path "package-lock.json") { Remove-Item -Force "package-lock.json" }
Write-Host "Done." -ForegroundColor Green

# 第二步：重装（包含你列出的所有必需包）
Write-Host "Step 2: Installing dependencies..." -ForegroundColor Yellow
npm install
Write-Host "Done. Run: npm run dev" -ForegroundColor Green
