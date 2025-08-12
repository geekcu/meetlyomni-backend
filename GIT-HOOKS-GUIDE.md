# Git Hooks 使用指南

## 概述

本项目配置了智能的Git hooks来确保代码质量。Git hooks会在特定的Git操作时自动运行，执行代码质量检查。

## 可用的Git Hooks

### 1. setup-git-hooks-final.ps1 (推荐)
智能的Git hooks配置，具有以下特性：

- **pre-commit**: 自动格式化代码 + 重新暂存 + 快速构建
- **pre-push**: 智能覆盖率检查
  - 当没有Controllers/Services代码时：跳过覆盖率检查，只运行基本测试
  - 当有Controllers/Services代码时：强制执行80%覆盖率要求
  - 当覆盖率工具失败时：自动降级到基本测试

### 2. setup-git-hooks-simple.ps1
简化的Git hooks配置，适合早期开发阶段：

- **pre-commit**: 自动格式化代码 + 重新暂存 + 快速构建
- **pre-push**: 格式检查 + 构建 + 单元测试（禁用覆盖率检查）

## 使用方法

### 设置Git Hooks

```powershell
# 使用智能Git hooks（推荐）
.\setup-git-hooks-final.ps1

# 或使用简化版本（早期开发）
.\setup-git-hooks-simple.ps1
```

### 临时禁用Git Hooks

```powershell
# 禁用Git hooks
git config core.hooksPath /dev/null

# 重新启用Git hooks
git config --unset core.hooksPath
```

## 覆盖率要求

### 当前设置
- **覆盖率阈值**: 80%
- **覆盖范围**: Controllers和Services目录下的代码
- **检查时机**: 当检测到Controllers或Services代码时

### 如何达到覆盖率要求

1. **为Controllers添加单元测试**:
   ```csharp
   // 示例：HealthControllerTests.cs
   public class HealthControllerTests
   {
       [Fact]
       public void Get_ShouldReturnOkResult()
       {
           // 测试代码
       }
   }
   ```

2. **为Services添加单元测试**:
   ```csharp
   // 示例：UserServiceTests.cs
   public class UserServiceTests
   {
       [Fact]
       public void GetUser_ShouldReturnUser()
       {
           // 测试代码
       }
   }
   ```

3. **确保测试项目引用API项目**:
   ```xml
   <!-- 在 *.Unit.tests.csproj 中添加 -->
   <ItemGroup>
     <ProjectReference Include="..\MeetlyOmni.Api\MeetlyOmni.Api.csproj" />
   </ItemGroup>
   ```

## 故障排除

### 覆盖率检查失败

如果覆盖率检查失败，Git hooks会自动降级到基本测试：

1. **检查覆盖率工具**:
   ```powershell
   dotnet tool list
   dotnet tool restore
   ```

2. **手动测试覆盖率**:
   ```powershell
   dotnet-coverage collect "dotnet test src/MeetlyOmni.Unit.tests/MeetlyOmni.Unit.tests.csproj -c Release --no-build" -f cobertura -o coverage/coverage.cobertura.xml
   ```

3. **查看覆盖率报告**:
   ```powershell
   # 查看生成的覆盖率文件
   Get-Content coverage/coverage.cobertura.xml
   ```

### 构建失败

1. **检查项目引用**:
   ```powershell
   dotnet restore
   dotnet build
   ```

2. **检查代码格式**:
   ```powershell
   dotnet format
   ```

### 测试失败

1. **运行测试**:
   ```powershell
   dotnet test src/MeetlyOmni.Unit.tests/MeetlyOmni.Unit.tests.csproj
   ```

2. **检查测试项目配置**:
   - 确保测试项目引用了API项目
   - 确保测试方法使用了正确的测试框架（xUnit）

## 最佳实践

1. **开发阶段**: 使用 `setup-git-hooks-simple.ps1`
2. **有业务逻辑时**: 切换到 `setup-git-hooks-final.ps1`
3. **定期检查覆盖率**: 手动运行覆盖率检查确保质量
4. **编写测试**: 为所有Controllers和Services编写单元测试
5. **保持测试更新**: 当修改业务逻辑时，同步更新测试

## 文件结构

```
meetlyomni-backend/
├── setup-git-hooks-final.ps1      # 智能Git hooks配置
├── setup-git-hooks-simple.ps1     # 简化Git hooks配置
├── .git/hooks/                    # Git hooks目录
│   ├── pre-commit                 # 提交前检查
│   ├── pre-push                   # 推送前检查
│   └── pre-push.ps1              # PowerShell脚本
└── coverage/                      # 覆盖率报告目录
    └── coverage.cobertura.xml     # Cobertura格式覆盖率报告
```
