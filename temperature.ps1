#<HTML>
#Location: Hyrum, UT<BR />
#Condition: Sunny<BR />
#Temperature: 42<BR />
#Feels Like: [Feels]<BR />
#Dew Point: [Dew]<BR />
#Humidity: 44<BR />
#Wind: [wind]<BR />
#Visibility: [Visibility]<BR />
#Barometer: [Barometer]<BR />
#UV Index: [UV]<BR />
#Sunrise: [Sunrise AMPM]<BR />
#Sunset: [Sunset AMPM]<BR />
#<BR />
#2024-03-09-1707
#</HTML>

$date = Get-Date

$SubscriptionKey = "xxxxx"

$Latitude = "41.631984571236515" #Hyrum, UT
$Longitude = "-111.81926447536614"

$RequestHeaders = @{

    "subscription-key" = $SubscriptionKey
    "Accept"           = "application/json"
}

#Tomorrow.io
# Longitude and Latitude 41.631984571236515, -111.81926447536614
#$weather = Invoke-RestMethod 'https://api.tomorrow.io/v4/weather/realtime?location=41.631984571236515,-111.81926447536614&units=imperial&apikey=xxxxx'


# Used to query by the name hyrum
# $weather = Invoke-RestMethod 'https://api.tomorrow.io/v4/weather/realtime?location=hyrum&units=imperial&apikey=xxxxx'

#Microsoft
$weather = Invoke-RestMethod -Uri "https://atlas.microsoft.com/weather/currentConditions/json?api-version=1.1&query=$($Latitude),$($Longitude)&unit=imperial" -Method GET -Headers $RequestHeaders

$file_data = "<HTML>`r`n"
$file_data += "Temperature: " + [Math]::Round($weather.results[0].temperature.value) + "<BR />`r`n"
$file_data += "Humidity: " + [Math]::Round($weather.results[0].relativeHumidity) + "<BR />`r`n"
$file_data += "<BR />`r`n"
$file_data += $date
$file_data += "`r`n</HTML>"

$file_data | Set-Content C:\Users\KVWJ\Desktop\weather\zara_weather.htm
