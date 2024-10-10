
-- Inserir modalidades
INSERT INTO Modalidade (nome, tipo)
VALUES 
    ('Futebol', 'equipe'),
    ('Basquete', 'equipe'),
    ('Tênis', 'individual'),
    ('Corrida', 'individual');

-- Inserir equipes (para modalidades de equipe)
INSERT INTO Equipe (nome, modalidade_id)
VALUES
    ('Vasco', 1),  -- Futebol
    ('Flamengo', 1),  -- Futebol
    ('Lakers', 2),  -- Basquete
    ('Chicago Bulls', 2);  -- Basquete

-- Inserir atletas (para modalidades individuais)
INSERT INTO Atleta (nome, data_nascimento, modalidade_id)
VALUES
    ('Luiz pe de chinelo', '1990-01-01', 3),  -- Tênis
    ('Izaqke mao de antena', '1992-05-15', 3),  -- Tênis
    ('Atleta 3', '1988-10-10', 4),  -- Corrida
    ('Atleta 4', '1995-12-12', 4);  -- Corrida

-- Inserir torneios
INSERT INTO Torneio (nome, formato, modalidade_id)
VALUES
    ('Copa Nacional de Futebol', 'pontos_corridos', 1),
    ('Campeonato Estadual de Basquete', 'eliminatorias', 2),
    ('Grand Slam de Tênis', 'eliminatorias', 3),
    ('Maratona Internacional', 'pontos_corridos', 4);

-- Inserir fases (classificatórias ou eliminatórias)
INSERT INTO Fase (nome, torneio_id, tipo_fase)
VALUES
    ('Classificatória', 1, 'grupos'), -- Fase de grupos para futebol
    ('Semifinal', 2, 'eliminatorias'), -- Semifinais de basquete
    ('Quartas de Final', 3, 'eliminatorias'), -- Quartas de final de tênis
    ('Corrida Completa', 4, 'grupos'); -- Corrida por pontos corridos

-- Inserir grupos (para fase de grupos no futebol)
INSERT INTO Grupo (nome, fase_id)
VALUES
    ('Grupo A', 1),
    ('Grupo B', 1);

-- Inserir partidas (exemplo para torneios de futebol e basquete)
INSERT INTO Partida (fase_id, data_hora, local, equipe1_id, equipe2_id, pontuacao_equipe1, pontuacao_equipe2, resultado)
VALUES
    -- Futebol (pontos corridos)
    (1, '2024-09-15 16:00:00', 'Estádio 1', 1, 2, 3, 1, 'vitoria_equipe1'),  -- Time A 3 x 1 Time B
    (1, '2024-09-20 16:00:00', 'Estádio 2', 2, 1, 1, 1, 'empate'),  -- Time B 1 x 1 Time A

    -- Basquete (eliminatórias)
    (2, '2024-09-25 18:00:00', 'Ginásio A', 3, 4, 80, 75, 'vitoria_equipe1'),  -- Time C 80 x 75 Time D
    (2, '2024-09-27 18:00:00', 'Ginásio B', 4, 3, 78, 80, 'vitoria_equipe2');  -- Time D 78 x 80 Time C

-- Atualizar pontuações de equipes (pontos corridos)
INSERT INTO Pontuacao (equipe_id, fase_id, pontos)
VALUES
    (1, 1, 4),  -- Time A (1 vitória e 1 empate = 4 pontos)
    (2, 1, 1);  -- Time B (1 empate = 1 ponto)

-- Atualizar pontuações de atletas
INSERT INTO Pontuacao (atleta_id, fase_id, pontos)
VALUES
    (1, 3, 3),  -- Atleta 1 (1 vitória no tênis)
    (2, 3, 0);  -- Atleta 2 (0 pontos no tênis)
