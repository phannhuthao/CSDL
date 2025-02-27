CREATE TABLE company_funds (
    fund_id INT PRIMARY KEY AUTO_INCREMENT,
    balance DECIMAL(15,2) NOT NULL -- Số dư quỹ công ty
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_name VARCHAR(50) NOT NULL,   -- Tên nhân viên
    salary DECIMAL(10,2) NOT NULL    -- Lương nhân viên
);

CREATE TABLE payroll (
    payroll_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,                      -- ID nhân viên (FK)
    salary DECIMAL(10,2) NOT NULL,   -- Lương được nhận
    pay_date DATE NOT NULL,          -- Ngày nhận lương
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

CREATE TABLE transaction_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    log_message TEXT NOT NULL,
    log_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


INSERT INTO company_funds (balance) VALUES (50000.00);

INSERT INTO employees (emp_name, salary) VALUES
('Nguyễn Văn An', 5000.00),
('Trần Thị Bốn', 4000.00),
('Lê Văn Cường', 3500.00),
('Hoàng Thị Dung', 4500.00),
('Phạm Văn Em', 3800.00);

-- 3 Thêm cột last_pay_date để theo dõi ngày trả lương gần nhất cho nhân viên.
ALTER TABLE employees ADD COLUMN last_pay_date DATE NULL;

-- 4 ) Viết một Stored Procedure trong MySQL để thực hiện transaction nhằm chuyển lương cho nhân viên từ quỹ công ty,
DELIMITER //

CREATE PROCEDURE process_salary_payment(IN p_emp_id INT)
BEGIN
    DECLARE v_salary DECIMAL(10,2);
    DECLARE v_balance DECIMAL(15,2);
    DECLARE v_emp_exists INT;
    DECLARE v_error INT DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_error = 1;

    -- Bắt đầu transaction
    START TRANSACTION;

    -- Kiểm tra nhân viên có tồn tại hay không
    SELECT COUNT(*) INTO v_emp_exists FROM employees WHERE emp_id = p_emp_id;
    IF v_emp_exists = 0 THEN
        INSERT INTO transaction_log (log_message) 
        VALUES (CONCAT('Nhân viên không tồn tại: ', p_emp_id));
        ROLLBACK;
        LEAVE proc_block;
    END IF;

    -- Lấy mức lương của nhân viên
    SELECT salary INTO v_salary FROM employees WHERE emp_id = p_emp_id;

    -- Kiểm tra số dư quỹ công ty
    SELECT balance INTO v_balance FROM company_funds;
    IF v_balance < v_salary THEN
        INSERT INTO transaction_log (log_message) 
        VALUES ('Quỹ không đủ tiền.');
        ROLLBACK;
        LEAVE proc_block;
    END IF;

    -- Trừ tiền từ quỹ công ty
    UPDATE company_funds SET balance = balance - v_salary;

    -- Thêm bản ghi vào bảng payroll
    INSERT INTO payroll (emp_id, salary, pay_date) 
    VALUES (p_emp_id, v_salary, CURDATE());

    -- Cập nhật ngày nhận lương gần nhất cho nhân viên
    UPDATE employees SET last_pay_date = CURDATE() WHERE emp_id = p_emp_id;

    -- Kiểm tra lỗi hệ thống ngân hàng giả lập
    IF v_error = 1 THEN
        INSERT INTO transaction_log (log_message) 
        VALUES ('Lỗi trong quá trình chuyển lương.');
        ROLLBACK;
        LEAVE proc_block;
    END IF;

    -- Ghi log thành công
    INSERT INTO transaction_log (log_message) 
    VALUES (CONCAT('Chuyển lương cho nhân viên ID ', p_emp_id, ' thành công'));

    -- Commit transaction
    COMMIT;
    
END

-- 5 Gọi store procedure trên với tham số tương ứng
CALL process_salary_payment(1);