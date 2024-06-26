-- ###########################################################################################################
-- 1. Nic e nome dos utentes internados em quartos, o seu género, distrito e país. O
--    resultado deve vir ordenado pelo pais e distrito de forma ascendente, e pelo nic de
--    forma descendente. Nota: pretende-se uma interrogação com apenas um SELECT,
--    ou seja, sem sub-interrogações.

SELECT P.nic, P.nome, P.genero, P.distrito, P.pais
FROM pessoa P, internado I
WHERE (P.nic = I.utente) AND (I.tipo = "Q") 
ORDER BY P.pais, P.distrito ASC, P.nic DESC;

-- ###########################################################################################################
-- 2. Cedula, nome, e país dos médicos que são especialistas em pelo menos uma das
--    especialidades: cardiologia e otorrino, ou que tenham um nome contendo a letra
--    ‘e’ e tenham começado a sua actividade médica depois do ano de início da
--    pandemia C19 (2019). Nota: pode usar construtores de conjuntos.

(SELECT M.cedula, P.nome, P.pais
FROM medico M, pessoa P 
WHERE (P.nic = M.nic) AND (P.nome LIKE '%e%') AND (M.ano > 2019))
UNION 
(SELECT M.cedula, P.nome, P.pais
FROM especialista E, medico M, pessoa P
WHERE (P.nic = M.nic) AND (M.nic = E.medico) AND ((E.especialidade = "cardiologia") OR (E.especialidade = "otorrino")));

-- ###########################################################################################################
-- 3. Nic, nome e país dos utentes internados em enfermaria mais de 7 dias, que
--    receberam visitas solidárias de pelo menos uma pessoa de um país diferente do
--    seu e um nome com 5 letras, terminado por 'o'.

SELECT I.utente, P.nome, P.pais
FROM pessoa P, internado I, visita V
WHERE (I.utente = P.nic) AND (I.tipo = "E") AND (I.dias > 7)
AND (P.nic = V.utente) AND (V.tipo = "S")
AND (P.pais <> (SELECT PE.pais
                FROM pessoa PE
                WHERE (V.visitante = PE.nic)))
AND V.visitante = (SELECT PES.nic
                   FROM pessoa PES
                   WHERE (V.visitante = PES.nic) AND (PES.nome LIKE "____o"));

-- ###########################################################################################################
-- 4. Nome e ano (de início) dos médicos que iniciaram actividade depois do ano da
--    pandemia de Gripe A - H1N1 (2009), e que nunca foram responsáveis por
--    internamentos em quarto que tenham durado mais de 21 dias.

SELECT P.nome, M.ano
FROM medico M, pessoa P, internado I
WHERE (P.nic = M.nic) AND (M.ano > 2009)
AND (M.nic = I.medico) AND (I.dias > 21) AND I.medico NOT IN (SELECT IT.medico 
                                                                FROM internado IT
                                                                WHERE (IT.tipo = "Q"));

-- ###########################################################################################################
-- 5. Ano de actividade, nic, cedula e nome dos médicos que tenham sido responsáveis
--    por todos os internamentos de utentes do Mónaco (MC) realizados em enfermaria,
--    por mais de 100 dias, no ano em que iniciaram a sua actividade. Nota: o resultado
--    deve vir ordenado pelo ano e pelo nome de forma ascendente.

SELECT M.ano, M.nic, M.cedula, P.nome
FROM medico M, pessoa P, internado I
WHERE (P.nic = M.nic)
AND (M.nic = I.medico) AND (I.dias > 100) AND (I.tipo = 'E')
AND (I.utente = (SELECT PE.nic
                FROM pessoa PE
                WHERE (I.utente = PE.nic) AND (PE.pais = 'MC')))
        
AND (SELECT COUNT(*)
            FROM internado IT 
            WHERE (M.nic = IT.medico) AND (IT.ano = M.ano)) =
    (SELECT COUNT(*) 
            FROM internado INTE 
            WHERE (INTE.ano = M.ano))

AND (SELECT COUNT(*) 
            FROM internado INTE 
            WHERE (INTE.ano = M.ano)) > 0
ORDER BY M.ano ASC, P.nome ASC;

-- ###########################################################################################################
-- 6. Número de internamentos da responsabilidade de cada médico (indicando nic e
--    nome) em cada especialidade. Nota: ordene o resultado pela especialidade de
--    forma ascendente e pelo nome do médico de forma descendente.

