-- SEMPRE VERIFIQUE O RM, ESTE CÓDIGO É APENAS PARA QUEBRAR GALHO

select DuSTINCT tipo, unidade, codPessoa, chapa, chapa + ' - ' + nome as nome, admissao, codSecao, secao, codFuncao, funcao, codRequisito, codCurso, codCurso + ' - ' + nomeCurso as nomeCurso, codGrupoCurso, diasValidade, revCurso, geraPendencia, online, urlCurso, convert(varchar,dtTurma,103) as dtTurma,
    convert(varchar,dtProximoTre,103) as dtProximoTre, datediff(day,getdate(),dtProximoTre) as diasRestantes, status

from (

select tipo, unidade, codPessoa, chapa, nome, admissao, codSecao, secao, codFuncao, funcao, codRequisito, codCurso, nomeCurso, codGrupoCurso, diasValidade, revCurso, geraPendencia, online, urlCurso, dtTurma, dateAdd(day,diasValidade,dtTurma) as dtProximoTre,

        case
		when dtTurma is null then 
		when diasValidade=0 and dtTurma is not null then 'No prazo'
        testeeeeee
        nova branch
		when diasValidade>0 and dateAdd(day,diasValidade,dtTurma)<getdate() then 'Vencido'
		when diasValidade>0 and dateAdd(day,diasValidade,dtTurma) between getdate() and dateadd(day,31,getdate()) then 'Próximo do vencimento'
		when diasValidade>0 and dateAdd(day,diasValidade,dtTurma) between dateadd(day,31,getdate()) and dateadd(day,60,getdate()) then 'Requer programação'
		when diasValidade>0 and dateAdd(day,diasValidade,dtTurma) > dateadd(day,60,getdate()) then 'No prazo'
		when nomeCurso like '%desativado%' or codGrupoCurso = '99' then 'ERRO: curso desativado'
		else 'ERRO - Pendência não identificada'
	end as status

    from (

select tipo, unidade, codPessoa, chapa, nome, admissao, codSecao, secao, codFuncao, funcao, codRequisito, codCurso, nomeCurso, codGrupoCurso, diasValidade, revCurso, geraPendencia, online, urlCurso,

            (select max(a1.dtinicio) as dataTreinamento
            from VTURMAS a1 (nolock)
                inner join VTURMASCOMPL b1 (nolock) on a1.codcoligada = b1.codcoligada and a1.codturma = b1.codturma
                inner join VTURMA c1 (nolock) on a1.codcoligada = c1.codcoligada and a1.codturma = c1.codturma
                inner join VCURSOS d1 (nolock) on a1.codcoligada = d1.codcoligada and a1.codcurso = d1.codcurso
                inner join VCURSOSCOMPL e1 (nolock) on a1.codcoligada = e1.codcoligada and a1.codcurso = e1.codcurso
                left join ZMD_REVCURSO f1 (nolock) on a1.codcoligada = f1.codcoligada and a1.codcurso = f1.codcurso
            where a1.codcoligada = 1
                and a1.situacao = 'E'
                and (a1.codcurso = x.codcurso or a1.codcurso = (select g1.codcursorelac
                from VCURSOSCOMPL g1 (nolock)
                where g1.codColigada = 1 and g1.codCurso = x.codCurso) or e1.codcursorelac = x.codcurso)
                and (f1.revcurso = x.revcurso or f1.revcurso is null)
                and c1.codpessoa = x.codpessoa) as dtTurma

        from (
/*POR MAPA REQUISITO*/
select 'Matriz' as tipo, substring(a.codSecao,13,3) as unidade, a.codPessoa, a.chapa, a.nome, convert(varchar,a.dataAdmissao,103) as admissao, a.codSecao, b.descricao as secao, a.codFuncao, c.nome as funcao, d.codRequisito,
                isnull(f.codCurso,'ERRO') as codCurso, isnull(f.nomeCurso,'ERRO - Matriz de Treinamento não preenchida: Seção X Função') as nomeCurso, f.codGrupoCurso, isnull(f.diasValidade,0) as diasValidade, isnull(h.revCurso,'ERRO - Revisão Pendente') as revCurso, isnull(h.geraPendencia,'P') as geraPendencia,
                case
		when g.urlcurso is null then 'Indisponível'
		else 'Disponível'
	end as online, isnull(g.urlcurso,'') as urlCurso
            from PFUNC a (nolock)
                inner join PSECAO b (nolock) on a.codColigada = b.codColigada and a.codSecao = b.codigo
                inner join PFUNCAO c (nolock) on a.codColigada = c.codcoligada and a.codFuncao = c.codigo
                left join VMAPACONHECIMENTOREQACESSO d (nolock) on a.codColigada = d.codColigada and a.codSecao = d.codSecao and a.codFuncao = d.codFuncao and d.ativo = 1
                left join VREQUISITOSTREINADOS e (nolock) on a.codColigada = e.codColigada and d.codRequisito = e.codRequisito
                left join VCURSOS f (nolock) on a.codColigada = f.codColigada and e.codCurso = f.codCurso and f.codgrupocurso <> 99
                left join VCURSOSCOMPL g on a.codColigada = g.codColigada and f.codCurso = g.codCurso and (cast(a.chapa as int) <> cast(isnull(g.chapaaprov,0) as int) or cast(a.chapa as int) <> cast(isnull(g.chapaelab,0) as int) or cast(a.chapa as int) <> cast(isnull(g.chaparev,0) as int))
                left join ZMD_REVCURSO h on a.codColigada = h.codColigada and f.codCurso = h.codCurso
            where a.codColigada = 1
                and a.codSituacao not in ('D','I','P')
                and 'CRC' LIKE '%' + replace(replace(replace(substring
(a.codsecao,13,3),'ofc','cld'),'yyy','fzd'),'agf','fzd') + '%'

union all

/*PRO EQUIPAMENTO*/
    select 'Equipamento' as tipo, substring(b.codSecao,13,3) as unidade, b.codPessoa, b.chapa, b.nome, convert(varchar,b.dataAdmissao,103) as admissao, b.codSecao, c.descricao as secao, b.codFuncao, d.nome as funcao, g.codRequisito,
        f.codCurso, f.nomeCurso, f.codGrupoCurso, isnull(f.diasValidade,0) as diasValidade, isnull(h.revCurso,'ERRO - Revisão Pendente') as revCurso, isnull(h.geraPendencia,'P') as geraPendencia,
        case
		when e.urlcurso is null then 'Indisponível'
		else 'Disponível'
	end as online, isnull(e.urlcurso,'') as urlCurso
    from ZMD_FUNCEQUIP a (nolock)
        inner join PFUNC b (nolock) on a.codColigada = b.codColigada and a.chapa = b.chapa
        inner join PSECAO c (nolock) on a.codColigada = b.codColigada and b.codSecao = c.codigo
        inner join PFUNCAO d (nolock) on a.codColigada = d.codcoligada and b.codFuncao = d.codigo
        inner join VCURSOSCOMPL e (nolock) on a.codcoligada = e.codcoligada and a.tipoequip = e.tipoequip
        left join VCURSOS f (nolock) on a.codcoligada = f.codcoligada and e.codcurso = f.codcurso and f.codgrupocurso <> 99
        inner join VREQUISITOSTREINADOS g (nolock) on a.codColigada = g.codColigada and f.codCurso = g.codCurso
        left join ZMD_REVCURSO h (nolock) on a.codColigada = h.codColigada and f.codCurso = h.codCurso
    where a.codcoligada = 1
        and a.tipoOper = 'OPE'
        and b.codSituacao not in ('D','I','P')
        and 'CRC' LIKE '%' + replace(replace(replace(substring(b.codsecao,13,3),'ofc','cld'),'yyy','fzd'),'agf','fzd') + '%'

union all

    /*REINTEGRAÇÃO*/
    select 'Retorno' as tipo, x.unidade, x.codpessoa, x.chapa, x.colaborador as nome, x.admissao, x.codsecao, x.secao, x.codfuncao, x.funcao, '' as codRequisito, '3561' as codcurso, 'Reintegração retorno: ' + convert(varchar,x.retorno,103) + ' - ' + x.motivo + ' (' + cast(x.dias as varchar) + ' dias)' as nomeCurso,
        '' as codgrupocurso, '' as diasvalidade, 'NA' as revCurso, 'S' as gerapendencia, null as online, null as urlcurso
    from (
select replace(replace(replace(substring(a.codsecao,13,3),'ofc','cld'),'yyy','fzd'),'agf','fzd') as unidade, a.codpessoa, a.chapa, a.chapa + ' - ' + a.nome as colaborador, c.codigo as codfuncao, c.codigo + ' - ' + c.nome as funcao, a.codsecao, a.codsecao + ' - ' + e.descricao as secao,
            convert(varchar, a.dataadmissao, 103) as admissao, a.dataadmissao, lag(b.datamudanca,1,0) over (order by b.chapa, b.datamudanca) as saida, b.datamudanca as retorno, d.descricao as motivo,
            case
	when lag(b.novasituacao,1,0) over (order by b.chapa, b.datamudanca) not in ('a') and a.chapa = lag(b.chapa,1,0) over (order by b.chapa, b.datamudanca)
		then datediff(day, lag(b.datamudanca,1,0) over (order by b.chapa, b.datamudanca),b.datamudanca)
	else '0'
end as dias,
            (select count(a1.codturma) as verifica
            from vturmas a1 (nolock) inner join vturma b1 (nolock) on a1.codcoligada = b1.codcoligada and a1.codturma = b1.codturma
            where b1.codpessoa = a.codpessoa and a1.dtinicio >= b.datamudanca and a1.codcurso = 3561) as reintegracao
        from PFUNC a (nolock)
            inner join PPESSOA a1 on a.codpessoa = a1.codigo
            inner join PFHSTSIT b on a.codcoligada = b.codcoligada and a.chapa = b.chapa
            inner join PFUNCAO c (nolock) on a.codcoligada = c.codcoligada and a.codfuncao = c.codigo
            inner join PMUDSITUACAO d (nolock) on a.codcoligada = d.codcoligada and b.motivo = d.codcliente
            inner join PSECAO e (nolock) on a.codcoligada = e.codcoligada and a.codsecao = e.codigo
        where a.codcoligada = 1
            and a.codsituacao not in ('D','I','P')
            and a.dataadmissao <> b.datamudanca
            and b.datamudanca > '2021-04-01'
            and b.motivo not in ('IG','FG')
            /*and (a1.deficientefisico = 0 and a1.deficienteauditivo = 0 and a1.deficientefala = 0 and a1.deficientevisual = 0 and a1.deficientemental = 0 and a1.deficienteintelectual = 0)*/
            and 'CRC'
LIKE '%' + replace
(replace
(replace
(substring
(a.codsecao,13,3),'ofc','cld'),'yyy','fzd'),'agf','fzd') + '%'
and a.chapa not in
('009440','008132')) x
where x.dias >= 30
and x.reintegracao = 0
) x) y) result

where status <> 'No prazo'

order by 2, 5, 11