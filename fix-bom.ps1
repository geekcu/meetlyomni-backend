# PowerShell script to remove UTF-8 BOM from C# files

$files = @(
    "MeetlyOmni\MeetlyOmni.Api\Common\Enums\Event\EventStatus.cs",
    "MeetlyOmni\MeetlyOmni.Api\Common\Enums\EventContentBlock\BlockType.cs",
    "MeetlyOmni\MeetlyOmni.Api\Common\Enums\EventGameInstance\InstanceStatus.cs",
    "MeetlyOmni\MeetlyOmni.Api\Common\Enums\Game\GameType.cs",
    "MeetlyOmni\MeetlyOmni.Api\Common\Enums\Member\MemberStatus.cs",
    "MeetlyOmni\MeetlyOmni.Api\Common\Enums\MemberActivityLog\MemberEventType.cs",
    "MeetlyOmni\MeetlyOmni.Api\Common\Enums\Organization\PlanType.cs",
    "MeetlyOmni\MeetlyOmni.Api\Common\Enums\RaffleTicket\RaffleIssuedSource.cs",
    "MeetlyOmni\MeetlyOmni.Api\Common\Enums\RaffleTicket\RaffleTicketStatus.cs"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "Fixing $file"
        $content = Get-Content $file -Raw
        $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText((Resolve-Path $file).Path, $content, $utf8NoBomEncoding)
    }
}

Write-Host "BOM removal completed!" 