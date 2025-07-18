<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2024 v5.8.250
	 Created on:   	12/05/2025 12:00
	 Created by:   	mathieu.arth@econocom.com
	 Organization: 	Econocom
	 Filename:     	convert_pdf2txt
	===========================================================================
	.DESCRIPTION
		Monitor a folder for new PDF files and try to convert them into a txt file.
#>

# Warning: Do not rename Start-MyService, Invoke-MyService and Stop-MyService functions

function Start-MyService
{
	# Place one time startup code here.
	# Initialize global variables and open connections if needed
	$global:bRunService = $true
	$global:bServiceRunning = $false
	$global:bServicePaused = $false
	
	try
	{
		# Get the full path of the current script
		$scriptPath = $HostInvocation.MyCommand.Path
		
		# Get the directory of the current script
		$scriptDirectory = Split-Path -Path $scriptPath
		
		# Get the name of the script (without extension)
		$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($scriptPath)
		
		# Get the version of the script
		$scriptVersion = (Get-Item $scriptPath).VersionInfo.FileVersion
		
		# Define the path to the config file
		$global:configFilePath = Join-Path -Path $scriptDirectory -ChildPath "config.json"
		
		# Define the path to the dll file
		$global:dllFilePath = Join-Path -Path $scriptDirectory -ChildPath "itextsharp.dll"
		
		# Define the standard/default configuration
		$global:Config = Get-Config
		try
		{
			Save-Config $global:Config
			Write-Log -LogFile $global:Config.Log_File -Message "Config file   : Saving actual configuration. " -MessageType "Info"
		}
		catch
		{
			Write-Log -LogFile $global:Config.Log_File -Message "Config file   : Save error $($_.Exception.Message)" -MessageType "Error"
		}
		
		# Log service information
		Write-Log -LogFile $global:Config.Log_File -Message "Service       : $scriptName v$scriptVersion " -MessageType "Info"
		Write-Log -LogFile $global:config.Log_file -Message "Config        : $configFilePath."
		$hash = ((Get-FileHash -Path $scriptPath -Algorithm SHA256).Hash).tolower()
		Write-Log -LogFile $global:config.Log_file -Message "Hash          : $hash"
		
	}
	catch
	{
		Write-Log -LogFile $global:Config.Log_File -Message "An error occurred during service startup: $_" -MessageType "Error"
		throw
	}
	
	if (!(Test-Path -Path $dllFilePath -ErrorAction SilentlyContinue))
	{
		Write-Log -LogFile $global:Config.Log_File -Message "Service       : Missing DLL File" -MessageType "Error"
		throw "Missing DLL File"
	}
	Add-Type -Path $dllFilePath
	
	# check if folder_to_monitor exists
	if (-not (Test-Path -Path $global:config.Folder_to_monitor))
	{
		Write-Log -LogFile $global:config.Log_File -Message "Service       : The folder to monitor does not exist: $($global:config.Folder_to_monitor)" -MessageType Error
		throw "Folder to monitor does not exist."
	}
	
	# Monitor folder for new PDF files
	$global:watcher = New-Object System.IO.FileSystemWatcher
	$global:watcher.Path = $global:config.Folder_to_monitor
	$global:watcher.Filter = "*.pdf"
	$global:watcher.IncludeSubdirectories = $global:config.Recursive
	$global:watcher.EnableRaisingEvents = $true
	
	# Event handler for new files
	$global:onCreated = Register-ObjectEvent -InputObject $global:watcher -EventName Created -Action {
		$filePath = $Event.SourceEventArgs.FullPath
		$fileName = [System.IO.Path]::GetFileName($filePath)
		if (($global:config.Output_Folder -ne "") -and (Test-Path -Path $global:config.Output_Folder))
		{
			$outputPath = Join-Path -Path $global:config.Output_Folder -ChildPath ($fileName -replace '\.pdf$', '.txt')
		}
		else
		{
			$outputPath = ($filePath -replace '\.pdf$', '.txt')
		}
		try
		{
			# PDF to TXT conversion
			Convert-PDF2TXT -PDFPath $filepath >$outputPath
			Write-Log -LogFile $global:config.Log_File -Message "Convertion    : OK for $fileName  -->  $outputPath"
		}
		catch
		{
			Write-Log -LogFile $global:Config.Log_File -Message "Convertion   : Error processing new file $fileName - $_" -MessageType "Error"
			# Check if the output file exists and is zero bytes, then delete it
			if (Test-Path -Path $outputPath -PathType Leaf)
			{
				$fileSize = (Get-Item -Path $outputPath).Length
				if ($fileSize -eq 0)
				{
					Remove-Item -Path $outputPath -Force
					Write-Log -LogFile $global:config.Log_File -Message "Convertion : zero-byte file $outputPath deleted" -MessageType Warning
				}
			}
		}
	}
	Write-Log -LogFile $global:Config.Log_File -Message "Service       : Start " -MessageType "Info"
}

