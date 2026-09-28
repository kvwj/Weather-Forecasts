#Daytime forecast: "J-95 Weather - Much needed rain is in the forecast for this afternoon with a high near 45. Chance of snow tonight, down to just below freezing by the morning. South valley weather.

#Only on KVWJ!"

#Nighttime forecast: "South Valley weather - Partly cloudy skies tonight with an overnight low near 38.

#Warming this week with highs around 65. I'm Lydia with weather twice an hour on KVWJ!"



#$date = Get-Date

#Github update function
function git-getfile {
    param (
        $token,
        $owner,
        $repo,
        $path
    )

    $base64token = [System.Convert]::ToBase64String([char[]]$token)

    $headers = @{
        Authorization = 'Basic {0}' -f $base64token
        accept = 'application/vnd.github.v3+json'
    }

    Invoke-RestMethod -Headers $headers -Uri https://api.github.com/repos/$owner/$repo/contents/$path -Method Get | select *, @{n='content_decoded';e={[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_.content))}}
}
function git-updatefile {
    # requires git-getfile
    param (
        $token,
        $message = '',
        $content,
        $sha,
        $owner,
        $repo,
        $path
    )

    $base64token = [System.Convert]::ToBase64String([char[]]$token)

    $headers = @{
        Authorization = 'Basic {0}' -f $base64token
    }

    if (!$sha) {
        $sha = (git-getfile -token $token -owner $owner -repo $repo -path $path).sha
    }

    $body = @{
        message = $message
        content = $content
        sha = $sha
    } | ConvertTo-Json
    Write-Host "https://api.github.com/repos/$owner/$repo/contents/$path"
    Invoke-RestMethod -Headers $headers -Uri https://api.github.com/repos/$owner/$repo/contents/$path -Body $body -Method Put
}



$OPENAI_API_KEY = 'xxxxx'

$GITHUB_TOKEN = 'xxxxx'

#Open Weather Map

#$weather_forecast = Invoke-RestMethod 'https://api.openweathermap.org/data/2.5/forecast?lat=41.6314744&lon=-111.821586&cnt=8&appid=***openweathermap_api_key***&units=imperial'



#Tomorrow.io



#$weather_forecast = Invoke-RestMethod 'https://api.tomorrow.io/v4/weather/forecast?location=hyrum&timesteps=1h&units=imperial&apikey=***tomorrow_io_api_key***'


#Microsoft
$MicrosoftAPIKey = "xxxxx"
$Latitude = "41.631984571236515" #Hyrum, UT
$Longitude = "-111.81926447536614"

$RequestHeaders = @{

    "subscription-key" = $SubscriptionKey
    "Accept"           = "application/json"
}

$weather_forecast = Invoke-RestMethod -Uri "https://atlas.microsoft.com/weather/forecast/daily/json?api-version=1.1&query=$($Latitude),$($Longitude)&unit=imperial&duration=5" -Method GET -Headers $RequestHeaders




$min_temp = $weather_forecast.forecasts[0].temperature.minimum.value

$max_temp = $weather_forecast.forecasts[1].temperature.maximum.value



$weather_evening = $weather_forecast.forecasts[0].night.longPhrase

$weather_morning = $weather_forecast.forecasts[1].day.longPhrase




$day_tomorrow = ((get-date).DayOfWeek + 1)

if ($day_tomorrow -eq 7) {
    $day_tomorrow = 'Sunday'
}   


#$morning_script1 = "South valley weather: Up to " + [Math]::Round($temp_afternoon) + " today under " + $weather_afternoon + ". " + $weather_evening +  " overnight with low temps near " + [Math]::Round($temp_evening) + "."

#$morning_script2 = "Hyrum weather: " + $weather_evening +  " tonight with low temps near " + [Math]::Round($temp_evening) + ". Up to " + [Math]::Round($temp_afternoon) + " today under " + $weather_afternoon + "."

#$morning_script3 = "K-V-W-J weather: Up to " + [Math]::Round($temp_afternoon) + " today under " + $weather_afternoon + ". " + $weather_evening +  " overnight with low temps near " + [Math]::Round($temp_evening) + "."


# Before Microsoft API switch
#$evening_script1 = "South valley weather: " + $weather_evening +  " overnight with low temps near " + $min_temp + ". [pause] Up to " + $max_temp + " on " + $day_tomorrow + " under " + $weather_morning + "."

#$evening_script2 = "Hyrum weather: Up to " + $max_temp + " on " + $day_tomorrow + " under " + $weather_morning + ". [pause]" + $weather_evening +  " tonight with low temps near " + $min_temp + "."

#$evening_script3 = "K-V-W-J weather: " + $weather_evening +  " overnight with low temps near " + $min_temp + ". [pause] Up to " + $max_temp + " on " + $day_tomorrow + " under " + $weather_morning + "."

#After Microsoft API switch
#After Microsoft API Switch
$evening_script1 = "South valley weather: " + $weather_evening +  " overnight with low temps near " + $min_temp + ". [pause]" + $weather_morning + " and up to " + $max_temp + " on " + $day_tomorrow + "."

$evening_script2 = "Hyrum weather: " + $weather_morning + "up to " + $max_temp + " on " + $day_tomorrow + ". [pause]" + $weather_evening +  " tonight with low temps near " + $min_temp + "."

