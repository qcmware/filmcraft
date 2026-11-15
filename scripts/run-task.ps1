param(
    [string]$WorkingDirectory = (Split-Path -Parent $PSScriptRoot),
    [string]$ScriptPath = 'run-server.ps1',
    [string]$LogFile,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ScriptArguments
)

Set-Location -LiteralPath $WorkingDirectory;
$script = (Join-Path (Get-Location) $ScriptPath);
if (-not (Test-Path -LiteralPath $script -PathType Leaf)) {
    throw "No se encontró $script";
}
$shell = (Get-Process -Id $PID).Path;
if ([string]::IsNullOrWhiteSpace($shell)) {
    $shell = (Get-Command pwsh.exe, powershell.exe -ErrorAction Stop | Select-Object -First 1 -ExpandProperty Source);
}
$arguments = @('-NoProfile', '-File', $script) + @($ScriptArguments);
if (-not [string]::IsNullOrWhiteSpace($LogFile)) {
    $arguments += @('-LogFile', $LogFile);
}
Start-Process -FilePath $shell -WorkingDirectory (Get-Location).Path -ArgumentList $arguments -WindowStyle Hidden