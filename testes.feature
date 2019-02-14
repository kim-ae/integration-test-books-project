Criação, alteração de estoque, emprestimo e devolução

Criar livro com sucesso
	Dado que quero criar o livro "Zé"
	E ele tem o valor "1000" reais
	Quando faço requisição de criação (POST)
	Então recebe um retorno positivo (201)
	E recebo o livro com seu id gerado, nome "zé" e valor "1000" reais

Livro duplicado
	Dado que já possuo um livro "Zé"
	E quero criar um livro "Zé"
	E ele tem o valor de "1000" reais
	Quando faço requisição de criação (POST)
	Então recebo um retorno negativo (409)

Atualização de estoque
	Dado que tenho um livro qualquer criado
	Quando eu faço uma requsição para atualizar o estoque em 10 (PUT)
	Então recebo um retorno positivo (204)
	E quando consulto estoque vejo retorno 10

Atualização de estoque de livro inexistente
	Dado que não tenho um livro criado
	Quando eu faço uma requsição para atualizar o estoque em 10 (PUT)
	Então recebo um retorno de não encontrado (404)

Empréstimo
	Dado que tenho um livro qualquer criado
	E que o livro tem 10 em estoque
	Quando faço um emprestimo
	Então recebo um retorno positivo (204)
	E quando consulto estoque vejo retorno 9

Empréstimo de um livro sem estoque
	Dado que tenho um livro qualquer criado
	E que o livro tem 0 em estoque
	Quando faço um emprestimo
	Então recebo um retorno negativo (401)

Emprestimo de livro inexistente
	Dado que não tenho um livro criado
	Quando eu faço uma requsição para emprestar um livro (PUT)
	Então recebo um retorno de não encontrado (404)

Devolução
	Dado que tenho um livro qualquer criado
	E que sei que o estoque dele é "10"
	Quando faço a devolução de 1 unidade desse livro
	Então recebo um retorno positivo
	E vejo valido que o estoque é "11"


Devolução de livro inexistente
	Dado que não tenho um livro criado
	Quando eu faço uma requsição para devolver um livro (PUT)
	Então recebo um retorno de não encontrado (404)