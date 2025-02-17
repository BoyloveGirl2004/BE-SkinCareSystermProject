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
CREATE TABLE [dbo].[Users] (
    [UserId] NVARCHAR(450) NOT NULL PRIMARY KEY,
    [UserName] NVARCHAR(255) NULL,
    [Email] NVARCHAR(255) NOT NULL UNIQUE,
    [PasswordHash] NVARCHAR(MAX) NOT NULL,
    [Role] NVARCHAR(50) NOT NULL CHECK (Role IN ('Customer', 'Staff', 'Manager')),
    [Gender] NVARCHAR(10) NULL, -- Male, Female, Other
    [DateOfBirth] DATE NULL,
    [Address] NVARCHAR(MAX) NULL,
    [PhoneNumber] NVARCHAR(20) NULL,
    [ProfileImage] NVARCHAR(MAX) NULL, -- URL ảnh đại diện
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [Status] BIT NOT NULL DEFAULT 1 -- 1: Active, 0: Inactive
);

-- Tạo bảng Products
CREATE TABLE [dbo].[Products] (
    [ProductId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ProductName] NVARCHAR(255) NOT NULL,
    [Description] NVARCHAR(MAX) NULL,
    [Category] NVARCHAR(50) NOT NULL,
    [Price] DECIMAL(18, 2) NOT NULL,
    [StockQuantity] INT NOT NULL CHECK (StockQuantity >= 0),
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [UpdatedAt] DATETIME2 NULL,
    [Status] NVARCHAR(50) NOT NULL DEFAULT 'Available' -- Available, OutOfStock, Discontinued
);

