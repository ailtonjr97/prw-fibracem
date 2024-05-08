User Function cria_stamp()

Local nI, cConfig, aConfig 

//Cria uma nova conex�o com um banco (SGBD) atrav�s do DBAccess
TCLink() 

//Habilita o Dbaccess e acrescentar o campo STAMP nas novas tabelas
TCConfig('SETUSEROWSTAMP=ON') 

// Habilita criar o campo para tabelas j� existentes (Para usar esse segundo comando ( AUTOSTAMP ) , voc� deve primeiro habilitar o primeiro (USEROWSTAMP)
TCCONfig("SETAUTOSTAMP=ON") 

// Faz o Dbaccess acrescentar a coluna sem precisar recriar a tabela
TCRefresh("SA3010") 

//Ap�s execu��o desligar as chaves para n�o criar em outras tabelas do sistema desnecess�rias 
 TCCONfig("SETUSEROWSTAMP=OFF") 
 TCCONfig("SETAUTOSTAMP=OFF") 

//Encerra a conex�o especificada com o DBAccess
TCUnlink() 

Return
