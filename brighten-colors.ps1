# Darken the blue theme
$cssFile = "css/style.css"
$cssContent = Get-Content -Path $cssFile -Raw -Encoding UTF8
$cssContent = $cssContent -replace "#60A5FA", "#2563EB"  # primary to darker blue
$cssContent = $cssContent -replace "#93C5FD", "#3B82F6"  # secondary to medium blue
$cssContent = $cssContent -replace "#3B82F6", "#1E3A8A"  # dark to darker blue (but wait, dark was #3B82F6, now change to #1E3A8A)
# Actually, replace --dark first
$cssContent = $cssContent -replace "--dark: #3B82F6;", "--dark: #1E3A8A;"
Set-Content -Path $cssFile -Value $cssContent -Encoding UTF8

# Update HTML hardcoded colors
$files = Get-ChildItem -Recurse -Include *.html | Where-Object { $_.FullName -notlike "*node_modules*" }
foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $content = $content -replace "color: #60A5FA;", "color: #2563EB;"
    $content = $content -replace "color: #93C5FD;", "color: #3B82F6;"
    Set-Content -Path $file.FullName -Value $content -Encoding UTF8
}

Write-Host "Warna biru digelapkan ✅"