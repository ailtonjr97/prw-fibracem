#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

User Function FIBTRACKORDER()
    Local aArea := GetArea()
     
    Local aSize       := MsAdvSize()
    Local nPort       := 0
    Local cUrl        := "https://www.youtube.com/?app=desktop&gl=BR"
    Local oModal
    Local oWebEngine 
    Private oWebChannel := TWebChannel():New()
     
    //Cria a dialog
    oModal := MSDialog():New(aSize[7],0,aSize[6],aSize[5], "",,,,,,,,,.T./*lPixel*/)
     
        //Prepara o conector
        nPort := oWebChannel::connect()
 
        //Cria o componente que ir� carregar a url
        oWebEngine := TWebEngine():New(oModal, 0, 0, 100, 100,/*cUrl*/, nPort)
        oWebEngine:bLoadFinished := {|self, url| /*conout("Fim do carregamento da pagina " + url)*/ }
        oWebEngine:navigate(cUrl)
        oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
    oModal:Activate()
     
    RestArea(aArea)
Return
