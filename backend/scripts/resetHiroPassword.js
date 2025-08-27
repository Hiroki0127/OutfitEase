const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL || 'postgresql://localhost:5432/outfitease'
});

async function resetHiroPassword() {
    try {
        console.log('Resetting password for hiro@example.com...');
        
        // Hash the new password
        const saltRounds = 10;
        const newPassword = 'password123';
        const hashedPassword = await bcrypt.hash(newPassword, saltRounds);
        
        // Update the user's password
        const result = await pool.query(`
            UPDATE users 
            SET password_hash = $1
            WHERE email = 'hiro@example.com'
            RETURNING id, email, username
        `, [hashedPassword]);
        
        if (result.rows.length > 0) {
            console.log('✅ Password reset successful!');
            console.log('User:', result.rows[0]);
            console.log('New credentials:');
            console.log('Email: hiro@example.com');
            console.log('Password: password123');
        } else {
            console.log('❌ User hiro@example.com not found');
        }
        
    } catch (error) {
        console.error('Error resetting password:', error);
    } finally {
        await pool.end();
    }
}

resetHiroPassword();
