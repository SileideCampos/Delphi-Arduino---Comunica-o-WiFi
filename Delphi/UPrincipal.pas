unit UPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, IdBaseComponent, IdComponent, IdUDPBase,
  IdUDPClient;

type
  TForm1 = class(TForm)
    udp: TIdUDPClient;
    edtIP: TEdit;
    edtConexao: TSpeedButton;
    btnTemp: TSpeedButton;
    edtTemp: TEdit;
    edtPiscar: TSpeedButton;
    btnLeitura: TSwitch;
    procedure conexao;
    procedure edtConexaoClick(Sender: TObject);
    procedure btnTempClick(Sender: TObject);
    procedure edtPiscarClick(Sender: TObject);
    procedure btnLeituraSwitch(Sender: TObject);
  private
    FThread: TThread;
    valorTemp: String;
    procedure finalizarThread;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.btnTempClick(Sender: TObject);
begin
  udp.Send('temp');
  edtTemp.Text := udp.ReceiveString(700);
end;

procedure TForm1.conexao;
begin
  udp.Host := edtIP.Text;
  udp.Port := 3333;
  udp.Connect;
end;

procedure TForm1.edtConexaoClick(Sender: TObject);
begin
  conexao;
end;

procedure TForm1.edtPiscarClick(Sender: TObject);
begin
  udp.Send('piscar');
end;

procedure TForm1.btnLeituraSwitch(Sender: TObject);
begin
  if btnLeitura.IsChecked then
  begin
    FThread := TThread.CreateAnonymousThread(procedure
      begin
          udp.Send('temp');
          sleep(100);
          TThread.Synchronize(nil,
            procedure
            begin
              edtTemp.Text := udp.ReceiveString(700);
            end
          );        
      end);
    FThread.FreeOnTerminate := false;
    FThread.Start;
  end
  else
    finalizarThread;
end;

procedure TForm1.finalizarThread;
begin
  if FThread <> nil then
  begin
    FThread.Terminate;
    FThread.WaitFor;
    FreeAndNil(FThread);
  end;
end;



end.
