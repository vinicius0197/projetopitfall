# projetopitfall

Explicação do código:

A parte de como as macros que carregam os sprites e sons funcionam vou deixar para o jader explicar, pois ele sabe melhor o que cada linha faz. Aqui, vou descrever sob qual lógica o programa está rodando.

## .data: 

Temos algumas strings e algumas words. As strings são apenas para exibir informações (printfs) na tela. O importante são as words. 

No momento, temos uma word responsável por manter o nível em que o jogador se encontra, "LevelCounter";
outra word pra informar quantas vidas restam, "PlayerVida"; 
3 words para a lógica de posição do jogador (posição x, y, e uma flag para saber se ele está no andar de baixo ou de cima), "PlayerCoord"; 
algumas words para o posicionamento dos inimigos (posições x e y de barris, escorpiões, fogo/cobra. Em especial para os barris, eles podem estar parados ou rolando, então eles tem uma flag para informar isto. Temos também duas words para a lógica do crocodilo), "EnemyCoord"; e
posição x e y dos tesouros (no máximo um em uma tela, então 2 words bastam) e quais níveis tem tesouro nele (temos 3 tesouros no máximo, totalizando 5 words para a lógica de tesouros), "TreasureCoord".

## .text

Comentado se encontra o uso dos registradores permanentes. Tentei manter a convenção do uso de registradores ao máximo, mas em uma ou outra função posso ter desrespeitado-a: 

	s1 = endereco das coordenadas atuais Jogador;
	s2 = endereco das coordenadas atuais Inimigos;
	s3 = altura do pulo;
	s4 = quantos frames segura no momento mais alto do pulo (facilitar o pulo por cima de obstaculos);
	s5 = Pontuação;
	s10 = Tempo daqui a 20 min (usado para calculos de Timer);
	s11 = endereco das coordenadas do Tesouro.

Começamos fazendo algumas inicializações através de uma função STARTUP. 

## STARTUP:

A primeira linha é uma macro que o professor fez. Sem ela, ecalls não funcionam. ecall 130 carrega em a0 quantos ms se passaram desde o epoc.

Chamamos uma função que simula uma tela de loading, chamada Intro. Melhora a aparência do jogo dando um ar de um jogo mais real.

Adicionamos 20 minutos à a0 para ter o tempo em ms daqui a 20 minutos e salvamos em s10.

Salvamos o endereço nos registradores corretos de PlayerCoord, EnemyCoord e TreasureCoord, pois estas são checadas a cada frame (assim diminuímos o número de acesso à memória); inicializamos s3, s4, e s5.

Antes de chamarmos nossa primeira função, LOADLEVEL, chamamos uma função que faz com que o jogo comece em um nível aleatório, a RandomizeStartingLevel. A maioria das funções precisa alocar espaço para conservar o registrador ra. Vou omitir da explicação, mas é algo a se atentar.

## RandomizeStartingLevel:

Esta função usa o ecall 142 para gerar um inteiro entre 0-9 e depois soma 1 para resultar em um inteiro entre 1-10, e em seguida salvar este inteiro no LevelCounter. Para o seed que gera o número, usamos o resultado do ecall 130 (ms passados desde epoc).

Ela não faz parte da especificação e nem do jogo original, mas acrescenta diversão e variedade ao jogo. Para uma experiência mais fiel recomendo comentar a chamada.

## Intro:

Apenas desenha a capa do jogo na tela e em seguida aguarda 2 segundos para simular um loading. Depois disso limpa a tela com CLS.

## LOADLEVEL:

Essa função vai carregar os inimigos e tesouros de cada nível de acordo com o LevelCounter. 

