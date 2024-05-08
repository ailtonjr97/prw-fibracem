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
	
	//Monta o cabeçalho da Requisição
	aAdd(aHeader, 'User-Agent: Mozilla/4.0 (compatible; Protheus 12.1.x)')
	aAdd(aHeader, 'Content-Type: application/json; charset=utf-8')
	
	//Define a PATH da URL
	oRestClient:setPath('/remoto/get/teste')
	
	//Executa a Requisição
	If oRestClient:Get(aHeader)
		cResultado := oRestClient:GetResult()
		ShowLog('Sucesso na integração, resultado é: ' + CRLF + cResultado)
	Else
		cErro := oRestClient:GetLastError()
		ShowLog('Houve um erro na integração: ' + CRLF + cErro)
	EndIf
	
	FWRestArea(aArea)
Return Nil
