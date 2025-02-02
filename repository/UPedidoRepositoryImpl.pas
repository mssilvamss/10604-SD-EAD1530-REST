unit UPedidoRepositoryImpl;

interface

uses
  UPedidoRepositoryIntf, UPizzaTamanhoEnum, UPizzaSaborEnum, UDBConnectionIntf, FireDAC.Comp.Client, System.TypInfo;

type
  TPedidoRepository = class(TInterfacedObject, IPedidoRepository)
  private
    FDBConnection: IDBConnection;
    FFDQuery: TFDQuery;
  public
    procedure efetuarPedido(const APizzaTamanho: TPizzaTamanhoEnum; const APizzaSabor: TPizzaSaborEnum; const AValorPedido: Currency;
    const ATempoPreparo: Integer; const ACodigoCliente: Integer);
    procedure consultaPedido(const ADocCliente: string; out AFDQuery : TFDQuery);
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation

uses
  UDBConnectionImpl, System.SysUtils, Data.DB, FireDAC.Stan.Param;

const
  CMD_INSERT_PEDIDO
    : String =
    'INSERT INTO tb_pedido (cd_cliente, dt_pedido, dt_entrega, nr_tempopedido, vl_pedido, de_tamanho, de_sabor)'+#13+
    'VALUES (:pCodigoCliente, :pDataPedido, :pDataEntrega, :pTempoPedido, :pValorPedido, :pTamanho, :pSabor)';
    CMD_CONSULTAR_PEDIDO: String =
      'SELECT PED.DE_TAMANHO, PED.DE_SABOR, PED.VL_PEDIDO, PED.NR_TEMPOPEDIDO,'+#13+
      'CLI.ID'+#13+
      'FROM TB_PEDIDO as PED, TB_CLIENTE CLI'+#13+
      'WHERE PED.CD_CLIENTE = CLI.ID'+#13+
      'AND CLI.NR_DOCUMENTO = :PDOCUMENTOCLIENTE'+#13+
      'ORDER BY PED.ID DESC LIMIT 1';
  { TPedidoRepository }

procedure TPedidoRepository.consultaPedido(const ADocCliente: string;
  out AFDQuery: TFDQuery);
begin
  AFDQuery.Connection := FDBConnection.getDefaultConnection;
  AFDQuery.SQL.Text := CMD_CONSULTAR_PEDIDO;

  AFDQuery.ParamByName('pDocumentoCliente').AsString := ADocCliente;
  AFDQuery.Prepare;
  AFDQuery.Open;
end;

constructor TPedidoRepository.Create;
begin
  inherited;
  FDBConnection := TDBConnection.Create;
  FFDQuery := TFDQuery.Create(nil);
  FFDQuery.Connection := FDBConnection.getDefaultConnection;
end;

destructor TPedidoRepository.Destroy;
begin
  FFDQuery.Free;
  inherited;
end;

procedure TPedidoRepository.efetuarPedido(const APizzaTamanho: TPizzaTamanhoEnum; const APizzaSabor: TPizzaSaborEnum; const AValorPedido: Currency;
  const ATempoPreparo: Integer; const ACodigoCliente: Integer);
begin
  FFDQuery.SQL.Text := CMD_INSERT_PEDIDO;

  FFDQuery.ParamByName('pCodigoCliente').AsInteger := ACodigoCliente;
  FFDQuery.ParamByName('pDataPedido').AsDateTime := now();
  FFDQuery.ParamByName('pDataEntrega').AsDateTime := now();
  FFDQuery.ParamByName('pValorPedido').AsCurrency := AValorPedido;
  FFDQuery.ParamByName('pTempoPedido').AsInteger := ATempoPreparo;
  FFDQuery.ParamByName('pTamanho').AsString := GetEnumName(TypeInfo(TPizzaTamanhoEnum),integer(APizzaTamanho));
  FFDQuery.ParamByName('pSabor').AsString := GetEnumName(TypeInfo(TPizzaSaborEnum),integer(APizzaSabor));

  FFDQuery.Prepare;
  FFDQuery.ExecSQL(True);
end;

end.
