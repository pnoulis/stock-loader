USE MASTER;
GO 

IF EXISTS (
SELECT  1
FROM sys.databases
WHERE NAME = N'dummy' )
DROP DATABASE dummy;

IF EXISTS (
SELECT  1
FROM sys.procedures
WHERE NAME = 'addStockMove' )
DROP PROCEDURE dbo.addStockMove;

IF EXISTS(
SELECT  1
FROM sys.procedures
WHERE name = 'reverseStockMove' )
DROP PROCEDURE dbo.reverseStockMove;

IF EXISTS (
SELECT  1
FROM sys.procedures
WHERE NAME = 'subtract' )
DROP PROCEDURE dbo.subtract;

IF EXISTS (
SELECT  1
FROM sys.procedures
WHERE NAME = 'deleteStockOrder' )
DROP PROCEDURE dbo.deleteStockOrder 
GO  


CREATE DATABASE dummy COLLATE Latin1_General_100_CI_AI_SC_UTF8; 
GO 
USE dummy;
GO

CREATE TABLE Store ( 
  storeId INT NOT NULL -- PK
  CONSTRAINT PK_Store_storeId PRIMARY KEY CLUSTERED (storeId) 
);
GO

CREATE TABLE item ( 
  itemCID NVARCHAR(50) NOT NULL, -- PK
  itemName NVARCHAR(200) NOT NULL, 
  CONSTRAINT PK_Item_itemCID PRIMARY KEY CLUSTERED (itemCID) 
);
GO

CREATE TABLE Dbo.itemStg (
  itemCID NVARCHAR(50) NOT NULL, -- PK, FK
  storeID INT NOT NULL, -- FK
  qnt DECIMAL(18, 3) NULL CONSTRAINT PK_itemStg_itemCID PRIMARY KEY CLUSTERED (itemCID)
);
GO

CREATE TABLE dbo.stockOrders (
  stockOrderID BIGINT IDENTITY(1, 1) NOT NULL, -- PK
  storeID INT NOT NULL, -- FK
  issuer SMALLINT NULL,
  server SMALLINT NULL,
  issuedDate SMALLDATETIME NULL,
  servedDate SMALLDATETIME DEFAULT GETDATE() NOT NULL,
  orderStatus TINYINT DEFAULT 0,
  CONSTRAINT PK_stockOrders_stockOrderID PRIMARY KEY CLUSTERED (stockOrderID)
);
GO


CREATE TABLE dbo.stockMoves (
  stockMoveID BIGINT IDENTITY(1, 1) NOT NULL, -- PK
  stockOrderID BIGINT NOT NULL, --FK
  itemCID NVARCHAR(50) NOT NULL, -- FK
  itemName NVARCHAR(200) NOT NULL,
  stockBefore DECIMAL(18, 3) NOT NULL,
  stockIncrease DECIMAL(18, 3) NOT NULL,
  stockAfter DECIMAL(18, 3) NOT NULL,
  CONSTRAINT PK_stockMoves_stockMoveID PRIMARY KEY CLUSTERED (stockMoveID)
);
GO


-- FOREIGN KEYS
ALTER TABLE dbo.stockMoves WITH CHECK ADD CONSTRAINT 
FK_stockMoves_stockOrderID FOREIGN KEY (stockOrderID) REFERENCES 
dbo.stockOrders(stockOrderID);

ALTER TABLE dbo.stockMoves WITH CHECK ADD CONSTRAINT 
FK_stockMoves_itemCID FOREIGN KEY (itemCID) REFERENCES 
dbo.Item(ItemCID);

ALTER TABLE dbo.stockOrders WITH CHECK ADD CONSTRAINT 
FK_stockOrders_storeID FOREIGN KEY (storeID) REFERENCES 
dbo.store(StoreId);

ALTER TABLE dbo.itemStg WITH CHECK ADD CONSTRAINT 
FK_itemStg_itemCID FOREIGN KEY (itemCID) REFERENCES 
dbo.item(itemCID);

ALTER TABLE dbo.itemStg WITH CHECK ADD CONSTRAINT 
FK_itemStg_storeID FOREIGN KEY (storeID) REFERENCES 
dbo.store(storeID);
GO

-- ADD STOCK ORDER
CREATE PROCEDURE addStockOrder
@storeID INT = 1
AS
BEGIN
SET NOCOUNT ON;

INSERT INTO stockOrders (storeID, servedDate)
VALUES (@storeID, GETDATE());
SELECT * FROM stockOrders
WHERE stockOrderID = @@identity;
END;
GO

