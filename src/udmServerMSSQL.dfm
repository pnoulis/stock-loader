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
    TableName = 'eliza.dbo.stockMovesLog'
    Left = 168
    Top = 16
  end
end
