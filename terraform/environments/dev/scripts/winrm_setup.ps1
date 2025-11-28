<powershell>
    Enable-PSRemoting -Force

    $firewallParams = @{
        Action      = 'Allow'
        Description = 'Inbound rule for Windows Remote Management via WS-Management. [TCP 5985]'
        Direction   = 'Inbound'
        DisplayName = 'Windows Remote Management (HTTP-In)'
        LocalPort   = 5985
        Profile     = 'Any'
        Protocol    = 'TCP'
    }

    New-NetFirewallRule @firewallParams

    winrm set winrm/config/service/auth '@{Basic="true"}'
    winrm set winrm/config/service '@{AllowUnencrypted="true"}'
</powershell>
