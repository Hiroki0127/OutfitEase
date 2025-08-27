const db = require('../db');

exports.getAllForUser = async (userId) => {
  const res = await db.query(`
    SELECT p.id, p.user_id, p.outfit_id, p.planned_date, p.title,
           o.name, o.description, o.style, o.color, o.brand, o.season, o.occasion, o.total_price, o.image_url
    FROM outfit_planning p
    JOIN outfits o ON o.id = p.outfit_id
    WHERE p.user_id = $1
    ORDER BY p.planned_date
  `, [userId]);
  return res.rows;
};

exports.create = async (userId, outfitId, plannedDate, title) => {
  const res = await db.query(`
    INSERT INTO outfit_planning (user_id, outfit_id, planned_date, title)
    VALUES ($1, $2, $3, $4) RETURNING id, user_id, outfit_id, planned_date, title
  `, [userId, outfitId, plannedDate, title]);
  return res.rows[0];
};

exports.remove = async (id, userId) => {
  await db.query(`
    DELETE FROM outfit_planning WHERE id = $1 AND user_id = $2
  `, [id, userId]);
};