-- ADD STOCK MOVE
CREATE PROCEDURE addStockMove 
@stockOrderID BIGINT
,@itemCID NVARCHAR(50)
,@stockIncrease DECIMAL(18, 3)
,@stockMoveID BIGINT = NULL 
AS 
BEGIN
SET NOCOUNT ON;

declare @itemName nvarchar(200);
declare @stockBefore decimal(18, 3);
declare @stockAfter decimal(18, 3);

SELECT @stockOrderID = stockOrderID
FROM stockOrders
WHERE stockOrderID = @stockOrderID;

SELECT @itemName = a.itemName, @stockBefore = b.Qnt
FROM item a, itemStg b
WHERE a.itemCID = b.itemCID AND a.itemCID = @itemCID;

IF (@stockBefore IS NULL) SET @stockBefore = 0.0;
SET @stockAfter = @stockBefore + @stockIncrease;
IF (@stockAfter < 0.0) SET @stockAfter = 0.0;


IF (@stockMoveID IS NOT NULL) 
BEGIN
declare @sameItemCID NVARCHAR(50);
declare @prevStockIncrease decimal(18,3);

SELECT @prevStockIncrease = stockIncrease FROM stockMoves
WHERE stockMoveID  = @stockMoveID;

IF (@prevStockIncrease < 0.0 AND @stockIncrease > 0.0)
BEGIN
UPDATE stockMoves
SET stockIncrease = 0  WHERE stockMoveID = @stockMoveID;
END;

UPDATE stockMoves
SET @sameItemCID = itemCID, stockBefore = @stockBefore - stockIncrease,
stockIncrease = @stockIncrease + stockIncrease, stockAfter = @stockAfter
WHERE stockMoveID = @stockMoveID AND itemCID = @itemCID;

-- case where the stockMove exists but the previous
-- item the stockMove 'moved' was not the same
IF (@sameItemCID IS NULL) RETURN 1;

END
ELSE 
BEGIN

INSERT INTO stockMoves (
    stockOrderID, itemCID, itemName, stockBefore, stockIncrease, stockAfter
) VALUES (
    @stockOrderID, @itemCID, @itemName, @stockBefore, @stockIncrease, @stockAfter
);

END;

UPDATE itemStg SET Qnt = @stockAfter WHERE itemCID = @itemCID;

if (@stockmoveid is not null)
SELECT * from stockMoves where stockMoveID = @stockMoveID;
ELSE
SELECT * FROM stockMoves where stockMoveID = @@identity;

END;
GO


-- SUBTRACT
CREATE PROCEDURE subtract 
@term1 DECIMAL(18, 3)
,@term2 DECIMAL(18, 3) 
AS 
BEGIN
SET NOCOUNT ON;
SET @term1 = (@term1 - @term2);
IF (@term1 <= 0.0) RETURN 0
ELSE RETURN @term1;
END;
GO


-- REVERSE STOCK MOVE
CREATE PROCEDURE reverseStockMove 
@stockMoveID BIGINT 
AS 
BEGIN
SET NOCOUNT ON;

DECLARE @itemCID NVARCHAR(50);
DECLARE @stockBefore DECIMAL(18, 3);
DECLARE @stockDecrease DECIMAL(18, 3);
DECLARE @stockAfter DECIMAL(18, 3);

SELECT @itemCID = itemCID, @stockDecrease = stockIncrease
FROM stockmoves
WHERE stockMoveID = @stockMoveID;

IF (@itemCID IS NULL) RETURN 1;

SELECT @stockBefore = Qnt
FROM itemStg
WHERE itemCID = @itemCID;

EXEC @stockAfter = subtract @stockBefore, @stockDecrease;

IF (@stockAfter IS NULL) SET @stockAfter = 0;

UPDATE itemStg SET Qnt = @stockAfter WHERE itemCID = @itemCID;

DELETE FROM stockMoves WHERE stockMoveID = @stockMoveID;

RETURN 0;
END;
GO

-- DELETE STOCK ORDER
CREATE PROCEDURE deleteStockOrder 
@stockOrderID BIGINT 
AS 
BEGIN
SET NOCOUNT ON;

DECLARE @stockMoveID BIGINT;

DECLARE n CURSOR FAST_FORWARD FOR
SELECT stockMoveID 
FROM stockMoves
WHERE stockOrderID = @stockOrderID;

OPEN n;

FETCH NEXT FROM n INTO @stockMoveID;

WHILE @@FETCH_STATUS = 0 
BEGIN 
EXEC reverseStockMove @stockMoveID;
FETCH NEXT FROM n INTO @stockMoveID;
END;

CLOSE n;
DEALLOCATE n;

DELETE FROM stockOrders WHERE stockOrderID = @stockOrderID;
RETURN 0;
END;
GO
