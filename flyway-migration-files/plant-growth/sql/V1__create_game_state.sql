CREATE TABLE game_state (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  game_id UUID NOT NULL,
  scene_id VARCHAR(100) NOT NULL,
  -- json cho toàn màn hình
  state JSONB NOT NULL,
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, game_id)
);

CREATE INDEX idx_game_state_user_game ON game_state(user_id, game_id);