function Invoke-MyService
{
	$global:bServiceRunning = $true
	while ($global:bRunService)
	{
		try
		{
			if ($global:bServicePaused -eq $false) #Only act if service is not paused
			{
				#Place code for your service here
				#e.g. $ProcessList = Get-Process solitaire -ErrorAction SilentlyContinue
				
				# Use Write-Host or any other PowerShell output function to write to the System's application log
			}
		}
		catch
		{
			# Log exception in application log
			Write-Host $_.Exception.Message
		}
		# Adjust sleep timing to determine how often your service becomes active
		if ($global:bServicePaused -eq $true)
		{
			Start-Sleep -Seconds 20 # if the service is paused we sleep longer between checks
		}
		else
		{
			Start-Sleep -Seconds 2 # a lower number will make your service active more often and use more CPU cycles
		}
	}
	$global:bServiceRunning = $false
}

function Stop-MyService
{
	$global:bRunService = $false # Signal main loop to exit
	$CountDown = 30 # Maximum wait for loop to exit
	
	Write-Log -LogFile $global:Config.Log_File -Message "Service       : Stopping " -MessageType "Info"
	# Stop folder monitoring
	$global:watcher.EnableRaisingEvents = $false
	
	# Cleanup
	if ($global:onCreated -and $global:onCreated.Name)
	{
		try
		{
			Unregister-Event -SourceIdentifier $global:onCreated.Name
			Remove-Job -Name $global:onCreated.Name -Force
			Write-Log -LogFile $global:Config.Log_File -Message "Service       : Event removed " -MessageType "Info"
		}
		catch
		{
			Write-Log -LogFile $global:config.Log_File -Message "Service       : Failed to unregister event $_" -MessageType Error
		}
	}
	if ($global:watcher)
	{
		try
		{
			$global:watcher.Dispose()
			Write-Log -LogFile $global:Config.Log_File -Message "Service       : Watcher removed " -MessageType "Info"
		}
		catch { Write-Log -LogFile $global:config.Log_File -Message "Service       : Error during Watcher cleanup $_" -MessageType Error }
	}
	
	Write-Log -LogFile $global:Config.Log_File -Message "Service       : Stop " -MessageType "Info"
	
	while ($global:bServiceRunning -and $Countdown -gt 0)
	{
		Start-Sleep -Seconds 1 # wait for your main loop to exit
		$Countdown--
	}
}

function Pause-MyService
{
	# Service is being paused
	# Save state 
	$global:bServicePaused = $true
	# Note that the thread your PowerShell script is running on is not suspended on 'pause'.
	# It is your responsibility in the service loop to pause processing until a 'continue' command is issued.
	# It is recommended to sleep for longer periods between loop iterations when the service is paused.
	# in order to prevent excessive CPU usage by simply waiting and looping.
	
	Write-Log -LogFile $global:Config.Log_File -Message "Service       : Pause " -MessageType "Info"
	
	# Stop folder monitoring
	$global:watcher.EnableRaisingEvents = $false
}

function Continue-MyService
{
	# Service is being continued from a paused state
	# Restore any saved states if needed
	$global:bServicePaused = $false
	
	Write-Log -LogFile $global:Config.Log_File -Message "Service       : Restart " -MessageType "Info"
	
	# Restart folder monitoring
	$global:watcher.EnableRaisingEvents = $true
}

