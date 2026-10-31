# Build both Windows x64 formats from the same source.
# Run on Windows with Python 3.13 installed: powershell -ExecutionPolicy Bypass -File .\build-windows.ps1
param(
    [switch]$SkipInstall,
    [switch]$SkipSmokeTest
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Set-Location $PSScriptRoot

function Check-Exit([string]$label) {
    if ($LASTEXITCODE -ne 0) {
        throw "$label failed with exit code $LASTEXITCODE"
    }
}

if (-not (Test-Path "SweepAtlasSigh.txt")) {
    throw "Cannot find SweepAtlasSigh.txt in this repository."
}
if (-not (Test-Path "vhsimagestitch_launcher.py")) {
    throw "Cannot find vhsimagestitch_launcher.py."
}

python --version
Check-Exit "Python version check"
if (-not $SkipInstall) {
    python -m pip install --upgrade pip
    Check-Exit "Upgrade pip"
    python -m pip install --upgrade "pyinstaller>=6.10,<7" "numpy>=1.26,<3" "opencv-python>=4.9,<5"
    Check-Exit "Install build dependencies"
}

# The published repository uses .txt for the original Python script.
# Copy (don't rename or overwrite) it into the importable .py module.
Copy-Item -LiteralPath "SweepAtlasSigh.txt" -Destination "SweepAtlasSigh.py" -Force

python -m py_compile "SweepAtlasSigh.py" "vhsimagestitch_launcher.py"
Check-Exit "Python syntax check"

$common = @(
    "--noconfirm", "--clean", "--noupx", "--windowed",
    "--name", "VHSImageStitch", "--hidden-import", "tkinter", "--paths", "."
)

Write-Host "Building portable Windows folder..." -ForegroundColor Cyan
python -m PyInstaller @common --onedir --distpath "dist/portable" --workpath "build/portable" --specpath "build/portable_spec" "vhsimagestitch_launcher.py"
Check-Exit "PyInstaller onedir"

Write-Host "Building single-file Windows exe..." -ForegroundColor Cyan
python -m PyInstaller @common --onefile --distpath "dist/single" --workpath "build/single" --specpath "build/single_spec" "vhsimagestitch_launcher.py"
Check-Exit "PyInstaller onefile"

$folderExe = Join-Path $PSScriptRoot "dist\portable\VHSImageStitch\VHSImageStitch.exe"
$singleExe = Join-Path $PSScriptRoot "dist\single\VHSImageStitch.exe"
if (-not (Test-Path $folderExe) -or -not (Test-Path $singleExe)) {
    throw "Missing expected Windows exe output."
}

if (-not $SkipSmokeTest) {
    foreach ($exe in @($folderExe, $singleExe)) {
        Write-Host "Running synthetic packaged self-test: $exe"
        $p = Start-Process -FilePath $exe -ArgumentList "--self-test" -Wait -PassThru
        if ($p.ExitCode -ne 0) {
            throw "Packaged self-test failed with exit code $($p.ExitCode). See $env:LOCALAPPDATA\VHSImageStitch\vhsimagestitch.log"
        }
    }

    $log = Join-Path $env:LOCALAPPDATA "VHSImageStitch\vhsimagestitch.log"
    if (-not (Test-Path $log)) {
        throw "Packaged self-test produced no log: $log"
    }
    $tail = (Get-Content -LiteralPath $log -Tail 30) -join "`n"
    if ($tail -notmatch "PASS: synthetic scale registration") {
        throw "Packaged smoke test did not report registration PASS. Log tail: $tail"
    }
}

New-Item -ItemType Directory -Path "release" -Force | Out-Null
$zipPath = Join-Path $PSScriptRoot "release\VHSImageStitch-Windows-x64-Portable.zip"
$onePath = Join-Path $PSScriptRoot "release\VHSImageStitch-Windows-x64.exe"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Compress-Archive -Path "dist/portable/VHSImageStitch" -DestinationPath $zipPath
Copy-Item -LiteralPath $singleExe -Destination $onePath -Force

Get-Item $zipPath, $onePath | Select-Object Name, Length, FullName | Format-Table
Write-Host "Build complete. Both packages are in release\." -ForegroundColor Green
