const pool = require('../db');
const bcrypt = require('bcryptjs');

async function populateCommunityPosts() {
    try {
        console.log('👥 Creating community posts from multiple users...\n');

        // Create or get multiple users
        const usersData = [
            { email: 'sarah@example.com', username: 'sarah_fashion', password: 'password123' },
            { email: 'mike@example.com', username: 'mike_style', password: 'password123' },
            { email: 'emma@example.com', username: 'emma_trends', password: 'password123' },
            { email: 'alex@example.com', username: 'alex_outfits', password: 'password123' },
            { email: 'jessica@example.com', username: 'jessica_chic', password: 'password123' }
        ];

        const createdUsers = [];
        
        for (const userData of usersData) {
            let userResult = await pool.query('SELECT id, email, username FROM users WHERE email = $1', [userData.email]);
            let userId;
            
            if (userResult.rows.length === 0) {
                // Create new user
                const hashedPassword = await bcrypt.hash(userData.password, 10);
                const newUser = await pool.query(`
                    INSERT INTO users (email, username, password_hash, role) 
                    VALUES ($1, $2, $3, $4) 
                    RETURNING id, email, username
                `, [userData.email, userData.username, hashedPassword, 'user']);
                userId = newUser.rows[0].id;
                createdUsers.push({ id: userId, ...userData });
                console.log(`✅ Created user: ${userData.username}`);
            } else {
                userId = userResult.rows[0].id;
                createdUsers.push({ id: userId, ...userResult.rows[0] });
                console.log(`✅ Using existing user: ${userResult.rows[0].username}`);
            }
        }

        console.log(`\n📦 Creating outfits and posts for ${createdUsers.length} users...\n`);

        // Create outfits and posts for each user
        for (let i = 0; i < createdUsers.length; i++) {
            const user = createdUsers[i];
            console.log(`\n👤 Creating data for ${user.username}...`);

            // Create some clothing items for this user
            const clothingItems = [
                {
                    name: `${user.username.charAt(0).toUpperCase() + user.username.slice(1)}'s Classic White Shirt`,
                    type: 'Shirt',
                    color: 'White',
                    style: 'Classic',
                    brand: 'Zara',
                    price: 45.00 + (i * 5),
                    season: 'All Season',
                    occasion: 'Casual'
                },
                {
                    name: `${user.username.charAt(0).toUpperCase() + user.username.slice(1)}'s Blue Jeans`,
                    type: 'Pants',
                    color: 'Blue',
                    style: 'Casual',
                    brand: 'Levi\'s',
                    price: 89.99 + (i * 5),
                    season: 'All Season',
                    occasion: 'Casual'
                },
                {
                    name: `${user.username.charAt(0).toUpperCase() + user.username.slice(1)}'s Black Boots`,
                    type: 'Shoes',
                    color: 'Black',
                    style: 'Classic',
                    brand: 'Dr. Martens',
                    price: 120.00 + (i * 10),
                    season: 'Fall',
                    occasion: 'Casual'
                }
            ];

            const createdClothing = [];
            for (const item of clothingItems) {
                const result = await pool.query(`
                    INSERT INTO clothing_items (user_id, name, type, color, style, brand, price, season, occasion)
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
                    RETURNING id, name
                `, [
                    user.id,
                    item.name,
                    item.type,
                    item.color,
                    item.style,
                    item.brand,
                    item.price,
                    item.season,
                    item.occasion
                ]);
                createdClothing.push(result.rows[0]);
            }

            // Create an outfit
            const outfitResult = await pool.query(`
                INSERT INTO outfits (user_id, name, description, total_price, style, color, brand, season, occasion)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
                RETURNING id, name
            `, [
                user.id,
                `${user.username}'s Casual Look`,
                `A stylish casual outfit put together by ${user.username}`,
                255.99 + (i * 10),
                ['Casual', 'Classic'],
                ['White', 'Blue', 'Black'],
                ['Zara', 'Levi\'s', 'Dr. Martens'],
                ['All Season', 'Fall'],
                ['Casual']
            ]);

            const outfitId = outfitResult.rows[0].id;

            // Link clothing items to outfit
            for (const clothing of createdClothing) {
                await pool.query(`
                    INSERT INTO outfit_items (outfit_id, clothing_item_id)
                    VALUES ($1, $2)
                `, [outfitId, clothing.id]);
            }

            // Create 2 posts for each user
            const postCaptions = [
                `Love this casual look! Perfect for a day out with friends. ${user.username.charAt(0).toUpperCase() + user.username.slice(1)}'s style is always on point! ✨`,
                `Just tried this new combination and I'm obsessed! The colors work so well together. What do you think? 💕`
            ];

            for (const caption of postCaptions) {
                await pool.query(`
                    INSERT INTO posts (user_id, outfit_id, caption)
                    VALUES ($1, $2, $3)
                `, [user.id, outfitId, caption]);
            }

            console.log(`  ✓ Created ${createdClothing.length} clothing items`);
            console.log(`  ✓ Created 1 outfit`);
            console.log(`  ✓ Created 2 posts`);
        }

        // Summary
        console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('✅ Community posts created successfully!\n');
        console.log('📊 Summary:');
        console.log(`   👥 Users: ${createdUsers.length}`);
        console.log(`   👔 Clothing Items: ${createdUsers.length * 3}`);
        console.log(`   👗 Outfits: ${createdUsers.length}`);
        console.log(`   📸 Posts: ${createdUsers.length * 2}`);
        console.log('\n👥 Created Users:');
        createdUsers.forEach(user => {
            console.log(`   - ${user.username} (${user.email}) - password: password123`);
        });
        console.log('\n🎯 You can now:');
        console.log('   - See posts from all users in the community feed');
        console.log('   - Test the community features');
        console.log('   - Login with any user to see their posts');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    } catch (error) {
        console.error('❌ Error populating community posts:', error);
        console.error('Error details:', error.message);
        console.error('Stack:', error.stack);
    } finally {
        await pool.end();
    }
}

// Run the script
populateCommunityPosts();