SELECT M.nic, P.nome, I.especialidade, COUNT(I.especialidade) AS numero_de_especialidade_responsaveis
FROM medico M, internado I, pessoa P
WHERE M.nic = I.medico
AND M.nic = P.nic
GROUP BY I.especialidade, P.nome
ORDER BY I.especialidade ASC, P.nome DESC;

-- ###########################################################################################################
-- 7. Cédula, nome e nacionalidade dos médicos que foram responsáveis (como
--    especialidade/actividade principal), por mais internamentos em quarto, em cada
--    uma das especialidades existentes. Notas: em caso de empate, devem ser
--    mostrados todos os médicos em causa.

SELECT DISTINCT M.cedula, P.nome, P.pais, INTE.especialidade
FROM medico M, pessoa P, especialista E, internado INTE
WHERE (P.nic = M.nic) 
AND (E.medico = M.nic) AND (E.atividade = "P") 
AND (INTE.especialidade = E.especialidade) AND (INTE.medico = M.nic) AND (INTE.tipo = "Q") 
AND ((SELECT COUNT(*)
        FROM internado I
        WHERE (I.medico = M.nic) 
        AND (I.especialidade = E.especialidade) 
        AND (I.tipo = "Q")) >= (SELECT COUNT(*)
                                    FROM medico M2, pessoa P2, especialista E2, internado I2
                                    WHERE (P2.nic = M2.nic) 
                                    AND (P.nic <> P2.nic) 
                                    AND (E2.medico = M2.nic) 
                                    AND (E2.atividade = "P") 
                                    AND (I2.medico = M2.nic) 
                                    AND (I2.especialidade = E2.especialidade) 
                                    AND (I2.especialidade = INTE.especialidade) 
                                    AND (I2.tipo = "Q")));

-- ###########################################################################################################
-- 8. Nome, ano de nascimento e nacionalidade das pessoas que nasceram depois do
--    ano inicial da Operação Nariz Vermelho (2002) e visitaram menos de 5 internados
--    distintos, mesmo que não tenham visitado nenhum. Pretende-se uma interrogação
--    sem sub-interrogações: apenas com um SELECT.

SELECT DISTINCT P.nome, P.ano, P.pais, V.utente, V.visitante
FROM pessoa P LEFT OUTER JOIN visita V ON (P.nic = V.visitante)
WHERE (P.ano > 2002)
GROUP BY P.nic
HAVING (COUNT(V.visitante) < 5);

-- ###########################################################################################################
-- 9. Para cada país e região de origem, o nic e nome da pessoa que realizou mais visitas
--    solidárias, indicando o número de visitas, e a maior e menor duração dos
--    internamentos visitados. Nota: devem ser mostrados todos os visitantes que
--    empatarem neste total de visitas.

SELECT P.pais, P.distrito, P.nome, 
(SELECT DISTINCT COUNT(IT.utente) FROM internado IT, visita V WHERE (V.visitante = P.nic) AND (V.tipo = "S") AND (V.utente = IT.utente)) AS numero_visitas, 
(SELECT MAX(IT.dias) FROM internado IT, visita VI WHERE (P.nic = VI.visitante) AND (VI.tipo = "S") AND (VI.utente = IT.utente)) AS max_dia_internado, 
(SELECT MIN(IT.dias) FROM internado IT, visita VI WHERE (P.nic = VI.visitante) AND (VI.tipo = "S") AND (VI.utente = IT.utente)) AS min_dia_internado
FROM internado I, pessoa P, visita V
WHERE (P.nic = V.visitante)
AND (V.utente = I.utente)
AND (SELECT DISTINCT COUNT(IT.utente) 
        FROM internado IT, visita V 
        WHERE (V.visitante = P.nic)
        AND (V.tipo = "S") 
        AND (V.utente = IT.utente))
        >= ALL(SELECT COUNT(VI.utente)
                FROM pessoa PE, visita VI 
                WHERE (PE.pais = P.pais)
                AND (PE.distrito = P.distrito) 
                AND (PE.nic = VI.visitante) 
                AND (VI.tipo = "S") 
            GROUP BY VI.visitante)
GROUP BY P.pais, P.distrito;
-- ###########################################################################################################