CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    student_name VARCHAR(50)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100),
    available_seats INT NOT NULL
);

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);
INSERT INTO students (student_name) VALUES ('Nguyễn Văn An'), ('Trần Thị Ba');

INSERT INTO courses (course_name, available_seats) VALUES 
('Lập trình C', 25), 
('Cơ sở dữ liệu', 22);

-- 2) Viết một Stored Procedure trong MySQL để thực hiện transaction nhằm đăng ký học phần cho một sinh viên vào một môn học bất kỳ, thực hiện theo các bước sau:

-- Tham số đầu vào của Stored Procedure:

-- p_student_name (VARCHAR(50)) - Tên của sinh viên muốn đăng ký.

-- p_course_name (VARCHAR(100)) - Tên môn học mà sinh viên muốn đăng ký.

-- Logic thực hiện trong Stored Procedure:

-- Kiểm tra xem môn học có chỗ trống không (available_seats > 0).

-- Nếu còn chỗ trống:

-- Thêm sinh viên vào bảng enrollments.

-- Giảm số chỗ trống của môn học đi 1 (available_seats - 1).

-- Commit transaction.

-- Nếu không còn chỗ trống:

-- Rollback transaction để đảm bảo không có thay đổi dữ liệu.

DELIMITER //

CREATE PROCEDURE enroll_student(
    IN p_student_name VARCHAR(50),
    IN p_course_name VARCHAR(100)
)
BEGIN
    DECLARE v_student_id INT;
    DECLARE v_course_id INT;
    DECLARE v_available_seats INT;

    SELECT student_id INTO v_student_id FROM students 
    WHERE student_name = p_student_name LIMIT 1;

    SELECT course_id, available_seats INTO v_course_id, v_available_seats 
    FROM courses WHERE course_name = p_course_name LIMIT 1;

    -- Kiểm tra nếu không tìm thấy sinh viên hoặc khóa học
    IF v_student_id IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Sinh viên không tồn tại!';
    END IF;

    IF v_course_id IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Môn học không tồn tại!';
    END IF;

    IF v_available_seats <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Môn học đã hết chỗ!';
    ELSE
        START TRANSACTION;
        
        INSERT INTO enrollments (student_id, course_id) 
        VALUES (v_student_id, v_course_id);

        UPDATE courses 
        SET available_seats = available_seats - 1 
        WHERE course_id = v_course_id;

        COMMIT;
    END IF;
END;

//
DELIMITER ;


-- 3) Gọi Stored Procedure với các tham số phù hợp để kiểm tra hoạt động
CALL enroll_student('Nguyễn Văn An', 'Lập trình C');
