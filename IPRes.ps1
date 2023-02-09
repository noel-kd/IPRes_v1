#Script Name: IPRes
#Version: 1
#Last Updated: 20220209
#Author: Kyle Noel

Clear-Host

#Assigning variables
$inFilePath=$args[0]
$clientIp=0
$index=0
$progress=1
$dateTime=(Get-Date).ToString('yyyMMdd-HHmm.ss.fff')
$dateHeader=Get-Date -UFormat '%A %m/%d/%Y %T'

#Assigning output filepath variables
$ipPath=".\data\dns\resolved.txt"
$noIpPath=".\data\dns\unresolved.txt"
$pingIpPath=".\data\ping\success-ip.txt"
$pingHostPath=".\data\ping\success-host.txt"
$noPingIpPath=".\data\ping\fail-ip.txt"
$noPingHostPath=".\data\ping\fail-host.txt"
$reportName="report-" + $dateTime + ".txt"
$reportPath=".\reports\$reportName"

$host.privatedata.ProgressBackgroundColor="DarkMagenta"

#Help menu display
if(($inFilePath -eq "-help") -or ($inFilePath -eq "help")){
    Write-Host "`n`t`t--- HELP MENU ---" -ForegroundColor Yellow
    Write-Host "`n`tRun IPRes.ps1 with the following argument:"
    Write-Host "`tFilepath of file containing list of hostnames."
    Write-Host "`tExample:"
    Write-Host "`t  PS C:\IPRes> .\IPRes.ps1 .\hostnames.txt"
    Write-Host "`tNOTE: running IPRes.ps1 will clear files in data directory." -ForegroundColor Red
    Write-Host "`tSee " -NoNewline; Write-Host "README.txt" -ForegroundColor Cyan -NoNewline; Write-Host " for additional information."
    Write-Host "`nPress any key to exit..."
    $host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') | Clear-Host
    exit}

#Assigning inFileName variable after help menu to avoid error 'IPRes\help not found'
$inFileName=(Get-Item $inFilePath).Name

#Check for existing files and clears/creates new
if(!(Test-Path $IpPath)){
    New-Item -Path $IpPath | Out-Null}
else{Clear-Content $IpPath}

if(!(Test-Path $noIpPath)){
    New-Item -Path $noIpPath | Out-Null}
else{Clear-Content $noIpPath}

if(!(Test-Path $pingIpPath)){
    New-Item -Path $pingIpPath | Out-Null}
else{Clear-Content $pingIpPath}

if(!(Test-Path $pingHostPath)){
    New-Item -Path $pingHostPath | Out-Null}
else{Clear-Content $pingHostPath}

if(!(Test-Path $noPingHostPath)){
    New-Item -Path $noPingHostPath | Out-Null}
else{Clear-Content $noPingHostPath}

if(!(Test-Path $noPingIpPath)){
    New-Item -Path $noPingIpPath | Out-Null}
else{Clear-Content $noPingIpPath}

if(!(Test-Path $reportPath)){
    New-Item -Path $reportPath | Out-Null}
else{Clear-Content $reportPath}

#Sets report file header
"$dateHeader`n" | Out-File -FilePath $reportPath -Append
"Hostname`tIP Address`t`tConnected" | Out-File -FilePath $reportPath -Append  
"--------`t----------`t`t----------" | Out-File -FilePath $reportPath -Append

#Retrieves hostname input file, parses file
$clients=Get-Content -Path $inFilePath
foreach($client in $clients){
    
    $currProgress=[math]::Round($progress/$clients.count*100)
    Write-Progress -Activity "Processing $inFileName" -Status "Progress: $currProgress %    Checking: $client" -Id 1 -PercentComplete $currProgress

    #Pulls DNS
    $clientIp=Resolve-DnsName -Name $client -Type A -ErrorAction SilentlyContinue | Select-Object -Property IPAddress -ExpandProperty IPAddress
    
    #Outputs resolved IPs
    if($clientIp -match "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$"){
        $clientIp | Out-File -FilePath $IpPath -Append
        
        #Pings IPs and outputs results
        if(Test-Connection $clientIp -Count 1 -Quiet){
            $clientIp | Out-File -FilePath $pingIpPath -Append
            $client | Out-File -FilePath $pingHostPath -Append
            "$client`t$clientIp`t`tYES" | Out-File -FilePath $reportPath -Append
            $index += 1}
        else{$client | Out-File -FilePath $noPingHostPath -Append
            $clientIp | Out-File -FilePath $noPingIpPath -Append
            "$client`t$clientIp`t`tNO" | Out-File -FilePath $reportPath -Append}}
    
    #Outputs unresolved hostnames
    else{  
        $client | Out-File -FilePath $noIpPath -Append
        "$client`tUNRESOLVED`t`tNO" | Out-File -FilePath $reportPath -Append}
    
    $clientIp=0
    $progress++}

"`nTotal connected: " + $index + " of " + $clients.count | Out-File -FilePath $reportPath -Append
"`nNOTE: Unresolved clients do not have a DHCP lease." | Out-File -FilePath $reportPath -Append
"      They have likely been disconnected > 24hrs." | Out-File -FilePath $reportPath -Append

Write-Progress -Activity "`nProcessing Complete" -Id 1 -Complete

Write-Host "`n`t`t--- OPERATION COMPLETE ---" -ForegroundColor Yellow

Write-Host "`n`tThe following hostnames could not be resolved:  "
$unresClients=Get-Content -Path $noIpPath
foreach($unresClient in $unresClients){
    Write-Host "`t$unresClient" -ForegroundColor Red }

Write-Host "`n`tCheck " -NoNewline; Write-Host "IPRes\data\dns" -ForegroundColor Cyan -NoNewline; Write-Host " for DNS information."
Write-Host "`tCheck " -NoNewline; Write-Host "IPRes\data\ip" -ForegroundColor Cyan -NoNewline; Write-Host " for connection status."
Write-Host "`tCheck " -NoNewline; Write-Host "IPRes\reports" -ForegroundColor Cyan -NoNewline; Write-Host " for full report.`n"

Write-Host "`nPress any key to exit..."
$host.UI.RawUI.ReadKey() | Clear-Host