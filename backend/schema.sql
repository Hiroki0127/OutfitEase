-- Enable pgcrypto and GIN indexing
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "btree_gin";

-- USERS table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  username TEXT NOT NULL,
  password_hash TEXT NOT NULL,
  avatar_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  role TEXT NOT NULL
);

-- CLOTHING ITEMS table
CREATE TABLE IF NOT EXISTS clothing_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT,
  color TEXT,
  style TEXT,
  brand TEXT,
  price DECIMAL,
  season TEXT,                 -- Optional: e.g. "summer", "winter"
  occasion TEXT,               -- Optional: e.g. "formal", "casual"
  image_url TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for clothing_items filtering
CREATE INDEX IF NOT EXISTS idx_clothing_type ON clothing_items(type);
CREATE INDEX IF NOT EXISTS idx_clothing_color ON clothing_items(color);
CREATE INDEX IF NOT EXISTS idx_clothing_style ON clothing_items(style);
CREATE INDEX IF NOT EXISTS idx_clothing_brand ON clothing_items(brand);
CREATE INDEX IF NOT EXISTS idx_clothing_price ON clothing_items(price);
CREATE INDEX IF NOT EXISTS idx_clothing_season ON clothing_items(season);
CREATE INDEX IF NOT EXISTS idx_clothing_occasion ON clothing_items(occasion);

-- OUTFITS table
CREATE TABLE IF NOT EXISTS outfits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name TEXT,
  description TEXT,
  total_price DECIMAL,
  image_url TEXT,      -- URL for outfit image
  style TEXT[],        -- Now supports multiple styles like ["casual", "streetwear"]
  color TEXT[],
  brand TEXT[],
  season TEXT[],         -- Optional for filtering
  occasion TEXT[],     -- Optional: multiple tags for occasion
  created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for outfits filtering (arrays require GIN)
CREATE INDEX IF NOT EXISTS idx_outfits_style ON outfits USING GIN(style);
CREATE INDEX IF NOT EXISTS idx_outfits_color ON outfits USING GIN(color);
CREATE INDEX IF NOT EXISTS idx_outfits_brand ON outfits USING GIN(brand);
CREATE INDEX IF NOT EXISTS idx_outfits_occasion ON outfits USING GIN(occasion);
CREATE INDEX IF NOT EXISTS idx_outfits_season ON outfits(season);
CREATE INDEX IF NOT EXISTS idx_outfits_total_price ON outfits(total_price);

-- OUTFIT ITEMS join table
CREATE TABLE IF NOT EXISTS outfit_items (
  outfit_id UUID REFERENCES outfits(id) ON DELETE CASCADE,
  clothing_item_id UUID REFERENCES clothing_items(id) ON DELETE CASCADE,
  PRIMARY KEY (outfit_id, clothing_item_id)
);

-- PLANNING table
CREATE TABLE IF NOT EXISTS outfit_planning (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  outfit_id UUID REFERENCES outfits(id),
  planned_date DATE
);

-- POSTS table (community sharing)
CREATE TABLE IF NOT EXISTS posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  outfit_id UUID REFERENCES outfits(id) ON DELETE CASCADE,
  caption TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- POST LIKES table
CREATE TABLE IF NOT EXISTS post_likes (
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  PRIMARY KEY (post_id, user_id)
);

-- POST COMMENTS table
CREATE TABLE IF NOT EXISTS post_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  comment TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- WEATHER DATA table
CREATE TABLE IF NOT EXISTS weather_data (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  location TEXT,
  latitude DECIMAL,
  longitude DECIMAL,
  temperature DECIMAL,
  conditions TEXT,
  humidity INTEGER,
  wind_speed DECIMAL,
  recorded_at TIMESTAMP DEFAULT NOW()
);

-- GENERATED OUTFITS table (for AI-generated outfit suggestions)
CREATE TABLE IF NOT EXISTS generated_outfits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name TEXT,
  description TEXT,
  total_price DECIMAL,
  style TEXT[],
  color TEXT[],
  brand TEXT[],
  season TEXT[],
  occasion TEXT[],
  generation_filters JSONB,    -- Store the filters used to generate this outfit
  is_saved BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- GENERATED OUTFIT ITEMS join table
CREATE TABLE IF NOT EXISTS generated_outfit_items (
  generated_outfit_id UUID REFERENCES generated_outfits(id) ON DELETE CASCADE,
  clothing_item_id UUID REFERENCES clothing_items(id) ON DELETE CASCADE,
  PRIMARY KEY (generated_outfit_id, clothing_item_id)
);

-- USER PREFERENCES table
CREATE TABLE IF NOT EXISTS user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  preferred_styles TEXT[],
  preferred_colors TEXT[],
  preferred_brands TEXT[],
  budget_range TEXT,           -- 'low', 'medium', 'high'
  size_preferences JSONB,      -- Store size preferences for different clothing types
  weather_sensitivity BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- TRENDS table (for tracking current fashion trends)
CREATE TABLE IF NOT EXISTS trends (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  category TEXT,               -- 'color', 'style', 'pattern', 'accessory'
  popularity_score INTEGER DEFAULT 0,
  season TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- USER TREND INTERACTIONS table
CREATE TABLE IF NOT EXISTS user_trend_interactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  trend_id UUID REFERENCES trends(id) ON DELETE CASCADE,
  interaction_type TEXT,       -- 'viewed', 'liked', 'applied'
  created_at TIMESTAMP DEFAULT NOW()
);

-- Saved Outfits table
CREATE TABLE IF NOT EXISTS saved_outfits (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL,
    outfit_id UUID NOT NULL,
    saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, outfit_id)
);

-- Indexes for new tables
CREATE INDEX IF NOT EXISTS idx_weather_data_user ON weather_data(user_id);
CREATE INDEX IF NOT EXISTS idx_generated_outfits_user ON generated_outfits(user_id);
CREATE INDEX IF NOT EXISTS idx_user_preferences_user ON user_preferences(user_id);
CREATE INDEX IF NOT EXISTS idx_trends_category ON trends(category);
CREATE INDEX IF NOT EXISTS idx_trends_active ON trends(is_active);
CREATE INDEX IF NOT EXISTS idx_user_trend_interactions_user ON user_trend_interactions(user_id);
