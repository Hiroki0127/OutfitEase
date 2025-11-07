const pool = require('../db');
const bcrypt = require('bcryptjs');

async function populateSampleData() {
    try {
        console.log('🎨 Starting to populate sample data...\n');

        // Get or create a test user
        let userResult = await pool.query('SELECT id, email, username FROM users WHERE email = $1', ['kitty@gmail.com']);
        let userId;
        
        if (userResult.rows.length === 0) {
            // Create a new user if kitty doesn't exist
            const hashedPassword = await bcrypt.hash('password1234', 10);
            const newUser = await pool.query(`
                INSERT INTO users (email, username, password_hash, role) 
                VALUES ($1, $2, $3, $4) 
                RETURNING id, email, username
            `, ['kitty@gmail.com', 'kittychan', hashedPassword, 'user']);
            userId = newUser.rows[0].id;
            console.log('✅ Created user: kitty@gmail.com');
        } else {
            userId = userResult.rows[0].id;
            console.log(`✅ Using existing user: ${userResult.rows[0].username} (${userResult.rows[0].email})`);
        }

        // Clear existing data for this user (optional - comment out if you want to keep existing data)
        console.log('\n🧹 Cleaning up existing data...');
        await pool.query('DELETE FROM outfit_planning WHERE user_id = $1', [userId]);
        await pool.query('DELETE FROM outfit_items WHERE outfit_id IN (SELECT id FROM outfits WHERE user_id = $1)', [userId]);
        await pool.query('DELETE FROM posts WHERE user_id = $1', [userId]);
        await pool.query('DELETE FROM outfits WHERE user_id = $1', [userId]);
        await pool.query('DELETE FROM clothing_items WHERE user_id = $1', [userId]);
        console.log('✅ Cleaned up existing data\n');

        // 1. Create Clothing Items
        console.log('👔 Creating clothing items...');
        const clothingItems = [
            {
                name: 'Classic White Button-Down Shirt',
                type: 'Shirt',
                color: 'White',
                style: 'Classic',
                brand: 'Ralph Lauren',
                price: 89.99,
                season: 'All Season',
                occasion: 'Business',
                image_url: null
            },
            {
                name: 'Dark Navy Blazer',
                type: 'Blazer',
                color: 'Navy',
                style: 'Formal',
                brand: 'J.Crew',
                price: 199.99,
                season: 'All Season',
                occasion: 'Business',
                image_url: null
            },
            {
                name: 'Slim Fit Black Jeans',
                type: 'Pants',
                color: 'Black',
                style: 'Casual',
                brand: 'Levi\'s',
                price: 79.99,
                season: 'All Season',
                occasion: 'Casual',
                image_url: null
            },
            {
                name: 'White Canvas Sneakers',
                type: 'Shoes',
                color: 'White',
                style: 'Casual',
                brand: 'Converse',
                price: 55.00,
                season: 'All Season',
                occasion: 'Casual',
                image_url: null
            },
            {
                name: 'Floral Summer Dress',
                type: 'Dress',
                color: 'Pink',
                style: 'Boho',
                brand: 'Free People',
                price: 128.00,
                season: 'Summer',
                occasion: 'Casual',
                image_url: null
            },
            {
                name: 'Brown Leather Ankle Boots',
                type: 'Shoes',
                color: 'Brown',
                style: 'Classic',
                brand: 'Clarks',
                price: 149.99,
                season: 'Fall',
                occasion: 'Casual',
                image_url: null
            },
            {
                name: 'Gray Cashmere Sweater',
                type: 'Sweater',
                color: 'Gray',
                style: 'Classic',
                brand: 'Everlane',
                price: 98.00,
                season: 'Winter',
                occasion: 'Casual',
                image_url: null
            },
            {
                name: 'Black Leather Jacket',
                type: 'Jacket',
                color: 'Black',
                style: 'Edgy',
                brand: 'AllSaints',
                price: 450.00,
                season: 'Fall',
                occasion: 'Casual',
                image_url: null
            },
            {
                name: 'Khaki Chinos',
                type: 'Pants',
                color: 'Khaki',
                style: 'Casual',
                brand: 'Banana Republic',
                price: 69.99,
                season: 'All Season',
                occasion: 'Business Casual',
                image_url: null
            },
            {
                name: 'Red Floral Blouse',
                type: 'Shirt',
                color: 'Red',
                style: 'Feminine',
                brand: 'Anthropologie',
                price: 78.00,
                season: 'Spring',
                occasion: 'Casual',
                image_url: null
            }
        ];

        const createdClothing = [];
        for (const item of clothingItems) {
            const result = await pool.query(`
                INSERT INTO clothing_items (user_id, name, type, color, style, brand, price, season, occasion, image_url)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
                RETURNING id, name
            `, [
                userId,
                item.name,
                item.type,
                item.color,
                item.style,
                item.brand,
                item.price,
                item.season,
                item.occasion,
                item.image_url
            ]);
            createdClothing.push(result.rows[0]);
            console.log(`  ✓ ${result.rows[0].name}`);
        }
        console.log(`✅ Created ${createdClothing.length} clothing items\n`);

        // 2. Create Outfits
        console.log('👗 Creating outfits...');
        const outfits = [
            {
                name: 'Smart Casual Office',
                description: 'Professional yet comfortable for the office',
                total_price: 289.98,
                style: ['Classic', 'Business'],
                color: ['White', 'Navy', 'Black'],
                brand: ['Ralph Lauren', 'J.Crew', 'Levi\'s'],
                season: ['All Season'],
                occasion: ['Business'],
                clothing_ids: [0, 1, 2] // White shirt, Navy blazer, Black jeans
            },
            {
                name: 'Weekend Casual',
                description: 'Comfortable and stylish for weekend outings',
                total_price: 134.99,
                style: ['Casual'],
                color: ['Black', 'White'],
                brand: ['Levi\'s', 'Converse'],
                season: ['All Season'],
                occasion: ['Casual'],
                clothing_ids: [2, 3] // Black jeans, White sneakers
            },
            {
                name: 'Summer Garden Party',
                description: 'Beautiful floral dress for summer events',
                total_price: 128.00,
                style: ['Boho', 'Feminine'],
                color: ['Pink'],
                brand: ['Free People'],
                season: ['Summer'],
                occasion: ['Casual'],
                clothing_ids: [4] // Floral dress
            },
            {
                name: 'Fall Evening Look',
                description: 'Stylish outfit for fall evenings',
                total_price: 599.98,
                style: ['Edgy', 'Classic'],
                color: ['Black', 'Brown'],
                brand: ['AllSaints', 'Clarks'],
                season: ['Fall'],
                occasion: ['Casual'],
                clothing_ids: [7, 5] // Leather jacket, Brown boots
            },
            {
                name: 'Winter Cozy',
                description: 'Warm and comfortable winter outfit',
                total_price: 167.99,
                style: ['Classic', 'Casual'],
                color: ['Gray', 'Khaki'],
                brand: ['Everlane', 'Banana Republic'],
                season: ['Winter'],
                occasion: ['Casual'],
                clothing_ids: [6, 8] // Gray sweater, Khaki chinos
            }
        ];

        const createdOutfits = [];
        for (const outfit of outfits) {
            const result = await pool.query(`
                INSERT INTO outfits (user_id, name, description, total_price, style, color, brand, season, occasion)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
                RETURNING id, name
            `, [
                userId,
                outfit.name,
                outfit.description,
                outfit.total_price,
                outfit.style,
                outfit.color,
                outfit.brand,
                outfit.season,
                outfit.occasion
            ]);
            
            const outfitId = result.rows[0].id;
            
            // Link clothing items to outfit
            for (const clothingIndex of outfit.clothing_ids) {
                await pool.query(`
                    INSERT INTO outfit_items (outfit_id, clothing_item_id)
                    VALUES ($1, $2)
                `, [outfitId, createdClothing[clothingIndex].id]);
            }
            
            createdOutfits.push({ id: outfitId, name: result.rows[0].name });
            console.log(`  ✓ ${result.rows[0].name}`);
        }
        console.log(`✅ Created ${createdOutfits.length} outfits\n`);

        // 3. Create Outfit Plans
        console.log('📅 Creating outfit plans...');
        const today = new Date();
        const plans = [
            {
                outfit_id: createdOutfits[0].id, // Smart Casual Office
                planned_date: new Date(today.getTime() + 1 * 24 * 60 * 60 * 1000) // Tomorrow
            },
            {
                outfit_id: createdOutfits[1].id, // Weekend Casual
                planned_date: new Date(today.getTime() + 6 * 24 * 60 * 60 * 1000) // Next Saturday
            },
            {
                outfit_id: createdOutfits[2].id, // Summer Garden Party
                planned_date: new Date(today.getTime() + 10 * 24 * 60 * 60 * 1000) // 10 days from now
            },
            {
                outfit_id: createdOutfits[3].id, // Fall Evening Look
                planned_date: new Date(today.getTime() + 3 * 24 * 60 * 60 * 1000) // 3 days from now
            }
        ];

        for (const plan of plans) {
            await pool.query(`
                INSERT INTO outfit_planning (user_id, outfit_id, planned_date)
                VALUES ($1, $2, $3)
            `, [userId, plan.outfit_id, plan.planned_date]);
            console.log(`  ✓ Planned outfit for ${plan.planned_date.toISOString().split('T')[0]}`);
        }
        console.log(`✅ Created ${plans.length} outfit plans\n`);

        // 4. Create Posts
        console.log('📸 Creating posts...');
        const posts = [
            {
                outfit_id: createdOutfits[0].id,
                caption: 'My go-to office look! Professional but comfortable. Perfect for those long work days. 💼✨'
            },
            {
                outfit_id: createdOutfits[1].id,
                caption: 'Weekend vibes! Love how comfortable this outfit is while still looking put together. Casual but chic! ☀️'
            },
            {
                outfit_id: createdOutfits[2].id,
                caption: 'Summer garden party outfit! This floral dress is one of my favorites. Perfect for warm weather events. 🌸🌺'
            },
            {
                outfit_id: createdOutfits[3].id,
                caption: 'Fall evening outfit! The leather jacket and boots combo never goes out of style. 🍂🍁'
            }
        ];

        const createdPosts = [];
        for (const post of posts) {
            const result = await pool.query(`
                INSERT INTO posts (user_id, outfit_id, caption)
                VALUES ($1, $2, $3)
                RETURNING id, caption
            `, [userId, post.outfit_id, post.caption]);
            createdPosts.push(result.rows[0]);
            console.log(`  ✓ Post: "${post.caption.substring(0, 50)}..."`);
        }
        console.log(`✅ Created ${createdPosts.length} posts\n`);

        // Summary
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('✅ Sample data populated successfully!\n');
        console.log('📊 Summary:');
        console.log(`   👔 Clothing Items: ${createdClothing.length}`);
        console.log(`   👗 Outfits: ${createdOutfits.length}`);
        console.log(`   📅 Outfit Plans: ${plans.length}`);
        console.log(`   📸 Posts: ${createdPosts.length}`);
        console.log('\n🎯 You can now:');
        console.log('   - View your wardrobe in the app');
        console.log('   - See your outfits');
        console.log('   - Check your outfit calendar plans');
        console.log('   - Browse community posts');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    } catch (error) {
        console.error('❌ Error populating sample data:', error);
        console.error('Error details:', error.message);
        console.error('Stack:', error.stack);
    } finally {
        await pool.end();
    }
}

// Run the script
populateSampleData();

