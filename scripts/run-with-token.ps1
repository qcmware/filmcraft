param(
	[string]$WorkingDirectory = (Split-Path -Parent $PSScriptRoot),
	[string]$LogFile
)

Set-Location -LiteralPath $WorkingDirectory

.\set-token.ps1

$env:WGPU_BACKEND = "dx12"
$env:CARGO_INCREMENTAL = "0"

if ([string]::IsNullOrWhiteSpace($LogFile)) {
	.\run-server.ps1 -WorkingDirectory $WorkingDirectory
} else {
	.\run-server.ps1 -WorkingDirectory $WorkingDirectory -LogFile $LogFile
}