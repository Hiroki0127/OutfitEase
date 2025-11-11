const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const uploadRoutes = require('./routes/upload');
// Load env variables
dotenv.config();

const app = express();

// Middlewares
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// Routes
app.get('/', (req, res) => {
  res.send('Welcome to the OutfitEase API!');
});

app.use('/auth', require('./routes/auth'));
app.use('/clothes', require('./routes/clothes'));
app.use('/outfits', require('./routes/outfits'));
app.use('/planning', require('./routes/outfitPlanning')); 
app.use('/posts', require('./routes/posts'));
app.use('/likes', require('./routes/likes'));
app.use('/saved-outfits', require('./routes/savedOutfits'));
app.use('/comments', require('./routes/comments'));
app.use('/upload', uploadRoutes);
app.use('/follow', require('./routes/follow'));
app.use('/users', require('./routes/users'));

// New feature routes
app.use('/outfit-generation', require('./routes/outfitGeneration'));
app.use('/weather', require('./routes/weather'));

const PORT = process.env.PORT || 3000;
const server = app.listen(PORT, () => {
  console.log(`🚀 Server is running on port ${PORT}`);
});
module.exports = server;