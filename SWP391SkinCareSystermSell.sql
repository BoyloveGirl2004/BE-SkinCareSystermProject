-- Create database
CREATE DATABASE SWP391SkinCareSellSysterm;
GO

-- Use the newly created database
USE SWP391SkinCareSellSysterm;
GO

-- Create tables
CREATE TABLE [dbo].[Users] (
    [UserId] NVARCHAR(450) NOT NULL PRIMARY KEY,
    [UserName] NVARCHAR(255) NULL,
    [Email] NVARCHAR(255) NOT NULL UNIQUE,
    [PasswordHash] NVARCHAR(MAX) NOT NULL,
    [Role] NVARCHAR(50) NOT NULL CHECK (Role IN ('Customer', 'Staff', 'Manager')),
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [Status] BIT NOT NULL DEFAULT 1 -- Active or Inactive
);

CREATE TABLE [dbo].[Products] (
    [ProductId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ProductName] NVARCHAR(255) NOT NULL,
    [Description] NVARCHAR(MAX) NULL,
    [Category] NVARCHAR(50) NOT NULL,
    [Price] DECIMAL(18, 2) NOT NULL,
    [StockQuantity] INT NOT NULL,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [UpdatedAt] DATETIME2 NULL,
    [Status] NVARCHAR(50) NOT NULL DEFAULT 'Available' -- Available, OutOfStock, Discontinued
);

