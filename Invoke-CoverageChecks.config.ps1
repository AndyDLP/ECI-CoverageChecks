#region config
<#
Define a filter for the outputted data
Make sure that for multiple filters, you have a comma between filter definitions

This does not apply for AD info / Domain controller info / SYSVOL backlog info (yet)

Possible values for filters:
 - Category        = Whatever the heading is before the table in the outputted report, can change with additional data
 - Type            = Property - For defining thresholds on a property e.g. The example below can be changed to only show Disks with the property 'PercentFree' of less than 30 (%) by change the value to 30
                   = Display  - For defining what properties show and how to sort the output table. Some filters are already in place with this option
                   = Hidden   - Set to this option to fully hide the category (even if there are potential issues within it)
 - Property        = [Only available for a filter types: Property] - Specify the property name / column header to filter on
 - Comparison      = [Only available for a filter types: Property] - Specify the comparison i.e. greater than or less than.
                     See PowerShell comparison operators: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_operators?view=powershell-6
 - Value           = [Only available for a filter types: Property] - Specify the value to filter against

 - Action          = [Only available for a filter type of Display] - Specify whether to Include or Exclude properties
 - Properties      = [Only available for a filter type of Display] - Specify which properties (As a comma separated list of strings) to show / hide. Enter a star "*" for all properties. Is passed verbatim to Select-Object so hashtables work for renaming column headers
 - SortingProperty = [Only available for a filter type of Display] - Specify a property to sort the resulting table on
 - SortingType     = [Only available for a filter type of Display] - Specify the sorting type to use; either Ascending or Descending

#>

$DefaultFilters = @(
    @{
        Category = 'Disks'
        Type = 'Property'
        Property = 'PercentFree'
        Comparison = '-lt'
        Value = 100 # only show disks at 100% of less free space (example)
    },
    @{
        Category = 'VMSnapshots'
        Type = 'Display'
        Action = 'Include'
        Properties = @('VIServer','Name','ParentSnapshot','Description','Created','PowerState','VM','SizeGB','IsCurrent','IsReplaySupported')
        SortingProperty = 'VIServer'
        SortingType = 'Ascending'
    },
    @{
        Category = 'LastEvents'
        Type = 'Display'
        Action = 'Include'
        Properties = @('VIServer','IpAddress','UserAgent','CreatedTime','UserName','LoginTime','ChainId','FullFormattedMessage','To','NewStatus')
        SortingProperty = 'VIServer'
        SortingType = 'Ascending'
    },
    @{
        Category = 'VMs'
        Type = 'Display'
        Action = 'Include'
        Properties = @('VIServer','Name','PowerState','NumCpu','CoresPerSocket','MemoryGB','ProvisionedSpaceGB','UsedSpaceGB','Notes','Folder','Version')
        SortingProperty = 'VIServer'
        SortingType = 'Ascending'
    },
    @{
        Category = 'Datastores'
        Type = 'Display'
        Action = 'Include'
        Properties = @('VIServer','Name','Datacenter','CapacityGB','FreeSpaceGB','Accessible','Type','State','FileSystemVersion')
        SortingProperty = 'VIServer'
        SortingType = 'Ascending'
    },
    @{
        Category = 'DFSRBacklogs'
        Type = 'Display'
        Action = 'Include'
        Properties = @('ComputerName','ReplicationGroupname','SendingMember','ReceivingMember','BacklogFileCount')
        SortingProperty = 'ComputerName'
        SortingType = 'Ascending'
    },
    @{
        Category = 'Disks'
        Type = 'Display'
        Action = 'Include'
        Properties = @('ComputerName','Volume','TotalSize','FreeSpace','PercentFree')
        SortingProperty = 'PercentFree'
        SortingType = 'Ascending'
    },
    @{
        Category = 'Unresponsive Domain Controllers'
        Type = 'Display'
        Action = 'Include'
        Properties = @('ComputerName','ServerResponding','ServerWSManrunning')
        SortingProperty = 'ComputerName'
        SortingType = 'Ascending'
    },
    @{
        Category = 'Unresponsive servers'
        Type = 'Display'
        Action = 'Include'
        Properties = @('ComputerName','Error','ServerResponding','ServerWSManrunning','Ignored')
        SortingProperty = 'ComputerName'
        SortingType = 'Ascending'
    },
    @{
        Category = 'ExpiredSoonCertificates'
        Type = 'Display'
        Action = 'Include'
        Properties = @('ComputerName','Subject','Issuer','NotBefore','NotAfter','Thumbprint','HasPrivateKey')
        SortingProperty = 'ComputerName'
        SortingType = 'Ascending'
    },
    @{
        Category = 'GeneralInformation'
        Type = 'Display'
        Action = 'Include'
        Properties = @('ComputerName','OperatingSystem','IsVirtual','IsServerCore','SMB1Enabled','InstallDate','LastBootUpTime','CPUs','MemoryGB')
        SortingProperty = 'ComputerName'
        SortingType = 'Ascending'
    },
    @{
        Category = 'LocalAdministrators'
        Type = 'Display'
        Action = 'Include'
        Properties = @('ComputerName','Group','Members')
        SortingProperty = 'ComputerName'
        SortingType = 'Ascending'
    },
    @{
        Category = 'NonStandardScheduledTasks'
        Type = 'Display'
        Action = 'Include'
        Properties = @(@{n='ComputerName';e={$_.HostName}},'TaskName','Status','Next Run Time','Last Run Time','Last Result','Author','Run As User','Schedule Type')
        SortingProperty = @('ComputerName','Last Run Time')
        SortingType = 'Ascending'
    },
    @{
        Category = 'NonStandardServices'
        Type = 'Display'
        Action = 'Include'
        Properties = @( @{n='ComputerName';e={$_.SystemName}},'Name','DisplayName','State','StartMode','StartName','PathName')
        SortingProperty = 'ComputerName'
        SortingType = 'Ascending'
    },
    @{
        Category = 'PendingReboot'
        Type = 'Display'
        Action = 'Include'
        Properties = @( @{n='ComputerName';e={$_.Computer}},'CBServicing','WindowsUpdate','PendComputerRename','RebootPending','CCMClientSDK' )
        SortingProperty = 'ComputerName'
        SortingType = 'Ascending'
    },
    @{
        Category = 'SharedPrinters'
        Type = 'Display'
        Action = 'Include'
        Properties = @('ComputerName','Printername','IsPingable','PublishedToAD','PrinterAddress','PrinterDriver')
        SortingProperty = 'ComputerName','PrinterName'
        SortingType = 'Ascending'
    },
    @{
        Category = 'UpdateInfo'
        Type = 'Display'
        Action = 'Include'
        Properties = @('ComputerName','UpToDate','LastSearch','LastInstall')
        SortingProperty = 'ComputerName'
        SortingType = 'Ascending'
    }
)

