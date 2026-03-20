#
# Install the AI Team Bootstrap into a target project.
# Usage: .\install.ps1 -Target "C:\path\to\target\project"
#

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Target
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BootstrapDir = Join-Path $ScriptDir "bootstrap"

if (-not (Test-Path $Target -PathType Container)) {
    Write-Error "Target directory '$Target' does not exist."
    exit 1
}

if (-not (Test-Path $BootstrapDir -PathType Container)) {
    Write-Error "Bootstrap directory not found at '$BootstrapDir'."
    exit 1
}

# Check for existing .claude directory
$ClaudeDir = Join-Path $Target ".claude"
if (Test-Path $ClaudeDir) {
    $reply = Read-Host "Warning: Target already has a .claude/ directory. Overwrite? (y/N)"
    if ($reply -ne "y" -and $reply -ne "Y") {
        Write-Host "Aborted."
        exit 0
    }
}

Write-Host "Copying bootstrap files to $Target..."

# Copy all files including hidden
Get-ChildItem -Path $BootstrapDir -Force | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $Target -Recurse -Force
}

Write-Host ""
Write-Host "Bootstrap installed successfully."
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Open $Target in your editor with Claude Code"
Write-Host "  2. Run /setup to initialize your AI development team"
