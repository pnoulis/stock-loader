IF OBJECT_ID ('addStockMove') IS NOT NULL
  DROP PROCEDURE addStockMove;
GO

CREATE PROCEDURE addStockMove
  @itemCID NVARCHAR(50),
  @stockOrderID INTEGER,
  @stockIncrease INTEGER,
  @storeID INTEGER,
  @moveID INTEGER = NULL
AS
BEGIN

  SET NOCOUNT ON;

  DECLARE @itemName NVARCHAR(200);
  DECLARE @stockBefore INTEGER;
  DECLARE @stockAfter INTEGER;

  SET @itemCID = (SELECT itemCID FROM item WHERE itemCID = @itemCID);
  IF (@itemCID IS NULL) RETURN 1

  SET @stockOrderID = (SELECT stockOrderID FROM stockOrders WHERE stockOrderID = @stockOrderID);
  IF (@stockOrderID IS NULL) RETURN 1;

  SET @storeID = (SELECT storeID FROM store WHERE storeID = @storeID);
  IF (@storeID IS NULL) RETURN 1;

  IF (@moveID IS NOT NULL)
  BEGIN
    SET @moveID = (SELECT moveID FROM stockMoves WHERE moveID = @moveID);
    IF (@moveID IS NULL) RETURN 1;
  END

SELECT
@itemName = itemName,
@stockBefore = itemAmount
FROM Item
WHERE itemCID = @itemCID;

IF (@stockBefore IS NULL) SET @stockBefore = 0;
SET @stockAfter = @stockBefore + @stockIncrease;
IF (@stockAfter < 0) SET @stockAfter = 0;

IF (@moveID IS NOT NULL)
BEGIN
  UPDATE stockMoves
  SET stockBefore = @stockBefore, stockIncrease = @stockIncrease, stockAfter = @stockAfter
  WHERE moveID = @moveID;
END
ELSE
BEGIN
  INSERT INTO stockMoves (stockOrderID, storeID, itemCID, itemName, stockBefore, stockIncrease, stockAfter)
  VALUES (@stockOrderID, @storeID, @itemCID, @itemName, @stockBefore, @stockIncrease, @stockAfter);
END

UPDATE item
SET itemAmount = @stockAfter
WHERE itemCID = @itemCID;

END;
GO
