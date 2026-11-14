$randomNumberGenerator = [Security.Cryptography.RandomNumberGenerator]::Create()
try {
    $tokenBytes = New-Object byte[] 32
    $randomNumberGenerator.GetBytes($tokenBytes)
    $env:FILMCRAFT_CONTROL_TOKEN = [BitConverter]::ToString($tokenBytes).Replace("-", "").ToLowerInvariant()
}
finally {
    $randomNumberGenerator.Dispose()
}