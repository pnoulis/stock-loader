use dummy;
GO

INSERT INTO Store (storeId) VALUES (1);
GO

INSERT INTO Item (itemCID, itemName)
VALUES
  ('00001', 'φραπες'),
  ('00002', 'λεμοναδα'),
  ('00003', 'πιτσα οικογενειακοι'),
  ('00004', 'πορτοκαλαδα μεγαλη 500''ml'),
  ('00005', 'crate full of coca colas'),
  ('00006', 'Grash fed roasted beef that has received daily massages'),
  ('00007', 'Vodka'),
  ('00008', 'Lemons'),
  ('00009', 'Apples'),
  ('00010', 'Bannana');
GO

INSERT INTO stockOrders (storeID, moveDate)
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
  *addStockMove*
  @itemCID,
  @stockOrderID,
  @stockIncrease,
  @storeID,
  @moveID = NULL
*/

addStockMove '00001', 1, 2, 1;
GO
addSTockMove '00002', 1, 4, 1;
GO
addStockMove '00003', 2, 10, 1;
GO
addStockMove '00004', 21, 20, 1;
GO
addStockMove '00005', 21, 10, 1;
GO
addStockMove '00006', 21, 25, 1;
GO
addStockMove '00007', 21, 26, 1;
GO
addStockMove '00008', 21, 26, 1;
GO
addStockMove '00009', 21, 19, 1;
GO
addStockMove '00004', 21, 100, 1;
GO
addStockMove '00005', 21, 100, 1;
GO
addStockMove '00006', 21, 100, 1;
GO
addStockMove '00007', 21, 100, 1;
GO
addStockMove '00008', 21, 100, 1;
GO
addStockMove '00009', 21, 100, 1;
GO
