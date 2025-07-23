# 测试Git钩子是否正常工作的脚本
Write-Host "🧪 正在测试Git钩子..."

# 检查pre-commit钩子是否存在
if (Test-Path .git/hooks/pre-commit) {
    Write-Host "✅ pre-commit钩子文件存在"
    
    # 显示钩子内容
    Write-Host "`n📄 钩子内容："
    Get-Content .git/hooks/pre-commit | ForEach-Object { Write-Host "  $_" }
    
    # 测试dotnet命令
    Write-Host "`n🔍 测试dotnet命令可用性..."
    
    try {
        $formatResult = dotnet format MeetlyOmni.sln --dry-run --verbosity quiet 2>&1
        Write-Host "✅ dotnet format: 可用"
    } catch {
        Write-Host "❌ dotnet format: 失败 - $_"
    }
    
    try {
        $buildResult = dotnet build MeetlyOmni.sln --no-restore --verbosity quiet 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ dotnet build: 成功"
        } else {
            Write-Host "⚠️  dotnet build: 有警告或错误"
        }
    } catch {
        Write-Host "❌ dotnet build: 失败 - $_"
    }
    
    try {
        $testResult = dotnet test MeetlyOmni.sln --no-build --verbosity quiet 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ dotnet test: 成功"
        } else {
            Write-Host "⚠️  dotnet test: 有失败的测试"
        }
    } catch {
        Write-Host "❌ dotnet test: 失败 - $_"
    }
    
    Write-Host "`n🎉 钩子测试完成！现在可以正常提交代码了。"
} else {
    Write-Host "❌ pre-commit钩子文件不存在"
    Write-Host "请运行: .\setup-git-hooks.ps1"
} 