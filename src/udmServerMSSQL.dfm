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
    TableName = 'stockOrders'
    Left = 210
    Top = 20
  end
  object queryStockMoves: TFDQuery
    Connection = connection
    Left = 200
    Top = 120
  end
  object FDStoredProc1: TFDStoredProc
    Connection = connection
    SchemaName = 'dbo'
    StoredProcName = 'getStockMove'
    Left = 380
    Top = 153
  end
end
