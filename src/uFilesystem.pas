unit uFilesystem;

interface
 {
   getProjectRoot uses matchFilenameInPath to locate the
   project root
 }
 function getProjectRoot(const projectName: string): string;
 {
   anchorProjectRoot sets the current directory to the project root
   if a project name has provided and getProjectRoot manages to locate it
   if it fails it throws an exception
 }
 procedure anchorProjectRoot(const projectName: string);

 {
   Makes sure path exists and user has requested accessMode
 }
 procedure ensureFile(path: string; const accessMode: byte);

implementation
uses
FMX.Dialogs,
System.sysUtils,
System.IOUtils;

 {
   filename is compared against each directory in the current dir path
   up to root
 }
 function matchFilenameInPath(const path, filename: string): string;
  begin
   try
    if TPath.getFilename(path) = filename then
     exit(path);
    result := matchFilenameInPath(TDirectory.getParent(path), filename);
   except
    result := '';
   end;
  end;

 function getProjectRoot(const projectName: string): string;
  begin
   result := matchFilenameInPath(TDirectory.getCurrentDirectory, projectName);
  end;

 procedure anchorProjectRoot(const projectName: string);
  begin
  const projectRoot = getProjectRoot(projectName);
  if projectRoot = '' then
  raise EFileNotFoundException.Create('Project root not found: ' + projectName)
  else
  TDirectory.SetCurrentDirectory(projectRoot);
  end;

  procedure ensureFile(path: string; const accessMode: byte);
  begin
    var
      LFile: file;

      path := TPath.GetFullPath(path);

      if (accessMode < fmOpenRead) or (accessMode > fmOpenReadWrite) then
        raise Exception.CreateFmt('Unrecognized access mode: %d', [accessMode]);

      if not FileExists(path) then
        raise Exception.Create('Missing file: ' + path);

      AssignFile(LFile, path);
      FileMode := accessMode;

      try
        Reset(LFile);
      except
        case accessMode of
          fmOpenRead:
            raise Exception.Create('Missing read permissions: ' + path);
          fmOpenWrite:
            raise Exception.Create('Missing write permissions: ' + path);
          fmOpenReadWrite:
            raise Exception.Create('Missing read & write permissions: ' + path);
        end;
      end;
      CloseFile(LFile);
  end;
end.
