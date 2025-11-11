const pool = require('../db');

const relationships = [
  // Hiro's network
  { follower: 'hiro@example.com', following: 'kitty@gmail.com' },
  { follower: 'hiro@example.com', following: 'sarah@example.com' },
  { follower: 'hiro@example.com', following: 'mike@example.com' },
  { follower: 'hiro@example.com', following: 'emma@example.com' },

  // Kitty's network
  { follower: 'kitty@gmail.com', following: 'hiro@example.com' },
  { follower: 'kitty@gmail.com', following: 'sarah@example.com' },
  { follower: 'kitty@gmail.com', following: 'mike@example.com' },

  // Community users following each other
  { follower: 'sarah@example.com', following: 'mike@example.com' },
  { follower: 'sarah@example.com', following: 'emma@example.com' },
  { follower: 'mike@example.com', following: 'sarah@example.com' },
  { follower: 'mike@example.com', following: 'alex@example.com' },
  { follower: 'emma@example.com', following: 'jessica@example.com' },
  { follower: 'emma@example.com', following: 'sarah@example.com' },
  { follower: 'alex@example.com', following: 'sarah@example.com' },
  { follower: 'alex@example.com', following: 'mike@example.com' },
  { follower: 'jessica@example.com', following: 'alex@example.com' },
  { follower: 'jessica@example.com', following: 'sarah@example.com' },

  // Cross-network connections
  { follower: 'sarah@example.com', following: 'hiro@example.com' },
  { follower: 'mike@example.com', following: 'hiro@example.com' },
  { follower: 'emma@example.com', following: 'hiro@example.com' },
  { follower: 'alex@example.com', following: 'kitty@gmail.com' },
  { follower: 'jessica@example.com', following: 'kitty@gmail.com' },
];

async function populateFollowRelationships() {
  console.log('🔗 Populating follower/following relationships...\n');

  const emails = Array.from(
    new Set(relationships.flatMap(rel => [rel.follower, rel.following]))
  );

  try {
    const { rows } = await pool.query(
      'SELECT id, email, username FROM users WHERE email = ANY($1::text[])',
      [emails]
    );

    const emailToUser = new Map(rows.map(row => [row.email, row]));
    const missingEmails = emails.filter(email => !emailToUser.has(email));

    if (missingEmails.length) {
      console.warn('⚠️ The following emails were not found in the users table:');
      missingEmails.forEach(email => console.warn(`   - ${email}`));
      console.warn('Continuing with available users...\n');
    }

    let inserted = 0;
    let skipped = 0;

    for (const { follower, following } of relationships) {
      const followerUser = emailToUser.get(follower);
      const followingUser = emailToUser.get(following);

      if (!followerUser || !followingUser) {
        skipped++;
        continue;
      }

      if (followerUser.id === followingUser.id) {
        console.warn(`⚠️ Skipping self-follow attempt for ${follower}`);
        skipped++;
        continue;
      }

      await pool.query(
        `INSERT INTO user_followers (follower_id, following_id)
         VALUES ($1, $2)
         ON CONFLICT (follower_id, following_id) DO NOTHING`,
        [followerUser.id, followingUser.id]
      );

      inserted++;
      console.log(`✅ ${followerUser.username} now follows ${followingUser.username}`);
    }

    console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('✅ Follow relationships populated!\n');
    console.log('📊 Summary:');
    console.log(`   ➕ Inserted relationships: ${inserted}`);
    console.log(`   ⚠️ Skipped (missing users/self-follow): ${skipped}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  } catch (error) {
    console.error('❌ Error creating follow relationships:', error);
  } finally {
    await pool.end();
  }
}

populateFollowRelationships();

