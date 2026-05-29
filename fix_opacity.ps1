$files = Get-ChildItem -Path lib -Filter *.dart -Recurse
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $newContent = $content -replace 'withOpacity\(', 'withValues(alpha: '
    if ($content -ne $newContent) {
        Set-Content $file.FullName $newContent
        Write-Host "Updated $($file.FullName)"
    }
}
