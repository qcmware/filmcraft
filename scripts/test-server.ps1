param(
	[string]$HostName = '127.0.0.1',
	[int]$Port = 9876,
	[string]$LogFile
)

if ([string]::IsNullOrWhiteSpace($LogFile)) {
	Test-NetConnection $HostName -Port $Port
} else {
	Test-NetConnection $HostName -Port $Port *> $LogFile
}