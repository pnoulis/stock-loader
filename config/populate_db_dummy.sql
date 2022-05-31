use dummy;
GO

INSERT INTO Store (storeId) VALUES (1);
INSERT INTO Store (storeID) VALUES(5);
GO

INSERT INTO Item (itemCID, itemName)
VALUES
  ('000001', 'φραπες'),
  ('000002', 'λεμοναδα'),
  ('000003', 'πιτσα οικογενειακοι'),
  ('000004', 'πορτοκαλαδα μεγαλη 500''ml'),
  ('000005', 'crate full of coca colas'),
  ('000006', 'Grash fed roasted beef that has received daily massages'),
  ('000007', 'Vodka'),
  ('000008', 'Lemons'),
  ('000009', 'Apples'),
  ('000010', 'Bannana');
GO

INSERT INTO itemStg (itemCID, storeID, Qnt)
VALUES
  ('000001', 1, NULL),
  ('000002', 1, NULL),
  ('000003', 1, NULL),
  ('000004', 1, NULL),
  ('000005', 1, NULL),
  ('000006', 1, NULL),
  ('000007', 1, NULL),
  ('000008', 1, NULL),
  ('000009', 1, NULL),
  ('000010', 1, NULL)
GO

INSERT INTO stockOrders (storeID, servedDate)
VALUES
  (1, '2022-01-01 00:30:00'), -- storeID = 1
  (1, '2022-01-02 00:30:00'), -- storeID = 2
  (1, '2022-01-03 00:30:00'), -- storeID = 3
  (1, '2022-01-04 00:30:00'), -- storeID = 4
  (1, '2022-01-05 00:30:00'), -- storeID = 5
  (1, '2022-02-06 00:30:00'), -- storeID = 6
  (1, '2022-02-07 00:30:00'), -- storeID = 7
  (1, '2022-02-08 00:30:00'), -- storeID = 8
  (1, '2022-02-09 00:30:00'), -- storeID = 9
  (1, '2022-03-10 00:30:00'), -- storeID = 10
  (1, '2022-03-11 00:30:00'), -- storeID = 11
  (1, '2022-03-12 00:30:00'), -- storeID = 12
  (1, '2022-03-13 00:30:00'), -- storeID = 13
  (1, '2022-03-14 00:30:00'), -- storeID = 14
  (1, '2022-04-15 00:30:00'), -- storeID = 15
  (1, '2022-04-16 00:30:00'), -- storeID = 16
  (1, '2022-04-17 00:30:00'), -- storeID = 17
  (1, '2022-04-18 00:30:00'), -- storeID = 18
  (1, '2022-05-1 00:30:00'), -- storeID = 19
  (1, '2022-05-2 00:30:00'), -- storeID = 20
  (1, '2022-05-3 00:30:00'); -- storeID = 21
GO


/*
** addStockMove **
@stockOrderID  BIGINT
,@itemCID NVARCHAR(50)
,@stockIncrease DECIMAL(18,3)
,@stockMoveID BIGINT = NULL
*/

addStockMove 1, '000001', 2;
GO
addSTockMove 1, '000002', 4.002; 
GO
addStockMove 2, '000003', 10.54;
GO
addStockMove 21, '000004', 10.006; 
GO
addStockMove 21, '000005', 10.009; 
GO
addStockMove 21, '000006', 10.333; 
GO
addStockMove 21, '000007', 10.378; 
GO
addStockMove 21, '000008', 10.5; 
GO
addStockMove 21, '000009', 10.050; 
GO
addStockMove 21, '000004', 10.005; 
GO
addStockMove 21, '000005', 10.2; 
GO
addStockMove 21, '000006', 6.666; 
GO
addStockMove 21, '000007', 9; 
GO
addStockMove 21, '000008', 5; 
GO
addStockMove 21, '000009', 4.576;
GO
