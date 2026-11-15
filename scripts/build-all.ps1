param(
	[string]$WorkingDirectory = (Split-Path -Parent $PSScriptRoot),
	[string]$LogFile
)

Set-Location -LiteralPath $WorkingDirectory
$env:WGPU_BACKEND = "dx12"
if ([string]::IsNullOrWhiteSpace($LogFile)) {
	cargo build --release -p filmcraft -p filmcraft-cli
} else {
	cargo build --release -p filmcraft -p filmcraft-cli *> $LogFile
}