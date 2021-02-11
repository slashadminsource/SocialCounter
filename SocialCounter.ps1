
Import-Module Microsoft.PowerShell.IoT

#VARIABLES -----------------------------------------------
[string]$bannerText = ""
[string]$text = ""
[string]$subText = ""
[string]$displayText = ""
[int]$cmdDelay = 20
#[int]$scrollDelay = 1500
[int]$facebookCollectInterval = 15 #minutes
[DateTime]$global:facebookLastCollection= (Get-Date).AddMinutes(-20)

[string]$displayMode = "SCROLL"#"FLASH"
[int]$modeDelay = 550#150
[string]$fbPageURL = "https://www.facebook.com/DarkScrolls.co.uk" #"https://www.facebook.com/SlashAdminLifeInIT"
        
$settings = New-Object Settings("$PSScriptRoot\settings.cfg")

[Button]$backButton 	= New-Object Button(25)
[Button]$upButton 		= New-Object Button(24)
[Button]$downButton 	= New-Object Button(23)
[Button]$selectButton 	= New-Object Button(28)
[Button]$resetButton 	= New-Object Button(27)

$hashTable = New-Object system.collections.hashtable
$hashTable.add('a',0x77)
$hashTable.add('b',0x7F)
$hashTable.add('c',0x4E)
$hashTable.add('d',0x7E)
$hashTable.add('e',0x4F)
$hashTable.add('f',0x47)
$hashTable.add('g',0x5E)
$hashTable.add('h',0x37)
$hashTable.add('i',0x06)
$hashTable.add('j',0x3C)
$hashTable.add('k',0x37)
$hashTable.add('l',0x0E)
$hashTable.add('m',0x54)
$hashTable.add('n',0x76)
$hashTable.add('o',0x7E)
$hashTable.add('p',0x67)
$hashTable.add('q',0x73)
$hashTable.add('r',0x66)
$hashTable.add('s',0x5B)
$hashTable.add('t',0x0F)
$hashTable.add('u',0x3E)
$hashTable.add('v',0x3E)
$hashTable.add('w',0x2A)
$hashTable.add('x',0x37)
$hashTable.add('y',0x3B)
$hashTable.add('z',0x6D)

$hashTable.add('A',0xF7)
$hashTable.add('B',0xFF)
$hashTable.add('C',0xCE)
$hashTable.add('D',0xFE)
$hashTable.add('E',0xCF)
$hashTable.add('F',0xC7)
$hashTable.add('G',0xDE)
$hashTable.add('H',0xB7)
$hashTable.add('I',0x86)
$hashTable.add('J',0xBC)
$hashTable.add('K',0xB7) 
$hashTable.add('L',0x8E)
$hashTable.add('M',0xD4)
$hashTable.add('N',0xF6) 
$hashTable.add('O',0xFE)
$hashTable.add('P',0xE7)
$hashTable.add('Q',0xF3)
$hashTable.add('R',0xE6) 
$hashTable.add('S',0xDB)
$hashTable.add('T',0x8F)
$hashTable.add('U',0xBE)
$hashTable.add('V',0xBE)
$hashTable.add('W',0xAA)
$hashTable.add('X',0xB7)
$hashTable.add('Y',0xBB)
$hashTable.add('Z',0xED)

$hashTable.add('0',0x7E)
$hashTable.add('1',0x30)
$hashTable.add('2',0x6D)
$hashTable.add('3',0x79)
$hashTable.add('4',0x33)
$hashTable.add('5',0x5B)
$hashTable.add('6',0x5F)
$hashTable.add('7',0x70)
$hashTable.add('8',0x7F)
$hashTable.add('9',0x7B)

