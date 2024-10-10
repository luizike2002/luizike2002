
--Selecionar todas as Equipes com Suas Modalidades
SELECT E.nome AS equipe, M.nome AS modalidade
FROM Equipe E
JOIN Modalidade M ON E.modalidade_id = M.id;

--Selecionar todos os Atletas com Suas Modalidades
SELECT A.nome AS atleta, M.nome AS modalidade
FROM Atleta A
JOIN Modalidade M ON A.modalidade_id = M.id;

--Selecionar Modalidades e Tipos (Individual ou Equipe)
SELECT nome AS modalidade, tipo
FROM Modalidade;    

--Selecionar Partidas e Resultados (Futebol, Basquete, etc.)
SELECT P.id AS partida_id, E1.nome AS equipe1, E2.nome AS equipe2, P.pontuacao_equipe1, P.pontuacao_equipe2, P.resultado
FROM Partida P
JOIN Equipe E1 ON P.equipe1_id = E1.id
JOIN Equipe E2 ON P.equipe2_id = E2.id
WHERE P.fase_id = 1;  -- Substituir o ID da fase desejada

--Selecionar Classificação das Equipes (Pontos Corridos)
SELECT E.nome AS equipe, P.pontos
FROM Pontuacao P
JOIN Equipe E ON P.equipe_id = E.id
JOIN Fase F ON F.id = P.fase_id
WHERE F.nome = 'Classificatória'  -- Nome da fase ou outro critério
ORDER BY P.pontos DESC;

--Selecionar Classificação dos Atletas (Modalidades Individuais)
SELECT A.nome AS atleta, P.pontos
FROM Pontuacao P
JOIN Atleta A ON P.atleta_id = A.id
JOIN Fase F ON F.id = P.fase_id
WHERE F.nome = 'Quartas de Final'  -- Substituir pela fase correta
ORDER BY P.pontos DESC;


--Selecionar as Equipes Classificadas para a Próxima Fase
SELECT E.nome AS equipe, P.pontos
FROM Pontuacao P
JOIN Equipe E ON P.equipe_id = E.id
JOIN Fase F ON F.id = P.fase_id
WHERE F.nome = 'Classificatória'  -- Substituir pela fase desejada
ORDER BY P.pontos DESC
LIMIT 2;  -- Seleciona as 2 equipes com mais pontos para avançar
