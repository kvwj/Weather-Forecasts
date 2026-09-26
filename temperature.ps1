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

#Tomorrow.io
# Longitude and Latitude 41.631984571236515, -111.81926447536614
$weather = Invoke-RestMethod 'https://api.tomorrow.io/v4/weather/realtime?location=41.631984571236515,-111.81926447536614&units=imperial&apikey=xxxxx'


# Used to query by the name hyrum
# $weather = Invoke-RestMethod 'https://api.tomorrow.io/v4/weather/realtime?location=hyrum&units=imperial&apikey=xxxxx'

$file_data = "<HTML>`r`n"
$file_data += "Temperature: " + [Math]::Round($weather.data.values.temperature) + "<BR />`r`n"
$file_data += "Humidity: " + [Math]::Round($weather.data.values.humidity) + "<BR />`r`n"
$file_data += "<BR />`r`n"
$file_data += $date
$file_data += "`r`n</HTML>"

$file_data | Set-Content C:\Users\KVWJ\Desktop\weather\zara_weather.htm
