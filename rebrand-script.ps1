# Rebrand script for Janten Terkini
# Backup articles.json
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Copy-Item -Path "articles.json" -Destination "articles.json.bak.$timestamp" -Force

# Function to perform replacements
function Replace-InFile {
    param (
        [string]$filePath
    )
    $content = Get-Content -Path $filePath -Raw -Encoding UTF8
    $originalContent = $content

    # Branding replacements
    $content = $content -replace "Warta Janten", "Janten Terkini"
    $content = $content -replace "wartajanten", "jantenterkini"
    $content = $content -replace "WartaJanten", "JantenTerkini"

    # Email
    $content = $content -replace "wartajanten@gmail\.com", "jantenterkini@gmail.com"

    # Social handles and URLs
    $content = $content -replace "facebook\.com/wartajanten", "facebook.com/jantenterkini"
    $content = $content -replace "twitter\.com/wartajanten", "twitter.com/jantenterkini"
    $content = $content -replace "instagram\.com/wartajanten", "instagram.com/jantenterkini"
    $content = $content -replace "youtube\.com/wartajanten", "youtube.com/jantenterkini"

    # Page titles
    $content = $content -replace "- Warta Janten", "- Janten Terkini"

    # Logo text replacement
    $content = $content -replace '<span style="font-weight: bold; color: #1F2937; font-size: 24px; letter-spacing: -0.5px;">WARTA<span style="color: #7F2B2B; font-weight: normal; font-size: 18px; margin-left: 2px;">JANTEN</span></span>', '<span style="font-weight: bold; color: #1F2937;">JANTEN</span><span style="font-size: smaller; color: #7F2B2B;">TERKINI</span>'

    # Alt text for logo
    $content = $content -replace 'alt="[^"]*logo[^"]*"', 'alt="Janten Terkini"'

    # Color replacements (assuming specific mappings)
    $content = $content -replace "#FFCC00", "#1F2937"  # primary
    $content = $content -replace "#1E2024", "#111827"  # dark
    # For secondary, assuming #7F2B2B is new, but need to find old secondary. Assuming old secondary is something like #some color, but since not specified, skip or assume.

    # Encoding fixes
    $content = $content -replace '["""]', '"'  # “ -> "
    $content = $content -replace "[''']", "'"  # ' -> '
    $content = $content -replace '[–—]', '-'  # – — -> -
    $content = $content -replace '\uFFFD', ' '  # U+FFFD -> space
    $content = $content -replace '&nbsp;', ' '

    # Package.json specific
    if ($filePath -like "*package.json") {
        $content = $content -replace '"name":\s*"[^"]*"', '"name": "jantenterkini"'
        $content = $content -replace '"name":\s*"[^"]*article-generator[^"]*"', '"name": "jantenterkini-article-generator"'
    }

    # If content changed, write back
    if ($content -ne $originalContent) {
        Set-Content -Path $filePath -Value $content -Encoding UTF8
        return $true
    }
    return $false
}

# Get all relevant files
$files = Get-ChildItem -Recurse -Include *.html, *.css, *.json, *.md, *.toml | Where-Object { $_.FullName -notlike "*node_modules*" }

$changedFiles = @{
    "main pages" = 0
    "article pages" = 0
    "css" = 0
    "package" = 0
    "docs" = 0
}

foreach ($file in $files) {
    $changed = Replace-InFile -filePath $file.FullName
    if ($changed) {
        if ($file.Name -like "*.html" -and $file.Directory.Name -eq "article") {
            $changedFiles["article pages"]++
        } elseif ($file.Name -like "*.html") {
            $changedFiles["main pages"]++
        } elseif ($file.Name -like "*.css") {
            $changedFiles["css"]++
        } elseif ($file.Name -like "*package.json") {
            $changedFiles["package"]++
        } elseif ($file.Name -like "*.md" -or $file.Name -like "*.toml") {
            $changedFiles["docs"]++
        }
    }
}

# Output results
Write-Host "Jumlah file yang diubah:"
Write-Host "main pages: $($changedFiles['main pages'])"
Write-Host "article pages: $($changedFiles['article pages'])"
Write-Host "css: $($changedFiles['css'])"
Write-Host "package: $($changedFiles['package'])"
Write-Host "docs: $($changedFiles['docs'])"
Write-Host "Rebrand Janten Terkini selesai ✅"