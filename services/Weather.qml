pragma Singleton

import QtQuick
import Quickshell
import Caelestia
import Caelestia.Config
import qs.utils

Singleton {
    id: root

    property string city
    property string loc
    property var cc
    property list<var> forecast
    property list<var> hourlyForecast

    readonly property string icon: cc ? Icons.getWeatherIcon(cc.weatherCode) : "cloud_alert"
    readonly property string description: cc?.weatherDesc ?? I18n.tr("无天气信息")
    readonly property string temp: GlobalConfig.services.useFahrenheit ? `${cc?.tempF ?? 0}°F` : `${cc?.tempC ?? 0}°C`
    readonly property string feelsLike: GlobalConfig.services.useFahrenheit ? `${cc?.feelsLikeF ?? 0}°F` : `${cc?.feelsLikeC ?? 0}°C`
    readonly property int humidity: cc?.humidity ?? 0
    readonly property real windSpeed: cc?.windSpeed ?? 0
    readonly property string windLevelLabel: cc ? getWindLevel(cc.windSpeed) : "--"
    readonly property string windDirection: cc?.windDirection ?? ""
    readonly property string sunrise: cc ? Qt.formatDateTime(new Date(cc.sunrise), GlobalConfig.services.useTwelveHourClock ? "h:mm A" : "h:mm") : "--:--"
    readonly property string sunset: cc ? Qt.formatDateTime(new Date(cc.sunset), GlobalConfig.services.useTwelveHourClock ? "h:mm A" : "h:mm") : "--:--"

    readonly property var cachedCities: new Map()

    function reload(): void {
        const configLocation = GlobalConfig.services.weatherLocation;

        if (configLocation) {
            if (configLocation.indexOf(",") !== -1 && !isNaN(parseFloat(configLocation.split(",")[0]))) {
                loc = configLocation;
                fetchCityFromCoords(configLocation);
            } else {
                fetchCoordsFromCity(configLocation);
            }
        } else if (!loc || timer.elapsed() > 900) {
            Requests.get("https://ipinfo.io/json", text => {
                const response = JSON.parse(text);
                if (response.loc) {
                    loc = response.loc;
                    city = response.city ?? "";
                    timer.restart();
                }
            });
        }
    }

    function fetchCityFromCoords(coords: string): void {
        if (cachedCities.has(coords)) {
            city = cachedCities.get(coords);
            return;
        }

        const [lat, lon] = coords.split(",").map(s => s.trim());

        const fallbackToBigDataCloud = () => {
            const fallbackUrl = `https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${lat}&longitude=${lon}&localityLanguage=zh`;
            Requests.get(fallbackUrl, text => {
                const geo = JSON.parse(text);
                const geoCity = geo.city || geo.locality;
                if (geoCity) {
                    city = geoCity;
                    cachedCities.set(coords, geoCity);
                } else {
                    city = "未知城市";
                }
            });
        };

        const nominatimUrl = `https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lon}&format=geocodejson&accept-language=zh`;
        Requests.get(nominatimUrl, text => {
            const geo = JSON.parse(text).features?.[0]?.properties.geocoding;
            if (geo) {
                const geoCity = geo.type === "city" ? geo.name : geo.city;
                if (geoCity) {
                    city = geoCity;
                    cachedCities.set(coords, geoCity);
                    return;
                }
            }
            fallbackToBigDataCloud();
        }, fallbackToBigDataCloud);
    }

    function fetchCoordsFromCity(cityName: string): void {
        const url = `https://geocoding-api.open-meteo.com/v1/search?name=${encodeURIComponent(cityName)}&count=1&language=zh&format=json`;

        Requests.get(url, text => {
            const json = JSON.parse(text);
            if (json.results && json.results.length > 0) {
                const result = json.results[0];
                loc = result.latitude + "," + result.longitude;
                city = result.name;
            } else {
                loc = "";
                reload();
            }
        });
    }

    function fetchWeatherData(): void {
        const url = getWeatherUrl();
        if (url === "")
            return;

        Requests.get(url, text => {
            const json = JSON.parse(text);
            if (!json.current || !json.daily)
                return;

            cc = {
                weatherCode: json.current.weather_code,
                weatherDesc: getWeatherCondition(json.current.weather_code),
                tempC: Math.round(json.current.temperature_2m),
                tempF: Math.round(toFahrenheit(json.current.temperature_2m)),
                feelsLikeC: Math.round(json.current.apparent_temperature),
                feelsLikeF: Math.round(toFahrenheit(json.current.apparent_temperature)),
                humidity: json.current.relative_humidity_2m,
                windSpeed: json.current.wind_speed_10m,
                windDirection: getWindDirection(json.current.wind_direction_10m ?? 0),
                isDay: json.current.is_day,
                sunrise: json.daily.sunrise[0].replace("T", " "),
                sunset: json.daily.sunset[0].replace("T", " ")
            };

            const forecastList = [];
            for (let i = 0; i < json.daily.time.length; i++)
                forecastList.push({
                    date: json.daily.time[i].replace(/-/g, "/"),
                    maxTempC: Math.round(json.daily.temperature_2m_max[i]),
                    maxTempF: Math.round(toFahrenheit(json.daily.temperature_2m_max[i])),
                    minTempC: Math.round(json.daily.temperature_2m_min[i]),
                    minTempF: Math.round(toFahrenheit(json.daily.temperature_2m_min[i])),
                    weatherCode: json.daily.weather_code[i],
                    weatherDesc: getWeatherCondition(json.daily.weather_code[i]),
                    icon: Icons.getWeatherIcon(json.daily.weather_code[i])
                });
            forecast = forecastList;

            const hourlyList = [];
            const now = new Date();
            for (let i = 0; i < json.hourly.time.length; i++) {
                const time = new Date(json.hourly.time[i].replace("T", " "));

                if (time < now)
                    continue;

                hourlyList.push({
                    timestamp: json.hourly.time[i],
                    hour: time.getHours(),
                    tempC: Math.round(json.hourly.temperature_2m[i]),
                    tempF: Math.round(toFahrenheit(json.hourly.temperature_2m[i])),
                    weatherCode: json.hourly.weather_code[i],
                    icon: Icons.getWeatherIcon(json.hourly.weather_code[i])
                });
            }
            hourlyForecast = hourlyList;
        });
    }

    function toFahrenheit(celcius: real): real {
        return celcius * 9 / 5 + 32;
    }

    function getWeatherUrl(): string {
        if (!loc || loc.indexOf(",") === -1)
            return "";

        const [lat, lon] = loc.split(",").map(s => s.trim());
        const baseUrl = "https://api.open-meteo.com/v1/forecast";
        const params = [
            "latitude=" + lat,
            "longitude=" + lon,
            "hourly=weather_code,temperature_2m",
            "daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset",
            "current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m,wind_direction_10m",
            "timezone=auto",
            "forecast_days=7"
        ];

        return baseUrl + "?" + params.join("&");
    }

    function getWeatherCondition(code: string): string {
        const conditions = {
            "0": "晴",
            "1": "晴",
            "2": "多云",
            "3": "阴",
            "45": "雾",
            "48": "雾",
            "51": "小毛毛雨",
            "53": "毛毛雨",
            "55": "大毛毛雨",
            "56": "冻毛毛雨",
            "57": "冻毛毛雨",
            "61": "小雨",
            "63": "中雨",
            "65": "大雨",
            "66": "冻雨",
            "67": "冻雨",
            "71": "小雪",
            "73": "中雪",
            "75": "大雪",
            "77": "雪粒",
            "80": "阵雨",
            "81": "中阵雨",
            "82": "大阵雨",
            "85": "小阵雪",
            "86": "大阵雪",
            "95": "雷暴",
            "96": "雷暴伴冰雹",
            "99": "雷暴伴冰雹"
        };
        return conditions[code] || "未知";
    }

    function getWindLevel(speed: real): string {
        // 中国风力等级标准（蒲福风级 0-12级）
        if (speed < 0.3) return "无风 (0级)";
        if (speed < 1.6) return "软风 (1级)";
        if (speed < 3.4) return "轻风 (2级)";
        if (speed < 5.5) return "微风 (3级)";
        if (speed < 8.0) return "和风 (4级)";
        if (speed < 10.8) return "清风 (5级)";
        if (speed < 13.9) return "强风 (6级)";
        if (speed < 17.2) return "疾风 (7级)";
        if (speed < 20.8) return "大风 (8级)";
        if (speed < 24.5) return "烈风 (9级)";
        if (speed < 28.5) return "狂风 (10级)";
        if (speed < 32.7) return "暴风 (11级)";
        return "飓风 (12级)";
    }

    function getWindDirection(degrees: real): string {
        const directions = ["北风", "北东北风", "东北风", "东东北风",
                           "东风", "东东南风", "东南风", "南东南风",
                           "南风", "南西南风", "西南风", "西西南风",
                           "西风", "西西北风", "西北风", "北西北风"];
        const index = Math.round(degrees / 22.5) % 16;
        return directions[index];
    }

    Component.onCompleted: Qt.callLater(reload)

    onLocChanged: fetchWeatherData()

    Connections {
        function onWeatherLocationChanged(): void {
            root.reload();
        }

        target: GlobalConfig.services
    }

    // Retry when the config file finishes loading (in case weatherLocation was set after Component.onCompleted)
    Connections {
        function onLoaded(): void {
            root.reload();
        }

        target: GlobalConfig
    }

    Timer {
        interval: 3600000 // 1 hour
        running: true
        repeat: true
        onTriggered: fetchWeatherData()
    }

    ElapsedTimer {
        id: timer
    }
}