-- Bảng chính sách hủy
CREATE TABLE [dbo].[CancellationPolicies] (
    [PolicyId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [PolicyName] NVARCHAR(255) NOT NULL,
    [Description] NVARCHAR(MAX) NULL,
    [ApplicableDays] INT NOT NULL CHECK (ApplicableDays > 0), -- Số ngày áp dụng
    [PolicyType] NVARCHAR(50) NOT NULL DEFAULT 'Refund' -- Refund, Exchange, etc.
);

-- Tạo bảng SkinTypes
CREATE TABLE [dbo].[SkinTypes] (
    [SkinTypeId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [SkinType] NVARCHAR(50) NOT NULL UNIQUE -- Da dầu, Da hỗn hợp, Da khô, Da thường
);

-- Bảng SkinCareRoutines
CREATE TABLE [dbo].[SkinCareRoutines] (
    [RoutineId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [SkinTypeId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[SkinTypes](SkinTypeId),
    [StepNumber] INT NOT NULL CHECK (StepNumber > 0),
    [Description] NVARCHAR(MAX) NOT NULL
);

-- Bảng Orders
CREATE TABLE [dbo].[Orders] (
    [OrderId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [CustomerId] NVARCHAR(450) NOT NULL FOREIGN KEY REFERENCES [dbo].[Users](UserId),
    [TotalPrice] DECIMAL(18, 2) NOT NULL CHECK (TotalPrice >= 0),
    [OrderStatus] NVARCHAR(50) NOT NULL DEFAULT 'Pending',
    [PolicyId] INT NULL FOREIGN KEY REFERENCES [dbo].[CancellationPolicies](PolicyId),
    [ShippingAddressId] INT NULL FOREIGN KEY REFERENCES [dbo].[ShippingAddresses](AddressId),
    [DiscountAmount] DECIMAL(18,2) NOT NULL DEFAULT 0, 
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [UpdatedAt] DATETIME2 NULL
);

-- Bảng OrderItems (Đổi Price thành UnitPrice)
CREATE TABLE [dbo].[OrderItems] (
    [OrderItemId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [OrderId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Orders](OrderId),
    [ProductId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Products](ProductId),
    [Quantity] INT NOT NULL CHECK (Quantity > 0),
    [UnitPrice] DECIMAL(18, 2) NOT NULL CHECK (UnitPrice >= 0),
    [DiscountAmount] DECIMAL(18,2) NOT NULL DEFAULT 0
);

-- Bảng Promotions
CREATE TABLE [dbo].[Promotions] (
    [PromotionId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Code] NVARCHAR(50) NOT NULL UNIQUE,
    [Description] NVARCHAR(MAX) NULL,
    [DiscountPercentage] DECIMAL(5, 2) NOT NULL CHECK (DiscountPercentage BETWEEN 0 AND 100),
    [StartDate] DATETIME NOT NULL,
    [EndDate] DATETIME NOT NULL,
    [MinimumOrderValue] DECIMAL(18, 2) NULL CHECK (MinimumOrderValue >= 0),
    [Status] NVARCHAR(50) NOT NULL DEFAULT 'Active' -- Active, Expired
);

-- Bảng Ratings & Feedback (đánh giá sản phẩm)
CREATE TABLE [dbo].[RatingsFeedback] (
    [FeedbackId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [CustomerId] NVARCHAR(450) NOT NULL FOREIGN KEY REFERENCES [dbo].[Users](UserId),
    [ProductId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Products](ProductId),
    [Rating] INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    [Comment] NVARCHAR(MAX) NULL,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETDATE()
);

-- Bảng Carts
CREATE TABLE [dbo].[Carts] (
    [CartId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [CustomerId] NVARCHAR(450) NOT NULL UNIQUE FOREIGN KEY REFERENCES [dbo].[Users](UserId)
);

-- Bảng CartItems (Thêm OriginalPrice)
CREATE TABLE [dbo].[CartItems] (
    [CartItemId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [CartId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Carts](CartId),
    [ProductId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Products](ProductId),
    [Quantity] INT NOT NULL CHECK (Quantity > 0),
    [OriginalPrice] DECIMAL(18, 2) NOT NULL CHECK (OriginalPrice >= 0)
);

-- Bảng blog
CREATE TABLE [dbo].[Blogs] (
    [BlogId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Title] NVARCHAR(255) NOT NULL,
    [Content] NVARCHAR(MAX) NOT NULL,
    [AuthorId] NVARCHAR(450) NOT NULL FOREIGN KEY REFERENCES [dbo].[Users](UserId),
    [Category] NVARCHAR(50) NULL,
    [ViewCount] INT NOT NULL DEFAULT 0,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [UpdatedAt] DATETIME2 NULL
);

-- Bảng báo cáo
CREATE TABLE [dbo].[Reports] (
    [ReportId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ManagerId] NVARCHAR(450) NOT NULL FOREIGN KEY REFERENCES [dbo].[Users](UserId),
    [ReportType] NVARCHAR(50) NOT NULL, -- Sales, Inventory, Customer
    [ReportStatus] NVARCHAR(50) NOT NULL DEFAULT 'Pending', -- Pending, Completed
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [Content] NVARCHAR(MAX) NOT NULL
);

-- Bảng CustomerProfiles (Mỗi khách hàng chỉ có một hồ sơ)
CREATE TABLE [dbo].[CustomerProfiles] (
    [ProfileId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [CustomerId] NVARCHAR(450) NOT NULL UNIQUE FOREIGN KEY REFERENCES [dbo].[Users](UserId),
    [SkinTypeId] INT NULL FOREIGN KEY REFERENCES [dbo].[SkinTypes](SkinTypeId)
);


-- Bảng FAQ (ProductId có thể NULL)
CREATE TABLE [dbo].[FAQ] (
    [FaqId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ProductId] INT NULL FOREIGN KEY REFERENCES [dbo].[Products](ProductId),
    [Question] NVARCHAR(MAX) NOT NULL,
    [Answer] NVARCHAR(MAX) NULL,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETDATE()
);

-- Bảng PaymentDetails (Thêm TransactionId)
CREATE TABLE [dbo].[PaymentDetails] (
    [PaymentId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [OrderId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Orders](OrderId),
    [PaymentMethod] NVARCHAR(50) NOT NULL,
    [PaymentStatus] NVARCHAR(50) NOT NULL DEFAULT 'Pending',
    [PaymentDate] DATETIME2 NULL,
    [TransactionId] NVARCHAR(255) NULL
);

-- Bảng ShippingAddresses (Thêm OrderId)
CREATE TABLE [dbo].[ShippingAddresses] (
    [AddressId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [UserId] NVARCHAR(450) NOT NULL FOREIGN KEY REFERENCES [dbo].[Users](UserId),
    [Address] NVARCHAR(MAX) NOT NULL,
    [City] NVARCHAR(100) NOT NULL,
    [State] NVARCHAR(100) NULL,
    [PostalCode] NVARCHAR(20) NOT NULL,
    [Country] NVARCHAR(100) NOT NULL,
    [PhoneNumber] NVARCHAR(20) NULL,
    [IsDefault] BIT NOT NULL DEFAULT 0
);

-- Bảng lịch sử đơn hàng
CREATE TABLE [dbo].[OrderHistory] (
    [OrderHistoryId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [OrderId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Orders](OrderId),
    [Status] NVARCHAR(50) NOT NULL CHECK (Status IN ('Pending', 'Shipped', 'Delivered', 'Canceled')),
    [Note] NVARCHAR(MAX) NULL,
    [UpdateTime] DATETIME2 NOT NULL DEFAULT GETDATE()
);

-- Bảng kiểm tra loại da
CREATE TABLE [dbo].[SkinTypeTests] (
    [TestId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [CustomerId] NVARCHAR(450) NOT NULL FOREIGN KEY REFERENCES [dbo].[Users](UserId),
    [TestDate] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [ResultSkinTypeId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[SkinTypes](SkinTypeId)
);

-- Bảng câu hỏi kiểm tra
CREATE TABLE [dbo].[TestQuestions] (
    [QuestionId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [QuestionText] NVARCHAR(MAX) NOT NULL,
    [QuestionType] NVARCHAR(50) NOT NULL DEFAULT 'Single Choice' -- Single Choice, Multiple Choice
);

-- Bảng câu trả lời kiểm tra
CREATE TABLE [dbo].[TestAnswers] (
    [AnswerId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [QuestionId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[TestQuestions](QuestionId),
    [AnswerText] NVARCHAR(MAX) NOT NULL,
    [OptionLabel] NVARCHAR(1) NOT NULL CHECK (OptionLabel IN ('A', 'B', 'C', 'D')),
    [SkinTypeId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[SkinTypes](SkinTypeId)
);

-- Bảng kết quả kiểm tra
CREATE TABLE [dbo].[TestResults] (
    [ResultId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [TestId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[SkinTypeTests](TestId),
    [QuestionId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[TestQuestions](QuestionId),
    [AnswerId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[TestAnswers](AnswerId),
    [OptionLabel] NVARCHAR(1) NOT NULL CHECK (OptionLabel IN ('A', 'B', 'C', 'D')),
    [Score] INT NOT NULL DEFAULT 0
);

-- Bảng chi tiết giao hàng
CREATE TABLE [dbo].[DeliveryDetails] (
    [DeliveryId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [OrderId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Orders](OrderId),
    [DeliveryStatus] NVARCHAR(50) NOT NULL DEFAULT 'Pending', -- Pending, Shipped, Delivered
    [CourierName] NVARCHAR(255) NULL,
    [TrackingNumber] NVARCHAR(255) NULL,
    [DeliveryDate] DATETIME2 NULL,
    [EstimatedDeliveryDate] DATETIME2 NULL, -- Ngày giao hàng dự kiến
    [DeliveredDate] DATETIME2 NULL -- Ngày giao hàng thành công
);

-- Bảng InventoryLogs (Thêm Restock vào LogType)
CREATE TABLE [dbo].[InventoryLogs] (
    [LogId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ProductId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Products](ProductId),
    [QuantityChange] INT NOT NULL,
    [LogType] NVARCHAR(50) NOT NULL CHECK (LogType IN ('Stock-In', 'Stock-Out', 'Restock')),
    [LogDate] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [Reason] NVARCHAR(MAX) NULL
);

-- Bảng PromotionApplications (Thêm AppliedToOrder)
CREATE TABLE [dbo].[PromotionApplications] (
    [ApplicationId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [PromotionId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Promotions](PromotionId),
    [ProductId] INT NULL FOREIGN KEY REFERENCES [dbo].[Products](ProductId),
    [OrderId] INT NULL FOREIGN KEY REFERENCES [dbo].[Orders](OrderId),
    [AppliedDate] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [AppliedToOrder] BIT NOT NULL DEFAULT 0,
    [DiscountAmount] DECIMAL(18,2) NOT NULL DEFAULT 0
);

-- Bảng thuộc tính sản phẩm
CREATE TABLE [dbo].[ProductAttributes] (
    [AttributeId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ProductId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Products](ProductId),
    [AttributeName] NVARCHAR(255) NOT NULL,
    [AttributeValue] NVARCHAR(255) NOT NULL
);

-- Bảng ProductImages
CREATE TABLE [dbo].[ProductImages] (
    [ImageId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ProductId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Products](ProductId),
    [ImageUrl] NVARCHAR(MAX) NOT NULL,
    [IsMainImage] BIT NOT NULL DEFAULT 0,
    CONSTRAINT CHK_MainImage UNIQUE (ProductId, IsMainImage) WHERE IsMainImage = 1
);

-- Bảng thông báo người dùng
CREATE TABLE [dbo].[UserNotifications] (
    [NotificationId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [UserId] NVARCHAR(450) NOT NULL FOREIGN KEY REFERENCES [dbo].[Users](UserId),
    [Message] NVARCHAR(MAX) NOT NULL,
    [NotificationType] NVARCHAR(50) NOT NULL DEFAULT 'General', -- Order Update, Promotion, etc.
    [Status] NVARCHAR(50) NOT NULL DEFAULT 'Unread',
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETDATE()
);

-- Bảng gợi ý sản phẩm theo loại da
CREATE TABLE [dbo].[ProductRecommendations] (
    [RecommendationId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [SkinTypeId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[SkinTypes](SkinTypeId),
    [ProductId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Products](ProductId),
    [RoutineStep] INT NOT NULL,
    [RecommendationReason] NVARCHAR(255) NULL -- Best Seller, User Rating, etc.
);

-- Bảng điểm thưởng khách hàng
CREATE TABLE [dbo].[CustomerPoints] (
    [PointId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [CustomerId] NVARCHAR(450) NOT NULL FOREIGN KEY REFERENCES [dbo].[Users](UserId),
    [Points] INT NOT NULL CHECK (Points >= 0),
    [PointType] NVARCHAR(50) NOT NULL DEFAULT 'Earned', -- Earned, Redeemed
    [OrderId] INT NULL FOREIGN KEY REFERENCES [dbo].[Orders](OrderId),
    [EarnedDate] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [RedeemedDate] DATETIME2 NULL
);

