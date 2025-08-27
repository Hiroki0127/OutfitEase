const express = require('express');
const router = express.Router();
const weatherController = require('../controllers/weatherController');
const verifyToken = require('../middleware/authMiddleware');

// Protect all routes
router.use(verifyToken);

// Get current weather
router.get('/current', weatherController.getCurrentWeather);

// Get weather forecast
router.get('/forecast', weatherController.getWeatherForecast);

// Get weather-based recommendations
router.post('/recommendations', weatherController.getWeatherRecommendations);

module.exports = router; 