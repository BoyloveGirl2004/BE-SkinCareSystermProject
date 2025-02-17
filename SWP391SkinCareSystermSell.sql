-- Xóa database cũ nếu có
DROP DATABASE IF EXISTS SWP391SkinCareSellSystem;
GO

-- Tạo lại database
CREATE DATABASE SWP391SkinCareSellSystem;
GO

-- Sử dụng database mới
USE SWP391SkinCareSellSystem;
GO

-- Tạo bảng Users
CREATE TABLE [dbo].[users] (
    [user_id] BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [user_name] NVARCHAR(255) NULL,
    [email] NVARCHAR(255) NOT NULL UNIQUE,
    [password_hash] NVARCHAR(MAX) NOT NULL,
    [role] NVARCHAR(50) NOT NULL CHECK ([role] IN ('Customer', 'Staff', 'Manager')),
    [created_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [status] BIT NOT NULL DEFAULT 1, -- 1: Active, 0: Inactive
    [gender] NVARCHAR(10) NULL, -- Male, Female
    [date_of_birth] DATE NULL,
    [address] NVARCHAR(MAX) NULL,
    [phone_number] NVARCHAR(20) NULL,
    [profile_image] NVARCHAR(MAX) NULL -- Đường dẫn ảnh đại diện
);

-- Tạo bảng products với chuẩn snake_case
CREATE TABLE [dbo].[products] (
    [product_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [product_name] NVARCHAR(255) NOT NULL,
    [description] NVARCHAR(MAX) NULL,
    [category] NVARCHAR(50) NOT NULL,
    [price] DECIMAL(18, 2) NOT NULL,
    [stock_quantity] INT NOT NULL CHECK ([stock_quantity] >= 0),
    [created_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [updated_at] DATETIME2 NULL,
    [status] NVARCHAR(50) NOT NULL DEFAULT 'Available' -- Available, OutOfStock, Discontinued
);

-- Bảng chính sách hủy
CREATE TABLE [dbo].[cancellation_policies] (
    [policy_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [policy_name] NVARCHAR(255) NOT NULL,
    [description] NVARCHAR(MAX) NULL,
    [applicable_days] INT NOT NULL CHECK ([applicable_days] > 0), -- Số ngày áp dụng
    [policy_type] NVARCHAR(50) NOT NULL DEFAULT 'Refund' -- Refund, Exchange, etc.
);

-- Bảng loại da (SkinTypes)
CREATE TABLE [dbo].[skin_types] (
    [skin_type_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [skin_type] NVARCHAR(50) NOT NULL UNIQUE -- Da dầu, Da hỗn hợp, Da khô, Da thường
);

-- Bảng quy trình chăm sóc da (SkinCareRoutines)
CREATE TABLE [dbo].[skin_care_routines] (
    [routine_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [step_number] INT NOT NULL CHECK ([step_number] > 0),
    [description] NVARCHAR(MAX) NOT NULL
);

CREATE TABLE [dbo].[skin_care_routine_skin_types] (
    [routine_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[skin_care_routines](routine_id),
    [skin_type_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[skin_types](skin_type_id),
    PRIMARY KEY ([routine_id], [skin_type_id])
);

-- Bảng gợi ý sản phẩm sử dụng
CREATE TABLE [dbo].[recommended_products] (
    [product_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [product_name] NVARCHAR(255) NOT NULL,
    [brand] NVARCHAR(100) NOT NULL,
    [description] NVARCHAR(MAX),
    [skin_type_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[skin_types](skin_type_id)
);

-- Bảng tip chăm sóc da mặt
CREATE TABLE [dbo].[skin_care_tips] (
    [tip_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [tip_text] NVARCHAR(MAX) NOT NULL,
    [skin_type_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[skin_types](skin_type_id)
);


-- Bảng địa chỉ giao hàng (ShippingAddresses)
CREATE TABLE [dbo].[shipping_addresses] (
    [address_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [user_id] BIGINT NOT NULL FOREIGN KEY REFERENCES [dbo].[users](user_id),
    [address] NVARCHAR(MAX) NOT NULL,
    [city] NVARCHAR(100) NOT NULL,
    [state] NVARCHAR(100) NULL,
    [postal_code] NVARCHAR(20) NOT NULL,
    [country] NVARCHAR(100) NOT NULL,
    [phone_number] NVARCHAR(20) NULL,
    [is_default] BIT NOT NULL DEFAULT 0
);

-- Bảng đơn hàng (Orders)
CREATE TABLE [dbo].[orders] (
    [order_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [customer_id] BIGINT NOT NULL FOREIGN KEY REFERENCES [dbo].[users](user_id),
    [total_price] DECIMAL(18, 2) NOT NULL CHECK ([total_price] >= 0),
    [order_status] NVARCHAR(50) NOT NULL DEFAULT 'Pending',
    [policy_id] INT NULL FOREIGN KEY REFERENCES [dbo].[cancellation_policies](policy_id),
    [shipping_address_id] INT NULL FOREIGN KEY REFERENCES [dbo].[shipping_addresses](address_id),
    [discount_amount] DECIMAL(18,2) NOT NULL DEFAULT 0, 
    [created_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [updated_at] DATETIME2 NULL
);

-- Bảng chi tiết đơn hàng (OrderItems)
CREATE TABLE [dbo].[order_items] (
    [order_item_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [order_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[orders](order_id),
    [product_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[products](product_id),
    [quantity] INT NOT NULL CHECK ([quantity] > 0),
    [unit_price] DECIMAL(18, 2) NOT NULL CHECK ([unit_price] >= 0),
    [discount_amount] DECIMAL(18,2) NOT NULL DEFAULT 0
);

-- Bảng khuyến mãi (Promotions)
CREATE TABLE [dbo].[promotions] (
    [promotion_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [code] NVARCHAR(50) NOT NULL UNIQUE,
    [description] NVARCHAR(MAX) NULL,
    [discount_percentage] DECIMAL(5, 2) NOT NULL CHECK ([discount_percentage] BETWEEN 0 AND 100),
    [start_date] DATETIME NOT NULL,
    [end_date] DATETIME NOT NULL,
    [minimum_order_value] DECIMAL(18, 2) NULL CHECK ([minimum_order_value] >= 0),
    [status] NVARCHAR(50) NOT NULL DEFAULT 'Active' -- Active, Expired
);

-- Bảng đánh giá & phản hồi sản phẩm (Ratings & Feedback)
CREATE TABLE [dbo].[ratings_feedback] (
    [feedback_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [customer_id] BIGINT NOT NULL FOREIGN KEY REFERENCES [dbo].[users](user_id),
    [product_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[products](product_id),
    [rating] INT NOT NULL CHECK ([rating] BETWEEN 1 AND 5),
    [comment] NVARCHAR(MAX) NULL,
    [created_at] DATETIME2 NOT NULL DEFAULT GETDATE()
);

-- Bảng giỏ hàng (Carts)
CREATE TABLE [dbo].[carts] (
    [cart_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [customer_id] BIGINT NOT NULL UNIQUE FOREIGN KEY REFERENCES [dbo].[users](user_id)
);

-- Bảng chi tiết giỏ hàng (CartItems)
CREATE TABLE [dbo].[cart_items] (
    [cart_item_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [cart_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[carts](cart_id),
    [product_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[products](product_id),
    [quantity] INT NOT NULL CHECK ([quantity] > 0),
    [original_price] DECIMAL(18, 2) NOT NULL CHECK ([original_price] >= 0)
);

-- Bảng blog (Blogs)
CREATE TABLE [dbo].[blogs] (
    [blog_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [title] NVARCHAR(255) NOT NULL,
    [content] NVARCHAR(MAX) NOT NULL,
    [author_id] BIGINT NOT NULL FOREIGN KEY REFERENCES [dbo].[users](user_id),
    [category] NVARCHAR(50) NULL,
    [view_count] INT NOT NULL DEFAULT 0,
    [created_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [updated_at] DATETIME2 NULL
);

-- Bảng báo cáo (Reports)
CREATE TABLE [dbo].[reports] (
    [report_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [manager_id] BIGINT NOT NULL FOREIGN KEY REFERENCES [dbo].[users](user_id),
    [report_type] NVARCHAR(50) NOT NULL, -- Sales, Inventory, Customer
    [report_status] NVARCHAR(50) NOT NULL DEFAULT 'Pending', -- Pending, Completed
    [created_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [content] NVARCHAR(MAX) NOT NULL
);

-- Bảng hồ sơ khách hàng (CustomerProfiles)
CREATE TABLE [dbo].[customer_profiles] (
    [profile_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [customer_id] BIGINT NOT NULL UNIQUE FOREIGN KEY REFERENCES [dbo].[users](user_id),
    [skin_type_id] INT NULL FOREIGN KEY REFERENCES [dbo].[skin_types](skin_type_id)
);

-- Bảng FAQ (ProductId có thể NULL)
CREATE TABLE [dbo].[faq] (
    [faq_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [product_id] INT NULL FOREIGN KEY REFERENCES [dbo].[products](product_id),
    [question] NVARCHAR(MAX) NOT NULL,
    [answer] NVARCHAR(MAX) NULL,
    [created_at] DATETIME2 NOT NULL DEFAULT GETDATE()
);

-- Bảng chi tiết thanh toán (PaymentDetails)
CREATE TABLE [dbo].[payment_details] (
    [payment_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [order_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[orders](order_id),
    [payment_method] NVARCHAR(50) NOT NULL,
    [payment_status] NVARCHAR(50) NOT NULL DEFAULT 'Pending',
    [payment_date] DATETIME2 NULL,
    [transaction_id] NVARCHAR(255) NULL
);

-- Bảng lịch sử đơn hàng (OrderHistory)
CREATE TABLE [dbo].[order_history] (
    [order_history_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [order_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[orders](order_id),
    [status] NVARCHAR(50) NOT NULL CHECK ([status] IN ('Pending', 'Shipped', 'Delivered', 'Canceled')),
    [note] NVARCHAR(MAX) NULL,
    [update_time] DATETIME2 NOT NULL DEFAULT GETDATE()
);

-- Bảng kiểm tra loại da (SkinTypeTests)
CREATE TABLE [dbo].[skin_type_tests] (
    [test_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [customer_id] BIGINT NOT NULL FOREIGN KEY REFERENCES [dbo].[users](user_id),
    [test_date] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [result_skin_type_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[skin_types](skin_type_id)
);

-- Bảng câu hỏi kiểm tra loại da (TestQuestions)
CREATE TABLE [dbo].[test_questions] (
    [question_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [question_text] NVARCHAR(MAX) NOT NULL,
    [question_type] NVARCHAR(50) NOT NULL DEFAULT 'Single Choice' -- Single Choice, Multiple Choice
);

-- Bảng câu trả lời kiểm tra loại da (TestAnswers)
CREATE TABLE [dbo].[test_answers] (
    [answer_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [question_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[test_questions](question_id),
    [answer_text] NVARCHAR(MAX) NOT NULL,
    [option_label] NVARCHAR(1) NOT NULL CHECK ([option_label] IN ('A', 'B', 'C', 'D'))
);

-- Bảng kết quả kiểm tra loại da (TestResults)
CREATE TABLE [dbo].[test_results] (
    [result_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [test_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[skin_type_tests](test_id),
    [question_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[test_questions](question_id),
    [answer_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[test_answers](answer_id),
    [option_label] NVARCHAR(1) NOT NULL CHECK ([option_label] IN ('A', 'B', 'C', 'D')),
    [score] INT NOT NULL DEFAULT 0
);

-- Bảng chi tiết giao hàng (DeliveryDetails)
CREATE TABLE [dbo].[delivery_details] (
    [delivery_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [order_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[orders](order_id),
    [delivery_status] NVARCHAR(50) NOT NULL DEFAULT 'Pending', -- Pending, Shipped, Delivered
    [courier_name] NVARCHAR(255) NULL,
    [tracking_number] NVARCHAR(255) NULL,
    [delivery_date] DATETIME2 NULL,
    [estimated_delivery_date] DATETIME2 NULL, -- Ngày giao hàng dự kiến
    [delivered_date] DATETIME2 NULL -- Ngày giao hàng thành công
);

-- Bảng nhật ký kho hàng (InventoryLogs)
CREATE TABLE [dbo].[inventory_logs] (
    [log_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [product_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[products](product_id),
    [quantity_change] INT NOT NULL,
    [log_type] NVARCHAR(50) NOT NULL CHECK ([log_type] IN ('Stock-In', 'Stock-Out', 'Restock')),
    [log_date] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [reason] NVARCHAR(MAX) NULL
);

-- Bảng áp dụng khuyến mãi (PromotionApplications)
CREATE TABLE [dbo].[promotion_applications] (
    [application_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [promotion_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[promotions](promotion_id),
    [product_id] INT NULL FOREIGN KEY REFERENCES [dbo].[products](product_id),
    [order_id] INT NULL FOREIGN KEY REFERENCES [dbo].[orders](order_id),
    [applied_date] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [applied_to_order] BIT NOT NULL DEFAULT 0,
    [discount_amount] DECIMAL(18,2) NOT NULL DEFAULT 0
);

-- Bảng thuộc tính sản phẩm (ProductAttributes)
CREATE TABLE [dbo].[product_attributes] (
    [attribute_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [product_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[products](product_id),
    [attribute_name] NVARCHAR(255) NOT NULL,
    [attribute_value] NVARCHAR(255) NOT NULL
);

-- Bảng hình ảnh sản phẩm (ProductImages)
CREATE TABLE [dbo].[product_images] (
    [image_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [product_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[products](product_id),
    [image_url] NVARCHAR(MAX) NOT NULL,
    [is_main_image] BIT NOT NULL DEFAULT 0
);

-- Bảng thông báo người dùng (UserNotifications)
CREATE TABLE [dbo].[user_notifications] (
    [notification_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [user_id] BIGINT NOT NULL FOREIGN KEY REFERENCES [dbo].[users](user_id),
    [message] NVARCHAR(MAX) NOT NULL,
    [notification_type] NVARCHAR(50) NOT NULL DEFAULT 'General', -- Order Update, Promotion, etc.
    [status] NVARCHAR(50) NOT NULL DEFAULT 'Unread',
    [created_at] DATETIME2 NOT NULL DEFAULT GETDATE()
);

-- Bảng gợi ý sản phẩm theo loại da (ProductRecommendations)
CREATE TABLE [dbo].[product_recommendations] (
    [recommendation_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [skin_type_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[skin_types](skin_type_id),
    [product_id] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[products](product_id),
    [routine_step] INT NOT NULL CHECK ([routine_step] > 0),
    [recommendation_reason] NVARCHAR(255) NULL,
    CONSTRAINT UQ_Product_SkinType UNIQUE (skin_type_id, product_id, routine_step)
);

-- Bảng điểm thưởng khách hàng (CustomerPoints)
CREATE TABLE [dbo].[customer_points] (
    [point_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [customer_id] BIGINT NOT NULL FOREIGN KEY REFERENCES [dbo].[users](user_id),
    [points] INT NOT NULL CHECK ([points] >= 0),
    [point_type] NVARCHAR(50) NOT NULL DEFAULT 'Earned', -- Earned, Redeemed
    [order_id] INT NULL FOREIGN KEY REFERENCES [dbo].[orders](order_id),
    [earned_date] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [redeemed_date] DATETIME2 NULL
);
