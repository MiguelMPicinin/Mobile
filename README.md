- intrdução ao flutter
    -Nativo X Multiplataforma
        - Nativo:
            -Android:
                -IDE: Android Studio
                -SDK: Android SDK
                -Linguagens: Kotlin / Java
                -Plataformas: win / Linux / Mac
            -IOS:
                -IDE: Xcode
                -SDK: Cocoa Touch
                -Linguagens: Swift / ObjC
                -Plataformas: Mac
            Multiplataforma:
                - React Native:
                    -Linguagem: JavaScript
                    -Tipos de Software: Android/IOS/Web
                    -Resultado: Nativos()
                -Flutter:
                    -Linguagem: Dart
                    -Tipos de Software: Android/IOS/Web/Linux/Windows/Mac
                    -Resultado: Nativos()
                -Ionic
                    -Linguagem: JavaScript
                    -Tipos de software: Android/IOS/Web
                    -Resultado: Emulado(RunTime)
    -Configuração do ambiente de desenvolvimento
    -Estrutura de um aplicativo Flutter
        -Interface linha de comando
            -flutter create - criar workspaces(projetos)
            "flutter create --empty" - cria um app vazio padrão hello word
            "flutter create --platforms=android(qualquer plataforma)"
                Escolher a plataforma de desenvolvimento
        Exemplo de uso:
        flutter create --platforms=android --empty nome_app
        obs: não usar caracteres especiais no nome"ç,~,^,´,`"
            
            
            -flutter run -rodar a aplicação no emulador
            construção do apk
            -verbose
            "flutter run-v"

            -flutter pug get (Atualização dos pacotes)

            --flutter upgrade - atualiza a versão do flutter

            --flutter downgrade - volta pra versão anterior

            --flutter doctor - verifica as disponibilidades de uso

            --