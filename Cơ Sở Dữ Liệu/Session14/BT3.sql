-- 1. Bảng customers (Khách hàng)
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Bảng orders (Đơn hàng)
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) DEFAULT 0,
    status ENUM('Pending', 'Completed', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- 3. Bảng products (Sản phẩm)
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Bảng order_items (Chi tiết đơn hàng)
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 5. Bảng inventory (Kho hàng)
CREATE TABLE inventory (
    product_id INT PRIMARY KEY,
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- 6. Bảng payments (Thanh toán)
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('Credit Card', 'PayPal', 'Bank Transfer', 'Cash') NOT NULL,
    status ENUM('Pending', 'Completed', 'Failed') DEFAULT 'Pending',
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);


-- 2 Hãy tạo một trigger BEFORE INSERT để kiểm tra đơn hàng trước khi thêm vào order_items với yêu cầu sau:

-- Khi khách hàng đặt hàng, cần kiểm tra xem sản phẩm có đủ số lượng trong kho hay không trước khi thêm vào bảng order_items. Nếu không đủ, báo lỗi SQLSTATE '45000' với MESSAGE_TEXT = 'Không đủ hàng trong kho!'. --

CREATE TRIGGER before_insert_order_items
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE stock INT;
    -- Lấy số lượng tồn kho của sản phẩm
    SELECT stock_quantity INTO stock FROM inventory WHERE product_id = NEW.product_id;
    
    -- Kiểm tra nếu số lượng tồn kho không đủ
    IF stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không đủ hàng trong kho!';
    END IF;
END;


-- 3 Hãy tạo một trigger AFTER INSERT để cập nhật tổng tiền của đơn hàng sau khi thêm sản phẩm vào order_items

CREATE TRIGGER after_insert_order_items
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    -- Cập nhật tổng tiền của đơn hàng
    UPDATE orders
    SET total_amount = total_amount + (NEW.price * NEW.quantity)
    WHERE order_id = NEW.order_id;
END;

-- 4 Hãy tạo một trigger BEFORE UPDATE để kiểm tra số lượng hàng tồn kho trước khi cập nhật số lượng sản phẩm trong order_items
CREATE TRIGGER before_update_order_items
BEFORE UPDATE ON order_items
FOR EACH ROW
BEGIN
    DECLARE stock INT;
    -- Lấy số lượng tồn kho của sản phẩm
    SELECT stock_quantity INTO stock FROM inventory WHERE product_id = NEW.product_id;
    
    -- Kiểm tra nếu số lượng tồn kho không đủ
    IF stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không đủ hàng trong kho để cập nhật số lượng!';
    END IF;
END;


-- 5  Hãy tạo một trigger AFTER UPDATE để cập nhật lại tổng tiền (total_amount) của đơn hàng khi một sản phẩm trong order_items
CREATE TRIGGER after_update_order_items
AFTER UPDATE ON order_items
FOR EACH ROW
BEGIN
    -- Cập nhật tổng tiền của đơn hàng
    UPDATE orders
    SET total_amount = total_amount - (OLD.price * OLD.quantity) + (NEW.price * NEW.quantity)
    WHERE order_id = NEW.order_id;
END;


-- 6  Hãy tạo một trigger BEFORE DELETE để ngăn chặn việc xóa đơn hàng đã được thanh toán trong bảng orders 
CREATE TRIGGER before_delete_orders
BEFORE DELETE ON orders
FOR EACH ROW
BEGIN
    -- Nếu đơn hàng đã hoàn thành, không cho phép xóa
    IF OLD.status = 'Completed' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không thể xóa đơn hàng đã thanh toán!';
    END IF;
END;


-- 7 Hãy tạo một trigger AFTER DELETE để hoàn trả số lượng hàng vào kho sau khi xóa một sản phẩm khỏi order_items
CREATE TRIGGER after_delete_order_items
AFTER DELETE ON order_items
FOR EACH ROW
BEGIN
    -- Cộng lại số lượng hàng vào kho
    UPDATE inventory
    SET stock_quantity = stock_quantity + OLD.quantity
    WHERE product_id = OLD.product_id;
END;


-- 8  Hãy xóa tất cả các trigger đã tạo trên.
DROP TRIGGER IF EXISTS before_insert_order_items;
DROP TRIGGER IF EXISTS after_insert_order_items;
DROP TRIGGER IF EXISTS before_update_order_items;
DROP TRIGGER IF EXISTS after_update_order_items;
DROP TRIGGER IF EXISTS before_delete_orders;
DROP TRIGGER IF EXISTS after_delete_order_items;
