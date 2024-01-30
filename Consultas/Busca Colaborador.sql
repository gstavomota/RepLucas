select
    vwPessoas.chapa
    ,vwPessoas.nome
    ,vwPessoas.tag_unidade
    ,vwPessoas.funcao as cargo
    ,psecao.DESCRICAO as departamento
from vwPessoas
 
left join pfunc on vwPessoas.chapa = pfunc.CHAPA
left join psecao on pfunc.CODSECAO = psecao.CODIGO
 
where vwPessoas.nome like '%ISABELA souza%'