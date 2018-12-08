# projetopitfall

	Explica��o do c�digo:

	A parte de como as macros que carregam os sprites e sons funcionam vou deixar para o jader explicar, pois ele sabe melhor o que cada linha faz. Aqui, vou descrever sob qual l�gica o programa est� rodando.

# .data: 

	Temos algumas strings e algumas words. As strings s�o apenas para exibir informa��es (printfs) na tela. O importante s�o as words. 
	No momento, temos uma word respons�vel por manter o n�vel em que o jogador se encontra, "LevelCounter"; 
outra word pra informar quantas vidas restam, "PlayerVida"; 
3 words para a l�gica de posi��o do jogador (posi��o x, y, e uma flag para saber se ele est� no andar de baixo ou de cima), "PlayerCoord"; 
algumas words para o posicionamento dos inimigos (posi��es x e y de barris, escorpi�es, fogo/cobra. Em especial para os barris, eles podem estar parados ou rolando, ent�o eles tem uma flag para informar isto), "EnemyCoord"; e
posi��o x e y dos tesouros (no m�ximo um em uma tela, ent�o 2 words bastam), "TreasureCoord".

# .text

	Comentado se encontra o uso dos registradores permanentes. Tentei manter a conven��o do uso de registradores ao m�ximo, mas em uma ou outra fun��o posso ter desrespeitado-a: 
	s1 = endereco das coordenadas atuais Jogador;
	s2 = endereco das coordenadas atuais Inimigos;
	s3 = altura do pulo;
	s4 = quantos frames segura no momento mais alto do pulo (facilitar o pulo por cima de obstaculos);
	s5 = Pontua��o;
	s10 = Tempo daqui a 20 min (usado para calculos de Timer);
	s11 = endereco das coordenadas do Tesouro.

	Come�amos fazendo algumas inicializa��es. 
	A primeira linha � uma macro que o professor fez. Sem ela, ecalls n�o funcionam.
	ecall 130 carrega em a0 quantos ms se passaram desde o epoc.
	Adicionamos 20 minutos � a0 para ter o tempo em ms daqui a 20 minutos e salvamos em s10.
	Salvamos o endere�o nos registradores corretos de PlayerCoord, EnemyCoord e TreasureCoord, pois estas s�o checadas a cada frame (assim diminu�mos o n�mero de acesso � mem�ria); inicializamos s3, s4, e s5.
	Chamamos nossa primeira fun��o, LOADLEVEL. A maioria das fun��es precisa alocar espa�o para conservar o registrador ra. Vou omitir da explica��o, mas � algo a se atentar.

## LOADLEVEL:
	Essa fun��o vai carregar os inimigos e tesouros de cada n�vel de acordo com o LevelCounter. 
	Temos labels de n�veis 1-10, e cada um desses labels come�a fazendo uma compara��o com o LevelCounter para saber se deve carregar aquele n�vel ou n�o. Se o LC corresponder com o label em quest�o, ele carrega os dados de TODOS os inimigos e tesouros, inclusive se n�o houverem nenhum deles (neste caso ele preenche com 0. Isso � necess�rio para evitar que carregue lixo de n�veis anteriores). Se o label n�o corresponder com o LC, ele verifica o pr�ximo label. Ao final de uma compara��o de label bem sucedida, ela pula para o label EndLoadLevel para n�o ter que fazer mais compara��es. EndLoadLevel � apenas para evitar vazamento de mem�ria e garantir o bom retorno � quem chamou a fun��o.

	Vamos agora � fun��o principal do projeto, e tamb�m a mais simples, a UPDATE. Ela s� chama outras fun��es e ao final chama a si mesma para manter o loop. Este ecall 132 � para controlar a frequ�ncia no rars (sleep thread). A primeira fun��o que ela chama � a BACKGROUND.

## BACKGROUND:
	Essa fun��o desenha o fundo do jogo na tela atrav�s de uma macro. 
	Deixo ao jader explicar esta macro.

	A pr�xima fun��o da update � a HUD. Assim como a Update, ela apenas chama outras fun��es, todas de escrever na tela. Em ordem, ela chama TIMER, SCORE e LIVES.

## TIMER:
	Essa fun��o escreve o tempo decorrido de forma decrescente.
	Ela come�a especificando a cor e posi��es x, y do Timer (a3, a1, a2).
	Em seguida ela pega o tempo em ms do momento em que foi chamada (ecall 130).
	Em seguida temos 5 blocos de ecalls para escrever, respectivamente, as dezenas de minutos, as unidades de minutos, os dois-pontos divisor, as dezenas de segundos e as unidades de segundos.
	
## SCORE:
	Com blocos ecalls (como no timer), ela escreve na tela "Pontos: x".

## LIVES:
	Com blocos ecalls (como no timer), ela escreve na tela "Vidas: y".

	Conclu�mos a HUD. Agora na Update vem a CheckJump, mas antes dela vou explicar a Jump.

