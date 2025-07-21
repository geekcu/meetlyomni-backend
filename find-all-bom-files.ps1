# Find all text files with UTF-8 BOM

Write-Host "Searching for all text files with BOM..."

$extensions = @("*.cs", "*.json", "*.xml", "*.config", "*.txt", "*.md", "*.editorconfig", "*.gitignore")

foreach ($extension in $extensions) {
    $files = Get-ChildItem -Path "MeetlyOmni" -Filter $extension -Recurse -ErrorAction SilentlyContinue
    
    foreach ($file in $files) {
        try {
            $bytes = Get-Content $file.FullName -Encoding Byte -TotalCount 3 -ErrorAction SilentlyContinue
            
            # Check for UTF-8 BOM (239, 187, 191)
            if ($bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191) {
                Write-Host "Found BOM in: $($file.FullName)"
                
                # Read content and rewrite without BOM
                $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
                if ($content) {
                    $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $false
                    [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBomEncoding)
                    Write-Host "Fixed: $($file.FullName)"
                }
            }
        }
        catch {
            Write-Host "Error checking file: $($file.FullName) - $($_.Exception.Message)"
        }
    }
}

Write-Host "Comprehensive BOM fix completed!" 