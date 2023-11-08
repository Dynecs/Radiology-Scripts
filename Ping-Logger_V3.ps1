$PACS = Get-Content "C:\PATH\TO\DIR\FOR\.CSV FILE\CREATION\F5LB.txt"
$count = 1


# Time stamp format for the file name:
$YEARSTART = get-date -format yyyy-MM-dd;
$TIMESTART = get-date -format HH.mm.ss


# Log file location and default name:
$DefaulLogName = "PingLog-$hostname-$YEARSTART-$TIMESTART.CSV"
$logname = $DefaulLogName


# CSV file setup:
add-content C:\PATH\TO\DIR\FOR\.CSV FILE\CREATION\$logname "Rad WS,PACS,Latency,Date,Time,User";


# Start time assumes successful ping to calculate seconds
# since sucsessful response in case there's never a response:
$LastSuccessful = get-date

$ping = Test-Connection $PACS -Count $count -ErrorAction SilentlyContinue 
    
    if ($ping-eq $null)
       {
            $TimeSpan = [DateTime](get-date) - [DateTime]$LastSuccessful
            $TotalSeconds = $timespan.TotalSeconds
            $TIMENOW = get-date -format HH:mm.ss
            Write-host "$TIMENOW : Last Ping Timed out. Logged to file. $TotalSeconds Since last sucsess"
            $YEAR = get-date -format yyyy-MM-dd;
            $TIME = get-date -format HH:mm:ss
            add-content C:\PATH\TO\DIR\FOR\.CSV FILE\CREATION\$logname "$hostname,$PACS,>50,$YEAR,$TIME,$env:USERNAME";
            start-sleep -Milliseconds 1
       }
    else
       {
        for ($i=1; $i -le 10; $i++)
            {
            $ping = Test-Connection $PACS -Count $count -ErrorAction SilentlyContinue
            # Update the time since sucsessful in case the next ping fails.
            $LastSuccessful = get-date
            $TIMENOW = get-date -format HH:mm:ss
            $pingtime = $ping.ResponseTime
            Write-host "$TIMENOW : Ping Successful. Reponse Time = $pingtime"
            # Log success to file.
            $YEAR = get-date -format yyyy-MM-dd;
            $TIME = get-date -format HH:mm:ss;
            Add-Content C:\PATH\TO\DIR\FOR\.CSV FILE\CREATION\$logname "$hostname,$PACS,$pingtime,$YEAR,$TIME,$env:USERNAME"
            Start-Sleep -Milliseconds 1
            }
       }

$Latency = Import-Csv C:\PATH\TO\DIR\FOR\.CSV FILE\CREATION\PingLog-$hostname-$YEARSTART-$TIMESTART.CSV | select -ExpandProperty Latency | Measure-Object -Average | select -ExpandProperty Average
    if ( Test-Path C:\PATH\TO\DIR\FOR\.CSV FILE\CREATION\PingLog-$hostname-$YEARSTART-$TIMESTART.CSV -IsValid )
       {
            Add-Content C:\PATH\TO\DIR\FOR\.CSV FILE\CREATION\PingLog-$hostname-$YEARSTART-$TIMESTART.CSV "Average Latency,,$Latency";
       }
