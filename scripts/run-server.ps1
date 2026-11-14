param(
	[int]$Port = 9876
)

Set-Location D:\Projects\filmcraft
$env:WGPU_BACKEND = "dx12"
cargo run --release -p filmcraft -- --control $Port