<#
Define conditional formatting for the outputted data
Make sure that for multiple conditions, you have a comma between condition definitions

This does not apply for AD info / Domain controller info / SYSVOL backlog info (yet)

Possible values for conditions:
 - Category        = Whatever the heading is before the table in the outputted report
 - Property        = Specify the property name / column header to format on
 - Comparison      = Specify the comparison i.e. greater than or less than.
                     See PowerShell comparison operators: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_operators?view=powershell-6
 - Value           = Specify the value to filter against

#>
$ConditionalFormatting = @(
    @{
        Category = 'DCDiag Results'
        Property = 'FailedTests'
        Comparison = '-ne'
        Value = $null
    },
    @{
        Category = 'Domain Controllers'
        Property = 'NTDSService'
        Comparison = '-eq'
        Value = 'Stopped'
    },
    @{
        Category = 'Domain Controllers'
        Property = 'NetlogonService'
        Comparison = '-eq'
        Value = 'Stopped'
    },
    @{
        Category = 'Domain Controllers'
        Property = 'DNSService'
        Comparison = '-eq'
        Value = 'Stopped'
    },
    @{
        Category = 'Domain Controllers'
        Property = 'NetlogonAccessible'
        Comparison = '-eq'
        Value = $false
    },
    @{
        Category = 'Domain Controllers'
        Property = 'SYSVOLAccessible'
        Comparison = '-eq'
        Value = $false
    },
    @{
        Category = 'SYSVOL Backlog'
        Property = 'BacklogFileCount'
        Comparison = '-ne'
        Value = 0
    },
    @{
        Category = 'Disks'
        Property = 'PercentFree'
        Comparison = '-lt'
        Value = 50
    },
    @{
        Category = 'NonStandardScheduledTasks'
        Property = 'Run As User'
        Comparison = '-match'
        Value = 'administrator'
    },
    @{
        Category = 'NonStandardServices'
        Property = 'State'
        Comparison = '-eq'
        Value = "Stopped"
    },
    @{
        Category = 'NonStandardServices'
        Property = 'StartName'
        Comparison = '-match'
        Value = 'administrator'
    },
    @{
        Category = 'PendingReboot'
        Property = 'RebootPending'
        Comparison = '-eq'
        Value = $true
    },
    @{
        Category = 'ExpiredSoonCertificates'
        Property = 'NotBefore'
        Comparison = '-gt'
        Value = (Get-Date)
    },
    @{
        Category = 'ExpiredSoonCertificates'
        Property = 'NotAfter'
        Comparison = '-lt'
        Value = (Get-Date)
    },
    @{
        Category = 'UpdateInfo'
        Property = 'UpToDate'
        Comparison = '-eq'
        Value = $false
    },
    @{
        Category = 'SharedPrinters'
        Property = 'IsPingable'
        Comparison = '-eq'
        Value = $false
    }
)