# Function to convert the pdf to txt
function Convert-PDF2TXT
{
	param
	(
		[Parameter(Mandatory = $true,
				   HelpMessage = 'Enter full path to the PDF file.')]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$PDFPath
	)
	
	if (Test-Path -Path $PDFPath -ErrorAction SilentlyContinue)
	{
		$extension = [System.IO.Path]::GetExtension($PDFPath)
		if ($extension -notmatch ".pdf")
		{
			Write-Log -LogFile $global:Config.Log_File -Message "Convertion   : Selected file is not a PDF file or have an wrong extension ! " -MessageType "Error"
		}
		else
		{
			$pdf = New-Object iTextSharp.text.pdf.pdfreader -ArgumentList $PDFPath
			for ($page = 1; $page -le $pdf.NumberOfPages; $page++)
			{
				$text = [iTextSharp.text.pdf.parser.PdfTextExtractor]::GetTextFromPage($pdf, $page)
				Write-Output $text
			}
			$pdf.Close()
		}
	}
	else
	{
		Write-Log -LogFile $global:Config.Log_File -Message "Convertion    : Selected file $PDFPath does not exist, check the path and try again !" -MessageType "Error"
	}
}

# Function to write to a log file
function Write-Log
{
	param (
		[Parameter(Mandatory = $true)]
		[string]$Message,
		[Parameter(Mandatory = $false)]
		[ValidateSet("Info", "Warning", "Error", "Debug")]
		[string]$MessageType = "Info",
		[Parameter(Mandatory = $false)]
		[string]$LogFile = "$scriptDirectory\$scriptName.log"
	)
	
	# Ensure the log directory exists
	$logDirectory = [System.IO.Path]::GetDirectoryName($LogFile)
	if (!(Test-Path -Path $logDirectory))
	{
		New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
	}
	
	# Format the log entry with a timestamp and message type
	$timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
	$logEntry = "[$timestamp] [$MessageType] $Message"
	
	# Append the log entry to the log file
	Add-Content -Path $LogFile -Value $logEntry
}

# Function to get the default or saved configuration
function Get-Config
{
	# Define the standard/default configuration
	$defaultConfig = @{
		Folder_to_monitor = $scriptDirectory
		Output_Folder	  = ""
		Log_File		  = Join-Path -Path $scriptDirectory -ChildPath "$scriptName.log"
		Recursive		  = $true
	}
	
	# Initialize final config with defaults
	$finalConfig = $defaultConfig.Clone()
	
	# Check if the config file exists
	if (Test-Path -Path $global:configFilePath)
	{
		Write-Log -LogFile $defaultConfig.Log_File -Message "Config file   : Found config file, loading " -MessageType "Info"
		try
		{
			# Load the configuration from the file
			$userConfig = Get-Content -Path $global:configFilePath | ConvertFrom-Json
			
			# Merge user config into defaults
			foreach ($key in $userConfig.PSObject.Properties.Name)
			{
				$finalConfig[$key] = $userConfig.$key
			}
		}
		catch
		{
			Write-Log -LogFile $defaultConfig.Log_File -Message "Config file  : Error reading configuration file: $($_.Exception.Message)" -MessageType "Error"
		}
	}
	else
	{
		Write-Log -LogFile $defaultConfig.Log_File -Message "Config file: Configuration file not found. Using default configuration." -MessageType "Warning"
	}
	
	# Return the final configuration
	Save-Config -Config $finalConfig
	return $finalConfig
}

# Function to save configuration
function Save-Config
{
	param (
		[Parameter(Mandatory = $true)]
		[PSCustomObject]$Config
	)
	# Ensure the config directory exists
	$configDirectory = [System.IO.Path]::GetDirectoryName($global:configFilePath)
	if (!(Test-Path -Path $configDirectory))
	{
		New-Item -ItemType Directory -Path $configDirectory -Force | Out-Null
	}
	$Config | ConvertTo-Json -Depth 10 | Set-Content -Path $global:configFilePath
}
