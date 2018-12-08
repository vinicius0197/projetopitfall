# projetopitfall

	Explicação do código:

	A parte de como as macros que carregam os sprites e sons funcionam vou deixar para o jader explicar, pois ele sabe melhor o que cada linha faz. Aqui, vou descrever sob qual lógica o programa está rodando.

# .data: 

	Temos algumas strings e algumas words. As strings são apenas para exibir informações (printfs) na tela. O importante são as words. 
	No momento, temos uma word responsável por manter o nível em que o jogador se encontra, "LevelCounter"; 
outra word pra informar quantas vidas restam, "PlayerVida"; 
3 words para a lógica de posição do jogador (posição x, y, e uma flag para saber se ele está no andar de baixo ou de cima), "PlayerCoord"; 
algumas words para o posicionamento dos inimigos (posições x e y de barris, escorpiões, fogo/cobra. Em especial para os barris, eles podem estar parados ou rolando, então eles tem uma flag para informar isto), "EnemyCoord"; e
posição x e y dos tesouros (no máximo um em uma tela, então 2 words bastam), "TreasureCoord".

# .text

	Comentado se encontra o uso dos registradores permanentes. Tentei manter a convenção do uso de registradores ao máximo, mas em uma ou outra função posso ter desrespeitado-a: 
	s1 = endereco das coordenadas atuais Jogador;
	s2 = endereco das coordenadas atuais Inimigos;
	s3 = altura do pulo;
	s4 = quantos frames segura no momento mais alto do pulo (facilitar o pulo por cima de obstaculos);
	s5 = Pontuação;
	s10 = Tempo daqui a 20 min (usado para calculos de Timer);
	s11 = endereco das coordenadas do Tesouro.

	Começamos fazendo algumas inicializações. 
	A primeira linha é uma macro que o professor fez. Sem ela, ecalls não funcionam.
	ecall 130 carrega em a0 quantos ms se passaram desde o epoc.
	Adicionamos 20 minutos à a0 para ter o tempo em ms daqui a 20 minutos e salvamos em s10.
	Salvamos o endereço nos registradores corretos de PlayerCoord, EnemyCoord e TreasureCoord, pois estas são checadas a cada frame (assim diminuímos o número de acesso à memória); inicializamos s3, s4, e s5.
	Chamamos nossa primeira função, LOADLEVEL. A maioria das funções precisa alocar espaço para conservar o registrador ra. Vou omitir da explicação, mas é algo a se atentar.

## LOADLEVEL:
	Essa função vai carregar os inimigos e tesouros de cada nível de acordo com o LevelCounter. 
	Temos labels de níveis 1-10, e cada um desses labels começa fazendo uma comparação com o LevelCounter para saber se deve carregar aquele nível ou não. Se o LC corresponder com o label em questão, ele carrega os dados de TODOS os inimigos e tesouros, inclusive se não houverem nenhum deles (neste caso ele preenche com 0. Isso é necessário para evitar que carregue lixo de níveis anteriores). Se o label não corresponder com o LC, ele verifica o próximo label. Ao final de uma comparação de label bem sucedida, ela pula para o label EndLoadLevel para não ter que fazer mais comparações. EndLoadLevel é apenas para evitar vazamento de memória e garantir o bom retorno à quem chamou a função.

	Vamos agora à função principal do projeto, e também a mais simples, a UPDATE. Ela só chama outras funções e ao final chama a si mesma para manter o loop. Este ecall 132 é para controlar a frequência no rars (sleep thread). A primeira função que ela chama é a BACKGROUND.

## BACKGROUND:
	Essa função desenha o fundo do jogo na tela através de uma macro. 
	Deixo ao jader explicar esta macro.

	A próxima função da update é a HUD. Assim como a Update, ela apenas chama outras funções, todas de escrever na tela. Em ordem, ela chama TIMER, SCORE e LIVES.

## TIMER:
	Essa função escreve o tempo decorrido de forma decrescente.
	Ela começa especificando a cor e posições x, y do Timer (a3, a1, a2).
	Em seguida ela pega o tempo em ms do momento em que foi chamada (ecall 130).
	Em seguida temos 5 blocos de ecalls para escrever, respectivamente, as dezenas de minutos, as unidades de minutos, os dois-pontos divisor, as dezenas de segundos e as unidades de segundos.
	
## SCORE:
	Com blocos ecalls (como no timer), ela escreve na tela "Pontos: x".

## LIVES:
	Com blocos ecalls (como no timer), ela escreve na tela "Vidas: y".

	Concluímos a HUD. Agora na Update vem a CheckJump, mas antes dela vou explicar a Jump.

