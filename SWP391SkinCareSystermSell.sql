-- Xóa database nếu đã tồn tại và tạo lại
DROP DATABASE IF EXISTS swp391skincaresellsystem;
CREATE DATABASE swp391skincaresellsystem;
USE swp391skincaresellsystem;

--------------------------------------------------
-- Bảng users (Quản lý thông tin người dùng)
CREATE TABLE users (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_name VARCHAR(255) DEFAULT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role ENUM('Customer','Staff','Manager') NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status BOOLEAN NOT NULL DEFAULT 1, -- 1: Active, 0: Inactive
    gender ENUM('Male','Female') DEFAULT NULL,
    date_of_birth DATE DEFAULT NULL,
    address TEXT DEFAULT NULL,
    phone_number VARCHAR(20) DEFAULT NULL,
    profile_image TEXT DEFAULT NULL
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng products (Quản lý sản phẩm)
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    description TEXT DEFAULT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(18,2) NOT NULL,
    stock_quantity INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT NULL,
    status ENUM('Available','OutOfStock','Discontinued') NOT NULL DEFAULT 'Available',
    CHECK (stock_quantity >= 0)
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng skin_types (Quản lý loại da)
CREATE TABLE skin_types (
    skin_type_id INT AUTO_INCREMENT PRIMARY KEY,
    skin_type VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng skin_care_routines (Lộ trình chăm sóc da)
CREATE TABLE skin_care_routines (
    routine_id INT AUTO_INCREMENT PRIMARY KEY,
    skin_type_id INT NOT NULL,
    step_number INT NOT NULL,
    description TEXT NOT NULL,
    CHECK (step_number > 0),
    FOREIGN KEY (skin_type_id) REFERENCES skin_types(skin_type_id)
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng user_details (Thông tin đặc thù theo vai trò)
CREATE TABLE user_details (
    user_id BIGINT PRIMARY KEY,
    loyalty_points INT DEFAULT NULL,
    preferred_skin_type_id INT DEFAULT NULL,
    hire_date DATE DEFAULT NULL,
    salary DECIMAL(18,2) DEFAULT NULL,
    department VARCHAR(255) DEFAULT NULL,
    CHECK (loyalty_points IS NULL OR loyalty_points >= 0),
    CHECK (salary IS NULL OR salary >= 0),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (preferred_skin_type_id) REFERENCES skin_types(skin_type_id)
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng cancellation_policies (Chính sách hủy)
CREATE TABLE cancellation_policies (
    policy_id INT AUTO_INCREMENT PRIMARY KEY,
    policy_name VARCHAR(255) NOT NULL,
    description TEXT DEFAULT NULL,
    applicable_days INT NOT NULL,
    policy_type VARCHAR(50) NOT NULL DEFAULT 'Refund',
    CHECK (applicable_days > 0)
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng shipping_addresses (Địa chỉ giao hàng)
CREATE TABLE shipping_addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) DEFAULT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) DEFAULT NULL,
    is_default BOOLEAN NOT NULL DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng orders (Đơn hàng)
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    total_price DECIMAL(18,2) NOT NULL,
    order_status ENUM('Pending','Shipped','Delivered','Canceled') NOT NULL DEFAULT 'Pending',
    policy_id INT DEFAULT NULL,
    shipping_address_id INT DEFAULT NULL,
    discount_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT NULL,
    CHECK (total_price >= 0),
    FOREIGN KEY (customer_id) REFERENCES users(user_id),
    FOREIGN KEY (policy_id) REFERENCES cancellation_policies(policy_id),
    FOREIGN KEY (shipping_address_id) REFERENCES shipping_addresses(address_id) ON DELETE SET NULL
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng order_items (Chi tiết đơn hàng)
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(18,2) NOT NULL,
    discount_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    CHECK (quantity > 0),
    CHECK (unit_price >= 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng promotions (Khuyến mãi)
CREATE TABLE promotions (
    promotion_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    description TEXT DEFAULT NULL,
    discount_percentage DECIMAL(5,2) NOT NULL,
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    minimum_order_value DECIMAL(18,2) DEFAULT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'Active',
    CHECK (discount_percentage BETWEEN 0 AND 100),
    CHECK (minimum_order_value IS NULL OR minimum_order_value >= 0)
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng ratings_feedback (Đánh giá & phản hồi sản phẩm)
CREATE TABLE ratings_feedback (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    product_id INT NOT NULL,
    rating INT NOT NULL,
    comment TEXT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (rating BETWEEN 1 AND 5),
    FOREIGN KEY (customer_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng carts (Giỏ hàng)
CREATE TABLE carts (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL UNIQUE,
    FOREIGN KEY (customer_id) REFERENCES users(user_id)
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng cart_items (Chi tiết giỏ hàng)
CREATE TABLE cart_items (
    cart_item_id INT AUTO_INCREMENT PRIMARY KEY,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    original_price DECIMAL(18,2) NOT NULL,
    CHECK (quantity > 0),
    CHECK (original_price >= 0),
    FOREIGN KEY (cart_id) REFERENCES carts(cart_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng blogs (Bài viết)
CREATE TABLE blogs (
    blog_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    author_id BIGINT NOT NULL,
    category VARCHAR(50) DEFAULT NULL,
    view_count INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT NULL,
    FOREIGN KEY (author_id) REFERENCES users(user_id)
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng faq (Câu hỏi thường gặp)
CREATE TABLE faq (
    faq_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT DEFAULT NULL,
    question TEXT NOT NULL,
    answer TEXT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng payment_details (Chi tiết thanh toán)
CREATE TABLE payment_details (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(50) NOT NULL DEFAULT 'Pending',
    payment_date DATETIME DEFAULT NULL,
    transaction_id VARCHAR(255) DEFAULT NULL,
    CHECK (payment_status IN ('Pending','Completed','Failed','Refunded')),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng order_history (Lịch sử đơn hàng)
CREATE TABLE order_history (
    order_history_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    note TEXT DEFAULT NULL,
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (status IN ('Pending','Shipped','Delivered','Canceled')),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng skin_type_tests (Kiểm tra loại da)
CREATE TABLE skin_type_tests (
    test_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    test_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    result_skin_type_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES users(user_id),
    FOREIGN KEY (result_skin_type_id) REFERENCES skin_types(skin_type_id)
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng test_results (Kết quả kiểm tra loại da)
CREATE TABLE test_results (
    result_id INT AUTO_INCREMENT PRIMARY KEY,
    test_id INT NOT NULL,
    total_A INT NOT NULL DEFAULT 0,
    total_B INT NOT NULL DEFAULT 0,
    total_C INT NOT NULL DEFAULT 0,
    total_D INT NOT NULL DEFAULT 0,
    final_skin_type_id INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (test_id) REFERENCES skin_type_tests(test_id),
    FOREIGN KEY (final_skin_type_id) REFERENCES skin_types(skin_type_id)
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng delivery_details (Chi tiết giao hàng)
CREATE TABLE delivery_details (
    delivery_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    delivery_status VARCHAR(50) NOT NULL DEFAULT 'Pending',
    courier_name VARCHAR(255) DEFAULT NULL,
    tracking_number VARCHAR(255) DEFAULT NULL,
    delivery_date DATETIME DEFAULT NULL,
    estimated_delivery_date DATETIME DEFAULT NULL,
    delivered_date DATETIME DEFAULT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng inventory_logs (Nhật ký kho hàng)
CREATE TABLE inventory_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity_change INT NOT NULL,
    log_type VARCHAR(50) NOT NULL,
    log_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reason TEXT DEFAULT NULL,
    CHECK (log_type IN ('Stock-In','Stock-Out','Restock')),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng promotion_applications (Áp dụng khuyến mãi)
CREATE TABLE promotion_applications (
    application_id INT AUTO_INCREMENT PRIMARY KEY,
    promotion_id INT NOT NULL,
    product_id INT DEFAULT NULL,
    order_id INT DEFAULT NULL,
    applied_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    discount_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (promotion_id) REFERENCES promotions(promotion_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng product_comparisons (So sánh sản phẩm)
CREATE TABLE product_comparisons (
    comparison_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    product1_id INT NOT NULL,
    product2_id INT NOT NULL,
    comparison_result TEXT DEFAULT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product1_id) REFERENCES products(product_id),
    FOREIGN KEY (product2_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng product_attributes (Thuộc tính sản phẩm)
CREATE TABLE product_attributes (
    attribute_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    attribute_name VARCHAR(255) NOT NULL,
    attribute_value VARCHAR(255) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng product_images (Hình ảnh sản phẩm)
CREATE TABLE product_images (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    image_url TEXT NOT NULL,
    is_main_image BOOLEAN NOT NULL DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng user_notifications (Thông báo người dùng)
CREATE TABLE user_notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL DEFAULT 'General',
    status VARCHAR(50) NOT NULL DEFAULT 'Unread',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng recommended_products (Gợi ý sản phẩm theo loại da)
CREATE TABLE recommended_products (
    recommendation_id INT AUTO_INCREMENT PRIMARY KEY,
    skin_type_id INT NOT NULL,
    product_id INT NOT NULL,
    recommendation_reason VARCHAR(255) DEFAULT NULL,
    FOREIGN KEY (skin_type_id) REFERENCES skin_types(skin_type_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

--------------------------------------------------
-- Bảng customer_points (Điểm thưởng khách hàng)
CREATE TABLE customer_points (
    point_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    points INT NOT NULL,
    point_type VARCHAR(50) NOT NULL DEFAULT 'Earned',
    order_id INT DEFAULT NULL,
    earned_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    redeemed_date DATETIME DEFAULT NULL,
    CHECK (points >= 0),
    FOREIGN KEY (customer_id) REFERENCES users(user_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
) ENGINE=InnoDB;

--------------------------------------------------
-- Tạo bảng sales_reports: lưu trữ báo cáo doanh số tổng hợp theo khoảng thời gian
CREATE TABLE sales_reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    report_date DATE NOT NULL,  -- Ngày báo cáo
    total_revenue DECIMAL(18,2) NOT NULL,
    total_orders INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

--------------------------------------------------
-- Tạo bảng sales_report_details: lưu trữ chi tiết doanh số theo sản phẩm trong báo cáo
CREATE TABLE sales_report_details (
    detail_id INT AUTO_INCREMENT PRIMARY KEY,
    report_id INT NOT NULL,
    product_id INT NOT NULL,
    product_quantity INT NOT NULL,
    product_revenue DECIMAL(18,2) NOT NULL,
    FOREIGN KEY (report_id) REFERENCES sales_reports(report_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;
