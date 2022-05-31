object dmServerMSSQL: TdmServerMSSQL
  Height = 480
  Width = 640
  object connection: TFDConnection
    LoginPrompt = False
    Left = 32
    Top = 16
  end
  object driverMSSQL: TFDPhysMSSQLDriverLink
    Left = 32
    Top = 88
  end
  object tableStockOrders: TFDTable
    Connection = connection
    FetchOptions.AssignedValues = [evRecordCountMode]
    FetchOptions.RecordCountMode = cmTotal
    SchemaName = 'dbo'
    TableName = 'stockOrders'
    Left = 168
    Top = 16
  end
  object queryStockMoves: TFDQuery
    Connection = connection
    Left = 160
    Top = 96
  end
  object queryItem: TFDQuery
    Connection = connection
    Left = 262
    Top = 19
  end
  object DataSource1: TDataSource
    Left = 32
    Top = 184
  end
  object queryAddStockOrder: TFDQuery
    Connection = connection
    Left = 136
    Top = 184
  end
  object queryAddStockMove: TFDQuery
    Connection = connection
    Left = 280
    Top = 184
  end
  object queryDeleteStockOrder: TFDQuery
    Connection = connection
    Left = 304
    Top = 97
  end
  object query: TFDQuery
    Connection = connection
    Left = 16
    Top = 264
  end
  object sproc: TFDStoredProc
    Connection = connection
    Left = 88
    Top = 264
  end
end
