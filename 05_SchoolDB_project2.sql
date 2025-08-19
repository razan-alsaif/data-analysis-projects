-- Create DB only if missing (no warnings)
SET @q := (
  SELECT IF(COUNT(*)=0,'CREATE DATABASE schooldb','SELECT 1')
  FROM INFORMATION_SCHEMA.SCHEMATA
  WHERE SCHEMA_NAME='schooldb'
);
PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;

USE schooldb;

-- Drop tables only if they exist (no warnings)
SET @d := (SELECT IF(EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES
                            WHERE TABLE_SCHEMA='schooldb' AND TABLE_NAME='studentsubjects'),
                     'DROP TABLE studentsubjects','SELECT 1'));
PREPARE s FROM @d; EXECUTE s; DEALLOCATE PREPARE s;

SET @d := (SELECT IF(EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES
                            WHERE TABLE_SCHEMA='schooldb' AND TABLE_NAME='subjects'),
                     'DROP TABLE subjects','SELECT 1'));
PREPARE s FROM @d; EXECUTE s; DEALLOCATE PREPARE s;

SET @d := (SELECT IF(EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES
                            WHERE TABLE_SCHEMA='schooldb' AND TABLE_NAME='students'),
                     'DROP TABLE students','SELECT 1'));
PREPARE s FROM @d; EXECUTE s; DEALLOCATE PREPARE s;

-- Create tables
CREATE TABLE IF NOT EXISTS students (
  student_id   INT AUTO_INCREMENT PRIMARY KEY,
  student_name VARCHAR(100) NOT NULL,
  birth_date   DATE,
  join_date    DATE,
  email        VARCHAR(100),
  gender       VARCHAR(10),
  grade_level  INT,
  track        VARCHAR(20),
  gpa          DECIMAL(5,2)
);

CREATE TABLE IF NOT EXISTS subjects (
  subject_id   INT AUTO_INCREMENT PRIMARY KEY,
  subject_name VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS studentsubjects (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT,
  subject_id INT,
  FOREIGN KEY (student_id) REFERENCES students(student_id),
  FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

-- Seed data (idempotent inserts)
INSERT INTO subjects (subject_name)
SELECT * FROM (SELECT 'Math' UNION SELECT 'Science' UNION SELECT 'Arabic' UNION SELECT 'English') AS t
WHERE NOT EXISTS (SELECT 1 FROM subjects);

INSERT INTO students (student_name, birth_date, join_date, email, gender, grade_level, track, gpa)
SELECT * FROM (
  SELECT 'Ali','2012-05-10','2024-09-01','ali@example.com','Male',1,'CS',58.00 UNION ALL
  SELECT 'Alaa','2011-03-20','2024-09-01','alaa@example.com','Female',1,'IT',62.50 UNION ALL
  SELECT 'Sara','2009-11-15','2023-09-01','sara@example.com','Female',2,'CS',77.25 UNION ALL
  SELECT 'Omar','2008-01-25','2022-09-01','omar@example.com','Male',6,'IS',100.00 UNION ALL
  SELECT 'Lama','2013-07-30','2024-09-01','lama@example.com','Female',1,'AI',91.00 UNION ALL
  SELECT 'Noor','2010-12-01','2022-09-01','noor@example.com','Female',2,'DS',45.50 UNION ALL
  SELECT 'Faisal','2012-09-09','2024-09-01','faisal@example.com','Male',1,'CS',88.00 UNION ALL
  SELECT 'Areej','2014-02-14','2024-09-01','areej@example.com','Female',1,'IT',95.00
) AS t
WHERE NOT EXISTS (SELECT 1 FROM students);

USE schooldb;

INSERT INTO studentsubjects (student_id, subject_id)
SELECT s.student_id, s.subject_id
FROM (
  SELECT 1 AS student_id, 1 AS subject_id
  UNION ALL SELECT 1, 2
  UNION ALL SELECT 2, 3
  UNION ALL SELECT 3, 1
  UNION ALL SELECT 4, 2
  UNION ALL SELECT 5, 4
  UNION ALL SELECT 6, 1
  UNION ALL SELECT 7, 2
  UNION ALL SELECT 8, 3
) AS s
WHERE NOT EXISTS (SELECT 1 FROM studentsubjects);

USE schooldb;

SET SQL_SAFE_UPDATES = 0;

UPDATE students
SET gender = CASE
               WHEN gender IN ('M','Male') THEN 'Male'
               WHEN gender IN ('F','Female') THEN 'Female'
               ELSE gender
             END;

UPDATE students
SET gpa = LEAST(gpa + 5, 100)
WHERE gpa < 60;

SET SQL_SAFE_UPDATES = 1;

SET @d := (SELECT IF(EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES
                            WHERE TABLE_SCHEMA='schooldb' AND TABLE_NAME='excellent_students'),
                     'DROP TABLE excellent_students','SELECT 1'));
PREPARE s FROM @d; EXECUTE s; DEALLOCATE PREPARE s;

CREATE TABLE excellent_students AS
SELECT *
FROM students
WHERE gpa > 90;

SET @d := (SELECT IF(EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES
                            WHERE TABLE_SCHEMA='schooldb' AND TABLE_NAME='failing_students'),
                     'DROP TABLE failing_students','SELECT 1'));
PREPARE s FROM @d; EXECUTE s; DEALLOCATE PREPARE s;

CREATE TABLE failing_students AS
SELECT *
FROM students
WHERE gpa < 60;

SELECT student_name
FROM students
WHERE UPPER(student_name) LIKE 'A%';

SELECT student_name
FROM students
WHERE CHAR_LENGTH(student_name) = 4;

SELECT ROUND(AVG(gpa), 2) AS avg_gpa,
       MAX(gpa) AS max_gpa,
       MIN(gpa) AS min_gpa
FROM students;

SELECT student_name
FROM students
WHERE grade_level = 6 AND gpa = 100;

SELECT student_name, birth_date,
       TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) AS age
FROM students
WHERE grade_level = 1
  AND TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) BETWEEN 10 AND 15;

SELECT COUNT(*) AS count_level2
FROM students
WHERE grade_level = 2;

SELECT DISTINCT track
FROM students
WHERE track IS NOT NULL AND track <> '';

SELECT UPPER(subject_name) AS subject_name_upper
FROM subjects;

SELECT ROUND(AVG(gpa) * MIN(gpa), 2) AS avg_times_min
FROM students;
SELECT * FROM students;