# Specify a list of VCenter servers or ESXI hosts to gather information from
# It is assumed that AD authentication has been enabled for the user running this script
# TODO: Add option to specify different credentials (Save to CLIXML?)
$VCentersAndESXIHosts = @(
)

# A comma separated list of servers names (strings) that will not be target for information gathering
$IgnoredServers = @(
)

# Create and convert to PDF instead of HTML
$ConvertToPDF = $true

# Change to $true to enable reporting sending via email
$SendEmail = $false

# Only define the below if email is enabled
if ($SendEmail -eq $true) {
    # A comma separated list of recipients for the email
    $TargetEmail = @(
    "recipient1@example.com"
    )

    # The SMTP relay that will allow the email
    $MailServer = "mail.example.com"
    
    # Port used for the SMTP relay
    $MailPort = 25
    
    # The from address for the report email
    $FromEmail = "ServerChecks@example.com"
    
    # The subject for the report email 
    $MailSubject = "Coverage Checks - $(Get-Date)"
}

# Report CSS

$CSSHeaders = @"
<style type="text/css">
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
  	margin: auto;
	max-width: 85%;
}

 
table {
	border-collapse: collapse;
	border: 1px black solid;
	font: 10pt Verdana, Geneva, Arial, Helvetica, sans-serif;
	color: black;
	margin-bottom: 10px;
	box-shadow: 10px 10px 5px #888;
}
 
table td {
	color: #000;
	font-size: 12px;
	padding-left: 0px;
	padding-right: 20px;
	text-align: left;
}
 
table th {
	color: #fff;
	background: #276dab;
	font-size: 12px;
	font-weight: bold;
	padding-left: 0px;
	padding-right: 20px;
	text-align: left;
}


h1 {
	text-align: center;
	clear: both; font-size: 130%;
	color:#354B5E;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
}

h2 {
	clear: both; font-size: 115%;
	color:#354B5E;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
}

h3 {
	clear: both;
	font-size: 100%;
	margin-left: 20px;
	margin-top: 30px;
	color:#475F77;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
}

h4 {
	clear: both;
	font-size: 75%;
	margin-left: 20px;
	margin-top: 30px;
	color:#475F77;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
}

p {
	margin-left: 20px;
	font-size: 12px;
}

.alert {
	color: red;
	font-weight: bold;
	}
 
table.list{ float: left; }
 
table.list td:nth-child(1) {
	font-weight: bold;
	border-right: 1px grey solid;
	text-align: right;
}
 
table.list td:nth-child(2) { padding-left: 7px; }
table tr:nth-child(even) td:nth-child(even) { background: #ececec; }
table tr:nth-child(odd) td:nth-child(odd) { background: #c8c8c8; }
table tr:nth-child(even) td:nth-child(odd) { background: #ececec; }
table tr:nth-child(odd) td:nth-child(even) { background: #c8c8c8; }
div.column { width: 320px; float: left; }
div.first{ padding-right: 20px; border-right: 3px grey solid; }
div.second{ margin-left: 30px; }
table{ margin-left: 20px; }

</style>
"@

#endregion