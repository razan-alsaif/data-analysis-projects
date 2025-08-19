DROP DATABASE IF EXISTS socialdb;
CREATE DATABASE socialdb;
USE socialdb;

CREATE TABLE users (
  user_id       INT AUTO_INCREMENT PRIMARY KEY,
  username      VARCHAR(50)  NOT NULL UNIQUE,
  email         VARCHAR(120) NOT NULL UNIQUE,
  password_hash BINARY(64)   NOT NULL,
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE profiles (
  profile_id  INT AUTO_INCREMENT PRIMARY KEY,
  user_id     INT          NOT NULL,
  full_name   VARCHAR(100) NOT NULL,
  bio         VARCHAR(200),
  location    VARCHAR(100),
  birth_date  DATE,
  created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE tweets (
  tweet_id   INT AUTO_INCREMENT PRIMARY KEY,
  user_id    INT          NOT NULL,
  content    VARCHAR(280) NOT NULL,
  created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE likes (
  like_id   INT AUTO_INCREMENT PRIMARY KEY,
  user_id   INT NOT NULL,
  tweet_id  INT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id)  REFERENCES users(user_id)   ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (tweet_id) REFERENCES tweets(tweet_id) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE KEY uk_like (user_id, tweet_id)
);

CREATE TABLE follows (
  follow_id   INT AUTO_INCREMENT PRIMARY KEY,
  follower_id INT NOT NULL,
  followee_id INT NOT NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (follower_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (followee_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE KEY uk_follow (follower_id, followee_id)
);

INSERT INTO users (username,email,password_hash) VALUES
('ali',  'ali@example.com',  CAST(SHA2('Ali@12345',256) AS BINARY(64))),
('sara', 'sara@example.com', CAST(SHA2('Sara@1234',256)  AS BINARY(64))),
('noor', 'noor@example.com', CAST(SHA2('Noor@1234',256)  AS BINARY(64))),
('omar', 'omar@example.com', CAST(SHA2('Omar@1234',256)  AS BINARY(64))),
('lama', 'lama@example.com', CAST(SHA2('Lama@1234',256)  AS BINARY(64)));

INSERT INTO profiles (user_id, full_name, bio, location, birth_date)
SELECT u.user_id,
       CONCAT(UPPER(LEFT(u.username,1)), SUBSTRING(u.username,2)),
       CONCAT('Hello, I am ', u.username),
       'Riyadh',
       '2000-01-01'
FROM users u;

INSERT INTO tweets (user_id, content) VALUES
((SELECT user_id FROM users WHERE username='ali'),  'My first tweet!'),
((SELECT user_id FROM users WHERE username='ali'),  'SQL day'),
((SELECT user_id FROM users WHERE username='sara'), 'Good morning'),
((SELECT user_id FROM users WHERE username='noor'), 'Learning SQL'),
((SELECT user_id FROM users WHERE username='omar'), 'Hello world'),
((SELECT user_id FROM users WHERE username='lama'), 'Coffee time');

INSERT INTO follows (follower_id, followee_id) VALUES
((SELECT user_id FROM users WHERE username='ali'),  (SELECT user_id FROM users WHERE username='sara')),
((SELECT user_id FROM users WHERE username='ali'),  (SELECT user_id FROM users WHERE username='noor')),
((SELECT user_id FROM users WHERE username='sara'), (SELECT user_id FROM users WHERE username='ali')),
((SELECT user_id FROM users WHERE username='noor'), (SELECT user_id FROM users WHERE username='omar'));

INSERT INTO likes (user_id, tweet_id)
SELECT u.user_id, t.tweet_id
FROM users u
JOIN tweets t ON t.user_id = (SELECT user_id FROM users WHERE username='ali')
WHERE u.username IN ('sara','noor');

DROP PROCEDURE IF EXISTS createAccount;
DELIMITER $$
CREATE PROCEDURE createAccount(
  IN p_username VARCHAR(50),
  IN p_email    VARCHAR(120),
  IN p_password VARCHAR(255),
  IN p_fullname VARCHAR(100),
  IN p_location VARCHAR(100),
  IN p_birth    DATE,
  IN p_bio      VARCHAR(200)
)
BEGIN
  INSERT INTO users (username, email, password_hash)
  VALUES (p_username, p_email, CAST(SHA2(p_password,256) AS BINARY(64)));

  INSERT INTO profiles (user_id, full_name, bio, location, birth_date)
  VALUES (LAST_INSERT_ID(), p_fullname, p_bio, p_location, p_birth);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS User_Follow;
DELIMITER $$
CREATE PROCEDURE User_Follow(
  IN p_follower_username VARCHAR(50),
  IN p_followee_username VARCHAR(50)
)
BEGIN
  DECLARE v_follower INT;
  DECLARE v_followee INT;

  SELECT user_id INTO v_follower FROM users WHERE username = p_follower_username LIMIT 1;
  SELECT user_id INTO v_followee FROM users WHERE username = p_followee_username LIMIT 1;

  IF v_follower IS NOT NULL AND v_followee IS NOT NULL AND v_follower <> v_followee THEN
    INSERT IGNORE INTO follows (follower_id, followee_id)
    VALUES (v_follower, v_followee);
  END IF;
END$$
DELIMITER ;

CALL createAccount('reem','reem@example.com','Reem@1234','Reem N.','Jeddah','2001-05-20','New here');
CALL User_Follow('reem','ali');

SELECT u.username, COUNT(t.tweet_id) AS tweets_count
FROM users u
LEFT JOIN tweets t ON t.user_id = u.user_id
WHERE u.username = 'ali'
GROUP BY u.user_id, u.username;
CALL createAccount(
  'ali_new',                
  'ali_new@example.com',    
  'Ali@123456',             
  'Ali New',                
  'Riyadh',                 
  '2001-05-20',             
  'New here'                
);

CALL createAccount(
  'sara_new',                
  'sara_new@example.com',    
  'Sara@123456',             
  'Sara Ahmed',              
  'Jeddah',                  
  '2002-07-15',              
  'Hello World'              
);

CALL User_Follow('ali_new', 'sara_new');

SELECT * FROM users;
SELECT * FROM profiles;
SELECT * FROM follows;
