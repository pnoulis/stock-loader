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
  object tableStockMovesLog: TFDTable
    Connection = connection
    FetchOptions.AssignedValues = [evRecordCountMode]
    FetchOptions.RecordCountMode = cmTotal
    TableName = 'stockMovesLog'
    Left = 168
    Top = 16
  end
  object queryStockMoves: TFDQuery
    Connection = connection
    Left = 160
    Top = 96
  end
  object FDStoredProc1: TFDStoredProc
    Connection = connection
    SchemaName = 'dbo'
    StoredProcName = 'getStockMoves'
    Left = 304
    Top = 224
  end
end
