use master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE [name] = N'dummy')
  DROP DATABASE dummy;
GO

use dummy;
GO;

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


