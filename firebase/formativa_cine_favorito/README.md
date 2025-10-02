# Cine Favorite (Formativa)
Construir um Aplicativo do zero - O CineFavorite que permitira criar uma conta e buscar filmes em uma API e montar uma galeria pessoal de filmes favoritos, com posters e notas avaliativas do usuario para o filme.

## Objetivos
- Criar uma Galeria personalizada por usuario de filmes favoritos
- Conectar o App com uma API(base de dados) de Filmes (TMDB)
- Permitir a Criação de Contas para Cada Usuário
- Listar filmes por uma Palavra-Chave

## Levantamento de Requisitos do Projeto
- ### Funcionais

- ## Não Funcionais

## Recursos do Projeto
- Linguagem de Programação : Flutter/Dart
- API TMDB : Base de dados para filmes
- Firebase: Authentication / FireStore
- Figma : Prototipagem
- VSCode : Desenvolvimento
- GitHub : Controle de Versionamento

## Diagramas
1. ### Diagrama de Classes
Demonstrar o Funcionamento das Entidades do Sistema

- Usuário (User): Classe já modelada pelo FirebaseAuth
    - Atributos: email, senha, uid
    - Métodos: Login(), Registrar(), Logout()

- Filmes Favoritos (FavoriteMovie): Classe modelada pelo DEV
    - Atributos: id, título, PosterPath, Nota
    - Métodos: AdicionarFilme(), RemoverFilme(), ListarFilme(), AtualizarNota() (CRUD)

```mermaid

    classDiagram
        class User{
            +String uid
            +String email
            +String password
            +createUser()
            +login()
            +logout()
        }

        class FavoriteMovie{
            +int id
            +String title
            +String posterPath
            +double Raiting
            +addFavorite()
            +removeFavorite()
            +updateMovieRaiting()
            +getFavoriteMovies()
        }

        User "1"--"1+" FavoriteMovie : "select"
```
2. ### Diagrama de Casos de Uso
Ação que os Atores podem Fazer
- Usuário (User):
    - Registrar
    - Login
    - Logout
    - Procurar Filmes na API
    - Salvar filmes aos Favoritos
    - Dar nota aos Filmes Favoritos
    - Remover Filme dos Favoritos

```mermaid

graph TD
    subgraph "Ações"
        ac1([Registrar])
        ac2([Login])
        ac3([Logout])
        ac4([SearchMovies])
        ac5([AddFavoriteMovie])
        ac6([UpdateRaitingMovie])
        ac7([RemoveFavoriteMovie])
    end

    user([Usuario])

    user --> ac1
    user --> ac2

    ac1 --> ac2
    ac2 --> ac3 
    ac2 --> ac4 
    ac2 --> ac5 
    ac2 --> ac6 
    ac2 --> ac7 

```


3. ### Fluxo
Determina o caminho percorrido pelo autor para Executar uma Ação

- Fluxo da Ação de Login

```mermaid

graph TD
    A[Início] --> B{Login Usuario}
    B --> C[Inserir Email e Senha]
    C --> D{Validar as Credenciais}
    D --> E[SIM]
    D --> F[NÃO]
    E --> G[HomePage]
    F --> B

```

## Prototipagem
Link dos Protótipos: https://www.figma.com/design/EnNIV0slYk2gsNFZqr25HA/Untitled?t=6pulWhQp9jmE8WXo-1



## Codificação

- Service --> Conectar com a API
- Model --> Favorite Movie
- Controller -> FireStore DataBase - Incompleto
- View -> Registro, Login, FavoriteView, SearchView
