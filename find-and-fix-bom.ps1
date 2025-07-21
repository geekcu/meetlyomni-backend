# Find and fix all .cs files with UTF-8 BOM

Write-Host "Searching for .cs files with BOM..."

$csFiles = Get-ChildItem -Path "MeetlyOmni" -Filter "*.cs" -Recurse

foreach ($file in $csFiles) {
    $bytes = Get-Content $file.FullName -Encoding Byte -TotalCount 3
    
    # Check for UTF-8 BOM (239, 187, 191)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191) {
        Write-Host "Found BOM in: $($file.FullName)"
        
        # Read content and rewrite without BOM
        $content = Get-Content $file.FullName -Raw
        $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBomEncoding)
        
        Write-Host "Fixed: $($file.FullName)"
    }
}

Write-Host "BOM fix completed!" 