$evening_script3 = "K-V-W-J weather: " + $weather_evening +  " overnight with low temps near " + $min_temp + ". [pause]" + $weather_morning + " and up to " + $max_temp + " on " + $day_tomorrow + "."


$file_path1="C:\Users\KVWJ\Desktop\weather\evening\script_archive\evening_script1-" + (Get-Date).ToString("yyyyMMdd") + ".txt"

$file_path2="C:\Users\KVWJ\Desktop\weather\evening\script_archive\evening_script2-" + (Get-Date).ToString("yyyyMMdd") + ".txt"

$file_path3="C:\Users\KVWJ\Desktop\weather\evening\script_archive\evening_script3-" + (Get-Date).ToString("yyyyMMdd") + ".txt"

#  $file_path1="evening_script1-" + (Get-Date).ToString("yyyyMMdd") + ".txt"

#  $file_path2="evening_script2-" + (Get-Date).ToString("yyyyMMdd") + ".txt"

#  $file_path3="evening_script3-" + (Get-Date).ToString("yyyyMMdd") + ".txt"

$evening_script1 | Out-File $file_path1

$evening_script2 | Out-File $file_path2

$evening_script3 | Out-File $file_path3



#$body = '{ "model": "tts-1", "input": "' + $morning_script1 + '", "voice": "nova"}'

#$r = Invoke-WebRequest https://api.openai.com/v1/audio/speech -Headers @{'Authorization' = 'Bearer ' + $OPENAI_API_KEY; 'Content-Type' = 'application/json'} -Method 'POST' -Body $body -OutFile "C:\Users\KVWJ\Desktop\weather\morning\am weather 1~0.mp3"

#Start-Sleep -Seconds 20

#$body = '{ "model": "tts-1", "input": "' + $morning_script2 + '", "voice": "nova"}'

#$r = Invoke-WebRequest https://api.openai.com/v1/audio/speech -Headers @{'Authorization' = 'Bearer ' + $OPENAI_API_KEY; 'Content-Type' = 'application/json'} -Method 'POST' -Body $body -OutFile "C:\Users\KVWJ\Desktop\weather\morning\am weather 2~0.mp3"

#Start-Sleep -Seconds 20

#$body = '{ "model": "tts-1", "input": "' + $morning_script3 + '", "voice": "nova"}'

#$r = Invoke-WebRequest https://api.openai.com/v1/audio/speech -Headers @{'Authorization' = 'Bearer ' + $OPENAI_API_KEY; 'Content-Type' = 'application/json'} -Method 'POST' -Body $body -OutFile "C:\Users\KVWJ\Desktop\weather\morning\am weather 3~0.mp3"

#Start-Sleep -Seconds 20

$body = '{ "model": "tts-1", "input": "' + $evening_script1 + '", "voice": "nova"}'

$r = Invoke-WebRequest https://api.openai.com/v1/audio/speech -Headers @{'Authorization' = 'Bearer ' + $OPENAI_API_KEY; 'Content-Type' = 'application/json'} -Method 'POST' -Body $body -OutFile "C:\Users\KVWJ\Desktop\weather\evening\pm weather 1~0.mp3"

Start-Sleep -Seconds 20

$body = '{ "model": "tts-1", "input": "' + $evening_script2 + '", "voice": "nova"}'

$r = Invoke-WebRequest https://api.openai.com/v1/audio/speech -Headers @{'Authorization' = 'Bearer ' + $OPENAI_API_KEY; 'Content-Type' = 'application/json'} -Method 'POST' -Body $body -OutFile "C:\Users\KVWJ\Desktop\weather\evening\pm weather 2~0.mp3"

Start-Sleep -Seconds 20

$body = '{ "model": "tts-1", "input": "' + $evening_script3 + '", "voice": "nova"}'

$r = Invoke-WebRequest https://api.openai.com/v1/audio/speech -Headers @{'Authorization' = 'Bearer ' + $OPENAI_API_KEY; 'Content-Type' = 'application/json'} -Method 'POST' -Body $body -OutFile "C:\Users\KVWJ\Desktop\weather\evening\pm weather 3~0.mp3"


$FileName = "C:\Users\KVWJ\Desktop\weather\evening\pm weather 1~0.mp3"
$base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($FileName))
git-updatefile -token $GITHUB_TOKEN -content $base64string -owner kvwj -repo Weather-Forecasts -path 'pm weather 1~0.mp3'

$FileName = "C:\Users\KVWJ\Desktop\weather\evening\pm weather 2~0.mp3"
$base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($FileName))
git-updatefile -token $GITHUB_TOKEN -content $base64string -owner kvwj -repo Weather-Forecasts -path 'pm weather 2~0.mp3'

$FileName = "C:\Users\KVWJ\Desktop\weather\evening\pm weather 3~0.mp3"
$base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($FileName))
git-updatefile -token $GITHUB_TOKEN -content $base64string -owner kvwj -repo Weather-Forecasts -path 'pm weather 3~0.mp3'

$base64string = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($evening_script1))
git-updatefile -token $GITHUB_TOKEN -content $base64string -owner kvwj -repo Weather-Forecasts -path 'evening_script1.txt'

$base64string = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($evening_script2))
git-updatefile -token $GITHUB_TOKEN -content $base64string -owner kvwj -repo Weather-Forecasts -path 'evening_script2.txt'

$base64string = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($evening_script3))
git-updatefile -token $GITHUB_TOKEN -content $base64string -owner kvwj -repo Weather-Forecasts -path 'evening_script3.txt'
