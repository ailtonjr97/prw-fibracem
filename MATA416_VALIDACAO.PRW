//Bibliotecas
#Include "Totvs.ch"

/*/{Protheus.doc} User Function valFrete
Para validar se frete esta valido
@author everson
@since 06/03/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

User Function u_valFrete()
	Local aArea         := FWGetArea()
	Local cResultado    := ''
	Local cErro         := ''
	Local aHeader       := {}
	Local oRestClient   := FWRest():New('http://intranet.fibracem.com')
	
	//Monta o cabe�alho da Requisi��o
	aAdd(aHeader, 'User-Agent: Mozilla/4.0 (compatible; Protheus 12.1.x)')
	aAdd(aHeader, 'Content-Type: application/json; charset=utf-8')
	
	//Define a PATH da URL
	oRestClient:setPath('/remoto/get/teste')
	
	//Executa a Requisi��o
	If oRestClient:Get(aHeader)
		cResultado := oRestClient:GetResult()
		ShowLog('Sucesso na integra��o, resultado �: ' + CRLF + cResultado)
	Else
		cErro := oRestClient:GetLastError()
		ShowLog('Houve um erro na integra��o: ' + CRLF + cErro)
	EndIf
	
	FWRestArea(aArea)
Return Nil
