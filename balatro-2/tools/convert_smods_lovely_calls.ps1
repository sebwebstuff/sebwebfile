param(
    [Parameter(Mandatory = $true)]
    [string]$InputFile,

    [string]$OutputFile = ""
)

if (-not (Test-Path $InputFile)) {
    throw "Input file not found: $InputFile"
}

if ([string]::IsNullOrWhiteSpace($OutputFile)) {
    $OutputFile = [System.IO.Path]::ChangeExtension($InputFile, '.native-preview.lua')
}

$content = Get-Content -Raw $InputFile

$replacements = @(
    @{ Pattern = 'SMODS\.end_calculate_context\(([^\)]*)\)'; Replace = '($1 and $1.joker_main)' },
    @{ Pattern = 'SMODS\.findModByID\(([^\)]*)\)\.path'; Replace = 'NATIVE_MOD_PATH' },
    @{ Pattern = 'SMODS\.Joker:new\('; Replace = 'NATIVE_JOKER_NEW(' },
    @{ Pattern = 'SMODS\.Deck:new\('; Replace = 'NATIVE_DECK_NEW(' },
    @{ Pattern = 'SMODS\.Sprite:new\('; Replace = 'NATIVE_SPRITE_NEW(' },
    @{ Pattern = 'SMODS\.'; Replace = 'NATIVE_SMODS.' },
    @{ Pattern = 'lovely\.'; Replace = 'NATIVE_LOVELY.' }
)

foreach ($entry in $replacements) {
    $content = [regex]::Replace($content, $entry.Pattern, $entry.Replace)
}

$header = @"
-- AUTO-GENERATED PREVIEW
-- This file is a mechanical conversion aid only.
-- It is NOT guaranteed runnable without manual integration.
-- Source: $InputFile

"@

Set-Content -Path $OutputFile -Value ($header + $content)
Write-Output "Wrote preview: $OutputFile"
