const pool = require('../db');
const { v4: uuidv4 } = require('uuid');

const outfitGenerationController = {
    // Generate outfits based on filters
    generateOutfits: async (req, res) => {
        try {
            const { 
                eventType, 
                colors, 
                style, 
                useOwnedOnly, 
                budget, 
                weather 
            } = req.body;
            const userId = req.user.id;

            let query = `
                SELECT ci.* FROM clothing_items ci 
                WHERE ci.user_id = $1
            `;
            let params = [userId];
            let paramCount = 1;

            // Add filters
            if (colors && colors.length > 0) {
                paramCount++;
                query += ` AND ci.color = ANY($${paramCount})`;
                params.push(colors);
            }

            if (style) {
                paramCount++;
                query += ` AND ci.style = $${paramCount}`;
                params.push(style);
            }

            if (useOwnedOnly) {
                // Only use owned clothing
                query += ` AND ci.user_id = $1`;
            }

            const result = await pool.query(query, params);
            const availableItems = result.rows;

            // Generate outfit combinations
            const outfits = generateOutfitCombinations(availableItems, {
                eventType,
                budget,
                weather
            });

            res.json({
                success: true,
                outfits: outfits
            });
        } catch (error) {
            console.error('Error generating outfits:', error);
            res.status(500).json({ 
                success: false, 
                message: 'Error generating outfits' 
            });
        }
    },

    // Generate weather-based recommendations
    generateWeatherBasedOutfits: async (req, res) => {
        try {
            const { temperature, conditions, humidity } = req.body;
            const userId = req.user.id;

            // Determine appropriate clothing based on weather
            const weatherRecommendations = getWeatherRecommendations(temperature, conditions, humidity);

            let query = `
                SELECT ci.* FROM clothing_items ci 
                WHERE ci.user_id = $1
            `;
            let params = [userId];

            if (weatherRecommendations.seasons.length > 0) {
                query += ` AND ci.season = ANY($2)`;
                params.push(weatherRecommendations.seasons);
            }

            const result = await pool.query(query, params);
            const availableItems = result.rows;

            // Generate weather-appropriate outfits
            const outfits = generateWeatherBasedCombinations(availableItems, weatherRecommendations);

            res.json({
                success: true,
                outfits: outfits,
                weatherRecommendations: weatherRecommendations
            });
        } catch (error) {
            console.error('Error generating weather-based outfits:', error);
            res.status(500).json({ 
                success: false, 
                message: 'Error generating weather-based outfits' 
            });
        }
    },

    // Get outfit suggestions for specific events
    getEventSuggestions: async (req, res) => {
        try {
            const { eventType } = req.params;
            const userId = req.user.id;

            const eventRecommendations = getEventRecommendations(eventType);

            let query = `
                SELECT ci.* FROM clothing_items ci 
                WHERE ci.user_id = $1
            `;
            let params = [userId];

            if (eventRecommendations.occasions.length > 0) {
                query += ` AND ci.occasion = ANY($2)`;
                params.push(eventRecommendations.occasions);
            }

            const result = await pool.query(query, params);
            const availableItems = result.rows;

            const outfits = generateEventBasedCombinations(availableItems, eventRecommendations);

            res.json({
                success: true,
                outfits: outfits,
                eventRecommendations: eventRecommendations
            });
        } catch (error) {
            console.error('Error getting event suggestions:', error);
            res.status(500).json({ 
                success: false, 
                message: 'Error getting event suggestions' 
            });
        }
    }
};

