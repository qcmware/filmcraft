Set-Location D:\Projects\filmcraft

.\set-token.ps1

$env:WGPU_BACKEND = "dx12"
$env:CARGO_INCREMENTAL = "0"

.\run-server.ps1