CREATE TABLE [dbo].[SkinTypes] (
    [SkinTypeId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [SkinType] NVARCHAR(50) NOT NULL -- Da dầu, Da hỗn hợp, Da khô, Da thường
);

CREATE TABLE [dbo].[SkinCareRoutines] (
    [RoutineId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [SkinTypeId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[SkinTypes](SkinTypeId),
    [StepNumber] INT NOT NULL,
    [Description] NVARCHAR(MAX) NOT NULL
);

CREATE TABLE [dbo].[Orders] (
    [OrderId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [CustomerId] NVARCHAR(450) NOT NULL FOREIGN KEY REFERENCES [dbo].[Users](UserId),
    [TotalPrice] DECIMAL(18, 2) NOT NULL,
    [OrderStatus] NVARCHAR(50) NOT NULL DEFAULT 'Pending', -- Pending, Shipped, Delivered, Canceled
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [UpdatedAt] DATETIME2 NULL
);

CREATE TABLE [dbo].[OrderItems] (
    [OrderItemId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [OrderId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Orders](OrderId),
    [ProductId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Products](ProductId),
    [Quantity] INT NOT NULL,
    [Price] DECIMAL(18, 2) NOT NULL
);

CREATE TABLE [dbo].[Promotions] (
    [PromotionId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Code] NVARCHAR(50) NOT NULL UNIQUE,
    [Description] NVARCHAR(MAX) NULL,
    [DiscountPercentage] DECIMAL(5, 2) NOT NULL,
    [StartDate] DATETIME NOT NULL,
    [EndDate] DATETIME NOT NULL,
    [Status] NVARCHAR(50) NOT NULL DEFAULT 'Active' -- Active, Expired
);

CREATE TABLE [dbo].[RatingsFeedback] (
    [FeedbackId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [CustomerId] NVARCHAR(450) NOT NULL FOREIGN KEY REFERENCES [dbo].[Users](UserId),
    [ProductId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Products](ProductId),
    [Rating] INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    [Comment] NVARCHAR(MAX) NULL,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETDATE()
);

CREATE TABLE [dbo].[Carts] (
    [CartId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [CustomerId] NVARCHAR(450) NOT NULL FOREIGN KEY REFERENCES [dbo].[Users](UserId)
);

CREATE TABLE [dbo].[CartItems] (
    [CartItemId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [CartId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Carts](CartId),
    [ProductId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Products](ProductId),
    [Quantity] INT NOT NULL,
    [Price] DECIMAL(18, 2) NOT NULL
);

CREATE TABLE [dbo].[Blogs] (
    [BlogId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Title] NVARCHAR(255) NOT NULL,
    [Content] NVARCHAR(MAX) NOT NULL,
    [AuthorId] NVARCHAR(450) NOT NULL FOREIGN KEY REFERENCES [dbo].[Users](UserId),
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [UpdatedAt] DATETIME2 NULL
);

CREATE TABLE [dbo].[Reports] (
    [ReportId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ManagerId] NVARCHAR(450) NOT NULL FOREIGN KEY REFERENCES [dbo].[Users](UserId),
    [ReportType] NVARCHAR(50) NOT NULL, -- Sales, Inventory, Customer
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [Content] NVARCHAR(MAX) NOT NULL
);

CREATE TABLE [dbo].[CustomerProfiles] (
    [ProfileId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [CustomerId] NVARCHAR(450) NOT NULL FOREIGN KEY REFERENCES [dbo].[Users](UserId),
    [SkinTypeId] INT NULL FOREIGN KEY REFERENCES [dbo].[SkinTypes](SkinTypeId),
    [Address] NVARCHAR(MAX) NULL,
    [PhoneNumber] NVARCHAR(20) NULL,
    [DateOfBirth] DATE NULL
);

CREATE TABLE [dbo].[FAQ] (
    [FaqId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Question] NVARCHAR(MAX) NOT NULL,
    [Answer] NVARCHAR(MAX) NOT NULL,
    [CreatedBy] NVARCHAR(450) NULL FOREIGN KEY REFERENCES [dbo].[Users](UserId), -- Người tạo câu hỏi/ trả lời
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETDATE()
);

CREATE TABLE [dbo].[PaymentDetails] (
    [PaymentId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [OrderId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Orders](OrderId),
    [PaymentMethod] NVARCHAR(50) NOT NULL, -- CreditCard, PayPal, BankTransfer, etc.
    [PaymentStatus] NVARCHAR(50) NOT NULL DEFAULT 'Pending', -- Pending, Completed, Failed
    [PaymentDate] DATETIME2 NULL
);

CREATE TABLE [dbo].[OrderHistory] (
    [OrderHistoryId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [OrderId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Orders](OrderId),
    [Status] NVARCHAR(50) NOT NULL, -- Pending, Shipped, Delivered, Canceled
    [UpdateTime] DATETIME2 NOT NULL DEFAULT GETDATE()
);

CREATE TABLE [dbo].[SkinTypeTests] (
    [TestId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [CustomerId] NVARCHAR(450) NOT NULL FOREIGN KEY REFERENCES [dbo].[Users](UserId),
    [TestDate] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [ResultSkinTypeId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[SkinTypes](SkinTypeId)
);

CREATE TABLE [dbo].[TestQuestions] (
    [QuestionId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [QuestionText] NVARCHAR(MAX) NOT NULL
);

CREATE TABLE [dbo].[TestAnswers] (
    [AnswerId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [QuestionId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[TestQuestions](QuestionId),
    [AnswerText] NVARCHAR(MAX) NOT NULL,
    [OptionLabel] NVARCHAR(1) NOT NULL CHECK (OptionLabel IN ('A', 'B', 'C', 'D')),
    [SkinTypeId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[SkinTypes](SkinTypeId)
);

CREATE TABLE [dbo].[TestResults] (
    [ResultId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [TestId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[SkinTypeTests](TestId),
    [QuestionId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[TestQuestions](QuestionId),
    [AnswerId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[TestAnswers](AnswerId),
    [OptionLabel] NVARCHAR(1) NOT NULL CHECK (OptionLabel IN ('A', 'B', 'C', 'D'))
);

CREATE TABLE [dbo].[DeliveryDetails] (
    [DeliveryId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [OrderId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Orders](OrderId),
    [DeliveryStatus] NVARCHAR(50) NOT NULL DEFAULT 'Pending', -- Pending, Shipped, Delivered
    [CourierName] NVARCHAR(255) NULL, -- Tên đơn vị vận chuyển
    [TrackingNumber] NVARCHAR(255) NULL, -- Mã theo dõi vận chuyển
    [DeliveryDate] DATETIME2 NULL, -- Ngày giao hàng dự kiến
    [DeliveredDate] DATETIME2 NULL -- Ngày giao hàng thành công
);

CREATE TABLE [dbo].[InventoryLogs] (
    [LogId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ProductId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Products](ProductId),
    [QuantityChange] INT NOT NULL, -- Positive for stock-in, negative for stock-out
    [LogType] NVARCHAR(50) NOT NULL, -- Stock-In, Stock-Out
    [LogDate] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [Reason] NVARCHAR(MAX) NULL -- Optional reason for the inventory change
);

CREATE TABLE [dbo].[PromotionApplications] (
    [ApplicationId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [PromotionId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Promotions](PromotionId),
    [ProductId] INT NULL FOREIGN KEY REFERENCES [dbo].[Products](ProductId),
    [OrderId] INT NULL FOREIGN KEY REFERENCES [dbo].[Orders](OrderId),
    [AppliedDate] DATETIME2 NOT NULL DEFAULT GETDATE()
);

CREATE TABLE [dbo].[ProductAttributes] (
    [AttributeId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ProductId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Products](ProductId),
    [AttributeName] NVARCHAR(255) NOT NULL, -- Tên thuộc tính (VD: Màu sắc)
    [AttributeValue] NVARCHAR(255) NOT NULL -- Giá trị thuộc tính (VD: Đỏ)
);

CREATE TABLE [dbo].[ProductImages] (
    [ImageId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ProductId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Products](ProductId),
    [ImageUrl] NVARCHAR(MAX) NOT NULL, -- Đường dẫn đến ảnh sản phẩm
    [IsMainImage] BIT NOT NULL DEFAULT 0 -- Ảnh chính của sản phẩm
);

CREATE TABLE [dbo].[UserNotifications] (
    [NotificationId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [UserId] NVARCHAR(450) NOT NULL FOREIGN KEY REFERENCES [dbo].[Users](UserId),
    [Message] NVARCHAR(MAX) NOT NULL,
    [Status] NVARCHAR(50) NOT NULL DEFAULT 'Unread', -- Read, Unread
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETDATE()
);

CREATE TABLE [dbo].[ProductRecommendations] (
    [RecommendationId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [SkinTypeId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[SkinTypes](SkinTypeId),
    [ProductId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[Products](ProductId),
    [RoutineStep] INT NOT NULL -- Bước trong lộ trình chăm sóc da
);

CREATE TABLE [dbo].[CustomerPoints] (
    [PointId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [CustomerId] NVARCHAR(450) NOT NULL FOREIGN KEY REFERENCES [dbo].[Users](UserId),
    [Points] INT NOT NULL,
    [EarnedDate] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [RedeemedDate] DATETIME2 NULL -- Ngày điểm được sử dụng
);

CREATE TABLE [dbo].[CancellationPolicies] (
    [PolicyId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [PolicyName] NVARCHAR(255) NOT NULL,
    [Description] NVARCHAR(MAX) NULL,
    [ApplicableDays] INT NOT NULL -- Số ngày áp dụng chính sách (ví dụ: hủy trong vòng 7 ngày)
);
