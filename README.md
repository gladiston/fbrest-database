# fbrest-database
É um conjunto de scripts para restaurar backup do FirebirdSQL para um disco local.

**fbrest-database-from-fbk.cmd**

Objetivo: Supondo que você tenha um arquivo local de FirebirdSQL, por exemplo, backup.fbk, você simplesmente vai ate o cmd e executa:
fbrest-database-from-fbk.cmd backup.fbk dados.fdb
E o script fará a restauração para você. 

**fbrest-database-from-server.cmd**

Objetivo: Supondo que você queira transferir um banco de dados remoto do FirebirdSQL para uma base local, simplesmente vai ate o cmd e executa:
fbrest-database-from-server.cmd fbserver01:/meusdados.fdb meusdadosdev.fdb
E o script fará um backup de fbserver01:/meusdados.fdb e o restaurará localmente como meusdadosdev.fdb. 

Nota: Estes scripts utilizarão as variaveis de ambiente ISC_USER e ISC_PASSWORD para suprimir a digitação da senha e a mesma não ficar exposta dentro deste script, então tenha certeza de ter definido estas variaives para o usuario/senha que costumeiramente utiliza para restaurar o backup ou fazer o backup do servidor para sua estação.

Claro que poderia usar o gbak diretamente, mas se fará isso muitas vezes é bom ter um script que agiliza.
Use o recurso do TAB de autocompletar no cmd para não ter que digitar rem os nomes de arquivos por inteiro.
