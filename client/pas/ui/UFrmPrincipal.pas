unit UFrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, UPizzaSaborEnum,UPedidoRetornoDTOImpl1, UPizzaTamanhoEnum;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edtDocumentoCliente: TLabeledEdit;
    cmbTamanhoPizza: TComboBox;
    cmbSaborPizza: TComboBox;
    Button1: TButton;
    mmRetornoWebService: TMemo;
    edtEnderecoBackend: TLabeledEdit;
    edtPortaBackend: TLabeledEdit;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure edtDocumentoClienteKeyPress(Sender: TObject; var Key: Char);

  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;



implementation

uses
  Rest.JSON, MVCFramework.RESTClient, UEfetuarPedidoDTOImpl, System.Rtti;

{$R *.dfm}


procedure TForm1.Button2Click(Sender: TObject);
var
  Clt: TRestClient;
  oDTO: TPedidoRetornoDTO;
  oRestReponse: IRESTResponse;
begin
  if edtDocumentoCliente.Text = EmptyStr then
    begin
      Application.MessageBox('Prezado cliente informe o n� do pedido', 'Aten��o',
      MB_OK + MB_ICONWARNING);
      edtDocumentoCliente.SetFocus;
    end
  else
  begin
    Clt := MVCFramework.RESTClient.TRestClient.Create(edtEnderecoBackend.Text,
      StrToIntDef(edtPortaBackend.Text, 80), nil);
    try
      oRestReponse := Clt.doGET('/consultaPedido',
        [edtDocumentoCliente.Text], nil);
    except
      // Professor n�o consigo tratar esse erro(Caso n�o exista n�mero de documento)
      Showmessage(oRestReponse.Error.ToString);
    end;

    oDTO := TJson.JsonToObject<TPedidoRetornoDTO>(oRestReponse.BodyAsString);
    mmRetornoWebService.Clear;

    mmRetornoWebService.Lines.Add('Tamanho da Pizza= ' +
      Copy(TRttiEnumerationType.GetName<TPizzaTamanhoEnum>(oDTO.PizzaTamanho),
      3, length(TRttiEnumerationType.GetName<TPizzaTamanhoEnum>
      (oDTO.PizzaTamanho))));

    mmRetornoWebService.Lines.Add('Sabor da Pizza  = ' +
      Copy(TRttiEnumerationType.GetName<TPizzaSaborEnum>(oDTO.PizzaSabor), 3,
      length(TRttiEnumerationType.GetName<TPizzaSaborEnum>(oDTO.PizzaSabor))));

    mmRetornoWebService.Lines.Add('Pre�o da Pizza  = ' + FormatCurr('R$ 0.00',
      oDTO.ValorTotalPedido));

    mmRetornoWebService.Lines.Add('Tempo de Preparo = ' +
      oDTO.TempoPreparo.ToString + ' minutos.');
  end;

end;



procedure TForm1.edtDocumentoClienteKeyPress(Sender: TObject; var Key: Char);
begin
  if not( key in['0'..'9',#08] ) then
    Key := #0;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Clt: TRestClient;
  oEfetuarPedido: TEfetuarPedidoDTO;
begin
  if edtDocumentoCliente.Text = EmptyStr then
  begin
    Application.MessageBox('Prezado cliente informe o n� do pedido', 'Aten��o',
      MB_OK + MB_ICONWARNING);
    edtDocumentoCliente.SetFocus;
  end
  else if cmbTamanhoPizza.ItemIndex < 0 then
  begin
    Application.MessageBox('Escolha um tamanho de pizza', 'Aten��o',
      MB_OK + MB_ICONWARNING);
    cmbTamanhoPizza.SetFocus;
  end
  else if cmbSaborPizza.ItemIndex < 0 then
  begin
    Application.MessageBox('Escolha um sabor de pizza', 'Aten��o',
      MB_OK + MB_ICONWARNING);
    cmbSaborPizza.SetFocus;
  end
  else
  begin
    Clt := MVCFramework.RESTClient.TRestClient.Create(edtEnderecoBackend.Text,
      StrToIntDef(edtPortaBackend.Text, 80), nil);
    try
      oEfetuarPedido := TEfetuarPedidoDTO.Create;
      try
        oEfetuarPedido.PizzaTamanho :=
          TRttiEnumerationType.GetValue<TPizzaTamanhoEnum>
          (cmbTamanhoPizza.Text);
        oEfetuarPedido.PizzaSabor :=
          TRttiEnumerationType.GetValue<TPizzaSaborEnum>(cmbSaborPizza.Text);
        oEfetuarPedido.DocumentoCliente := edtDocumentoCliente.Text;
        mmRetornoWebService.Text := Clt.doPOST('/efetuarPedido', [],
          TJson.ObjecttoJsonString(oEfetuarPedido)).BodyAsString;
      finally
        oEfetuarPedido.Free;
      end;
    finally
      Clt.Free;
    end;
  end;
end;

end.
