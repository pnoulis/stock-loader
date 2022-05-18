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
  object storedGetStockMove: TFDStoredProc
    Connection = connection
    SchemaName = 'dbo'
    StoredProcName = 'addStockMove'
    Left = 420
    Top = 53
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
    Left = 328
    Top = 24
  end
  object storedProc: TFDStoredProc
    Connection = connection
    SchemaName = 'dbo'
    Left = 384
    Top = 201
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
    Left = 140
    Top = 350
  end
end
