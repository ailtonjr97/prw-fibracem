User Function cria_stamp()

Local nI, cConfig, aConfig 

//Cria uma nova conexão com um banco (SGBD) através do DBAccess
TCLink() 

//Habilita o Dbaccess e acrescentar o campo STAMP nas novas tabelas
TCConfig('SETUSEROWSTAMP=ON') 

// Habilita criar o campo para tabelas já existentes (Para usar esse segundo comando ( AUTOSTAMP ) , você deve primeiro habilitar o primeiro (USEROWSTAMP)
TCCONfig("SETAUTOSTAMP=ON") 

// Faz o Dbaccess acrescentar a coluna sem precisar recriar a tabela
TCRefresh("SA3010") 

//Após execução desligar as chaves para não criar em outras tabelas do sistema desnecessárias 
 TCCONfig("SETUSEROWSTAMP=OFF") 
 TCCONfig("SETAUTOSTAMP=OFF") 

//Encerra a conexão especificada com o DBAccess
TCUnlink() 

Return
