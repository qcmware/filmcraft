param(
	[string]$WorkingDirectory = (Split-Path -Parent $PSScriptRoot),
	[int]$Port = 9876,
	[string]$ExecutablePath = 'target\release\filmcraft.exe',
	[string]$LogFile
)

Set-Location -LiteralPath $WorkingDirectory
$env:WGPU_BACKEND = "dx12"
if ([string]::IsNullOrWhiteSpace($LogFile)) {
	& $ExecutablePath --control $Port
} else {
	& $ExecutablePath --control $Port *> $LogFile
}