unit uDBConnect;

interface

procedure setupDBconn(conn: TObject; const iniSection: string; iniPath: string);

implementation

uses
  FireDAC.Comp.Client, Data.Win.ADODB,
  System.IniFiles, System.SysUtils, System.Classes,
  System.IOUtils, uFilesystem,
  System.Generics.Collections;

type
  TConfig = TDictionary<string, string>;

procedure readIni(const section, path: string; const config: TConfig);
begin
  var
    ini: TIniFile := nil;
  var
    keys: TStringList := nil;
  try
    ini := TIniFile.Create(path);
    keys := TStringList.Create;
    if not ini.SectionExists(section) then
      raise Exception.Createfmt('%s missing section: %s', [path, section]);
    ini.ReadSection(section, keys);
    for var key in keys do
      config.add(key, ini.ReadString(section, key, ''));
  finally
    FreeAndNil(ini);
    FreeAndNil(keys);
  end;
end;

procedure configureConnection(conn: TObject; const config: TConfig);
begin
  if conn is TFDConnection then
    try
      with conn as TFDConnection do
      begin
        DriverName := config['driverID'];
        params.add('Server=' + config['server']);
        params.add('Database=' + config['database']);
        params.add('User_Name=' + config['username']);
        params.add('OSAuthent=' + config['osAuthent']);
        params.add('Password=' + config['password']);
        LoginPrompt := config['loginPrompt'].ToBoolean;
        Connected := config['connected'].ToBoolean;
      end
    except
      raise Exception.Create('Configuration file missing keys or wrong values');
    end
  else if conn is TADOConnection then
  else
    raise Exception.Create('Unrecognized delphi connection type: ' +
      conn.ClassName);
end;

procedure setupDBconn(conn: TObject; const iniSection: string; iniPath: string);
begin
  var
    config: TConfig := nil;
  try
    iniPath := TPath.GetFullPath(iniPath);
    config := TConfig.Create;
    try
      uFilesystem.ensureFile(iniPath, fmOpenRead);
      readIni(iniSection, iniPath, config);
      configureConnection(conn, config);
    except
      on E: Exception do
        raise Exception.Create('Failed to connect to DB: ' + E.Message);
    end;
  finally
    FreeAndNil(config);
  end;
end;

end.
