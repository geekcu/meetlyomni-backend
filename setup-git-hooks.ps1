# Git钩子设置脚本
Write-Host "🔧 正在设置Git钩子..."

# 确保.git/hooks目录存在
if (-not (Test-Path .git/hooks)) {
    New-Item -ItemType Directory -Path .git/hooks -Force
    Write-Host "✅ 创建了 .git/hooks 目录"
}

# 创建pre-commit钩子内容
$preCommitContent = @'
#!/bin/sh
echo "🔍 Running dotnet format..."
dotnet format MeetlyOmni.sln || exit 1

echo "🔨 Building solution..."
dotnet build MeetlyOmni.sln --no-restore || exit 1

echo "🧪 Running tests..."
dotnet test MeetlyOmni.sln --no-build || exit 1
'@

# 写入pre-commit钩子
$preCommitContent | Out-File -FilePath ".git/hooks/pre-commit" -Encoding UTF8

Write-Host "✅ Git钩子设置完成！"
Write-Host "现在每次提交前都会自动执行："
Write-Host "  - 代码格式化 (dotnet format)"
Write-Host "  - 构建检查 (dotnet build)"
Write-Host "  - 单元测试 (dotnet test)" 