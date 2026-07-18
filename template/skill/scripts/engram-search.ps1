$ErrorActionPreference = "Stop"

$ScriptPath = Join-Path $PSScriptRoot "engram_search.py"

function Invoke-FirstPython {
    param([string[]] $PythonArgs)

    $commands = @(
        @{ Command = "python3"; Prefix = @() },
        @{ Command = "python"; Prefix = @() },
        @{ Command = "py"; Prefix = @("-3") }
    )

    foreach ($candidate in $commands) {
        if (Get-Command $candidate.Command -ErrorAction SilentlyContinue) {
            & $candidate.Command @($candidate.Prefix + $ScriptPath + $PythonArgs)
            exit $LASTEXITCODE
        }
    }

    [Console]::Error.WriteLine("Engram needs Python 3, but no python3, python, or py launcher was found on PATH.")
    exit 127
}

Invoke-FirstPython -PythonArgs $args