Temos labels de níveis 1-10, e cada um desses labels começa fazendo uma comparação com o LevelCounter para saber se deve carregar aquele nível ou não. Se o LC corresponder com o label em questão, ele carrega os dados de TODOS os inimigos e tesouros, inclusive se não houverem nenhum deles (neste caso ele preenche com 0. Isso é necessário para evitar que carregue lixo de níveis anteriores). Se o label não corresponder com o LC, ele verifica o próximo label. Ao final de uma comparação de label bem sucedida, ela pula para o label EndLoadLevel para não ter que fazer mais comparações. EndLoadLevel é apenas para evitar vazamento de memória e garantir o bom retorno à quem chamou a função.

Vamos agora à função principal do projeto, e também a mais simples, a UPDATE. Ela só chama outras funções e ao final chama a si mesma para manter o loop. Este ecall 132 é para controlar a frequência no rars (sleep thread). A primeira função que ela chama é a GAMEOVERCHECK e depois a BACKGROUND.

## GAMEOVERCHECK:

Verifica 3 condições de fim de jogo: falta de vidas, falta de tempo, ou todos os tesouros obtidos. Para as condições de derrota, ela chama GameOverLose; para a condição de vitória chama GameOverWin. A única diferença é a música que cada uma toca.

## BACKGROUND:
Essa função desenha o fundo do jogo na tela através de uma macro. É carregado o binário da imagem em memória referenciado por um endereço e em seguida copiado word a word os dados para a região de memória da saida VGA, aumentado ambos os endereços, endereço de imagem e endereço da saída VGA e executando-se um contador para saber quando chegar no fim da cópia.

O fundo a ser desenhado muda de acordo com o LevelCounter. Pegamos o resto da divisão do nível atual por 3. Cada um dos 3 valores de resto possíveis irá carregar um plano diferente. Isso causa a impressão maior que o jogador está se movendo.

Além disso, temos um caso particular. Se o nível apontado pelo LevelCounter for o 5º, então irá carregar um plano com crocodilos. Em Pitfall!, os crocodilos alternam entre fechar ou abrir a boca, custando uma vida se o jogador caia em cima da boca do crocodilo caso a mesma esteja aberta. Para implementar a lógica de alternar entre abre ou fecha, temos a função CrocBG que é chamada apenas quando estamos no nível 5.

## CrocBG:

A função funciona utilizando as duas words reservadas pra lógica dos crocodilos no .data: a primeira é uma flag pra verificar se a boca está aberta ou fechada; a segunda armazena um tempo. 

Assim que CrocBG é chamada, pegamos a hora atual em ms (ecall 130) e comparamos com o valor da segunda word. Caso a hora atual seja 2500 ou mais milisegundos maior, então pulamos para uma label ChangeState que altera a flag de estado da boca dos crocodilos e salva este tempo atual para ser usado para a comparação da próxima vez (assim alterando de estado a cada 2,5 segundos). Mudando ou não o estado, finalizamos a função desenhando o plano de fundo certo (boca aberta ou fechada) de acordo com o estado armazenado na flag.

A próxima função da update é a HUD. Assim como a Update, ela apenas chama outras funções, todas de escrever na tela. Em ordem, ela chama TIMER, SCORE e LIVES.

## TIMER:
Essa função escreve o tempo decorrido de forma decrescente. Ela começa especificando a cor e posições x, y do Timer (a3, a1, a2). Em seguida ela pega o tempo em ms do momento em que foi chamada (ecall 130). Em seguida temos 5 blocos de ecalls para escrever, respectivamente, as dezenas de minutos, as unidades de minutos, os dois-pontos divisor, as dezenas de segundos e as unidades de segundos.
	
## SCORE:
Com blocos ecalls (como no timer), ela escreve na tela "Pontos: x".

## LIVES:
Com blocos ecalls (como no timer), ela escreve na tela "Vidas: y".

Concluímos a HUD. Agora na Update vem a CheckJump, mas antes dela vou explicar a Jump.

## Jump:
Aqui informamos a altura máxima do pulo (s3) e quantos frames segurar (s4). A ideia é que a cada checkjump s3 decremente 1 até chegar a 0 e então começar a cair. 

