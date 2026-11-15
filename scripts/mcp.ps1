param(
	[string]$WorkingDirectory = (Split-Path -Parent $PSScriptRoot),
	[string]$HostName = '127.0.0.1',
	[int]$Port = 9876,
	[string]$ExecutablePath = 'target\release\filmcraft-cli.exe',
	[string]$LogFile,
	[Parameter(ValueFromRemainingArguments = $true)]
	[string[]]$ProgramArguments
)

Set-Location -LiteralPath $WorkingDirectory
$env:WGPU_BACKEND = "dx12"

$bridge = '{0}:{1}' -f $HostName, $Port
if ([string]::IsNullOrWhiteSpace($LogFile)) {
	& $ExecutablePath mcp --bridge $bridge @ProgramArguments
} else {
	& $ExecutablePath mcp --bridge $bridge @ProgramArguments *> $LogFile
}