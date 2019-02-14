require 'httparty'

class ServerError < StandardError  
end  

class BooksHelper
    @@ZE_BOOK = {
        'name': "zé",
        'price': "1000"
    }

    @@DEFAULT_STOCK = 10

    def self.delete book
        response = HttpParty.delete("/books/#{book}")
        raise ServerError, "Problema ao deletar #{response.code}" unless response.code.equal? HttpParty.http_status[:OK]
    end

    def self.create_ze_book
        HttpParty.post("/books/",
            body: @@ZE_BOOK.to_json,
            headers: {'Content-Type' => 'application/json'})
    end

    def self.atualiza_estoque book_id
        stock = {
            bookId: book_id,
            stock: @@DEFAULT_STOCK
        }

        HttpParty.put("/books/availability", 
            body: stock.to_json,
            headers: {'Content-Type' => 'application/json'})
    end

    def self.get_ze
        @@ZE_BOOK
    end

    def self.default_stock
        @@DEFAULT_STOCK
    end
end

RSpec.describe 'Validar a api de Livros' do
    it 'Criar livro com sucesso' do
        
        response = BooksHelper.create_ze_book()

        book = BooksHelper.get_ze

        expect(response.code).to eql HttpParty.http_status[:CREATED]
        expect(response.parsed_response).to be_a_kind_of(Object)
        expect(response["name"]).to eql(book[:name])
        expect(response["price"]).to eql(book[:price].to_f)
        expect(response["bookId"]).to be_a_kind_of(Integer)
        
        BooksHelper.delete(response["bookId"])
    end

    it 'Tentar criar livro duplicado' do
        response = BooksHelper.create_ze_book()
        book_id = response["bookId"]
        expect(response.code).to eql HttpParty.http_status[:CREATED]

        response = BooksHelper.create_ze_book()
        expect(response.code).to eql HttpParty.http_status[:CONFLICT]

        BooksHelper.delete(book_id)
    end

    it 'Atualizar o estoque' do
        livro = BooksHelper.create_ze_book()
        expect(livro.code).to eql HttpParty.http_status[:CREATED]

        book_id = livro["bookId"]

        attStockResponse = BooksHelper.atualiza_estoque book_id

        expect(attStockResponse.code).to eql HttpParty.http_status[:NO_CONTENT]

        getStockResponse = HttpParty.get("/books/#{book_id}/availability")

        expect(getStockResponse.code).to eql HttpParty.http_status[:OK]
        expect(getStockResponse["stock"]).to eql BooksHelper.default_stock

        BooksHelper.delete(book_id)
    end

    it 'Tenta atualizar stock de livro inexistente' do
        getResponse = HttpParty.get("/books")
        expect(getResponse.code).to eql HttpParty.http_status[:OK]
        livros = getResponse.parsed_response
        expect(livros).to be_empty

        response = BooksHelper.atualiza_estoque 1

        expect(response.code).to eql HttpParty.http_status[:NOT_FOUND]
    end

    it 'Faz um emprestimo' do
        livro = BooksHelper.create_ze_book()
        expect(livro.code).to eql HttpParty.http_status[:CREATED]

        book_id = livro["bookId"]

        attStockResponse = BooksHelper.atualiza_estoque book_id

        expect(attStockResponse.code).to eql HttpParty.http_status[:NO_CONTENT]

        loanResponse = HttpParty.put("/books/#{book_id}/loan")

        expect(loanResponse.code).to eql HttpParty.http_status[:NO_CONTENT]

        getStockResponse = HttpParty.get("/books/#{book_id}/availability")

        expect(getStockResponse.code).to eql HttpParty.http_status[:OK]
        expect(getStockResponse["stock"]).to eql BooksHelper.default_stock - 1

        BooksHelper.delete(book_id)
    end

    it 'Tentar emprestar um livro sem estoque' do
        livro = BooksHelper.create_ze_book()
        expect(livro.code).to eql HttpParty.http_status[:CREATED]

        book_id = livro["bookId"]

        loanResponse = HttpParty.put("/books/#{book_id}/loan")

        expect(loanResponse.code).to eql HttpParty.http_status[:NOT_AUTHORIZED]

        BooksHelper.delete(book_id)
    end

    it 'Tenta emprestar um livro inexistente' do
        getResponse = HttpParty.get("/books")
        expect(getResponse.code).to eql HttpParty.http_status[:OK]
        livros = getResponse.parsed_response
        expect(livros).to be_empty

        response = HttpParty.put("/books/#{1}/loan")

        expect(response.code).to eql HttpParty.http_status[:NOT_FOUND]
    end

    it 'Devolver um livro' do
        livro = BooksHelper.create_ze_book()
        expect(livro.code).to eql HttpParty.http_status[:CREATED]

        book_id = livro["bookId"]

        attStockResponse = BooksHelper.atualiza_estoque book_id

        expect(attStockResponse.code).to eql HttpParty.http_status[:NO_CONTENT]

        devolutionResponse = HttpParty.put("/books/#{book_id}/devolution")

        expect(devolutionResponse.code).to eql HttpParty.http_status[:NO_CONTENT]

        getStockResponse = HttpParty.get("/books/#{book_id}/availability")

        expect(getStockResponse.code).to eql HttpParty.http_status[:OK]
        expect(getStockResponse["stock"]).to eql BooksHelper.default_stock + 1

        BooksHelper.delete(book_id)
    end
    it 'Tentar devolução de um livro inextistente' do
        getResponse = HttpParty.get("/books")
        expect(getResponse.code).to eql HttpParty.http_status[:OK]
        livros = getResponse.parsed_response
        expect(livros).to be_empty

        response = HttpParty.put("/books/#{1}/devolution")

        expect(response.code).to eql HttpParty.http_status[:NOT_FOUND]
    end

end