Fazemos umas verificações para impedir pulos em mid-air e então definimos s3 e s4. Depois tocamos o som de pulo com a macro que o jader vai explicar. Percebi agora que pode está ocorrendo vazamento de memória aqui. Vou investigar depois.
	
## CheckJump:
Essa função é reponsável por fazer o pulo funcionar. É graças a ela que a cada frame depois de pular o jogo sabe até onde subir o jogador. Enquanto s3 não for 0, CheckJump vai fazer o jogador subir. Se é 0 ele cai. Na altura máxima (s3=1), ela chama MaxHeightHold, que nada mais é que um contador decrescente que impede que s3 vire 0 por s4 frames, e mantém o jogador nesta altura. Isto é para facilitar os pulos e simular uma física mais realista que leva em conta desacelaração.

A próxima função chamada pela Update é a GRAVIDADE.

## GRAVIDADE:
É uma função simples. A cada chamada (ou seja a cada frame) ela desloca o jogador pra baixo. A CheckJump compensa isso nos pulos subindo o jogador o dobro do que a gravidade abaixa. Além disso ela faz checagens para ver se o jogador está no chão, e se for o caso não desloca para baixo (checa tanto pro chão em cima quanto embaixo).

Em seguida vêm funções de desenhar objetos na tela, chamadas dentro de uma função maior, DRAW (assim como a Hud faz). A função DRAW chama, em ordem, e esta ordem importa para determinar quem fica um plano a frente caso ocupem o mesmo espaço, DrawSnake, DrawBarrel, DrawTreasure, DrawPlayer.

## DrawSnake
Desenha a cobra. Apenas pega x e y da memória e chama a função que chama a macro snake_print. Caso y seja 0, a função sai para a label NoMob e não desenha nada.

## DrawBarrel:
Desenha barris na tela. Como podem haver qualquer quantidade entre 0 e 2 barris na tela ao mesmo tempo, ela faz uma checagem para ver se existem barris para desenhar.

Essa checagem é feita olhando a coordenada y do barril e vendo se é 0. Y=0 é lá em cima, bem acima de onde o barril anda, então se for 0 significa que não existe aquele barril. Essa checagem é feita primeiro para o 1o barril. Se falha pro 1o, não faz sentido ter um segundo, então ele pula para o label NoMob.

Antes de desenhar os barris, ela chama a função CheckBarrel para verificar se tem que atualizar a posição do barril caso ele esteja se movendo.

No caso de haver barris, ele pega as coordenadas x, y dos barris e chama a função BarrelPrint que por sua vez chama a macro barrel_print feita pelo jader (esses passos a mais são para evitar memory leak, novamente).

## CheckBarrel:

Usando as flags de isMoving dos barris, determina se deve desenhar o barril uma posição pra esquerda ou não. Caso tenha desenhar o barril deslocado, a label que atualiza a posição é a Moving1 para o barril 1 e Moving2 para o barril 2. Dentro dessas labels, existe uma checagem para quando o barril rola para fora da área, BarrelOutOfBounds 1 e 2, para os barris 1 e 2. Elas funcionam igual a PlayerOutOfBoundsLeft mas sem a troca de nível.

## DrawTreasure:

Esta função decide se tem que desenhar ou não um tesouro. A posição é fixa (264, 131). Primeiro ela consulta o LevelCounter para obter o nível atual e então compara com as words que informam quais níveis devem conter tesouros. Se bater, então ele chama a função que desenha o tesouro e pula as próximas checagens. Se der errado ele compara com a próxima word de nível com tesouro e repete este comportamento até que acabem as words.  
	
## DrawPlayer:

Desenha o jogador. Deve ser a última draw a ser chamada para que o jogador sempre fique a frente dos demais objetos. Apenas pega x e y da memória e chama a função que chama a macro harry_print. Acredito que ambas macros de draw são parecidas, se não idênticas, mas novamente deixo para que o jader explique seu comportamento.