// Helper functions
function generateOutfitCombinations(items, filters) {
    const outfits = [];
    const categories = {
        tops: items.filter(item => ['Shirt', 'T-Shirt', 'Sweater', 'Blouse'].includes(item.type)),
        bottoms: items.filter(item => ['Pants', 'Jeans', 'Shorts', 'Skirt'].includes(item.type)),
        outerwear: items.filter(item => ['Jacket', 'Coat', 'Blazer'].includes(item.type)),
        shoes: items.filter(item => ['Shoes', 'Boots', 'Sneakers'].includes(item.type)),
        accessories: items.filter(item => ['Accessory'].includes(item.type))
    };

    // Generate combinations
    for (let i = 0; i < 10; i++) { // Generate 10 outfit suggestions
        const outfit = {
            id: uuidv4(),
            name: `Generated Outfit ${i + 1}`,
            items: [],
            totalPrice: 0,
            style: [],
            colors: [],
            estimatedCost: 0
        };

        // Add one item from each category if available
        if (categories.tops.length > 0) {
            const top = categories.tops[Math.floor(Math.random() * categories.tops.length)];
            outfit.items.push(top);
            outfit.totalPrice += top.price || 0;
            if (top.color) outfit.colors.push(top.color);
            if (top.style) outfit.style.push(top.style);
        }

        if (categories.bottoms.length > 0) {
            const bottom = categories.bottoms[Math.floor(Math.random() * categories.bottoms.length)];
            outfit.items.push(bottom);
            outfit.totalPrice += bottom.price || 0;
            if (bottom.color) outfit.colors.push(bottom.color);
            if (bottom.style) outfit.style.push(bottom.style);
        }

        if (categories.shoes.length > 0) {
            const shoes = categories.shoes[Math.floor(Math.random() * categories.shoes.length)];
            outfit.items.push(shoes);
            outfit.totalPrice += shoes.price || 0;
            if (shoes.color) outfit.colors.push(shoes.color);
            if (shoes.style) outfit.style.push(shoes.style);
        }

        // Add accessories randomly
        if (categories.accessories.length > 0 && Math.random() > 0.5) {
            const accessory = categories.accessories[Math.floor(Math.random() * categories.accessories.length)];
            outfit.items.push(accessory);
            outfit.totalPrice += accessory.price || 0;
        }

        outfit.estimatedCost = outfit.totalPrice;
        outfits.push(outfit);
    }

    return outfits;
}

function getWeatherRecommendations(temperature, conditions, humidity) {
    const recommendations = {
        seasons: [],
        styles: [],
        occasions: []
    };

    if (temperature < 10) {
        recommendations.seasons = ['Winter', 'Fall'];
        recommendations.styles = ['Warm', 'Layered'];
        recommendations.occasions = ['Casual', 'Formal'];
    } else if (temperature < 20) {
        recommendations.seasons = ['Spring', 'Fall'];
        recommendations.styles = ['Casual', 'Smart Casual'];
        recommendations.occasions = ['Casual', 'Business'];
    } else {
        recommendations.seasons = ['Summer', 'Spring'];
        recommendations.styles = ['Light', 'Casual'];
        recommendations.occasions = ['Casual', 'Sport'];
    }

    if (conditions === 'rainy') {
        recommendations.styles.push('Waterproof');
    }

    return recommendations;
}

function generateWeatherBasedCombinations(items, weatherRecs) {
    const filteredItems = items.filter(item => 
        weatherRecs.seasons.includes(item.season) ||
        weatherRecs.styles.includes(item.style)
    );

    return generateOutfitCombinations(filteredItems, {});
}

function getEventRecommendations(eventType) {
    const recommendations = {
        occasions: [],
        styles: [],
        colors: []
    };

    switch (eventType.toLowerCase()) {
        case 'formal':
            recommendations.occasions = ['Formal', 'Business'];
            recommendations.styles = ['Elegant', 'Professional'];
            break;
        case 'casual':
            recommendations.occasions = ['Casual', 'Weekend'];
            recommendations.styles = ['Comfortable', 'Relaxed'];
            break;
        case 'business':
            recommendations.occasions = ['Business', 'Formal'];
            recommendations.styles = ['Professional', 'Smart'];
            break;
        case 'sport':
            recommendations.occasions = ['Sport', 'Casual'];
            recommendations.styles = ['Athletic', 'Comfortable'];
            break;
        case 'evening':
            recommendations.occasions = ['Evening', 'Formal'];
            recommendations.styles = ['Elegant', 'Sophisticated'];
            break;
        default:
            recommendations.occasions = ['Casual'];
            recommendations.styles = ['Comfortable'];
    }

    return recommendations;
}

function generateEventBasedCombinations(items, eventRecs) {
    const filteredItems = items.filter(item => 
        eventRecs.occasions.includes(item.occasion) ||
        eventRecs.styles.includes(item.style)
    );

    return generateOutfitCombinations(filteredItems, {});
}

module.exports = outfitGenerationController; 