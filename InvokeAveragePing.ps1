$Latency = Import-Csv C:\Users\$USER\Documents\Scripts\PingLog-$hostname.CSV | select -ExpandProperty Latency | Measure-Object -Average | select -ExpandProperty Average

if ( Test-Path C:\Users\$USER\Documents\Scripts\PingLog-$hostname.CSV -IsValid )
            {
                Add-Content C:\Users\$USER\Documents\Scripts\PingLog-$hostname.CSV "Average Latency,,$Latency";
            }
