const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL || 'postgresql://localhost:5432/outfitease'
});

async function setupTestData() {
    try {
        console.log('Setting up test data...');
        
        // Create test user
        const testUser = await pool.query(`
            INSERT INTO users (email, username, password_hash, role) 
            VALUES ($1, $2, $3, $4) 
            ON CONFLICT (email) DO UPDATE SET username = EXCLUDED.username
            RETURNING id, email, username
        `, [
            'test@example.com',
            'testuser',
            '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', // password: 'password'
            'user'
        ]);
        
        console.log('Test user created:', testUser.rows[0]);
        
        // Create test clothing items
        const clothingItems = [
            {
                name: 'Blue T-Shirt',
                type: 'Shirt',
                color: 'Blue',
                style: 'Casual',
                brand: 'Nike',
                price: 25.00,
                season: 'Summer',
                occasion: 'Casual'
            },
            {
                name: 'Black Jeans',
                type: 'Pants',
                color: 'Black',
                style: 'Casual',
                brand: 'Levi\'s',
                price: 80.00,
                season: 'All Season',
                occasion: 'Casual'
            },
            {
                name: 'White Sneakers',
                type: 'Shoes',
                color: 'White',
                style: 'Casual',
                brand: 'Adidas',
                price: 120.00,
                season: 'All Season',
                occasion: 'Casual'
            },
            {
                name: 'Red Dress',
                type: 'Dress',
                color: 'Red',
                style: 'Formal',
                brand: 'Zara',
                price: 150.00,
                season: 'Spring',
                occasion: 'Evening'
            }
        ];
        
        for (const item of clothingItems) {
            await pool.query(`
                INSERT INTO clothing_items (user_id, name, type, color, style, brand, price, season, occasion)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
            `, [
                testUser.rows[0].id,
                item.name,
                item.type,
                item.color,
                item.style,
                item.brand,
                item.price,
                item.season,
                item.occasion
            ]);
        }
        
        console.log('Test clothing items created');
        
        // Create test outfits
        const outfits = [
            {
                name: 'Casual Weekend Look',
                description: 'Perfect for weekend activities',
                totalPrice: 225.00,
                style: ['Casual', 'Streetwear'],
                color: ['Blue', 'Black', 'White'],
                brand: ['Nike', 'Levi\'s', 'Adidas'],
                season: ['Summer', 'All Season'],
                occasion: ['Casual', 'Weekend']
            },
            {
                name: 'Evening Outfit',
                description: 'Elegant dress for special occasions',
                totalPrice: 150.00,
                style: ['Formal', 'Elegant'],
                color: ['Red'],
                brand: ['Zara'],
                season: ['Spring'],
                occasion: ['Evening', 'Formal']
            }
        ];
        
        for (const outfit of outfits) {
            await pool.query(`
                INSERT INTO outfits (user_id, name, description, total_price, style, color, brand, season, occasion)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
            `, [
                testUser.rows[0].id,
                outfit.name,
                outfit.description,
                outfit.totalPrice,
                outfit.style,
                outfit.color,
                outfit.brand,
                outfit.season,
                outfit.occasion
            ]);
        }
        
        console.log('Test outfits created');
        
        // Create test posts
        const posts = [
            {
                caption: 'My new casual weekend outfit! Perfect for hanging out with friends.',
                likeCount: 5,
                commentCount: 2,
                isLiked: false
            },
            {
                caption: 'Elegant evening look for tonight\'s dinner party.',
                likeCount: 12,
                commentCount: 4,
                isLiked: true
            }
        ];
        
        for (const post of posts) {
            await pool.query(`
                INSERT INTO posts (user_id, caption)
                VALUES ($1, $2)
            `, [
                testUser.rows[0].id,
                post.caption
            ]);
        }
        
        console.log('Test posts created');
        console.log('\n✅ Test data setup complete!');
        console.log('\nTest User Credentials:');
        console.log('Email: test@example.com');
        console.log('Password: password');
        
    } catch (error) {
        console.error('Error setting up test data:', error);
        console.error('Full error details:', error.message);
    } finally {
        await pool.end();
    }
}

setupTestData(); 