const jwt = require('jsonwebtoken');
const secret = process.env.JWT_SECRET;

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  //console.log('Authorization Header:', authHeader);

  const token = authHeader && authHeader.split(' ')[1];
  //console.log('Extracted Token:', token);

  if (!token) {
    console.log('No token provided');
    return res.status(401).json({ error: 'Token required' });
  }

  jwt.verify(token, secret, (err, user) => {
    if (err) {
      console.log('Token verification error:', err.message);
      return res.status(401).json({ error: 'Invalid token' });
    }

    console.log('Authenticated user:', user);
    req.user = user;
    next();
  });
}

module.exports = authenticateToken;


