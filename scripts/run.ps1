param(
	[string]$WorkingDirectory = (Split-Path -Parent $PSScriptRoot),
	[int]$Port = 9876,
	[string]$LogFile,
	[Parameter(ValueFromRemainingArguments = $true)]
	[string[]]$ProgramArguments
)

Set-Location -LiteralPath $WorkingDirectory
$env:WGPU_BACKEND = "dx12"
$cargoArguments = @('--release', '-p', 'filmcraft', '--', '--control', $Port) + @($ProgramArguments)
if ([string]::IsNullOrWhiteSpace($LogFile)) {
	& cargo run @cargoArguments
} else {
	& cargo run @cargoArguments *> $LogFile
}