A próxima função da Update é a maior e mais complexa, COLISION.

## COLISION:

Esta é a função que pega todos os dados que foram atualizados nas funções anteriores e realiza verificações para saber se algum objeto está no mesmo espaço de outro, e então decide como proceder quando estes eventos ocorrem.

Primeiro ela reserva os registradores t1 e t2 para serem os que armazenam as coordenadas x e y do jogador, e é interessante que nenhuma checagem que venha (e são muitas) altere estes registradores para que possamos diminuir o número de acesso à memória. 

Vamos realizar diversas verificações, nomeadamente, vamos checar para colisão com Barril 1, colisão com Barril 2, colisão com Tesouro, colisão com Cobra, colisão com Água e colisão com Crocodilo.

Cada uma dessas colisões utilizam duas funções auxiliares: Check-Snake/Water/Crocodile/FirstBarrel/etc-Colision, que é chamada quando o jogador está no mesmo ponto horizontal que o objeto em questão e verifica se eles também estão no mesmo ponto vertical (necessário separar em duas checagens, pois o jogador pode estar pulando por cima do objeto); e Snake/Water/Crocodile/FirstBarrel/etc-Colision, que é chamada quando se confirma que houve a colisão. O comportamento da primeira função é similar pra todas as variações, mas a da segunda muda de acordo com o objeto; colisão com barril retira 20 pontos, colisão com tesouro acrescenta 2500 pontos e zera a word que representa aquele tesouro (evita pegar o mesmo tesouro), colisão com cobra, água e crocodilo de boca aberta chamam função PlayerDeath. O processo checagem para tesouros é idêntico ao processo de decidir se desenha ou não o tesouro no nível. Além das duas funções pra cada objeto, eles também tem uma label End-objeto-Colision para auxiliar nas chamadas. 

A função PlayerDeath apenas atualiza a PlayerVida com menos uma vida e a posição do jogador para o lado esquerdo da tela (respawn).

Todas as funções de colisão tocam algum som através de chamadas de funções específicas de cada som.

A última função chamada pela Update é CONTROLE.

## CONTROLE:
Ela captura uma tecla do teclado através da função GetCommand e decide que ação tomar dependendo da tecla lida. Atualmente as ações possíveis são Jump, PlayerMoveRight e PlayerMoveLeft. Já expliquei Jump, vamos ver as outras duas, mas antes vamos ver a GetCommand.

## GetCommand:
Sendo bem sincero, eu não parei muito para enteder como funciona esta função, porque copiamos ela do exemplo do professor. O importante pra saber aqui é que ela é a alternativa pra não usar ecalls de input, pois estes travam o processo (thread) até que leiam algo. Desta forma, é possível não ler nada e partir para a próxima iteração do loop.

## PlayerMoveRight:
Esta função apenas atualiza a posição do jogador um certo valor para a direita. Antes disso no entanto, ela verifica se a posição futura está fora do limite da tela, e se estiver chama a função de PlayerOutOfBoundsRight.
	
## PlayerOutOfBoundsRight:
Esta função faz duas coisas: primeiro ela atualiza a posição do jogador para a extrema esquerda (assim dando a ilusão que a câmera foi pra frente pra acompanhar ele), e depois ela muda o nível. A atualização da posição do jogador é bem óbvia, apenas seta o valor da coordenada x de PlayerCoord para o valor desejado. Para mudar para o nível certo, ela identifica em qual nível o jogador está agora e checa pra ver se está no último nível, porque se estiver, ela vai para um label SetLevel que seta o nível como o nível 1. Se essa checagem falha, ela apenas incrementa o LevelCounter em 1. Por fim, ela chama a função LOADLEVEL para carregar em memória os valores corretos do novo nível.

É fácil ver que PlayerMoveLeft e PlayerOutOfBoundLeft se comportam de forma análoga às funções acima. 

Com isso concluo a explicação do código, espero que tenha sido bem elucidativo. Qualquer dúvida, só falar.