$hashTable.add('.',0x80)
$hashTable.add('!',0xA0)
$hashTable.add('-',0x01)
$hashTable.add('+',0x07)
$hashTable.add('"',0x22)
$hashTable.add('=',0x41)
$hashTable.add('_',0x08)
$hashTable.add('|',0x06)
$hashTable.add('\',0x03)
$hashTable.add('/',0x21)
$hashTable.add('[',0x4E)
$hashTable.add(']',0x78)
$hashTable.add('(',0x4F)
$hashTable.add(')',0x78)
$hashTable.add('<',0x43)
$hashTable.add('>',0x61)
$hashTable.add('?',0x65)
$hashTable.add("'",0x02)
$hashTable.add(' ',0x00)
$hashTable.add(':',0x60)

#---------------------------------------------------------


#FUNCTIONS --------------------------------------------------------------------------------------------------
function Initialise-Display()
{
	#SHUTDOWN 
	Write-Host "Issue Shutdown"
	$data = @(0x0C,0x00)
	$rtnv = Send-SPIData -Data $data -Channel 0 -raw 
	Start-Sleep -Milliseconds $cmdDelay
	 
	#SET DECODE (PRE DEFINED VALUES OR SEGMENT CONTROL)
	Write-Host "Set Decode Mode To no decode for all digits"
	$data = @(0x09,0x00)
	$rtnv = Send-SPIData -Data $data -Channel 0 -raw 
	Start-Sleep -Milliseconds $cmdDelay

	#INTENSITY
	Write-Host "Set Brightness To Max"
	$data = @(0x0A,0x0F)
	$rtnv = Send-SPIData -Data $data -Channel 0 -raw  
	Start-Sleep -Milliseconds $cmdDelay
	
	#SET SCAN MODE (HOW MANY DIGITS TO USE) 
	Write-Host "Set Scan Mode To All Digits"
	$data = @(0x0B,0x07)
	$rtnv = Send-SPIData -Data $data -Channel 0 -raw 
	Start-Sleep -Milliseconds $cmdDelay
	
	#Set display test to normal OPERATION 0x01 = test 0x00 = normal
	Write-Host "Test Mode Off"
	$data = @(0x0F,0x00)
	$rtnv = Send-SPIData -Data $data -Channel 0 -raw 
	Start-Sleep -Milliseconds $cmdDelay
	
	#Shutdown - resume NORMAL OPERATION
	Write-Host "Switching Shutdown Mode To Normal"
	$data = @(0x0C,0x01)
	$rtnv = Send-SPIData -Data $data -Channel 0 -raw 
	Start-Sleep -Milliseconds $cmdDelay   

	#SETTING ALL SEGEMENTS TO BLANK (in case old data is still stored in device)
	Write-Host "Resetting All Segments"
	For($i=1; $i -le 8 ; $i++)
	{
		$rtnv = Send-SPIData -Data $i,0x00 -Channel 0 -raw
		Start-Sleep -Milliseconds $cmdDelay
	}  
}
#------------------------------------------------------------------------------------------------------------

#MAIN CODE START-----------

Clear-Host
Initialise-Display


function Get-FacebookFollowers()
{
    $facebookFollowers = -1
    $facebookJob = $null
    
    if([bool](Get-Job -Name GetFacebookFollowers -ea silentlycontinue) -eq $false)
    {
        #Create a new job and start it
        $script = 
        {
            param ($fbPage, $delayInterval)

			try
			{         
				#Write-Host "Invoking web request:" $fbPage

				#$ProgressPreference = 'SilentlyContinue'
				#$web = Invoke-WebRequest -Uri $fbPage

				#linux specific alternative to invoke-webrequest because its so slow
				curl -s $fbPage --output $PSScriptRoot/fb.txt
				$web = Get-Content "$PSScriptRoot/fb.txt" -Raw 

				$initData = [regex]::matches($web, "\b\d[\d,.]*\b people follow this")
				#$initData = [regex]::matches($web.content, "\b\d[\d,.]*\b people follow this")
				$initData = $initData.Value
				$numFollowers = $initData.Split(" ")[0]
				
				#Start-Sleep -Seconds $delayInterval

				return $numFollowers
			}
			catch
			{
				$ErrorMessage = $_.Exception.Message
				Add-Content -Path "error.log" $ErrorMessage
			}
        }

		$elapsedTime = $(Get-Date) - $global:facebookLastCollection
		if($elapsedTime.TotalMinutes -gt $facebookCollectInterval)
		{

			Write-Host "starting new fb get followers job for: [$fbPageURL]"
			Write-Host "collection interval:" $facebookCollectInterval
			Write-Host "elapsed Time:" $elapsedTime.TotalMinutes

			$global:facebookLastCollection = $(Get-Date)
			$facebookJob = Start-Job -Name GetFacebookFollowers -ScriptBlock $script -ArgumentList $fbPageURL, $facebookCollectInterval
			Start-Sleep -seconds 10
		}
	}
	else
	{
		$facebookJob = Get-Job -Name GetFacebookFollowers
	        
		if($facebookJob.State -eq "Completed")
		{
			$facebookJob = Get-Job -Name GetFacebookFollowers
			$facebookFollowers = Receive-Job -Job $facebookJob -Keep
		
			Write-Host "Job Completed Retrieved Followers:" $facebookFollowers

			Remove-Job -Name GetFacebookFollowers -Force
		}
		elseif($facebookJob.State -eq "Failed")
		{
			Remove-Job -Name GetFacebookFollowers -Force
		}

		if($facebookFollowers -eq $null)
		{
			$facebookFollowers = -1
		}
	}

	#write-host "final exit point - followers:" $facebookFollowers
	return $facebookFollowers
}

function Send-Hardware($text)
{
	#$text = $text.ToUpper()

	[int]$displaySegment = 8

	if($text.Length -gt 8)
	{
		$text = $text.Substring(0,8)
	}

	if($text.Length -lt 8)
	{
		$text = $text.PadRight(8," ")
	}

	for($characterIndex = 0;$characterIndex -lt $text.Length;$characterIndex++)
	{
		$letter = $text[$characterIndex]
		$rtnv = Send-SPIData -Data $displaySegment,$hashTable[$letter.ToString()] -Channel 0 -raw
		$displaySegment--
	}
}

function Display-FacebookFollowers([int]$numberFollowers)
{
    $displayJob = $null
    
    if([bool](Get-Job -Name DisplayFacebookFollowers -ea silentlycontinue) -eq $false)
    {
        #Create a new job and start it
        $script = 
		{
			param ($displayText,$followers,$mode,$delay,$ht)
					
			Import-Module Microsoft.PowerShell.IoT

			function Send-Hardware($text)
			{
				[int]$displaySegment = 8

				if($text.Length -gt 8)
				{
					$text = $text.Substring(0,8)
				}

				if($text.Length -lt 8)
				{
					$text = $text.PadRight(8," ")
				}

				for($characterIndex = 0;$characterIndex -lt $text.Length;$characterIndex++)
				{
					$letter = $text[$characterIndex]
					$rtnv = Send-SPIData -Data $displaySegment,$ht[$letter.ToString()] -Channel 0 -raw
					$displaySegment--
				}
			}

			
			$displayText,$followers
			$displayText = $displayText.Replace("%followers%", $followers)
			$displayText = $displayText.ToUpper()


			if($mode -eq "FLASH")
			{
				$words = $displayText.Split(" ")
				
				foreach($word in $words)
				{
					Send-Hardware $word
					Start-Sleep -Milliseconds $delay
				}
			}
			elseif($mode -eq "SCROLL")
			{

				$text = "        " + $displayText 
				$subText = $text
				$dText = "        "

				for($i=0;$i -le $text.Length;$i++)
				{
					if($subText.Length -ge 8)
					{
						$dText = $subText.Substring(0, 8)
					}
					else
					{
						$dText = "        "
						$dText = $dText.Remove(0,($subText.length)).Insert(0,$subText)
					}

					if($subText.Length -gt 0)
					{
						$subText = $subText.Substring(1,$subText.Length-1)
					}

					Send-Hardware $dText

					Start-Sleep -Milliseconds $delay
				}
			}

			#Send-Hardware ""
		}

		Write-Host "starting new display followers job"
        $displayJob = Start-Job -Name DisplayFacebookFollowers -ScriptBlock $script -ArgumentList $bannerText,$numberFollowers,$displayMode,$modeDelay,$hashTable
    }
    else
    {
        $displayJob = Get-Job -Name DisplayFacebookFollowers
    }
    
    if($displayJob.State -eq "Completed")
    {
        Remove-Job -Name DisplayFacebookFollowers
    }
}

Class Button
{
    [int]$pin = 0
    [int]$bounceDelay = 150
    [DateTime]$triggerTime

    Button([int]$wiringPiPin)
    {
        $this.pin = $wiringPiPin
        $this.triggerTime = Get-Date
    }

    [bool]Pushed()
    {
        $status = (Get-GpioPin $this.pin).Value
        
        if($status -eq "High")
        {
            $timeLapsed = New-TimeSpan -Start $this.triggerTime -End (Get-Date)
                       
            if($timeLapsed.Milliseconds -ge $this.bounceDelay)
            {
                $this.triggerTime = Get-Date
                return $true
            }
        }

        return $false
    }
}

function Stop-Jobs()
{
	Write-Host "Stopping Jobs"
	#Suspend-Job -Name GetFacebookFollowers
	#Suspend-Job -Name DisplayFacebookFollowers

	Stop-Job -Name GetFacebookFollowers
	Stop-Job -Name DisplayFacebookFollowers

	Clear-Jobs
}

function Resume-Jobs()
{
	#Write-Host "Suspending Jobs"
	#Get-Job -Name GetFacebookFollowers | Resume-Job
	#Get-Job -Name DisplayFacebookFollowers | Resume-Job
}

function Get-HashKeyIndex([char]$c)
{
	$sHT = $hashTable.GetEnumerator() | Sort-Object -Property name
    $index = 0
	#$c = $c.ToUpper()

    foreach($v in $sHT)
    {
		#write-host "$c $($v.key)"
        if($c -eq $v.key)
        {
            return $index
        }
        
        $index++
    }

	return $null
}

function Get-HashKey($i)
{
	$sHT = $hashTable.GetEnumerator() | Sort-Object -Property name
    $index = 0

    foreach($v in $sHT)
    {
        if($index -eq $i)
        {
            return $v.Key
        }
        
        $index++
    }

	return $null
}

function Get-HardwareInput2($pText)
{
	$hashIndex = 30
	$stringIndex = 0
	$text = $pText

	#$text = "12345678"
	#write-host "length: $($text.length)"
	#if($text.Length -gt 8)
	#{
    #	write-host "**"
	#	$stringIndex = $text.Length-1
	#}

	$stringIndex = $text.Length-1

	#Send-Hardware Get-HashKey $hashIndex
	write-host "Get Input Start"
	Send-Hardware $text
	
	if($text.length -gt 0)
	{
		$char = $text[$stringIndex]
		$hashIndex = Get-HashKeyIndex($char)
	}

	while($true)
	{
		if($backButton.Pushed())
		{
			write-host "Get Input End"
			return $text
		}	
		elseif($upButton.Pushed())
		{
			if($hashIndex -gt 0)
			{
				$hashIndex--

				$char = Get-HashKey $hashIndex
				$text = $text.Remove($stringIndex,1).Insert($stringIndex,$char)
			}
		}
		elseif($downButton.Pushed())
		{
			if($hashIndex -lt ($hashTable.Count -1))
			{
				$hashIndex++

				$char = Get-HashKey $hashIndex
				$text = $text.Remove($stringIndex,1).Insert($stringIndex,$char)
			}
		}
		elseif($selectButton.Pushed())
		{
			$stringIndex++

			if($stringIndex -ge $text.Length)
			{
				$hashIndex = 30
				$text = $text + "A"
			}

			$char = $text[$stringIndex]
			$hashIndex = Get-HashKeyIndex($char)

			$char = Get-HashKey $hashIndex
			$text = $text.Remove($stringIndex,1).Insert($stringIndex,$char)
		}
		elseif($resetButton.Pushed())
		{
			if($stringIndex -gt 0)
			{
				$stringIndex--
				$text = $text.Remove($text.Length-1)
			}
		}
	
		#if text gt 8 only display the last 8
		if($text.Length -gt 8)
		{
			Send-Hardware $text.Substring($text.length-8)
		}
		else
		{
			Send-Hardware $text
		}
	}

	write-host "Get Input End"
	return $text
}

function Select-FromList([string]$menuName, [array]$menu)
{
	$menuIndex = 0
	$selection = ""

	Write-Host "Entering List"
	Send-Hardware $menuName
	
	while($true)
	{
		if($backButton.Pushed())
		{
			break
		}	
		elseif($upButton.Pushed())
		{
			if($menuIndex -gt 0)
			{
				$menuIndex--
			}

			Send-Hardware $menu[$menuIndex]
		}
		elseif($downButton.Pushed())
		{
			if($menuIndex -lt ($menu.length -1))
			{
				$menuIndex++
			}

			Send-Hardware $menu[$menuIndex]
		}
		elseif($selectButton.Pushed())
		{
			$selection = $menu[$menuIndex]
			break
		}
		
	}

	Write-Host "Exiting List"
	return $selection
}

function Test-WiFiNetwork
{
	$results = Test-Connection google.com
	if($results[0].Status -eq "Success")
	{
		#Connected
		Write-Host "Connected"
		return $true
	}
	else
	{
		#Not connected
		Write-Host "Failed"
		return $false
	}
}

function Enter-Menu()
{
	$menu = @("Set WiFi","Set Page")
	$menuIndex = 0

	Write-Host "Entering Menu"
	Send-Hardware "SETTINGS"
	
	while($true)
	{
		if($backButton.Pushed())
		{
			break
		}	
		elseif($upButton.Pushed())
		{
			if($menuIndex -gt 0)
			{
				$menuIndex--
			}

			Send-Hardware $menu[$menuIndex]
		}
		elseif($downButton.Pushed())
		{
			if($menuIndex -lt ($menu.length -1))
			{
				$menuIndex++
			}

			Send-Hardware $menu[$menuIndex]
		}
		elseif($selectButton.Pushed())
		{
			if($menu[$menuIndex] -eq "Set WiFi")
			{
				#Send-Hardware "opt 1"
				$wifiNetworks = Get-WiFiNetworks

				$selection = Select-FromList "WiFi" $wifiNetworks
				if($selection -ne "")
				{
					$wifiPwd = Get-HardwareInput2 " "
					$settings.wifiSSID = $selection
					$settings.wifipwd = $wifiPwd
					$settings.SaveConfig()
					write-host "selected wifi:$selection"
					write-host "wifi pwd:$wifiPwd"
				}

				#Connect
				Connect-WiFiNetwork $selection $wifiPwd
				$result = Test-WiFiNetwork
				
				if($result -eq $true)
				{
					Send-Hardware "OK"
				}
				else
				{
					Send-Hardware "Failed"
				}
				
				Start-Sleep 4
				
				break
			}
			elseif($menu[$menuIndex] -eq "Set Page")
			{
				#Send-Hardware "opt 2"
				$input = Get-HardwareInput2 $settings.url
				Write-Host "Hardware Input: $input"
				$settings.url = $input.ToLower()
				$settings.SaveConfig()
				$fbPageURL = $settings.url
				Send-Hardware "Saved"
				Start-Sleep -Seconds 2
				break
			}
		}
		
	}

	Send-Hardware "STARTING"
	Write-Host "Exiting Menu"
}

function Clear-Jobs()
{
	if([bool](Get-Job -Name GetFacebookFollowers -ea silentlycontinue) -eq $true)
	{
		Get-Job -Name  GetFacebookFollowers | Remove-Job -Force
	}

	if([bool](Get-Job -Name DisplayFacebookFollowers -ea silentlycontinue) -eq $true)
	{
		Get-Job -Name  DisplayFacebookFollowers | Remove-Job -Force
	}
}

Class Settings
{
    [string]$settingsFile = ""
	[string]$url = ""
	[string]$displayMode = ""
	[string]$text = ""
	[string]$wifiSSID = ""
	[string]$wifiPwd = ""
	[int]$modeDelay = 0
    
    Settings([string]$sFile)
    {
        $this.settingsFile = $sFile
    }

	[void]LoadConfig()
	{
		$lines = Get-Content $this.settingsFile
    	$this.url = $lines[0].Split(':')[1]+":"+$lines[0].Split(':')[2]
		$this.displayMode = $lines[1].Split(':')[1]
		$this.text = $lines[2].Split(':')[1]
		$this.wifiSSID = $lines[3].Split(':')[1]
		$this.wifiPwd = $lines[4].Split(':')[1]
		$this.modeDelay = $lines[5].Split(':')[1]
	
    	Write-Host "url:$($this.url)"
		Write-Host "displaymode:$($this.displayMode)"
		Write-Host "text:$($this.text)"
		Write-Host "wifissid:$($this.wifiSSID)"
		Write-Host "wifipwd:$($this.wifiPwd)"
		Write-Host "modedelay:$($this.modeDelay)"
	}

	[void]SaveConfig()
	{
		Set-Content -Path $this.settingsFile "url:$($this.url)"
		Add-Content -Path $this.settingsFile "displaymode:$($this.displayMode)"
		Add-Content -Path $this.settingsFile "text:$($this.text)"
		Add-Content -Path $this.settingsFile "wifissid:$($this.wifiSSID)"
		Add-Content -Path $this.settingsFile "wifipwd:$($this.wifiPwd)"
		Add-Content -Path $this.settingsFile "modedelay:$($this.modeDelay)"
	}
}

function Get-WiFiNetworks()
{
	$wirelessNetworks = iwlist wlan0 scan
	$wirelessNetworks = [regex]::matches($wirelessNetworks, 'ESSID:"\w+"')
	$wirelessNetworks = $wirelessNetworks.Value.Substring(7).TrimEnd('"')
	return $wirelessNetworks
}

function Connect-WiFiNetwork([string]$ssid, [string]$pwd)
{
	$cmd = iwconfig wlan0 essid $ssid key s:$pwd
	$cmd = dhclient wlan0
}

[int]$numFacebookFollowers = -1

$settings.LoadConfig()
$displayMode = $settings.displayMode
$fbPageURL = $settings.url
$bannerText = $settings.text
$modeDelay = $settings.modeDelay

#Get-HardwareInput2 "1234"
#return

Send-Hardware "VER 0.1"
Clear-Jobs
#Start-Sleep -Seconds 2
#$numFBF = Get-FacebookFollowers
#if($numFBF -ne 0 -and $numFBF -ne -1)
#{#
#	$numFacebookFollowers = $numFBF
#}

#Send-Hardware "STARTING"
#Start-Sleep -Seconds 30

while($true)
{
	#added to fix a weird issue where the variable is not being set from the menu
	$fbPageURL = $settings.url

	$numFBF = Get-FacebookFollowers
	
	if($numFBF -ne 0 -and $numFBF -ne -1)
	{
 		$numFacebookFollowers = $numFBF
	}

	Display-FacebookFollowers($numFacebookFollowers)

	#Detect key press to enter settings menu
	if($backButton.Pushed())
	{
		Stop-Jobs
		Enter-Menu
	}
	elseif($resetButton.Pushed())
	{
		#Write-Host "url:$fbPageURL"
		#Write-Host "settings:$($settings.url)"
		#get-job
	}
}



