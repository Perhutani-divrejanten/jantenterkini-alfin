# Script untuk memperbaiki quotation encoding dan karakter khusus

$WorkspaceRoot = "c:\KULIAH\MAGANG\Magang di Perhutani\Janten Terkini"

# Define replacements untuk quotation dan special characters
$replacements = @(
    @{ old = '"'; new = '"'; desc = 'Left double quote (")' },
    @{ old = '"'; new = '"'; desc = 'Right double quote (")' },
    @{ old = '''; new = "'"; desc = 'Left single quote (')' },
    @{ old = '''; new = "'"; desc = 'Right single quote (')' },
    @{ old = '–'; new = '-'; desc = 'En-dash (–)' },
    @{ old = '—'; new = '-'; desc = 'Em-dash (—)' },
    @{ old = [char]0xFFFD; new = ' '; desc = 'Replacement character (U+FFFD)' },
    @{ old = [char]0xA0; new = ' '; desc = 'Non-breaking space (nbsp)' }
)

$fileTypes = @("*.html", "*.js")
$filesUpdated = 0
$totalReplacements = 0

Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  PERBAIKAN ENCODING KARAKTER SEMUA FILE" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

foreach ($fileType in $fileTypes) {
    $files = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include $fileType -File |
             Where-Object { $_.FullName -notlike "*\node_modules\*" -and $_.FullName -notlike "*\archive\*" }
    
    foreach ($file in $files) {
        try {
            $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
            $originalContent = $content
            $fileReplacements = 0
            
            # Apply replacements
            foreach ($replacement in $replacements) {
                $pattern = [regex]::Escape($replacement.old)
                $matches = @([regex]::Matches($originalContent, $pattern))
                
                if ($matches.Count -gt 0) {
                    $content = $content -replace $pattern, $replacement.new
                    $fileReplacements += $matches.Count
                    Write-Host "  ✓ $($file.Name): $($replacement.desc) ($($matches.Count))"
                }
            }
            
            # Check if content changed
            if ($fileReplacements -gt 0) {
                Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
                $filesUpdated++
                $totalReplacements += $fileReplacements
            }
        } catch {
            Write-Host "Error processing $($file.FullName): $_" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✅ SELESAI!" -ForegroundColor Green
Write-Host "  • Total file diproses: $filesUpdated" -ForegroundColor Green
Write-Host "  • Total perbaikan karakter: $totalReplacements" -ForegroundColor Green
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Total files updated: $filesUpdated"
