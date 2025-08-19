USE schooldb;

-- tables & relations
CREATE TABLE IF NOT EXISTS teachers (
  teacher_id    INT AUTO_INCREMENT PRIMARY KEY,
  teacher_name  VARCHAR(100) NOT NULL,
  office_number VARCHAR(10),
  subject_id    INT,
  CONSTRAINT fk_teacher_subject
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

CREATE TABLE IF NOT EXISTS teacher_students (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  teacher_id INT NOT NULL,
  student_id INT NOT NULL,
  CONSTRAINT fk_ts_teacher FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id),
  CONSTRAINT fk_ts_student FOREIGN KEY (student_id) REFERENCES students(student_id),
  UNIQUE KEY uk_teacher_student (teacher_id, student_id)
);

-- procedure: student_info
DROP PROCEDURE IF EXISTS student_info;
DELIMITER $$
CREATE PROCEDURE student_info()
BEGIN
  SELECT
    s.student_id,
    s.student_name,
    sub.subject_id,
    sub.subject_name
  FROM students s
  JOIN studentsubjects ss ON ss.student_id = s.student_id
  JOIN subjects sub       ON sub.subject_id = ss.subject_id
  ORDER BY s.student_id, sub.subject_id;
END$$
DELIMITER ;

CALL student_info();

-- view: teacher_info
DROP VIEW IF EXISTS teacher_info;
CREATE VIEW teacher_info AS
SELECT
  t.teacher_name,
  t.office_number,
  sub.subject_name
FROM teachers t
LEFT JOIN subjects sub ON sub.subject_id = t.subject_id;

SELECT * FROM teacher_info;

DROP VIEW teacher_info;

-- index on students(student_name): safe drop -> create -> show -> drop
SET @exists := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema='schooldb'
    AND table_name='students'
    AND index_name='idx_student_name'
);
SET @sql := IF(@exists>0, 'DROP INDEX idx_student_name ON students', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

CREATE INDEX idx_student_name ON students(student_name);

SHOW INDEX FROM students WHERE Key_name='idx_student_name';

DROP INDEX idx_student_name ON students;
CALL student_info();
SELECT * FROM students;
SELECT * FROM teachers;
SELECT * FROM subjects;
SELECT * FROM studentsubjects;
SELECT * FROM teacher_students;
