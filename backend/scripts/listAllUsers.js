const pool = require('../db');

async function listAllUsers() {
    try {
        console.log('👥 Listing all users...\n');
        
        const result = await pool.query(`
            SELECT id, email, username, role, created_at
            FROM users
            ORDER BY created_at DESC
        `);
        
        console.log(`📊 Total users: ${result.rows.length}\n`);
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        
        // Known passwords from creation scripts
        const knownPasswords = {
            'kitty@gmail.com': 'password1234',
            'hiro@gmail.com': 'password123',
            'hiro@example.com': 'password123',
            'sarah@example.com': 'password123',
            'mike@example.com': 'password123',
            'emma@example.com': 'password123',
            'alex@example.com': 'password123',
            'jessica@example.com': 'password123',
            'test@example.com': 'password'
        };
        
        result.rows.forEach((user, index) => {
            const password = knownPasswords[user.email] || '(unknown - check your scripts)';
            console.log(`\n${index + 1}. ${user.username}`);
            console.log(`   📧 Email: ${user.email}`);
            console.log(`   🔑 Password: ${password}`);
            console.log(`   👤 Role: ${user.role}`);
            console.log(`   📅 Created: ${user.created_at}`);
            console.log(`   🆔 ID: ${user.id}`);
        });
        
        console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log(`\n✅ Total: ${result.rows.length} users\n`);
        
    } catch (error) {
        console.error('❌ Error listing users:', error);
        console.error('Error details:', error.message);
    } finally {
        await pool.end();
    }
}

// Run the script
listAllUsers();

