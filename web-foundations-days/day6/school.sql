PRAGMA foreign_keys = ON;

-- =========================================
-- DAY 6: A SCHOOL DATABASE
-- =========================================

-- 1. STUDENTS TABLE
CREATE TABLE students (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE
);

-- 2. COURSES TABLE
CREATE TABLE courses (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);

-- 3. ENROLMENTS TABLE
-- Links students and courses.
-- A student cannot enrol in the same course twice.
CREATE TABLE enrolments (
    id INTEGER PRIMARY KEY,
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    grade TEXT,

    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (course_id) REFERENCES courses(id),

    UNIQUE (student_id, course_id)
);

-- =========================================
-- SAMPLE STUDENTS
-- =========================================

INSERT INTO students (id, name, email) VALUES
(1, 'John Kamau', 'john@example.com'),
(2, 'Mary Wanjiku', 'mary@example.com'),
(3, 'Peter Mwangi', 'peter@example.com'),
(4, 'Jane Akinyi', 'jane@example.com');

-- =========================================
-- SAMPLE COURSES
-- =========================================

INSERT INTO courses (id, name) VALUES
(1, 'Web Development'),
(2, 'Database Systems'),
(3, 'Computer Programming');

-- =========================================
-- SAMPLE ENROLMENTS
-- =========================================

INSERT INTO enrolments (id, student_id, course_id, grade) VALUES
(1, 1, 1, 'A'),
(2, 1, 2, 'B'),
(3, 2, 1, 'A'),
(4, 2, 3, 'B'),
(5, 3, 2, 'A');

-- =========================================
-- QUERY 1:
-- All courses for one student by name
-- =========================================

SELECT
    students.name AS student_name,
    courses.name AS course_name,
    enrolments.grade
FROM enrolments
JOIN students ON enrolments.student_id = students.id
JOIN courses ON enrolments.course_id = courses.id
WHERE students.name = 'John Kamau';

-- =========================================
-- QUERY 2:
-- All students on one course
-- =========================================

SELECT
    courses.name AS course_name,
    students.name AS student_name
FROM enrolments
JOIN students ON enrolments.student_id = students.id
JOIN courses ON enrolments.course_id = courses.id
WHERE courses.name = 'Web Development';

-- =========================================
-- QUERY 3:
-- Number of students per course
-- =========================================

SELECT
    courses.name AS course_name,
    COUNT(enrolments.student_id) AS student_count
FROM courses
LEFT JOIN enrolments ON courses.id = enrolments.course_id
GROUP BY courses.id, courses.name;

-- =========================================
-- QUERY 4:
-- Students who have no enrolments
-- =========================================

SELECT
    students.id,
    students.name,
    students.email
FROM students
LEFT JOIN enrolments ON students.id = enrolments.student_id
WHERE enrolments.id IS NULL;

-- =========================================
-- QUERY 5:
-- Update one enrolment's grade
-- =========================================

UPDATE enrolments
SET grade = 'A+'
WHERE student_id = 1
  AND course_id = 2;

-- Check the updated enrolment
SELECT
    students.name AS student_name,
    courses.name AS course_name,
    enrolments.grade
FROM enrolments
JOIN students ON enrolments.student_id = students.id
JOIN courses ON enrolments.course_id = courses.id
WHERE student_id = 1
  AND course_id = 2;