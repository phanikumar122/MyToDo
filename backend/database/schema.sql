-- ============================================================
-- To-Do App MySQL Schema
-- Run: mysql -u root -p < backend/database/schema.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE test;

SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- Users Table
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id           VARCHAR(128) PRIMARY KEY,          -- Firebase UID
    google_id    VARCHAR(128) UNIQUE NOT NULL,
    name         VARCHAR(255)        NOT NULL,
    email        VARCHAR(255) UNIQUE NOT NULL,
    profile_picture TEXT,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_google_id (google_id)
) ENGINE=InnoDB;

-- ============================================================
-- Tasks Table
-- ============================================================
CREATE TABLE IF NOT EXISTS tasks (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     VARCHAR(128)  NOT NULL,
    title       VARCHAR(500)  NOT NULL,
    description TEXT,
    priority    ENUM('high','medium','low') NOT NULL DEFAULT 'medium',
    category    VARCHAR(100)  NOT NULL DEFAULT 'Personal',
    deadline    DATETIME,
    status      ENUM('pending','completed') NOT NULL DEFAULT 'pending',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_tasks_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id   (user_id),
    INDEX idx_status    (status),
    INDEX idx_deadline  (deadline),
    INDEX idx_priority  (priority),
    INDEX idx_category  (category)
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;
