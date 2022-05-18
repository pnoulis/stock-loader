USE Master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE NAME = N'dummy')
  DROP DATABASE dummy;

if EXISTS(SELECT 1 FROM sys.procedures where name = 'reverseStockMove')
  DROP PROCEDURE dbo.reverseStockMove;

IF EXISTS (SELECT 1 FROM sys.procedures WHERE NAME =  'subtract')
  DROP PROCEDURE dbo.subtract;

IF EXISTS (SELECT 1 FROM sys.procedures WHERE NAME = 'deleteStockOrder')
  DROP PROCEDURE dbo.deleteStockOrder

GO


CREATE DATABASE dummy;
  --COLLATE Latin1_General_100_CI_AI_SC_UTF8;
GO

USE dummy;
GO


CREATE TABLE Store (
  storeId INT NOT NULL, -- PK

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
  qnt DECIMAL(18,3) NULL

  CONSTRAINT PK_itemStg_itemCID PRIMARY KEY CLUSTERED (itemCID)
);
GO

CREATE TABLE dbo.stockOrders (
  stockOrderID BIGINT IDENTITY(1,1) NOT NULL, -- PK
  storeID INT NOT NULL, -- FK
  issuer INT NOT NULL,
  server INT NOT NULL,
  issuedDate SMALLDATETIME DEFAULT GETDATE() NOT NULL,
  servedDate SMALLDATETIME DEFAULT GETDATE() NOT NULL,
  orderStatus TINYINT DEFAULT 0,

  CONSTRAINT PK_stockOrders_stockOrderID PRIMARY KEY CLUSTERED (stockOrderID)
);
GO

CREATE TABLE dbo.stockMoves (
  stockMoveID BIGINT IDENTITY(1,1) NOT NULL, -- PK
  stockOrderID BIGINT NOT NULL, --FK
  itemCID NVARCHAR(50) NOT NULL, -- FK
  QntBefore DECIMAL(18,3) NULL,
  QntIncrease DECIMAL(18,3) NOT NULL,

  CONSTRAINT PK_stockMoves_stockMoveID PRIMARY KEY CLUSTERED (stockMoveID)
);
GO

-- FOREIGN KEYS
ALTER TABLE dbo.stockMoves
  WITH CHECK ADD CONSTRAINT
  FK_stockMoves_stockOrderID
  FOREIGN KEY (stockOrderID) REFERENCES
  dbo.stockOrders(stockOrderID);

ALTER TABLE dbo.stockMoves
  WITH CHECK ADD CONSTRAINT
  FK_stockMoves_itemCID
  FOREIGN KEY (itemCID) REFERENCES
  dbo.Item(ItemCID);

ALTER TABLE dbo.stockOrders
  WITH CHECK ADD CONSTRAINT
  FK_stockOrders_storeID
  FOREIGN KEY (storeID) REFERENCES
  dbo.store(StoreId);

ALTER TABLE dbo.itemStg
  WITH CHECK ADD CONSTRAINT
  FK_itemStg_itemCID
  FOREIGN KEY (itemCID) REFERENCES
  dbo.item(itemCID);

ALTER TABLE dbo.itemStg
  WITH CHECK ADD CONSTRAINT
  FK_itemStg_storeID
  FOREIGN KEY (storeID) REFERENCES
  dbo.store(storeID);
GO

create procedure addStockMove
@itemCID NVARCHAR(50),
@stockOrderID  BIGINT(255),
@stockIncrease DECIMAL(18,3),
@storeID INT,
@moveID BIGINT(255) = NULL
AS
BEGIN
set noCount on;
declare @itemName nvarchar(200);
declare @stockBefore decimal(18,3);
declare @stockAfter decimal(18,3);

select @stockOrderID = stockOrderID from stockOrders where stockOrderID = @stockOrderID;
if (@stockOrderID is NULL) return 1;

select @itemName = a.itemName, @stockBefore = b.Qnt from  item a, itemStg 
where a.itemCID = b.itemCID and a.itemCID = @itemCID;


select @itemName = 

--select @itemName = itemName, @stockBefore = Qnt 
END
GO

CREATE PROCEDURE subtract
@term1 INTEGER,
@term2 INTEGER
AS
BEGIN
set @term1 = (@term1 - @term2);
if (@term1 <= 0) return 0
else return @term1;
END;
GO

CREATE PROCEDURE reverseStockMove
@moveID INTEGER
AS
BEGIN
SET NOCOUNT ON;

DECLARE @itemCID NVARCHAR(50);
DECLARE @stockNow INTEGER;
DECLARE @stockIncrease INTEGER;
DECLARE @stockAfter INTEGER;

SELECT @itemCID = itemCID, @stockIncrease = stockIncrease FROM stockmoves WHERE moveID = @moveID;
if (@itemCID IS NULL) RETURN 1;

SELECT @stockNow = itemAmount FROM item WHERE itemCID = @itemCID;
EXEC @stockAfter = subtract @stockNow, @stockIncrease;
IF (@stockAfter is NULL) set @stockAfter = 0;

UPDATE item
SET itemAmount = @stockAfter WHERE itemCID = @itemCID;

DELETE FROM stockMoves where moveID = @moveID;
RETURN 0;
END;
GO

CREATE PROCEDURE deleteStockOrder
@stockOrderID INTEGER
AS
BEGIN
SET NOCOUNT ON;
DECLARE @moveID INTEGER;

DECLARE n CURSOR FAST_FORWARD 
FOR SELECT moveID FROM stockMoves WHERE stockOrderID = @stockOrderID;

OPEN n;

FETCH NEXT FROM n INTO @moveID;

WHILE @@FETCH_STATUS = 0
BEGIN
EXEC reverseStockMove @moveID;
FETCH NEXT FROM n INTO @moveID;
END

CLOSE n;
DEALLOCATE n;

DELETE FROM stockOrders WHERE stockOrderID = @stockOrderID;
END;
GO
