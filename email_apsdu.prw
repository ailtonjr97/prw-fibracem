#INCLUDE 'protheus.ch'
#INCLUDE 'Ap5Mail.ch'
 
/*/{Protheus.doc} User Function SduLogin
Enviar email de aviso que acessou o apsdu
@author Thalys Augusto
@since 15/07/2020
@version 1.0
@type function
/*/
 
User Function SduLogin()
    Local lRet := .T.
    Local cAssunto := 'Login no APSDU'
    Local cDestinatario := ''
    Local cMensagem := ''
    Local cUser := ParamIXB
     
    //Monta a mensagem do e-Mail
    cMensagem    :=    "Usuário Protheus <b>" +Alltrim(cUser)+ "</b> efetuou login no APSDU através do usuário de rede "
    cMensagem    +=    "<b>" + Alltrim(LogUserName()) + "</b> em " + DtoC( Date()) + " às " + Time() 
    cMensagem    +=    " na máquina <b>" + Lower(ComputerName()) + Upper(" (IP "+ GetClientIP()+" / PC: " +GetComputerName()+")</b>")
 
    //Dispara o e-Mail para o destinatario configurado
    cDestinatario := 'informatica04@fibracem.com'
    fSendMail(cDestinatario, cAssunto, cMensagem)
Return .T.
 
/*/{Protheus.doc} Static Function fSendMail
Função que realiza o envio do e-mail
@author Thalys Augusto
@since 15/07/2020
@version 1.0
@type function
/*/
 
Static Function fSendMail(cPara , cSubject, cMsg)
    Local oMail , oMessage
    Local lRet := .T.
    Local cSMTPServer := 'outlook.maiex13.com.br'
    Local cSMTPUser := 'suporte@fibracem.com'
    Local cSMTPPass := 'Fibracem@2021'
    Local cMailFrom := 'suporte@fibracem.com'
    Local nPort := 587
    Local lUseAuth := .T.
    Local cCopia := ''
    Local cMailError := ""
    Local nErro, nErroAuth
     
    //Faz a conexão com o eMail
    MsgRun('Conectando com SMTP ', ' ', {||oMail := TMailManager():New()})
    oMail:SetUseTLS( .T. )
    MsgRun('Inicializando SMTP', '', {|| oMail:Init( '', cSMTPServer , cSMTPUser, cSMTPPass, 0, nPort )})
    MsgRun('Setando Time-Out', '', {||oMail:SetSmtpTimeOut( 30 )})
    MsgRun('Conectando com servidor...', '', {||nErro := oMail:SmtpConnect()})
    MsgRun('Status de Retorno = ' +  Str(nErro, 6), '', {||})
     
    //Se usa autenticacao
    If lUseAuth
        nErroAuth := 0
        MsgRun('Autenticando Usuario [' + cSMTPUser + '] senha ********* ', '', {||nErroAuth := oMail:SmtpAuth(cSMTPUser , cSMTPPass)})
        MsgRun('Status de Retorno = ' + str(nErroAuth, 6), '', {||})
         
        //Se houve erro, busca ele
        If nErroAuth <> 0
            cMailError := oMail:GetErrorString(nErroAuth)
            cMailError := Iif(Empty(cMailError), '***Unknown Error***', cMailError)
            //ConOut('Erro de Autenticacao ' + str(nErroAuth, 4) + ' (' + cMAilError + ')')
            lRet := .F.
        EndIf
    EndIf
     
    //Se houve algum outro erro
    If nErro <> 0
        // Recupera erro
        cMailError := oMail:GetErrorString(nErro)
        cMailError := Iif(Empty(cMailError), '***Unknown Error***', cMailError)
        //ConOut(cMAilError)
        //ConOut('Erro de Conexão SMTP ' + str(nErro, 4))
        //ConOut('Desconectando do SMTP')
        oMail:SMTPDisconnect()
        lRet := .F.
    EndIf
     
    //Se tudo estiver ok para o envio
    If lRet
        //ConOut('Compondo mensagem em memória')
        oMessage := TMailMessage():New()
        oMessage:Clear()
        oMessage:cFrom := cMailFrom
        oMessage:cTo := cPara
        If !Empty(cCopia)
            oMessage:cCc := cCopia
        EndIf
        oMessage:cSubject := cSubject
        oMessage:cBody := cMsg
         
        //Tenta realizar o disparo
        MsgRun('Enviando Mensagem para [' + cPara + '] ', '', {|| nErro := oMessage:Send( oMail )})
        If nErro <> 0
            cMailError := oMail:GetErrorString(nErro)
            cMailError := Iif(Empty(cMailError), '***Unknown Error***', cMailError)
            //ConOut('Erro de Envio SMTP ' + str(nErro, 4) + ' (' + cMailError + ')')
            lRet := .F.
        EndIf
         
        //ConOut('Desconectando do SMTP')
        oMail:SMTPDisconnect()
    EndIf
     
Return lRet
