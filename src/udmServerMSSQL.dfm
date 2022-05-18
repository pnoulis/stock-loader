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
  object storedGetStockMove: TFDStoredProc
    Connection = connection
    SchemaName = 'dbo'
    StoredProcName = 'addStockMove'
    Left = 336
    Top = 42
    ParamData = <
      item
        Name = 'itemCID'
      end
      item
        Name = 'stockOrderID'
      end
      item
        Name = 'stockIncrease'
      end
      item
        Name = 'storeID'
      end
      item
        Name = 'moveID'
      end>
  end
  object queryItem: TFDQuery
    Connection = connection
    Left = 262
    Top = 19
  end
  object storedProc: TFDStoredProc
    Connection = connection
    SchemaName = 'dbo'
    Left = 307
    Top = 161
    ParamData = <
      item
        Name = 'stockOrderID'
        DataType = ftParams
        ParamType = ptResult
        Value = 0
      end
      item
        Name = 'storeID'
        DataType = ftInteger
        ParamType = ptInput
        Value = 0
      end>
  end
  object DataSource1: TDataSource
    Left = 112
    Top = 280
  end
end
