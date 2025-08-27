const axios = require('axios');

const weatherController = {
    // Get current weather for a location
    getCurrentWeather: async (req, res) => {
        try {
            const { latitude, longitude, city } = req.query;
            
            // Use OpenWeatherMap API (you'll need to add your API key)
            const apiKey = process.env.OPENWEATHER_API_KEY || 'your_api_key_here';
            let url;
            
            if (latitude && longitude) {
                url = `https://api.openweathermap.org/data/2.5/weather?lat=${latitude}&lon=${longitude}&appid=${apiKey}&units=metric`;
            } else if (city) {
                url = `https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${apiKey}&units=metric`;
            } else {
                return res.status(400).json({
                    success: false,
                    message: 'Please provide either latitude/longitude or city name'
                });
            }

            const response = await axios.get(url);
            const weatherData = response.data;

            // Extract relevant weather information
            const weatherInfo = {
                temperature: weatherData.main.temp,
                feelsLike: weatherData.main.feels_like,
                humidity: weatherData.main.humidity,
                conditions: weatherData.weather[0].main.toLowerCase(),
                description: weatherData.weather[0].description,
                windSpeed: weatherData.wind.speed,
                city: weatherData.name,
                country: weatherData.sys.country
            };

            res.json({
                success: true,
                weather: weatherInfo
            });
        } catch (error) {
            console.error('Error fetching weather:', error);
            res.status(500).json({
                success: false,
                message: 'Error fetching weather data'
            });
        }
    },

    // Get weather forecast for the next few days
    getWeatherForecast: async (req, res) => {
        try {
            const { latitude, longitude, city } = req.query;
            
            const apiKey = process.env.OPENWEATHER_API_KEY || 'your_api_key_here';
            let url;
            
            if (latitude && longitude) {
                url = `https://api.openweathermap.org/data/2.5/forecast?lat=${latitude}&lon=${longitude}&appid=${apiKey}&units=metric`;
            } else if (city) {
                url = `https://api.openweathermap.org/data/2.5/forecast?q=${city}&appid=${apiKey}&units=metric`;
            } else {
                return res.status(400).json({
                    success: false,
                    message: 'Please provide either latitude/longitude or city name'
                });
            }

            const response = await axios.get(url);
            const forecastData = response.data;

            // Process forecast data to get daily forecasts
            const dailyForecasts = processForecastData(forecastData);

            res.json({
                success: true,
                forecast: dailyForecasts
            });
        } catch (error) {
            console.error('Error fetching weather forecast:', error);
            res.status(500).json({
                success: false,
                message: 'Error fetching weather forecast'
            });
        }
    },

    // Get weather-based clothing recommendations
    getWeatherRecommendations: async (req, res) => {
        try {
            const { temperature, conditions, humidity } = req.body;

            const recommendations = generateWeatherRecommendations(temperature, conditions, humidity);

            res.json({
                success: true,
                recommendations: recommendations
            });
        } catch (error) {
            console.error('Error generating weather recommendations:', error);
            res.status(500).json({
                success: false,
                message: 'Error generating weather recommendations'
            });
        }
    }
};

// Helper function to process forecast data
function processForecastData(forecastData) {
    const dailyForecasts = [];
    const dailyData = {};

    forecastData.list.forEach(item => {
        const date = new Date(item.dt * 1000);
        const day = date.toISOString().split('T')[0];

        if (!dailyData[day]) {
            dailyData[day] = {
                date: day,
                temperatures: [],
                conditions: [],
                humidity: []
            };
        }

        dailyData[day].temperatures.push(item.main.temp);
        dailyData[day].conditions.push(item.weather[0].main);
        dailyData[day].humidity.push(item.main.humidity);
    });

    // Calculate daily averages
    Object.keys(dailyData).forEach(day => {
        const data = dailyData[day];
        const avgTemp = data.temperatures.reduce((a, b) => a + b, 0) / data.temperatures.length;
        const avgHumidity = data.humidity.reduce((a, b) => a + b, 0) / data.humidity.length;
        
        // Get most common condition
        const conditionCounts = {};
        data.conditions.forEach(condition => {
            conditionCounts[condition] = (conditionCounts[condition] || 0) + 1;
        });
        const mostCommonCondition = Object.keys(conditionCounts).reduce((a, b) => 
            conditionCounts[a] > conditionCounts[b] ? a : b
        );

        dailyForecasts.push({
            date: day,
            temperature: Math.round(avgTemp),
            conditions: mostCommonCondition.toLowerCase(),
            humidity: Math.round(avgHumidity),
            recommendations: generateWeatherRecommendations(avgTemp, mostCommonCondition.toLowerCase(), avgHumidity)
        });
    });

    return dailyForecasts;
}

// Helper function to generate weather-based clothing recommendations
function generateWeatherRecommendations(temperature, conditions, humidity) {
    const recommendations = {
        seasons: [],
        styles: [],
        occasions: [],
        clothingTypes: [],
        colors: [],
        accessories: []
    };

    // Temperature-based recommendations
    if (temperature < 5) {
        recommendations.seasons = ['Winter'];
        recommendations.styles = ['Warm', 'Layered'];
        recommendations.clothingTypes = ['Coat', 'Sweater', 'Scarf', 'Gloves'];
        recommendations.colors = ['Dark', 'Neutral'];
    } else if (temperature < 15) {
        recommendations.seasons = ['Fall', 'Winter'];
        recommendations.styles = ['Layered', 'Smart'];
        recommendations.clothingTypes = ['Jacket', 'Sweater', 'Long Sleeve'];
        recommendations.colors = ['Earth Tones', 'Neutral'];
    } else if (temperature < 25) {
        recommendations.seasons = ['Spring', 'Fall'];
        recommendations.styles = ['Casual', 'Smart Casual'];
        recommendations.clothingTypes = ['Light Jacket', 'Sweater', 'T-Shirt'];
        recommendations.colors = ['Bright', 'Pastel'];
    } else {
        recommendations.seasons = ['Summer'];
        recommendations.styles = ['Light', 'Casual'];
        recommendations.clothingTypes = ['T-Shirt', 'Shorts', 'Light Dress'];
        recommendations.colors = ['Bright', 'Light'];
    }

    // Condition-based recommendations
    if (conditions.includes('rain')) {
        recommendations.styles.push('Waterproof');
        recommendations.clothingTypes.push('Rain Jacket', 'Umbrella');
        recommendations.accessories.push('Waterproof Shoes');
    } else if (conditions.includes('snow')) {
        recommendations.styles.push('Insulated');
        recommendations.clothingTypes.push('Winter Boots', 'Heavy Coat');
        recommendations.accessories.push('Winter Hat', 'Gloves');
    } else if (conditions.includes('sun')) {
        recommendations.accessories.push('Sunglasses', 'Hat');
    }

    // Humidity-based recommendations
    if (humidity > 70) {
        recommendations.styles.push('Breathable');
        recommendations.clothingTypes.push('Cotton', 'Linen');
    }

    return recommendations;
}

module.exports = weatherController; 