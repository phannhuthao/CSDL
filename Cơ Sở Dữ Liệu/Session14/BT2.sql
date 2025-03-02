 Bảng departments (Phòng ban)
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(255) NOT NULL
);

-- 2. Bảng employees (Nhân viên)
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    department_id INT NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE CASCADE
);

-- 3. Bảng attendance (Chấm công)
CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    check_in_time DATETIME NOT NULL,
    check_out_time DATETIME,
    total_hours DECIMAL(5,2),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

-- 4. Bảng salaries (Bảng lương)
CREATE TABLE salaries (
    employee_id INT PRIMARY KEY,
    base_salary DECIMAL(10,2) NOT NULL,
    bonus DECIMAL(10,2) DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

-- 5. Bảng salary_history (Lịch sử lương)
CREATE TABLE salary_history (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

-- 2 Khi một nhân viên mới được thêm vào bảng employees, hãy đảm bảo rằng địa chỉ email của họ phải có đuôi "@company.com". Nếu không, hãy tự động chỉnh sửa email đó bằng cách thêm "@company.com" vào cuối.
DELIMITER //
CREATE TRIGGER before_insert_employee
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF NEW.email NOT LIKE '%@company.com' THEN
        SET NEW.email = CONCAT(NEW.email, '@company.com');
    END IF;
END;
//
DELIMITER ;



-- 3  Mỗi khi một nhân viên mới được thêm vào bảng employees, hãy tự động tạo một bản ghi lương cơ bản trong bảng salaries, với mức lương mặc định là 10,000.00 và không có thưởng (bonus = 0.00).
DELIMITER //
CREATE TRIGGER after_insert_employee
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    INSERT INTO salaries (employee_id, base_salary, bonus)
    VALUES (NEW.employee_id, 10000.00, 0.00);
END;
//
DELIMITER ;


-- 4 Khi một nhân viên bị xóa khỏi bảng employees, hãy tự động ghi nhận một dòng vào bảng salary_history với thông tin lương cuối cùng của họ trước khi bị xóa.
DELIMITER //
CREATE TRIGGER after_delete_employee
AFTER DELETE ON employees
FOR EACH ROW
BEGIN
    DECLARE last_salary DECIMAL(10,2);
    DECLARE last_bonus DECIMAL(10,2);

    -- Lấy thông tin lương trước khi xóa
    SELECT base_salary, bonus INTO last_salary, last_bonus
    FROM salaries WHERE employee_id = OLD.employee_id;

    -- Ghi lại lịch sử lương
    INSERT INTO salary_history (employee_id, old_salary, new_salary, reason)
    VALUES (OLD.employee_id, last_salary, NULL, 'Nhân viên bị xóa');

    -- Xóa lương của nhân viên khỏi bảng salaries
    DELETE FROM salaries WHERE employee_id = OLD.employee_id;
END;
//
DELIMITER ;


-- 5 Khi nhân viên checkout trong bảng attendance, hệ thống phải tự động tính toán tổng số giờ làm dựa vào thời gian check-in và check-out(Kết quả là hiệu của check-out và check-in).
DELIMITER //
CREATE TRIGGER before_update_attendance
BEFORE UPDATE ON attendance
FOR EACH ROW
BEGIN
    IF NEW.check_out_time IS NOT NULL THEN
        SET NEW.total_hours = TIMESTAMPDIFF(HOUR, NEW.check_in_time, NEW.check_out_time);
    END IF;
END;
//
DELIMITER ;



-- 6
INSERT INTO departments (department_name) VALUES 

('Phòng Nhân Sự'),

('Phòng Kỹ Thuật');

INSERT INTO employees (name, email, phone, hire_date, department_id)

VALUES ('Nguyễn Văn A', 'nguyenvana', '0987654321', '2024-02-17', 1);

-- 7
INSERT INTO attendance (employee_id, check_in_time)

VALUES (1, '2024-02-17 08:00:00');

UPDATE attendance

SET check_out_time = '2024-02-17 17:00:00'

WHERE employee_id = 1;