## Jump:
	Aqui informamos a altura máxima do pulo (s3) e quantos frames segurar (s4). A ideia é que a cada checkjump s3 decremente 1 até chegar a 0 e então começar a cair. 
	Fazemos umas verificações para impedir pulos em mid-air e então definimos s3 e s4. Depois tocamos o som de pulo com a macro que o jader vai explicar. Percebi agora que pode está ocorrendo vazamento de memória aqui. Vou investigar depois.
	
## CheckJump:
	Essa função é reponsável por fazer o pulo funcionar. É graças a ela que a cada frame depois de pular o jogo sabe até onde subir o jogador.
	Enquanto s3 não for 0, CheckJump vai fazer o jogador subir. Se é 0 ele cai.
	Na altura máxima (s3=1), ela chama MaxHeightHold, que nada mais é que um contador decrescente que impede que s3 vire 0 por s4 frames, e mantém o jogador nesta altura. Isto é para facilitar os pulos e simular uma física mais realista que leva em conta desacelaração.

	A próxima função chamada pela Update é a GRAVIDADE.

## GRAVIDADE:
	É uma função simples. A cada chamada (ou seja a cada frame) ela desloca o jogador pra baixo. A CheckJump compensa isso nos pulos subindo o jogador o dobro do que a gravidade abaixa.
	Além disso ela faz checagens para ver se o jogador está no chão, e se for o caso não desloca para baixo (checa tanto pro chão em cima quanto embaixo).

	Em seguida vêm funções de desenhar objetos na tela. Embora soltas agora, no futuro elas irão ser chamadas dentro de uma função maior, DRAW (assim como a Hud faz).

## DrawBarrel:
	Desenha barris na tela. Como podem haver qualquer quantidade entre 0 e 2 barris na tela ao mesmo tempo, ela faz uma checagem para ver se existem barris para desenhar.
	Essa checagem é feita olhando a coordenada y do barril e vendo se é 0. Y=0 é lá em cima, bem acima de onde o barril anda, então se for 0 significa que não existe aquele barril. 
	Essa checagem é feita primeiro para o 1o barril. Se falha pro 1o, não faz sentido ter um segundo, então ele pula para o label NoBarrel.
	No caso de haver barris, ele pega as coordenadas x, y dos barris e chama a função BarrelPrint que por sua vez chama a macro barrel_print feita pelo jader (esses passos a mais são para evitar memory leak, novamente).
	No momento, esta função contempla apenas barris parados.
	
## DrawPlayer:
	Desenha o jogador. Deve ser a última draw a ser chamada para que o jogador sempre fique a frente dos demais objetos.
	Apenas pega x e y da memória e chama a função que chama a macro harry_print.
	Acredito que ambas macros de draw são parecidas, se não idênticas, mas novamente deixo para que o jader explique seu comportamento.

	A última função chamada pela Update é CONTROLE.

## CONTROLE:
	Ela captura uma tecla do teclado através da função GetCommand e decide que ação tomar dependendo da tecla lida. Atualmente as ações possíveis são Jump, PlayerMoveRight e PlayerMoveLeft. Já expliquei Jump, vamos ver as outras duas, mas antes vamos ver a GetCommand.

## GetCommand:
	Sendo bem sincero, eu não parei muito para enteder como funciona esta função, porque copiamos ela do exemplo do professor. O importante pra saber aqui é que ela é a alternativa pra não usar ecalls de input, pois estes travam o processo (thread) até que leiam algo. Desta forma, é possível não ler nada e partir para a próxima iteração do loop.

## PlayerMoveRight:
	Esta função apenas atualiza a posição do jogador um certo valor para a direita. 
	Antes disso no entanto, ela verifica se a posição futura está fora do limite da tela, e se estiver chama a função de OutOfBoundsRight.
	
## OutOfBoundsRight:
	Esta função faz duas coisas: primeiro ela atualiza a posição do jogador para a extrema esquerda (assim dando a ilusão que a câmera foi pra frente pra acompanhar ele), e depois ela muda o nível.
	A atualização da posição do jogador é bem óbvia, apenas seta o valor da coordenada x de PlayerCoord para o valor desejado.
	 Para mudar para o nível certo, ela identifica em qual nível o jogador está agora e checa pra ver se está no último nível, porque se estiver, ela vai para um label SetLevel que seta o nível como o nível 1. 
	Se essa checagem falha, ela apenas incrementa o LevelCounter em 1. 
	Por fim, ela chama a função LOADLEVEL para carregar em memória os valores corretos do novo nível.

	É fácil ver que PlayerMoveLeft e OutOfBoundLeft se comportam de forma análoga às funções acima. 

	Com isso concluo a explicação do código, espero que tenha sido bem elucidativo. Qualquer dúvida, só falar.
	


















