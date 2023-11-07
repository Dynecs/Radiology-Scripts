# Powershell script designed to track latency between Rad Workstations and F5 Load Balancer every 2 hours.
# The results will be written and formatted in an Excel .CSV file. 
# The typical use case is to track intermittent network issues to help track down saturated switch ports or firewall capacity issues.
# Resolution is roughly 1 second rate. This can lead to large files if the script is left running for several days. 
# Approximatly 2MB of log file growth per day should be expected.
# Enabling NTFS compression on the folder is recomended to prevent unecassary file growth.
# Ping timeouts/failures will be recorded as >50 which is easy to spot in a graph as a dropped packet (time out)
# The filename output is formatted so the same script can be quickly started on multiple Workstations and all log files imported to
# the same folder for analysis without filename conflict. 


<#
CSV format:

Source,Destination,Year,Time,ResponseTime,User
hostnmame,X.X.X.X,YYYY/MM/MM,HH:MM:SS,ms,username
hostnmame,X.X.X.X,YYYY/MM/MM,HH:MM:SS,ms,username
hostnmame,X.X.X.X,YYYY/MM/MM,HH:MM:SS,ms,username
hostnmame,X.X.X.X,YYYY/MM/MM,HH:MM:SS,ms,username
hostnmame,X.X.X.X,YYYY/MM/MM,HH:MM:SS,ms,username
hostnmame,X.X.X.X,YYYY/MM/MM,HH:MM:SS,ms,username
hostnmame,X.X.X.X,YYYY/MM/MM,HH:MM:SS,ms,username
hostnmame,X.X.X.X,YYYY/MM/MM,HH:MM:SS,ms,username
hostnmame,X.X.X.X,YYYY/MM/MM,HH:MM:SS,ms,username
#>





# File name variables:
$hostname = $env:computername 
$PACS = Get-Content "C:\Users\gguaracha\Documents\Scripts\F5LB.txt"


# Time stamp format for the file name:
$YEARSTART = get-date -format yyyy-MM-dd;
$TIMESTART = get-date -format HH.mm.ss


# Log file location and default name:
$DefaulLogName = "PingLog-$hostname-$YEARSTART-$TIMESTART.CSV"
$logname = $DefaulLogName


# CSV file setup:
add-content C:\Users\gguaracha\Documents\Scripts\$logname "Rad WS,PACS,Latency,Date,Time,User";


# Start time assumes successful ping to calculate seconds
# since sucsessful response in case there's never a response.
$LastSuccessful = get-date


while($true)
{

        $res = Test-Connection $PACS -Count 1 -ErrorAction SilentlyContinue

        if ($res-eq $null) 
            {
                # Time out or failure of the ping.
                
                # How long since a last sucsessful ping?
                $TimeSpan = [DateTime](get-date) - [DateTime]$LastSuccessful

                $TotalSeconds = $timespan.TotalSeconds
                
                # Visual so users see something signafying failures.
                $TIMENOW = get-date -format HH:mm.ss
                Write-host "$TIMENOW : Last Ping Timed out. Logged to file. $TotalSeconds Since last sucsess"

 
                # Log failure to file.
                $YEAR = get-date -format yyyy-MM-dd;
                $TIME = get-date -format HH:mm:ss
                add-content C:\Users\gguaracha\Documents\Scripts\$logname "$hostname,$PACS,>50,$YEAR,$TIME,$env:USERNAME";
                
                # In case the NIC goes down, delay here so highest resolution of outage is 5 seconds.
                start-sleep -s 1
            }

        else
            {
                # Response to the ping message inside of the default 4 second time out.
                
                # Update the time since sucsessful in case the next ping fails.
                $LastSuccessful = get-date
                
                $TIMENOW = get-date -format HH:mm:ss
                $pingtime = $res.ResponseTime
                Write-host "$TIMENOW : Ping Successful. Reponse Time = $pingtime"



                # Log success to file.
                $YEAR = get-date -format yyyy-MM-dd;
                $TIME = get-date -format HH:mm:ss;
                 add-content C:\Users\gguaracha\Documents\Scripts\$logname "$hostname,$PACS,$pingtime,$YEAR,$TIME,$env:USERNAME";

                # Pause for 1 second to prevent low latency loop being too quick.
                start-sleep -s 1

                # Set $res to null in case the ping starts to fail
            }


}

Wait-Job -Name Ping-Logger Test
Invoke-Item C:\Users\gguaracha\Documents\Scripts\Untitled2.ps1