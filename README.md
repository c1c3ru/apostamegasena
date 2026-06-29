# 🍀 Gerador de Apostas - Loterias Brasileiras

Aplicação Flutter para geração inteligente de apostas para as principais loterias brasileiras: **Mega-Sena**, **Lotofácil**, **Quina**, **Dupla Sena** e **Timemania**.

## 📱 Funcionalidades

- ✅ Geração de apostas baseada em números mais frequentes
- ✅ Suporte para 5 modalidades de loteria
- ✅ Verificação automática de apostas duplicadas
- ✅ Interface intuitiva e responsiva
- ✅ Geração de 1 a 20 apostas por vez
- ✅ Números ordenados automaticamente

## 🎯 Loterias Suportadas

| Loteria | Números por Aposta | Faixa de Números |
|---------|-------------------|------------------|
| **Mega-Sena** | 6 | 1 a 60 |
| **Lotofácil** | 15 | 1 a 25 |
| **Quina** | 5 | 1 a 80 |
| **Dupla Sena** | 6 | 1 a 50 |
| **Timemania** | 10 (+1 Time) | 1 a 80 |

## 🏗️ Arquitetura

A aplicação segue os princípios de **Clean Architecture** com separação clara de responsabilidades:

```
lib/
├── app/                    # Configuração global da aplicação
│   ├── app_module.dart    # Módulo raiz (rotas e binds)
│   └── app_widget.dart    # Widget raiz (tema e configuração)
├── modules/
│   └── generator/         # Módulo de geração de apostas
│       ├── data/          # Camada de dados (listas de números)
│       ├── domain/        # Camada de domínio (entidades e use cases)
│       └── presenter/     # Camada de apresentação (UI e BLoC)
└── main.dart             # Ponto de entrada da aplicação
```

### Padrões Utilizados

- **BLoC Pattern**: Gerenciamento de estado reativo
- **Modular**: Injeção de dependências e roteamento
- **Clean Architecture**: Separação de camadas e responsabilidades

## 🧮 Algoritmo de Geração

O algoritmo suporta múltiplas **estratégias de geração** para adequar ao estilo do jogador:

1. **Frequência Histórica**: Utiliza listas dos números mais sorteados de cada loteria.
2. **Entropia de Shannon**: Pondera os números pela distribuição de seus aparecimentos históricos (caos vs previsibilidade), priorizando o "caos bem espalhado".
3. **Sistema Matemático**: Aplica filtros estatísticos (balanceamento par/ímpar, soma no range ótimo e cobertura de quadrantes) em apostas candidatas.
4. **Aleatoriedade Pura**: Sorteio completamente randômico usando todos os números do volante.
5. **Métricas de Auditoria**: Retorna informações sobre apostas rejeitadas e avisos matemáticos sobre a *Falácia do Apostador* ou ilusões de controle.

### Exemplo de Código

```dart
// Gerar 5 apostas para Mega-Sena com Entropia de Shannon
final usecase = GenerateBetsUsecase();
final lottery = Lottery.fromType(LotteryType.megaSena);
final resultado = usecase.gerarComResultado(
  lottery: lottery, 
  numberOfBets: 5,
  strategy: GenerationStrategy.entropyMixed,
);

// Acesso às apostas: resultado.apostas
// Informações extras: resultado.apostasRejeitadas, resultado.avisoMatematico
```

## 🚀 Como Executar

### Pré-requisitos

- Flutter SDK 3.0.0 ou superior
- Dart SDK 3.0.0 ou superior

### Instalação

```bash
# Clone o repositório
git clone <url-do-repositorio>
cd apostamegasena

# Instale as dependências
flutter pub get

# Execute a aplicação
flutter run
```

### Plataformas Suportadas

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Linux
- ✅ macOS
- ✅ Windows

## 🧪 Testes

A aplicação possui cobertura de testes unitários para as camadas críticas:

```bash
# Executar todos os testes
flutter test

# Executar testes com cobertura
flutter test --coverage

# Análise estática do código
flutter analyze
```

### Cobertura de Testes

- ✅ **UseCase**: Testes de geração, validação e duplicatas
- ✅ **Entities**: Testes de criação e comparação
- ✅ **BLoC**: Testes de estados e transições

## 📦 Dependências Principais

```yaml
dependencies:
  flutter_bloc: ^8.1.3      # Gerenciamento de estado
  flutter_modular: ^6.3.2   # Injeção de dependência
  equatable: ^2.0.5         # Comparação de objetos

dev_dependencies:
  flutter_test: sdk: flutter
  bloc_test: ^9.1.5         # Testes de BLoC
  flutter_lints: ^2.0.0     # Linting
```

## 🎨 Interface

A interface segue o **Material Design** com:

- Cards para organização visual
- Cores diferenciadas por loteria
- Feedback visual claro (loading, success, error)
- Responsividade para diferentes tamanhos de tela

## 📊 Dados Estatísticos

Os números mais frequentes são baseados em dados históricos dos concursos oficiais da Caixa Econômica Federal. Os dados são atualizados periodicamente para refletir as estatísticas mais recentes.

## 🔒 Privacidade

- ✅ Não coleta dados do usuário
- ✅ Não requer permissões especiais
- ✅ Funciona 100% offline
- ✅ Sem analytics ou tracking

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para:

1. Fazer fork do projeto
2. Criar uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abrir um Pull Request

## 📝 Licença

Este projeto é de código aberto e está disponível sob a licença MIT.

## ⚠️ Aviso Legal

Este aplicativo é apenas para fins educacionais e de entretenimento. Não garantimos ganhos em loterias. Jogue com responsabilidade.

---

**Desenvolvido com ❤️ usando Flutter**
