$Latency = Import-Csv C:\Users\gguaracha\Documents\Scripts\PingLog-$hostname.CSV | select -ExpandProperty Latency | Measure-Object -Average | select -ExpandProperty Average

if ( Test-Path C:\Users\gguaracha\Documents\Scripts\PingLog-$hostname.CSV -IsValid )
            {
                Add-Content C:\Users\gguaracha\Documents\Scripts\PingLog-$hostname.CSV "Average Latency,,$Latency";
            }