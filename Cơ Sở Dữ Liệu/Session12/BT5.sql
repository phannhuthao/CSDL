CREATE TABLE projects (
    project_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    budget DECIMAL(15, 2) NOT NULL,
    total_salary DECIMAL(15, 2) DEFAULT 0
);

CREATE TABLE workers (
    worker_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    project_id INT,
    salary DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE
);

-- 2 Thêm dữ liệu mẫu dưới đây --
INSERT INTO projects (name, budget) VALUES
('Bridge Construction', 10000.00),
('Road Expansion', 15000.00),
('Office Renovation', 8000.00);


-- 3 Tạo 2 trigger theo mô tả dưới đây --

-- Trigger AFTER INSERT: Khi một công nhân được thêm, lương của công nhân đó được cộng vào total_salary của dự án trong bảng projects --

-- Trigger AFTER DELETE: Khi một công nhân bị xóa, lương của công nhân đó được trừ khỏi total_salary của dự án. --

DELIMITER //
CREATE TRIGGER after_insert_worker
AFTER INSERT ON workers
FOR EACH ROW
BEGIN
    UPDATE projects
    SET total_salary = total_salary + NEW.salary
    WHERE project_id = NEW.project_id;
END;
//
DELIMITER ;

-- 4 Thực hiện insert các bản ghi sau và tiến hành hiển thị lại bảng projects để kiểm chứng: -- 
INSERT INTO workers (name, project_id, salary) VALUES
('John', 1, 2500.00),
('Alice', 1, 3000.00),
('Bob', 2, 2000.00),
('Eve', 2, 3500.00),
('Charlie', 3, 1500.00);

-- 5 Thực hiện xóa một công nhân bất kì rồi hiển thị bảng projects để kiểm tra -- 
DELETE FROM workers WHERE name = 'Alice';

SELECT * FROM projects;

