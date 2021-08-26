unit uFileProcessing;

interface

uses
    System.IOUtils, System.Threading, System.Types,
    System.Classes, System.SysUtils, System.SyncObjs,
    System.Generics.Collections, IdHashMessageDigest,
    Winapi.Windows;

type TDirectoryHash = class
  private
    FDirname: string;
    FFileList: TStringList;
    function GetHash(Filename: string): string;
    function GetThreadCount: integer;
    procedure DirectoryProcessing;
  public
    constructor Create;
    destructor Destroy; override;
    function GetHashFileList(Dirname: string): TStringLIst;
end;

implementation

// ������� ���������� TStringLIst - ���������� �� ���������, � ��
// �� ����� - ����� ����������� �� ����� �����, � �� �� ����
function CompareValues(List: TStringList; Index1, Index2: Integer): Integer;
begin
  result := CompareText(List.ValueFromIndex[Index1], List.ValueFromIndex[Index2]);
end;

constructor TDirectoryHash.Create;
begin
  FFileList := TStringList.Create;
end;

destructor TDirectoryHash.Destroy;
begin
  FreeAndNil(FFileList);
  inherited;
end;

// ���������� ���-�� ����������� ���� ��
function TDirectoryHash.GetThreadCount: integer;
var
  SysInfo: _SYSTEM_INFO;
begin
  GetSysteminfo(SysInfo);
  result := SysInfo.dwNumberOfProcessors;
end;

// ��������� ��� ��� ���� ������ � �������� FDirname
procedure TDirectoryHash.DirectoryProcessing;
var Attr: integer;
    FoundedFile: TSearchRec;
    Task: ITask;
    TaskList: array of ITask;
    Count: integer;
    Filename: string;
// ���������� ��������� ��� "�������" �������� ���������� �
// ������ ������
  function CaptureValue(Value: string): TProc;
  begin
    result := procedure
      begin
        MonitorEnter(FFileList);
        FFileList.AddPair(GetHash(Value), Value);
        MonitorExit(FFileList);
      end;
  end;

begin
  // ������������� ������������ ���-�� ������� ������� ���-�� ����������� ����
  // ��� ����������� ���������������� ������� � �� ������ ������������ �����
  // �� ������ ������������ ����� ��������
  TThreadPool.Default.SetMaxWorkerThreads(GetThreadCount);
  SetLength(TaskList, TThreadPool.Default.MaxWorkerThreads);

  // �������� � ����� �������� �������� ����, ���� �� �����������
  FDirname := IncludeTrailingPathDelimiter(FDirname);
  // ������������ ��� �����, ����� ���������
  Attr := faAnyFile - faDirectory;

  //  FL := TList<string>.Create;
  Count := 0;
  try
    if FindFirst(FDirname + '*', Attr, FoundedFile) = 0 then
      repeat
        Filename := FDirname + FoundedFile.Name;
        // ��� ��������� ������� �����
        Task := TTask.Create(CaptureValue(Filename));
        TaskList[Count] := Task;
        Inc(Count);
        if Count > Length(TaskList)-1 then
          SetLength(TaskList, Length(TaskList)*2);
      until FindNext(FoundedFile) <> 0;
  finally
    System.SysUtils.FindClose(FoundedFile);
    SetLength(TaskList, Count);
  end;

  // ��������� ������ �� ����������
  for Task in TaskList do
  begin
    Task.Start;
  end;

  // ���� ���������� ���� �����
  try
    TTask.WaitForAll(TaskList);
  except
    on E: EAggregateException do
  end;
end;

// ���������� MD5 ��� ����� filename
function TDirectoryHash.GetHash(Filename: string): string;
var FileStream: TFileStream;
    IdHashMD5: TIdHashMessageDigest5;
begin
  result := '';
  IdHashMD5 := TIdHashMessageDigest5.Create;
  try
    FileStream := TFileStream.Create(Filename, fmOpenRead, fmShareDenyNone);
  except on E: EFOpenError do
    begin
      FreeAndNil(IdHashMD5);
      Exit('');
    end;
  end;
  Result := IdhashMD5.HashStreamAsHex(FileStream);
  FreeAndNil(FileStream);
end;

// ���������� ��������������� �� ������ ������ TStringList
// <hashMD5> <��� �����>
function TDirectoryHash.GetHashFileList(Dirname: string): TStringLIst;
begin
    FFileList.Clear;
    FDirname := Dirname;
    FFileList.NameValueSeparator := ' ';
    DirectoryProcessing;
    FFileLIst.CustomSort(CompareValues);
    result := FFileList;
end;

end.