## Jump:
	Aqui informamos a altura m�xima do pulo (s3) e quantos frames segurar (s4). A ideia � que a cada checkjump s3 decremente 1 at� chegar a 0 e ent�o come�ar a cair. 
	Fazemos umas verifica��es para impedir pulos em mid-air e ent�o definimos s3 e s4. Depois tocamos o som de pulo com a macro que o jader vai explicar. Percebi agora que pode est� ocorrendo vazamento de mem�ria aqui. Vou investigar depois.
	
## CheckJump:
	Essa fun��o � repons�vel por fazer o pulo funcionar. � gra�as a ela que a cada frame depois de pular o jogo sabe at� onde subir o jogador.
	Enquanto s3 n�o for 0, CheckJump vai fazer o jogador subir. Se � 0 ele cai.
	Na altura m�xima (s3=1), ela chama MaxHeightHold, que nada mais � que um contador decrescente que impede que s3 vire 0 por s4 frames, e mant�m o jogador nesta altura. Isto � para facilitar os pulos e simular uma f�sica mais realista que leva em conta desacelara��o.

	A pr�xima fun��o chamada pela Update � a GRAVIDADE.

## GRAVIDADE:
	� uma fun��o simples. A cada chamada (ou seja a cada frame) ela desloca o jogador pra baixo. A CheckJump compensa isso nos pulos subindo o jogador o dobro do que a gravidade abaixa.
	Al�m disso ela faz checagens para ver se o jogador est� no ch�o, e se for o caso n�o desloca para baixo (checa tanto pro ch�o em cima quanto embaixo).

	Em seguida v�m fun��es de desenhar objetos na tela. Embora soltas agora, no futuro elas ir�o ser chamadas dentro de uma fun��o maior, DRAW (assim como a Hud faz).

## DrawBarrel:
	Desenha barris na tela. Como podem haver qualquer quantidade entre 0 e 2 barris na tela ao mesmo tempo, ela faz uma checagem para ver se existem barris para desenhar.
	Essa checagem � feita olhando a coordenada y do barril e vendo se � 0. Y=0 � l� em cima, bem acima de onde o barril anda, ent�o se for 0 significa que n�o existe aquele barril. 
	Essa checagem � feita primeiro para o 1o barril. Se falha pro 1o, n�o faz sentido ter um segundo, ent�o ele pula para o label NoBarrel.
	No caso de haver barris, ele pega as coordenadas x, y dos barris e chama a fun��o BarrelPrint que por sua vez chama a macro barrel_print feita pelo jader (esses passos a mais s�o para evitar memory leak, novamente).
	No momento, esta fun��o contempla apenas barris parados.
	
## DrawPlayer:
	Desenha o jogador. Deve ser a �ltima draw a ser chamada para que o jogador sempre fique a frente dos demais objetos.
	Apenas pega x e y da mem�ria e chama a fun��o que chama a macro harry_print.
	Acredito que ambas macros de draw s�o parecidas, se n�o id�nticas, mas novamente deixo para que o jader explique seu comportamento.

	A �ltima fun��o chamada pela Update � CONTROLE.

## CONTROLE:
	Ela captura uma tecla do teclado atrav�s da fun��o GetCommand e decide que a��o tomar dependendo da tecla lida. Atualmente as a��es poss�veis s�o Jump, PlayerMoveRight e PlayerMoveLeft. J� expliquei Jump, vamos ver as outras duas, mas antes vamos ver a GetCommand.

## GetCommand:
	Sendo bem sincero, eu n�o parei muito para enteder como funciona esta fun��o, porque copiamos ela do exemplo do professor. O importante pra saber aqui � que ela � a alternativa pra n�o usar ecalls de input, pois estes travam o processo (thread) at� que leiam algo. Desta forma, � poss�vel n�o ler nada e partir para a pr�xima itera��o do loop.

## PlayerMoveRight:
	Esta fun��o apenas atualiza a posi��o do jogador um certo valor para a direita. 
	Antes disso no entanto, ela verifica se a posi��o futura est� fora do limite da tela, e se estiver chama a fun��o de OutOfBoundsRight.
	
## OutOfBoundsRight:
	Esta fun��o faz duas coisas: primeiro ela atualiza a posi��o do jogador para a extrema esquerda (assim dando a ilus�o que a c�mera foi pra frente pra acompanhar ele), e depois ela muda o n�vel.
	A atualiza��o da posi��o do jogador � bem �bvia, apenas seta o valor da coordenada x de PlayerCoord para o valor desejado.
	 Para mudar para o n�vel certo, ela identifica em qual n�vel o jogador est� agora e checa pra ver se est� no �ltimo n�vel, porque se estiver, ela vai para um label SetLevel que seta o n�vel como o n�vel 1. 
	Se essa checagem falha, ela apenas incrementa o LevelCounter em 1. 
	Por fim, ela chama a fun��o LOADLEVEL para carregar em mem�ria os valores corretos do novo n�vel.

	� f�cil ver que PlayerMoveLeft e OutOfBoundLeft se comportam de forma an�loga �s fun��es acima. 

	Com isso concluo a explica��o do c�digo, espero que tenha sido bem elucidativo. Qualquer d�vida, s� falar.
	


















