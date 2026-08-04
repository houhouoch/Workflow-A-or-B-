param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [ValidateRange(1, 1000)]
    [int]$Tail = 30
)

if (-not (Test-Path -LiteralPath $Path)) {
    throw "Serial log does not exist: $Path"
}

Get-Content -LiteralPath $Path -Tail $Tail -Wait

