-- 1 tạo bảng account --
CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    account_name VARCHAR(50) NOT NULL,
    balance DECIMAL(10,2) NOT NULL
);


-- 2  Chạy câu lệnh  -- 
INSERT INTO accounts (account_name, balance) VALUES 
('Nguyễn Văn An', 1000.00),
('Trần Thị Bảy', 500.00);

-- 3 Viết một Stored Procedure trong MySQL để thực hiện transaction nhằm chuyển tiền từ tài khoản này sang tài khoản khác --
DELIMITER //

CREATE PROCEDURE transfer_money(
    IN from_account INT,
    IN to_account INT,
    IN amount DECIMAL(10,2)
)
BEGIN
    DECLARE from_balance DECIMAL(10,2);

    -- Lấy số dư của tài khoản gửi
    SELECT balance INTO from_balance FROM accounts WHERE account_id = from_account;

    -- Kiểm tra nếu số dư không đủ
    IF from_balance < amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Số dư không đủ để thực hiện giao dịch';
    ELSE
        START TRANSACTION;
        
        UPDATE accounts SET balance = balance - amount WHERE account_id = from_account;
       
        UPDATE accounts SET balance = balance + amount WHERE account_id = to_account;
        
        COMMIT;
    END IF;
END;

//
DELIMITER ;

-- 4 Gọi store procedure trên với tham số tương ứng. --
CALL transfer_money(1, 2, 300.00);
