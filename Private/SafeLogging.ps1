#
# SafeLogging.ps1
# Provides safe wrapper functions for logging that gracefully handle missing LoggingModule
#

function Write-SafeLogInternal {
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [hashtable]$Additional = @{},

        [Parameter(Mandatory)]
        [string]$PreferredCommand,   # z.B. 'Write-InfoLog' from LoggingModule

        [Parameter(Mandatory)]
        [string]$FallbackCommand,    # z.B. 'Write-Information' as native fallback

        [string]$Prefix = ''         # z.B. '[INFO] - '
    )

    # Hashtable -> Context-String
    $context = if ($Additional.Count -gt 0) {
        ($Additional.GetEnumerator() | ForEach-Object { "$($_.Key): $($_.Value)" }) -join "`n"
    } else {
        ""
    }

    if (Get-Command $PreferredCommand -ErrorAction SilentlyContinue) {
        # LoggingModule-Variante
        & $PreferredCommand -Message $Message -Context $context
    }
    else {
        # Fallback: direkt auf Standard-Cmdlet (Information/Warning/Error) schreiben
        $finalMessage = if ($Prefix) { "$Prefix$Message" } else { $Message }

        & $FallbackCommand $finalMessage

        if ($Additional.Count -gt 0) {
            $Additional.GetEnumerator() | ForEach-Object {
                & $FallbackCommand "  | $($_.Key): $($_.Value)"
            }
        }
    }
}

function Write-SafeInfoLog {
    param(
        [string]$Message,
        [hashtable]$Additional = @{}
    )

    $params = @{
        Message          = $Message
        Additional       = $Additional
        PreferredCommand = 'Write-InfoLog'
        FallbackCommand  = 'Write-Information'
        Prefix           = '[INFO] - '
    }

    Write-SafeLogInternal @params
}

function Write-SafeWarningLog {
    param(
        [string]$Message,
        [hashtable]$Additional = @{}
    )

    $params = @{
        Message          = $Message
        Additional       = $Additional
        PreferredCommand = 'Write-WarningLog'
        FallbackCommand  = 'Write-Warning'
        # kein Prefix nötig
    }

    Write-SafeLogInternal @params
}

function Write-SafeErrorLog {
    param(
        [string]$Message,
        [hashtable]$Additional = @{}
    )

    $params = @{
        Message          = $Message
        Additional       = $Additional
        PreferredCommand = 'Write-ErrorLog'
        FallbackCommand  = 'Write-Error'
        # kein Prefix nötig
    }

    Write-SafeLogInternal @params
}


function Write-SafeDebugLog {
    param(
        [string]$Message,
        [hashtable]$Additional = @{}
    )

    $params = @{
        Message          = $Message
        Additional       = $Additional
        PreferredCommand = 'Write-DebugLog'
        FallbackCommand  = 'Write-Verbose'
        Prefix           = '[DEBUG] - '
    }

    Write-SafeLogInternal @params
}
