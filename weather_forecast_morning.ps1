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



$OPENAI_API_KEY = '***openapikey***'



#Open Weather Map

#$weather_forecast = Invoke-RestMethod 'https://api.openweathermap.org/data/2.5/forecast?lat=41.6314744&lon=-111.821586&cnt=8&appid=***openweathermap_api_key***&units=imperial'



#Tomorrow.io



$weather_forecast = Invoke-RestMethod 'https://api.tomorrow.io/v4/weather/forecast?location=hyrum&timesteps=1h&units=imperial&apikey=***tomorrow_io_api_key***'



$min_temp_array = @()

$max_temp_array = @()

$conditions_result_array_evening = @()

$conditions_result_array_morning = @()

$conditions_array = (Get-Content 'C:\Users\KVWJ\Desktop\weather\weather_codes.json' | Out-String | ConvertFrom-Json)



foreach($hour in ($weather_forecast.timelines.hourly | Select-Object -First 15)) {

    $max_temp_array += $hour.values.temperature

}



foreach($hour in ($weather_forecast.timelines.hourly | Select-Object -First 27 | Select-Object -Skip 15)) {

    $min_temp_array += $hour.values.temperature

}



$min_temp = [Math]::Round(($min_temp_array | Measure-Object -Minimum).Minimum)

$max_temp = [Math]::Round(($max_temp_array | Measure-Object -Maximum).Maximum)



#"An" only needs to be used for 8, 11, 18, 80-89



foreach($code in ($weather_forecast.timelines.hourly | Select-Object -First 15) ) {

    $conditions_result_array_morning += $code.values.weatherCode

}



foreach($code in ($weather_forecast.timelines.hourly | Select-Object -First 27 | Select-Object -Skip 15) ) {

    $conditions_result_array_evening += $code.values.weatherCode

}



$weather_evening = $conditions_array.(($conditions_result_array_evening | Group-Object -NoElement)[0].Name)

$weather_morning = $conditions_array.(($conditions_result_array_evening | Group-Object -NoElement)[0].Name)



$morning_script1 = "South valley weather: Up to " + $max_temp + " today under " + $weather_morning + ". [pause]" + $weather_evening +  " overnight with low temps near " + $min_temp + "."

$morning_script2 = "Hyrum weather: " + $weather_evening +  " tonight with low temps near " + $min_temp + ". [pause] Up to " + $max_temp + " today under " + $weather_morning + "."

$morning_script3 = "K-V-W-J weather: Up to " + $max_temp + " today under " + $weather_morning + ". [pause]" + $weather_evening +  " overnight with low temps near " + $min_temp + "."





#$evening_script1 = "South valley weather: " + $weather_evening +  " overnight with low temps near " + $min_temp + ". [pause] Up to " + $max_temp + " on " + ((get-date).DayOfWeek + 1) + " under " + $weather_morning + "."

#$evening_script2 = "Hyrum weather: Up to " + $max_temp + " on " + ((get-date).DayOfWeek + 1) + " under " + $weather_morning + ". [pause]" + $weather_evening +  " tonight with low temps near " + $min_temp + "."

#$evening_script3 = "K-V-W-J weather: " + $weather_evening +  " overnight with low temps near " + $min_temp + ". [pause] Up to " + $max_temp + " on " + ((get-date).DayOfWeek + 1) + " under " + $weather_morning + "."



$file_path1="C:\Users\KVWJ\Desktop\weather\morning\script_archive\morning_script1-" + (Get-Date).ToString("yyyyMMdd") + ".txt"

$file_path2="C:\Users\KVWJ\Desktop\weather\morning\script_archive\morning_script2-" + (Get-Date).ToString("yyyyMMdd") + ".txt"

$file_path3="C:\Users\KVWJ\Desktop\weather\morning\script_archive\morning_script3-" + (Get-Date).ToString("yyyyMMdd") + ".txt"

# $file_path1="evening_script1-" + (Get-Date).ToString("yyyyMMdd") + ".txt"

# $file_path2="evening_script2-" + (Get-Date).ToString("yyyyMMdd") + ".txt"

# $file_path3="evening_script3-" + (Get-Date).ToString("yyyyMMdd") + ".txt"

$morning_script1 | Out-File $file_path1

$morning_script2 | Out-File $file_path2

