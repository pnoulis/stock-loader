use master;
GO

  IF OBJECT_ID('dbo.FK_stockMoves_stockOrderID', 'F') IS NOT NULL
  ALTER TABLE dbo.stockMoves DROP CONSTRAINT FK_stockMoves_moveID;

  IF OBJECT_ID('dbo.FK_stockMoves_itemCID', 'F') IS NOT NULL
  ALTER TABLE dbo.stockMoves DROP CONSTRAINT FK_stockMoves_itemCID;

  IF OBJECT_ID('dbo.FK_stockMoves_storeID', 'F') IS NOT NULL
  ALTER TABLE dbo.stockMoves DROP CONSTRAINT FK_stockMoves_storeID;

  IF OBJECT_ID('dbo.FK_stockMovesLog_storeID', 'F') IS NOT NULL
  ALTER TABLE dbo.stockOrders DROP CONSTRAINT FK_stockOrders_storeID;
  GO

  IF OBJECT_ID(N'dbo.stockOrders', N'U') IS NOT NULL
  DROP TABLE dbo.stockMovesLog;
  GO

  IF OBJECT_ID(N'dbo.stockMoves', N'U') IS NOT NULL
  DROP TABLE dbo.stockMoves;
  GO

CREATE TABLE dbo.stockOrders (
  stockOrderID INT IDENTITY(1,1) NOT NULL, -- PK
  storeID INT NOT NULL, -- FK
  moveDate smalldatetime DEFAULT GETDATE() NOT NULL,

  CONSTRAINT PK_stockOrders_stockOrderID PRIMARY KEY CLUSTERED (stockOrderID)
);
GO

CREATE TABLE dbo.stockMoves (
  moveID INT IDENTITY(1,1) NOT NULL, --PK
  stockOrderID INT NOT NULL, --FK
  storeID INT NOT NULL, -- FK
  itemCID NVARCHAR(50) NOT NULL, -- FK
  itemName NVARCHAR(200) NOT NULL, -- FK
  stockBefore INT NULL,
  stockIncrease INT NOT NULL,
  stockAfter INT NOT NULL,

  CONSTRAINT PK_stockMoves_moveID PRIMARY KEY CLUSTERED (moveID)
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

ALTER TABLE dbo.stockMoves
  WITH CHECK ADD CONSTRAINT
  FK_stockMoves_storeID
  FOREIGN KEY (storeID) REFERENCES
  dbo.Store(StoreId);

ALTER TABLE dbo.stockOrders
  WITH CHECK ADD CONSTRAINT
  FK_stockOrders_storeID
  FOREIGN KEY (storeID) REFERENCES
  dbo.Store(storeId);
GO
