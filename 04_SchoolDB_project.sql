CREATE DATABASE SchoolDB;
USE SchoolDB;
CREATE TABLE Students (
    student_id INT AUTO_INCREMENT PRIMARY KEY, -- الرقم التسلسلي
    student_name VARCHAR(100) NOT NULL,        -- اسم الطالب
    birth_date DATE,                           -- تاريخ الميلاد
    join_date DATE,                            -- تاريخ الالتحاق
    email VARCHAR(100),                        -- البريد الالكتروني
    gender CHAR(1) CHECK (gender IN ('M','F')),-- الجنس (M/F)
    grade_level INT CHECK (grade_level BETWEEN 1 AND 6), -- المستوى الدراسي
    track VARCHAR(20) CHECK (track IN ('علمي','إنساني')), -- المسار
    gpa DECIMAL(5,2) CHECK (gpa BETWEEN 0 AND 100)       -- المعدل التراكمي
);
CREATE TABLE Teachers (
    teacher_id INT AUTO_INCREMENT PRIMARY KEY,
    teacher_name VARCHAR(100) NOT NULL,
    birth_date DATE,
    gender CHAR(1) CHECK (gender IN ('M','F')),
    email VARCHAR(100),
    office_number VARCHAR(10)
);
CREATE TABLE Subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL
);
CREATE TABLE StudentSubjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    subject_id INT,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (subject_id) REFERENCES Subjects(subject_id)
);