$morning_script3 | Out-File $file_path3



$body = '{ "model": "tts-1", "input": "' + $morning_script1 + '", "voice": "nova"}'

$r = Invoke-WebRequest https://api.openai.com/v1/audio/speech -Headers @{'Authorization' = 'Bearer ' + $OPENAI_API_KEY; 'Content-Type' = 'application/json'} -Method 'POST' -Body $body -OutFile "C:\Users\KVWJ\Desktop\weather\morning\am weather 1~0.mp3"

Start-Sleep -Seconds 20

$body = '{ "model": "tts-1", "input": "' + $morning_script2 + '", "voice": "nova"}'

$r = Invoke-WebRequest https://api.openai.com/v1/audio/speech -Headers @{'Authorization' = 'Bearer ' + $OPENAI_API_KEY; 'Content-Type' = 'application/json'} -Method 'POST' -Body $body -OutFile "C:\Users\KVWJ\Desktop\weather\morning\am weather 2~0.mp3"

Start-Sleep -Seconds 20

$body = '{ "model": "tts-1", "input": "' + $morning_script3 + '", "voice": "nova"}'

$r = Invoke-WebRequest https://api.openai.com/v1/audio/speech -Headers @{'Authorization' = 'Bearer ' + $OPENAI_API_KEY; 'Content-Type' = 'application/json'} -Method 'POST' -Body $body -OutFile "C:\Users\KVWJ\Desktop\weather\morning\am weather 3~0.mp3"

#Start-Sleep -Seconds 20

#$body = '{ "model": "tts-1", "input": "' + $evening_script1 + '", "voice": "nova"}'

#$r = Invoke-WebRequest https://api.openai.com/v1/audio/speech -Headers @{'Authorization' = 'Bearer ' + $OPENAI_API_KEY; 'Content-Type' = 'application/json'} -Method 'POST' -Body $body -OutFile "C:\Users\KVWJ\Desktop\weather\evening\pm weather 1~0.mp3"

#Start-Sleep -Seconds 20

#$body = '{ "model": "tts-1", "input": "' + $evening_script2 + '", "voice": "nova"}'

#$r = Invoke-WebRequest https://api.openai.com/v1/audio/speech -Headers @{'Authorization' = 'Bearer ' + $OPENAI_API_KEY; 'Content-Type' = 'application/json'} -Method 'POST' -Body $body -OutFile "C:\Users\KVWJ\Desktop\weather\evening\pm weather 2~0.mp3"

#Start-Sleep -Seconds 20

#$body = '{ "model": "tts-1", "input": "' + $evening_script3 + '", "voice": "nova"}'

#$r = Invoke-WebRequest https://api.openai.com/v1/audio/speech -Headers @{'Authorization' = 'Bearer ' + $OPENAI_API_KEY; 'Content-Type' = 'application/json'} -Method 'POST' -Body $body -OutFile "C:\Users\KVWJ\Desktop\weather\evening\pm weather 3~0.mp3"



$FileName = "C:\Users\KVWJ\Desktop\weather\morning\am weather 1~0.mp3"
$base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($FileName))
git-updatefile -token '***github_token***' -content $base64string -owner kvwj -repo Weather-Forecasts -path 'am weather 1~0.mp3'

$FileName = "C:\Users\KVWJ\Desktop\weather\morning\am weather 2~0.mp3"
$base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($FileName))
git-updatefile -token '***github_token***' -content $base64string -owner kvwj -repo Weather-Forecasts -path 'am weather 2~0.mp3'

$FileName = "C:\Users\KVWJ\Desktop\weather\morning\am weather 3~0.mp3"
$base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($FileName))
git-updatefile -token '***github_token***' -content $base64string -owner kvwj -repo Weather-Forecasts -path 'am weather 3~0.mp3'

$base64string = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($morning_script1))
git-updatefile -token '***github_token***' -content $base64string -owner kvwj -repo Weather-Forecasts -path 'morning_script1.txt'

$base64string = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($morning_script2))
git-updatefile -token '***github_token***' -content $base64string -owner kvwj -repo Weather-Forecasts -path 'morning_script2.txt'

$base64string = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($morning_script3))
git-updatefile -token '***github_token***' -content $base64string -owner kvwj -repo Weather-Forecasts -path 'morning_script3.txt'
