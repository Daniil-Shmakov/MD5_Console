{  �������:
�������� ������� ��������� ������, �������:
- �������� �� ���� ��� ��������;
- ���������� ������ ������ ���� ������ � ������ ��������;
- ������� ��� ������� ��� MD5;
- ��������� ������� ��������� �� ����������� ����� � �������:
  ��� ��������������

�������� ����������: ������� ������ ���� �������������, ��� �������
�������������� ���� ������������ ����.

����������:
- ����������������� ��������� - ������ �� ������.
- ��� �������� MD5 ����������� ������� ����������, �������� �� Indy
- ����� ������� ������ ������ ����� ����������� �� ������� �����.
������������ ������ ������� ����� ����������� ����� ���������
��������� ����� � ��������.
- ����� ������ ������� � ������ ������ ��������, � ��� ��������������
������ ������.
}

program MD5_PPL;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Classes,
  uFileProcessing in 'uFileProcessing.pas';

procedure ListOutput(List: TStringList);
var s: string;
begin
  for s in List.ToStringArray do
    writeln(s);
end;

var Dirname: string;
    DirHash: TDirectoryHash;
begin
  try
    // ���-�� ������� ������� ������ ���-�� ���� ��� (�����������)
    // ��� ���������� �������������� ��������

    // ������ � ������������ �������� - ������� ��� ������
    if ParamCount > 0 then
      Dirname := ParamStr(1)
    else
    begin
      Writeln('������� ������� ��� ������: MD5_PPL.EXE <Directory>');
      Exit;
    end;

    DirHash := TDirectoryHash.Create;
    ListOutput(DirHash.GetHashFileList(Dirname));
    FreeAndNil(DirHash);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
