object dmServerMSSQL: TdmServerMSSQL
  Height = 600
  Width = 800
  PixelsPerInch = 120
  object connection: TFDConnection
    LoginPrompt = False
    Left = 40
    Top = 20
  end
  object driverMSSQL: TFDPhysMSSQLDriverLink
    Left = 40
    Top = 110
  end
  object tableStockOrders: TFDTable
    Connection = connection
    FetchOptions.AssignedValues = [evRecordCountMode]
    FetchOptions.RecordCountMode = cmTotal
    SchemaName = 'dbo'
    TableName = 'stockOrders'
    Left = 210
    Top = 20
  end
  object queryStockMoves: TFDQuery
    Connection = connection
    Left = 200
    Top = 120
  end
  object queryItem: TFDQuery
    Connection = connection
    Left = 328
    Top = 24
  end
  object DataSource1: TDataSource
    Left = 40
    Top = 230
  end
  object queryAddStockOrder: TFDQuery
    Connection = connection
    Left = 170
    Top = 230
  end
  object queryAddStockMove: TFDQuery
    Connection = connection
    Left = 350
    Top = 230
  end
  object queryDeleteStockOrder: TFDQuery
    Connection = connection
    Left = 380
    Top = 121
  end
end
