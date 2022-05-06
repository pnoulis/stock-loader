use master;
GO

DROP DATABASE IF EXISTS dummy;
GO

CREATE DATABASE dummy
  COLLATE Latin1_General_100_CI_AI_SC_UTF8;
GO


use dummy;
GO

-- ALTER TABLE stockMoves DROP CONSTRAINT IF EXISTS FK_stockMoves_itemCID;
-- ALTER TABLE stockMoves DROP CONSTRAINT IF EXISTS FK_stockMoves_storeID;
-- ALTER TABLE stockMoves DROP CONSTRAINT IF EXISTS FK_stockMoves_moveID;
-- ALTER TABLE stockMovesLog DROP CONSTRAINT IF EXISTS FK_stockMovesLog_storeID;
-- GO

DROP TABLE IF EXISTS stockMoves;
DROP TABLE IF EXISTS stockMovesLog;
DROP TABLE IF EXISTS Store;
DROP TABLE IF EXISTS Item;
GO


CREATE TABLE Store (
  storeId INT NOT NULL,

  CONSTRAINT PK_Store_storeId PRIMARY KEY CLUSTERED (storeId)
);
GO

CREATE TABLE Item (
  itemCID NVARCHAR(50) NOT NULL, -- PK
  itemName NVARCHAR(200) NOT NULL,
  itemAmount INT DEFAULT 0 NOT NULL,

  CONSTRAINT PK_Item_itemCID PRIMARY KEY CLUSTERED (itemCID)
);
GO

CREATE TABLE dbo.stockMovesLog (
  moveID INT IDENTITY(1,1) NOT NULL, -- PK
  storeID INT NOT NULL, -- FK
  moveDate smalldatetime DEFAULT GETDATE() NOT NULL,

  CONSTRAINT PK_stockMovesLog_moveID PRIMARY KEY CLUSTERED (moveID)
);
GO

CREATE TABLE dbo.stockMoves (
  moveID INT NOT NULL, --FK
  storeID INT NOT NULL, -- FK
  itemCID NVARCHAR(50) NOT NULL, -- FK
  itemName NVARCHAR(200) NOT NULL, -- FK
  stockBefore INT NULL,
  stockIncrease INT NOT NULL,
  stockAfter INT NOT NULL,
);
GO


-- FOREIGN KEYS
ALTER TABLE dbo.stockMoves
  WITH CHECK ADD CONSTRAINT
  FK_stockMoves_moveID
  FOREIGN KEY (moveID) REFERENCES
  dbo.stockMovesLog(moveID);


ALTER TABLE dbo.stockMoves
  WITH CHECK ADD CONSTRAINT
  FK_stockMoves_itemCID
  FOREIGN KEY (itemCID) REFERENCES
  dbo.Item(ItemCID);

ALTER TABLE dbo.stockMoves
  WITH CHECK ADD CONSTRAINT
  FK_stockMoves_storeID
  FOREIGN KEY (storeID) REFERENCES
  dbo.Store(StoreId);

ALTER TABLE dbo.stockMovesLog
  WITH CHECK ADD CONSTRAINT
  FK_stockMovesLog_storeID
  FOREIGN KEY (storeID) REFERENCES
  dbo.Store(storeId);
GO

-- Procedure

CREATE PROCEDURE addStockMove
  @itemCID NVARCHAR (50),
  @stockIncrease INTEGER,
  @moveID INTEGER,
  @itemName NVARCHAR (200) = ''
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @storeID INTEGER;
  DECLARE @stockBefore INTEGER;
  DECLARE @stockAfter INTEGER;

  SELECT
    @itemCID = itemCID,
    @itemName = itemName,
    @stockBefore = itemAmount
    FROM Item
   WHERE itemCID = @itemCID;

  UPDATE Item
     SET itemAmount = @stockIncrease + @stockBefore
   WHERE itemCID = @itemCID;

  SET @stockAfter = @stockIncrease + @stockBefore;
  SET @storeID = 1;

  INSERT INTO stockMoves (
    moveID, storeID, itemCID, itemName, stockBefore, stockIncrease, stockAfter
  )
  VALUES (
    @moveID, @storeID, @itemCID, @itemName, @stockBefore, @stockIncrease, @stockAfter
  );

END;
GO
