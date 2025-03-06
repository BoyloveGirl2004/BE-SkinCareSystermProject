-- 1. Xóa và tạo lại database
DROP DATABASE IF EXISTS skincaresellproduct;
GO
CREATE DATABASE skincaresellproduct;
GO
USE skincaresellproduct;
GO

-- 2. Bảng cancellation_policies
CREATE TABLE cancellation_policies (
    policy_id INT IDENTITY(1,1) PRIMARY KEY,
    policy_name VARCHAR(255) NOT NULL,
    description NVARCHAR(MAX) NULL,
    applicable_days INT NOT NULL,
    policy_type VARCHAR(50) NOT NULL DEFAULT 'Refund',
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

-- 3. Bảng users
CREATE TABLE users (
    user_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_name VARCHAR(255) NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash NVARCHAR(MAX) NOT NULL,
    role VARCHAR(50) NOT NULL CONSTRAINT CHK_users_role CHECK (role IN ('Customer','Staff','Manager')),
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    status BIT NOT NULL DEFAULT 1,
    gender VARCHAR(10) NULL CONSTRAINT CHK_users_gender CHECK (gender IN ('Male','Female')),
    date_of_birth DATE NULL,
    address NVARCHAR(MAX) NULL,
    phone_number VARCHAR(20) NULL,
    profile_image NVARCHAR(MAX) NULL,
    money DECIMAL(18,2) NOT NULL DEFAULT 0,
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

-- 4. Bảng products
CREATE TABLE products (
    product_id INT IDENTITY(1,1) PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    description NVARCHAR(MAX) NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(18,2) NOT NULL,
    stock_quantity INT NOT NULL,
    product_image NVARCHAR(MAX) NULL,
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'Available' 
           CONSTRAINT CHK_products_status CHECK (status IN ('Available','OutOfStock','Discontinued')),
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

-- 5. Bảng skin_types
CREATE TABLE skin_types (
    skin_type_id INT IDENTITY(1,1) PRIMARY KEY,
    skin_type VARCHAR(50) NOT NULL UNIQUE,
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

-- 6. Bảng skin_care_routines
CREATE TABLE skin_care_routines (
    routine_id INT IDENTITY(1,1) PRIMARY KEY,
    skin_type_id INT NOT NULL,
    step_number INT NOT NULL,
    description NVARCHAR(MAX) NOT NULL,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CONSTRAINT UQ_skin_care_routines UNIQUE (skin_type_id, step_number),
    CONSTRAINT FK_skin_care_routines_skin_types FOREIGN KEY (skin_type_id) REFERENCES skin_types(skin_type_id)
);
GO

-- 7. Bảng orders
CREATE TABLE orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    total_price DECIMAL(18,2) NOT NULL,
    order_status VARCHAR(50) NOT NULL DEFAULT 'Pending' 
                 CONSTRAINT CHK_orders_status CHECK (order_status IN ('Pending','Shipped','Delivered','Canceled')),
    cancellation_policy_id INT NULL,
    discount_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME NULL,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_orders_users FOREIGN KEY (customer_id) REFERENCES users(user_id),
    CONSTRAINT FK_orders_cancellation_policies FOREIGN KEY (cancellation_policy_id) REFERENCES cancellation_policies(policy_id)
);
GO

-- 8. Bảng order_items
CREATE TABLE order_items (
    order_item_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(18,2) NOT NULL,
    discount_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_order_items_orders FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT FK_order_items_products FOREIGN KEY (product_id) REFERENCES products(product_id)
);
GO

-- 9. Bảng promotions
CREATE TABLE promotions (
    promotion_id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    description NVARCHAR(MAX) NULL,
    discount_percentage DECIMAL(5,2) NOT NULL,
    start_date DATETIME NOT NULL DEFAULT GETDATE(),
    end_date DATETIME NOT NULL DEFAULT GETDATE(),
    minimum_order_value DECIMAL(18,2) NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'Active',
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

-- 10. Bảng ratings_feedback
CREATE TABLE ratings_feedback (
    feedback_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    product_id INT NOT NULL,
    rating INT NOT NULL,
    comment NVARCHAR(MAX) NULL,
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    IsDeleted BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_ratings_feedback_users FOREIGN KEY (customer_id) REFERENCES users(user_id),
    CONSTRAINT FK_ratings_feedback_products FOREIGN KEY (product_id) REFERENCES products(product_id)
);
GO

-- 11. Bảng payment_details
CREATE TABLE payment_details (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(50) NOT NULL DEFAULT 'Pending',
    payment_date DATETIME NULL,
    transaction_id VARCHAR(255) NULL,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_payment_details_orders FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);
GO

-- 12. Bảng order_history
CREATE TABLE order_history (
    order_history_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    note NVARCHAR(MAX) NULL,
    update_time DATETIME NOT NULL DEFAULT GETDATE(),
    IsDeleted BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_order_history_orders FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);
GO

-- 13. Bảng skin_type_tests
CREATE TABLE skin_type_tests (
    test_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    test_date DATETIME NOT NULL DEFAULT GETDATE(),
    result_skin_type_id INT NOT NULL,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CONSTRAINT UQ_skin_type_tests UNIQUE (customer_id, test_date),
    CONSTRAINT FK_skin_type_tests_users FOREIGN KEY (customer_id) REFERENCES users(user_id),
    CONSTRAINT FK_skin_type_tests_skin_types FOREIGN KEY (result_skin_type_id) REFERENCES skin_types(skin_type_id)
);
GO

-- 14. Bảng test_results
CREATE TABLE test_results (
    result_id INT IDENTITY(1,1) PRIMARY KEY,
    test_id INT NOT NULL,
    total_A INT NOT NULL DEFAULT 0,
    total_B INT NOT NULL DEFAULT 0,
    total_C INT NOT NULL DEFAULT 0,
    total_D INT NOT NULL DEFAULT 0,
    final_skin_type_id INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    IsDeleted BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_test_results_skin_type_tests FOREIGN KEY (test_id) REFERENCES skin_type_tests(test_id),
    CONSTRAINT FK_test_results_skin_types FOREIGN KEY (final_skin_type_id) REFERENCES skin_types(skin_type_id)
);
GO

-- 15. Bảng promotion_applications
CREATE TABLE promotion_applications (
    application_id INT IDENTITY(1,1) PRIMARY KEY,
    promotion_id INT NOT NULL,
    product_id INT NULL,
    order_id INT NULL,
    applied_date DATETIME NOT NULL DEFAULT GETDATE(),
    discount_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_promotion_applications_promotions FOREIGN KEY (promotion_id) REFERENCES promotions(promotion_id),
    CONSTRAINT FK_promotion_applications_products FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT FK_promotion_applications_orders FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
GO

-- 16. Bảng recommended_products
CREATE TABLE recommended_products (
    recommendation_id INT IDENTITY(1,1) PRIMARY KEY,
    skin_type_id INT NOT NULL,
    product_id INT NOT NULL,
    recommendation_reason VARCHAR(255) NULL,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CONSTRAINT UQ_recommended_products UNIQUE (skin_type_id, product_id),
    CONSTRAINT FK_recommended_products_skin_types FOREIGN KEY (skin_type_id) REFERENCES skin_types(skin_type_id),
    CONSTRAINT FK_recommended_products_products FOREIGN KEY (product_id) REFERENCES products(product_id)
);
GO

-- 17. Bảng blogs
CREATE TABLE blogs (
    blog_id INT IDENTITY(1,1) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    author_id BIGINT NOT NULL,
    category VARCHAR(50) NULL,
    view_count INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME NULL,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_blogs_users FOREIGN KEY (author_id) REFERENCES users(user_id)
);
GO

-- 18. Bảng faq
CREATE TABLE faq (
    faq_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NULL,
    question NVARCHAR(MAX) NOT NULL,
    answer NVARCHAR(MAX) NULL,
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    IsDeleted BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_faq_products FOREIGN KEY (product_id) REFERENCES products(product_id)
);
GO

-- 19. Bảng sales_reports
CREATE TABLE sales_reports (
    report_id INT IDENTITY(1,1) PRIMARY KEY,
    report_date DATE NOT NULL,
    total_revenue DECIMAL(18,2) NOT NULL,
    total_orders INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

-- 20. Bảng sales_report_details
CREATE TABLE sales_report_details (
    detail_id INT IDENTITY(1,1) PRIMARY KEY,
    report_id INT NOT NULL,
    product_id INT NOT NULL,
    product_quantity INT NOT NULL,
    product_revenue DECIMAL(18,2) NOT NULL,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_sales_report_details_sales_reports FOREIGN KEY (report_id) REFERENCES sales_reports(report_id) ON DELETE CASCADE,
    CONSTRAINT FK_sales_report_details_products FOREIGN KEY (product_id) REFERENCES products(product_id)
);
GO
