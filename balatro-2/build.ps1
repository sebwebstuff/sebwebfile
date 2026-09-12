# Build script to create a .love file and a love.js web build
# A .love file is just a zip archive with game files

$OutputFile = "balatro-orce.love"
$SourceDir = Get-Location

# Explicit output directory to exclude from the package
$OutputDir = Join-Path $SourceDir "Balatro"
$ZipOutput = "$OutputFile.zip"

Write-Host "Building $OutputFile..." -ForegroundColor Cyan

# Remove old artifacts if they exist
foreach ($old in @($OutputFile, $ZipOutput)) {
    if (Test-Path $old) {
        Write-Host "Removing old $old..." -ForegroundColor Yellow
        Remove-Item $old -Force -ErrorAction SilentlyContinue
    }
}

# Get all files to include (exclude build scripts, git files, the output folder, etc.)
$FilesToInclude = Get-ChildItem -Path $SourceDir -Recurse -File | Where-Object {
    $_.FullName -notmatch '\\.git\\' -and
    ($OutputDir -eq $null -or ($_.FullName -notlike "$OutputDir*")) -and
    $_.Extension -notin @('.love', '.ps1', '.py', '.md', '.gitignore') -and
    $_.Name -notin @('build.ps1', 'serve.py', 'README.md', '.gitignore')
}

Write-Host "Found $($FilesToInclude.Count) files to package" -ForegroundColor Green

# Create a temporary directory for staging
$TempDir = Join-Path $env:TEMP "balatro-build-$(Get-Random)"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

try {
    # Copy files to temp directory maintaining structure
    foreach ($file in $FilesToInclude) {
        $relativePath = $file.FullName.Substring($SourceDir.Path.Length + 1)
        $destPath = Join-Path $TempDir $relativePath
        $destDir = Split-Path $destPath -Parent
        
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        
        Copy-Item $file.FullName -Destination $destPath -Force
    }
    
    Write-Host "Creating .love archive..." -ForegroundColor Cyan
    
    # Create zip file (which is what .love files are) then rename to .love
    Compress-Archive -Path "$TempDir\*" -DestinationPath $ZipOutput -CompressionLevel Optimal -Force
    Move-Item -Path $ZipOutput -Destination $OutputFile -Force
    
    $FileSize = (Get-Item $OutputFile).Length / 1MB
    Write-Host "Successfully created $OutputFile ($([math]::Round($FileSize, 2)) MB)" -ForegroundColor Green
    
} finally {
    # Clean up temp directory and any leftover zip
    if (Test-Path $TempDir) {
        Remove-Item $TempDir -Recurse -Force
    }
    if (Test-Path $ZipOutput) {
        Remove-Item $ZipOutput -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "`nBuilding love.js web output..." -ForegroundColor Cyan

$webBuildReady = $false
$loveJsInput = Join-Path $SourceDir $OutputFile
$loveJsOutputName = "Balatro"

# Keep the initial memory larger than the packed data size to avoid love.js allocation errors.
$assetBytes = (Get-Item $loveJsInput).Length
$memoryStep = 16MB
$recommendedMemory = [int64]([math]::Ceiling(($assetBytes * 1.35) / $memoryStep) * $memoryStep)
$minimumMemory = 256MB
$loveJsMemory = [int64]([math]::Max($minimumMemory, $recommendedMemory))

$loveJsArgs = @(
    $loveJsInput,
    $loveJsOutputName,
    "-t", "Balatro",
    "-m", $loveJsMemory.ToString()
)

$loveJsCandidates = @(
    @{ type = "direct"; command = (Join-Path $SourceDir "node_modules\.bin\love.js.cmd"); prefix = @() },
    @{ type = "direct"; command = "C:\Users\winke\node_modules\.bin\love.js.cmd"; prefix = @() },
    @{ type = "node"; command = "node"; prefix = @((Join-Path $SourceDir "love.js\index.js")) },
    @{ type = "npx"; command = "npx"; prefix = @("love.js.cmd") }
)

$selectedLoveJs = $null
foreach ($candidate in $loveJsCandidates) {
    if ($candidate.type -eq "direct") {
        if (Test-Path $candidate.command) {
            $selectedLoveJs = $candidate
            break
        }
        continue
    }

    if (Get-Command $candidate.command -ErrorAction SilentlyContinue) {
        $selectedLoveJs = $candidate
        break
    }
}

if ($null -eq $selectedLoveJs) {
    Write-Host "love.js CLI not detected. Install Node.js and love.js (or run npm install in ./love.js) and rerun this script." -ForegroundColor Yellow
} else {
    Write-Host "Using love.js launcher: $($selectedLoveJs.command)" -ForegroundColor Gray
    Write-Host "love.js memory: $loveJsMemory bytes" -ForegroundColor Gray

    # Clean previous web build output
    if (Test-Path $OutputDir) {
        Remove-Item $OutputDir -Recurse -Force
    }

    & $selectedLoveJs.command @($selectedLoveJs.prefix + $loveJsArgs)
    $loveJsExitCode = $LASTEXITCODE

    $requiredArtifacts = @(
        (Join-Path $OutputDir "game.js"),
        (Join-Path $OutputDir "love.js")
    )
    $missingArtifacts = @($requiredArtifacts | Where-Object { -not (Test-Path $_) })

    if ($loveJsExitCode -eq 0 -and $missingArtifacts.Count -eq 0) {
        $webBuildReady = $true
        Write-Host "love.js build complete: $OutputDir" -ForegroundColor Green
    } else {
        Write-Host "love.js build failed or did not produce required files." -ForegroundColor Yellow
        if ($loveJsExitCode -ne 0) {
            Write-Host "  Exit code: $loveJsExitCode" -ForegroundColor Yellow
        }
        if ($missingArtifacts.Count -gt 0) {
            Write-Host "  Missing artifacts:" -ForegroundColor Yellow
            $missingArtifacts | ForEach-Object { Write-Host "    - $_" -ForegroundColor Yellow }
        }
    }
}

$patchScript = Join-Path $SourceDir "patch-html.ps1"
if ($webBuildReady -and (Test-Path $patchScript)) {
    Write-Host "\nRunning patch-html.ps1 to ensure canonical HTML/CSS" -ForegroundColor Cyan
    & $patchScript
    if ($LASTEXITCODE -ne 0) {
        Write-Host "patch-html.ps1 reported a non-zero exit code ($LASTEXITCODE)" -ForegroundColor Yellow
    }
} elseif (-not $webBuildReady) {
    Write-Host "Skipping patch-html.ps1 because web build artifacts were not generated." -ForegroundColor Yellow
} else {
    Write-Host "patch-html.ps1 not found; skipping canonical HTML/CSS update." -ForegroundColor Yellow
}

Write-Host "`nDone!" -ForegroundColor Cyan
Write-Host "  - Run with Love2D: love $OutputFile" -ForegroundColor White
Write-Host "  - Web build output: $OutputDir" -ForegroundColor White
