-- Create databases
CREATE DATABASE IF NOT EXISTS test;
CREATE DATABASE IF NOT EXISTS analytics;
CREATE DATABASE IF NOT EXISTS logs;

-- Create users and grant permissions
CREATE USER IF NOT EXISTS 'user_test'@'%' IDENTIFIED BY 'testpass';
GRANT ALL PRIVILEGES ON test.* TO 'user_test'@'%';

CREATE USER IF NOT EXISTS 'user_analytics'@'%' IDENTIFIED BY 'analyticspass';
GRANT ALL PRIVILEGES ON analytics.* TO 'user_analytics'@'%';

CREATE USER IF NOT EXISTS 'user_logs'@'%' IDENTIFIED BY 'logspass';
GRANT ALL PRIVILEGES ON logs.* TO 'user_logs'@'%';

FLUSH PRIVILEGES;
