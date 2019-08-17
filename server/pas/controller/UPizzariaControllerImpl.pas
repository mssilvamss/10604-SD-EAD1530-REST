unit UPizzariaControllerImpl;

interface

{$I dmvcframework.inc}

uses  MVCFramework,
      MVCFramework.Logger,
      MVCFramework.Commons,
      Web.HTTPApp,
      UPizzaTamanhoEnum,
      UPizzaSaborEnum,
      UEfetuarPedidoDTOImpl,
      UPedidoRetornoDTOImpl,
      UPedidoServiceIntf;

type

  [MVCDoc('Pizzaria backend')]
  [MVCPath('/')]
  TPizzariaBackendController = class(TMVCController)
  public

    [MVCDoc('Criar novo pedido "201: Created"')]
    [MVCPath('/efetuarPedido')]
    [MVCHTTPMethod([httpPOST])]
    procedure efetuarPedido(const AContext: TWebContext);

    [MVCDoc('Consultar pedido "200: OK"')]
    [MVCPath('/consultaPedido/($doc)')]
    [MVCHTTPMethod([httpGET])]
    procedure consultaPedido(const AContext: TWebContext);

  end;

implementation

uses
  System.SysUtils,
  Rest.json,
  MVCFramework.SystemJSONUtils,
  UPedidoServiceImpl;

{ TApp1MainController }

procedure TPizzariaBackendController.consultaPedido(const AContext: TWebContext);
var
    oPedidoRetornoDTO: TPedidoRetornoDTO;
    oDocumento       : string;
    oPedidoService   : IPedidoService;
begin
  oDocumento := AContext.Request.Params['doc'];
  oPedidoService := TPedidoService.Create;

  TRY
    oPedidoRetornoDTO := oPedidoService.consultaPedido(oDocumento);
    Render(TJson.ObjectToJsonString(oPedidoRetornoDTO));
    oPedidoRetornoDTO.Free;
  except
    On E : Exception do
    begin
      AContext.Response.StatusCode := HTTP_Status.NotFound;
      Render(e.Message);
    end;
  END;

  Log.Info('==>Executou o método ', 'consultaPedido');
end;

procedure TPizzariaBackendController.efetuarPedido(const AContext: TWebContext);
var
  oEfetuarPedidoDTO: TEfetuarPedidoDTO;
  oPedidoRetornoDTO: TPedidoRetornoDTO;
  oBody : string;
begin
  oBody := AContext.Request.Body;
  oEfetuarPedidoDTO := TJson.JsonToObject<TEfetuarPedidoDTO>(oBody);
  try
    with TPedidoService.Create do
      try
        oPedidoRetornoDTO := efetuarPedido(oEfetuarPedidoDTO.PizzaTamanho, oEfetuarPedidoDTO.PizzaSabor, oEfetuarPedidoDTO.DocumentoCliente);
        Render(TJson.ObjectToJsonString(oPedidoRetornoDTO));
      finally
        oPedidoRetornoDTO.Free
      end;
  finally
    oEfetuarPedidoDTO.Free;
  end;
  Log.Info('==>Executou o método ', 'efetuarPedido');
end;

end.
