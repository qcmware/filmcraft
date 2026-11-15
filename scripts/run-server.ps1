param(
	[string]$WorkingDirectory = (Split-Path -Parent $PSScriptRoot),
	[int]$Port = 9876,
	[string]$LogFile
)

Set-Location -LiteralPath $WorkingDirectory
$env:WGPU_BACKEND = "dx12"
if ([string]::IsNullOrWhiteSpace($LogFile)) {
	cargo run --release -p filmcraft -- --control $Port
} else {
	cargo run --release -p filmcraft -- --control $Port *> $LogFile
}