-- 1) Alterando coluna e depois alterando de volta
alter table pessoa_tb RENAME COLUMN descricao TO description;
alter table pessoa_tb RENAME COLUMN description TO descricao;

-- 3 & 5) Inserindo linha em COMP AEREA e logo em seguida deletando-a
insert into Comp_aerea_tb (cnpj, nome)
    values ('29609139000119', 'malaysia airlines');
DELETE from Comp_aerea_tb WHERE cnpj = '29609139000119';

-- 4) o local de destino do voo de código 93742 deveria ser Recife em vez de Porto Alegre
update voo_tb
set local_chegada = 'Recife'
WHERE codigo = '93742';

-- 6/8/11) consultar nome, cpf, idade e fidelidade dos Passageiros que residem em Recife ou Rondonópolis
select P.nome, P.cpf, P.idade, PA.fidelidade
from pessoa_tb P
    inner join endereco_tb E
        on P.cpf = E.cpf
    inner join cep_tb C
        on E.cep = C.cep
    inner join passageiro_tb PA
        on P.cpf = PA.cpf_pe
where C.cidade in ('Recife', 'Rondonópolis')

-- 7) Exibir nome e cpf dos funcionários que trabalharam nos meses de junho e julho
select P.nome, P.cpf
from trabalha_tb T
    inner join tripulante_tb TR
        on T.cpf_tri = TR.cpf_pe
    inner join pessoa_tb P
        on TR.cpf_pe = P.cpf
where T.data_trabalha between to_date('01/06/2022', 'dd/mm/yyyy') and to_date('30/07/2022', 'dd/mm/yyyy')
group by (P.nome,P.cpf)

-- 9) Selecina passageiros cujoo nome se inicia pela letra 'M'
select P.cpf, P.nome, P.idade
from pessoa_tb P
    inner join passageiro_tb PA
        on P.cpf = PA.cpf_pe
WHERE nome LIKE 'M%';

-- 12/18) consultar compra(s) com maior percentual de desconto exibindo o ID da compra o percentual do desconto e o nome do comprador

select C.id_compra, C.porcentagem, P.nome 
from compra_tb C
    inner join passageiro_tb PA
        on C.cpf_pa = PA.cpf_pe
    inner join pessoa_tb P
        on PA.cpf_pe = P.cpf
where porcentagem in (select max(porcentagem) from compra_tb)

-- 10) Selecionar apenas os tripulantes supervisionados
select P.nome, T.cadastro, T.cargo
from tripulante_tb T
    inner join pessoa_tb P
        on P.cpf = T.cpf_pe
where cadastro_supervisor is not null

-- 14) consultar a média de bagagens que uma pessoa carrega
select avg(tot_bagagem)
from (select cpf_pa, count(*) as tot_bagagem
from bagagem_tb
group by cpf_pa)


-- 22/15) mostrar a quantidade de aviões que cada companhia aérea possui
select C.nome as cia_aerea, count(*) as tot_aeronaves
from aviao_tb A
    inner join comp_aerea_tb C
        on A.cnpj_cia = C.cnpj
group by C.nome
    
-- 13/25) cria view sobre a lotação de cada voo e dps consulta os voos com a menor lotação

drop view capacidade_voo_tb;

create view capacidade_voo_tb (voo, ocupacao) as
select codigo_voo, count(*)
from passagem_tb
group by codigo_voo;

select * from capacidade_voo_tb;

select * from capacidade_voo_tb
where ocupacao in (select min(ocupacao) from capacidade_voo_tb)

-- 21) exibir informações de cpf, cargo e salário dos tripulantes ordenados por salário 
select cpf_pe, cargo, salario
from tripulante_tb
order by salario DESC 

-- 26) Concede permissão publica para todas as operações na view capacidade_voo_tb 
-- e depois revoga permissão.
grant all on capacidade_voo_tb to public;
revoke all on capacidade_voo_tb to public;


------------------------------ PL --------------------------------

-- Função para calcular a soma do peso de todas as bagagens que um passageiro possui
CREATE OR REPLACE PROCEDURE peso_total_bagage (cpf bagagem_tb.cpf_pa%TYPE)
--RETURN bagagem_tb.peso%TYPE   
IS
    tot_weight bagagem_tb.peso%TYPE;
begin
    select sum(bagagem_tb.peso) into tot_weight
    from bagagem_tb
    where bagagem_tb.cpf_pa = cpf;

    --RETURN tot_weight;
    dbms_output.put_line(tot_weight);
    
end peso_total_bagage;
/
execute peso_total_bagage('10982770669');
/




/*10. LOOP EXIT WHEN - comando de repetição com critério de saída definido
Descrição: Usando como condição de parada a falta de dados no cursor declarado (cursor_func), o LOOP foi programado para 
armazenar em uma variável (cpfESalario_func) o CPF e o salário dos funcionários que recebem um salário de 2500.00 ou mais. */
DECLARE
    
    iterator BINARY_INTEGER := 0;
    trip_cpf tripulante_tb.cpf_pe%TYPE;
    trip_salario tripulante_tb.salario%TYPE;
    TYPE tripInfo IS RECORD (salario tripulante_tb.salario%TYPE, cpf tripulante_tb.cpf_pe%TYPE);
    TYPE TabelaFunc IS TABLE OF tripInfo INDEX BY BINARY_INTEGER;
    cpfESalario_func TabelaFunc;
    CURSOR cursor_func IS SELECT cpf_pe, salario FROM tripulante_tb;
    
BEGIN
    DBMS_OUTPUT.Put_line('Funcionários que recebem 2500.00 ou mais');
    OPEN cursor_func;
    
        LOOP
            FETCH cursor_func INTO trip_cpf, trip_salario;
            IF trip_salario >= 5000.00 THEN
                cpfESalario_func(iterator).cpf := trip_cpf;
                cpfESalario_func(iterator).salario := trip_salario;
                DBMS_OUTPUT.Put_line(cpfESalario_func(iterator).cpf || ' ' || cpfESalario_func(iterator).salario);
                iterator := iterator+1;
            END IF;
            EXIT WHEN cursor_func%NOTFOUND;
        END LOOP;

    CLOSE cursor_func;
    
END;
/

-- trigger para impedir que haja redução no salário de um tripulante

-- trigger para impedir que um passageiro leve mais de 40kg de bagagem

-- trigger que impede que novos pilotos tenham salario inicial abaixo de 15.000 e que comissários tenham salário inicial inferior a 3.000

