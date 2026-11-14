param(
    [string]$ScriptPath = 'run-server.ps1'
)

$script = (Join-Path (Get-Location) $ScriptPath);
if (-not (Test-Path -LiteralPath $script -PathType Leaf)) {
    throw "No se encontró $script";
}
$shell = (Get-Process -Id $PID).Path;
if ([string]::IsNullOrWhiteSpace($shell)) {
    $shell = (Get-Command pwsh.exe, powershell.exe -ErrorAction Stop | Select-Object -First 1 -ExpandProperty Source);
}
Start-Process -FilePath $shell -WorkingDirectory (Get-Location).Path -ArgumentList @('-NoProfile', '-File', $script) -WindowStyle Hidden