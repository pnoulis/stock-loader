object dmEliza: TdmEliza
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
  object tableStockMovesLog: TFDTable
    Connection = connection
    FetchOptions.AssignedValues = [evRecordCountMode]
    FetchOptions.RecordCountMode = cmTotal
    TableName = 'eliza.dbo.stockMovesLog'
    Left = 210
    Top = 20
  end
end
