const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL || 'postgresql://localhost:5432/outfitease'
});

async function addMockPosts() {
    try {
        console.log('Adding mock users and posts for community testing...');
        
        // Create multiple mock users
        const mockUsers = [
            {
                email: 'sarah@example.com',
                username: 'sarah_fashion',
                password: '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi' // password: 'password'
            },
            {
                email: 'mike@example.com',
                username: 'mike_style',
                password: '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi' // password: 'password'
            },
            {
                email: 'emma@example.com',
                username: 'emma_trends',
                password: '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi' // password: 'password'
            },
            {
                email: 'alex@example.com',
                username: 'alex_outfits',
                password: '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi' // password: 'password'
            }
        ];
        
        const createdUsers = [];
        
        for (const user of mockUsers) {
            const result = await pool.query(`
                INSERT INTO users (email, username, password_hash, role) 
                VALUES ($1, $2, $3, $4) 
                ON CONFLICT (email) DO UPDATE SET username = EXCLUDED.username
                RETURNING id, email, username
            `, [
                user.email,
                user.username,
                user.password,
                'user'
            ]);
            
            createdUsers.push(result.rows[0]);
            console.log(`Created user: ${result.rows[0].username}`);
        }
        
        // Create mock outfits for each user
        const mockOutfits = [
            {
                name: 'Summer Beach Vibes',
                description: 'Perfect for a day at the beach with friends!',
                totalPrice: 89.99,
                style: ['Casual', 'Summer'],
                color: ['White', 'Blue'],
                brand: ['H&M', 'Nike'],
                season: ['Summer'],
                occasion: ['Casual', 'Beach'],
                imageURL: 'https://res.cloudinary.com/dloz83z8m/image/upload/v1756044960/outfitease/beach_outfit.jpg'
            },
            {
                name: 'Office Professional',
                description: 'Clean and professional look for the workplace',
                totalPrice: 245.00,
                style: ['Professional', 'Business'],
                color: ['Black', 'Gray'],
                brand: ['Banana Republic', 'Cole Haan'],
                season: ['All Season'],
                occasion: ['Work', 'Professional'],
                imageURL: 'https://res.cloudinary.com/dloz83z8m/image/upload/v1756044960/outfitease/office_outfit.jpg'
            },
            {
                name: 'Weekend Brunch',
                description: 'Comfortable yet stylish for weekend brunches',
                totalPrice: 156.50,
                style: ['Casual', 'Trendy'],
                color: ['Pink', 'White'],
                brand: ['Zara', 'Steve Madden'],
                season: ['Spring', 'Summer'],
                occasion: ['Casual', 'Brunch'],
                imageURL: 'https://res.cloudinary.com/dloz83z8m/image/upload/v1756044960/outfitease/brunch_outfit.jpg'
            },
            {
                name: 'Evening Cocktail',
                description: 'Elegant outfit for evening events and parties',
                totalPrice: 320.00,
                style: ['Elegant', 'Formal'],
                color: ['Black', 'Gold'],
                brand: ['Macy\'s', 'Nine West'],
                season: ['All Season'],
                occasion: ['Evening', 'Party'],
                imageURL: 'https://res.cloudinary.com/dloz83z8m/image/upload/v1756044960/outfitease/evening_outfit.jpg'
            }
        ];
        
        const createdOutfits = [];
        
        for (let i = 0; i < mockOutfits.length; i++) {
            const outfit = mockOutfits[i];
            const userId = createdUsers[i].id;
            
            const result = await pool.query(`
                INSERT INTO outfits (user_id, name, description, total_price, style, color, brand, season, occasion, image_url)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
                RETURNING id, name
            `, [
                userId,
                outfit.name,
                outfit.description,
                outfit.totalPrice,
                outfit.style,
                outfit.color,
                outfit.brand,
                outfit.season,
                outfit.occasion,
                outfit.imageURL
            ]);
            
            createdOutfits.push(result.rows[0]);
            console.log(`Created outfit: ${result.rows[0].name} for ${createdUsers[i].username}`);
        }
        
        // Create mock posts with different captions and engagement
        const mockPosts = [
            {
                caption: 'Just got this amazing summer outfit! Perfect for beach days 🌊☀️ #summerstyle #beachvibes',
                likeCount: 23,
                commentCount: 5
            },
            {
                caption: 'New office look for the week. Professional but comfortable! 💼 #workwear #professional',
                likeCount: 18,
                commentCount: 3
            },
            {
                caption: 'Weekend brunch outfit! Love how this turned out 🥂 #brunch #weekend #fashion',
                likeCount: 31,
                commentCount: 7
            },
            {
                caption: 'Evening cocktail party outfit. Feeling elegant tonight! ✨ #evening #party #elegant',
                likeCount: 42,
                commentCount: 9
            }
        ];
        
        const createdPosts = [];
        
        for (let i = 0; i < mockPosts.length; i++) {
            const post = mockPosts[i];
            const userId = createdUsers[i].id;
            const outfitId = createdOutfits[i].id;
            
            const result = await pool.query(`
                INSERT INTO posts (user_id, caption, outfit_id, image_url)
                VALUES ($1, $2, $3, $4)
                RETURNING id, caption
            `, [
                userId,
                post.caption,
                outfitId,
                mockOutfits[i].imageURL
            ]);
            
            createdPosts.push(result.rows[0]);
            console.log(`Created post: "${result.rows[0].caption.substring(0, 50)}..." for ${createdUsers[i].username}`);
        }
        
        // Add some random likes to posts (from different users)
        const likeCombinations = [
            { postIndex: 0, userIndex: 1 }, // mike likes sarah's post
            { postIndex: 0, userIndex: 2 }, // emma likes sarah's post
            { postIndex: 1, userIndex: 0 }, // sarah likes mike's post
            { postIndex: 1, userIndex: 3 }, // alex likes mike's post
            { postIndex: 2, userIndex: 0 }, // sarah likes emma's post
            { postIndex: 2, userIndex: 1 }, // mike likes emma's post
            { postIndex: 3, userIndex: 0 }, // sarah likes alex's post
            { postIndex: 3, userIndex: 1 }, // mike likes alex's post
            { postIndex: 3, userIndex: 2 }, // emma likes alex's post
        ];
        
        for (const like of likeCombinations) {
            const postId = createdPosts[like.postIndex].id;
            const userId = createdUsers[like.userIndex].id;
            
            await pool.query(`
                INSERT INTO post_likes (post_id, user_id)
                VALUES ($1, $2)
                ON CONFLICT (post_id, user_id) DO NOTHING
            `, [postId, userId]);
            
            console.log(`${createdUsers[like.userIndex].username} liked ${createdUsers[like.postIndex].username}'s post`);
        }
        
        // Add some comments
        const mockComments = [
            { text: 'Love this outfit! Where did you get it?', userIndex: 1 },
            { text: 'Perfect for summer! 🔥', userIndex: 2 },
            { text: 'Looking professional! 👔', userIndex: 0 },
            { text: 'This is so cute! 💕', userIndex: 3 },
            { text: 'Great choice for brunch!', userIndex: 1 },
            { text: 'Elegant and sophisticated! ✨', userIndex: 2 }
        ];
        
        for (let i = 0; i < mockComments.length; i++) {
            const comment = mockComments[i];
            const postId = createdPosts[i % createdPosts.length].id;
            const userId = createdUsers[comment.userIndex].id;
            
            await pool.query(`
                INSERT INTO post_comments (post_id, user_id, comment)
                VALUES ($1, $2, $3)
            `, [postId, userId, comment.text]);
            
            console.log(`${createdUsers[comment.userIndex].username} commented on a post`);
        }
        
        console.log('\n✅ Mock community data created successfully!');
        console.log('\n📊 Summary:');
        console.log(`- Created ${createdUsers.length} mock users`);
        console.log(`- Created ${createdOutfits.length} mock outfits`);
        console.log(`- Created ${createdPosts.length} mock posts`);
        console.log(`- Added ${likeCombinations.length} likes`);
        console.log(`- Added ${mockComments.length} comments`);
        
        console.log('\n👥 Mock Users:');
        createdUsers.forEach(user => {
            console.log(`- ${user.username} (${user.email})`);
        });
        
        console.log('\n🎯 Test Instructions:');
        console.log('1. Go to Community tab in your iOS app');
        console.log('2. You should see posts from different users');
        console.log('3. Try liking/unliking posts');
        console.log('4. Try viewing post details');
        console.log('5. Test the like functionality in post details view');
        
    } catch (error) {
        console.error('Error adding mock posts:', error);
        console.error('Full error details:', error.message);
    } finally {
        await pool.end();
    }
}

addMockPosts();
