-- База данных для приложения StudyFlow
-- Версия 1.0

-- Таблица пользователей
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'STUDENT' 
        CHECK (role IN ('STUDENT', 'TEACHER', 'ADMIN')),
    avatar_url TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Таблица учебных предметов
CREATE TABLE subjects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    color_hex VARCHAR(7) NOT NULL DEFAULT '#667eea',
    teacher_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT valid_color CHECK (color_hex ~* '^#[0-9A-Fa-f]{6}$')
);

-- Связь студентов с предметами (многие-ко-многим)
CREATE TABLE enrollments (
    student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject_id INTEGER NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (student_id, subject_id)
);

-- Таблица учебных задач
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    subject_id INTEGER NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    due_date TIMESTAMP,
    priority VARCHAR(10) NOT NULL DEFAULT 'MEDIUM' 
        CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT')),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'OVERDUE')),
    created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT valid_due_date CHECK (due_date > created_at)
);

-- Таблица заметок
CREATE TABLE notes (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject_id INTEGER REFERENCES subjects(id) ON DELETE SET NULL,
    tags TEXT[] DEFAULT '{}',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Таблица расписания занятий
CREATE TABLE schedule_entries (
    id SERIAL PRIMARY KEY,
    subject_id INTEGER NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room VARCHAR(50),
    type VARCHAR(20) NOT NULL DEFAULT 'LECTURE'
        CHECK (type IN ('LECTURE', 'LAB', 'SEMINAR', 'PRACTICE')),
    
    CONSTRAINT valid_time CHECK (end_time > start_time)
);

-- Таблица прикрепленных файлов
CREATE TABLE resources (
    id SERIAL PRIMARY KEY,
    filename VARCHAR(255) NOT NULL,
    file_path TEXT NOT NULL,
    file_type VARCHAR(50),
    file_size BIGINT,
    uploaded_by INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject_id INTEGER REFERENCES subjects(id) ON DELETE SET NULL,
    task_id INTEGER REFERENCES tasks(id) ON DELETE SET NULL,
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Индексы для ускорения поиска
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_tasks_subject_status ON tasks(subject_id, status);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_priority ON tasks(priority);
CREATE INDEX idx_notes_user_subject ON notes(user_id, subject_id);
CREATE INDEX idx_notes_tags ON notes USING gin(tags);
CREATE INDEX idx_schedule_subject_day ON schedule_entries(subject_id, day_of_week);
CREATE INDEX idx_resources_subject ON resources(subject_id);

-- Триггер для автоматического обновления updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at 
    BEFORE UPDATE ON tasks 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notes_updated_at 
    BEFORE UPDATE ON notes 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Вставка тестовых данных (опционально)
INSERT INTO users (username, email, password_hash, full_name, role) VALUES
('student1', 'student1@university.com', 'hashed_password_1', 'Иван Иванов', 'STUDENT'),
('teacher1', 'teacher1@university.com', 'hashed_password_2', 'Петр Петров', 'TEACHER');

INSERT INTO subjects (name, description, color_hex, teacher_id) VALUES
('ООП и Java', 'Объектно-ориентированное программирование на Java', '#667eea', 2),
('Базы данных', 'Проектирование и программирование баз данных', '#764ba2', 2),
('Алгоритмы', 'Алгоритмы и структуры данных', '#f093fb', 2);

INSERT INTO enrollments (student_id, subject_id) VALUES
(1, 1), (1, 2), (1, 3);

INSERT INTO tasks (title, description, subject_id, due_date, priority, status) VALUES
('Лабораторная работа 10', 'Создание финального проекта по ООП', 1, CURRENT_TIMESTAMP + INTERVAL '7 days', 'HIGH', 'PENDING'),
('Курсовая по БД', 'Проектирование базы данных для приложения', 2, CURRENT_TIMESTAMP + INTERVAL '14 days', 'MEDIUM', 'IN_PROGRESS'),
('Алгоритмы сортировки', 'Реализация алгоритмов быстрой сортировки', 3, CURRENT_TIMESTAMP + INTERVAL '3 days', 'URGENT', 'PENDING');
