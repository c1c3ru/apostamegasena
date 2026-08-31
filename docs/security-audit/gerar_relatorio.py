#!/usr/bin/env python3
"""Gera o relatório de auditoria de segurança em PDF.

Uso:
    source docs/security-audit/venv/bin/activate
    python docs/security-audit/gerar_graficos.py
    python docs/security-audit/gerar_relatorio.py

Saída: docs/security-audit/relatorio-auditoria-seguranca.pdf
"""
import datetime
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import cm
from reportlab.lib.enums import TA_LEFT, TA_CENTER, TA_JUSTIFY
from reportlab.platypus import (
    BaseDocTemplate, PageTemplate, Frame, Paragraph, Spacer, Table, TableStyle,
    Image, NextPageTemplate, PageBreak, HRFlowable, KeepTogether, ListFlowable,
    ListItem,
)
from reportlab.pdfgen import canvas as pdfcanvas

OUT_DIR = "docs/security-audit"
PDF_PATH = f"{OUT_DIR}/relatorio-auditoria-seguranca.pdf"
PROJETO = "apostamegasena (Gerador de Apostas)"
DATA_HOJE = datetime.date.today().strftime("%d/%m/%Y")

COR_CRITICA = colors.HexColor("#B91C1C")
COR_ALTA = colors.HexColor("#EA580C")
COR_MEDIA = colors.HexColor("#D97706")
COR_BAIXA = colors.HexColor("#2563EB")
COR_FORTE = colors.HexColor("#059669")
COR_TEXTO = colors.HexColor("#1f2937")
COR_MUTED = colors.HexColor("#6b7280")
COR_FUNDO_CLARO = colors.HexColor("#f3f4f6")

PAGE_W, PAGE_H = A4
MARGIN = 2 * cm

# ---------------------------------------------------------------------------
# Estilos
# ---------------------------------------------------------------------------
styles = getSampleStyleSheet()
styles.add(ParagraphStyle("H1", parent=styles["Heading1"], fontSize=20, textColor=COR_TEXTO,
                           spaceAfter=12, spaceBefore=4))
styles.add(ParagraphStyle("H2", parent=styles["Heading2"], fontSize=15, textColor=COR_TEXTO,
                           spaceAfter=8, spaceBefore=14))
styles.add(ParagraphStyle("H3", parent=styles["Heading3"], fontSize=12, textColor=COR_TEXTO,
                           spaceAfter=6, spaceBefore=10))
styles.add(ParagraphStyle("Corpo", parent=styles["BodyText"], fontSize=10, leading=14.5,
                           alignment=TA_JUSTIFY, textColor=COR_TEXTO, spaceAfter=6))
styles.add(ParagraphStyle("CorpoPequeno", parent=styles["BodyText"], fontSize=8.5, leading=12,
                           textColor=COR_TEXTO))
styles.add(ParagraphStyle("CodeBlock", fontName="Courier", fontSize=8, leading=11,
                           textColor=COR_TEXTO, backColor=COR_FUNDO_CLARO,
                           borderPadding=6, leftIndent=2, spaceAfter=6))
styles.add(ParagraphStyle("Capa_Titulo", parent=styles["Title"], fontSize=21, leading=26,
                           textColor=COR_TEXTO, alignment=TA_CENTER, spaceAfter=10))
styles.add(ParagraphStyle("Capa_Sub", parent=styles["Normal"], fontSize=13, textColor=COR_MUTED,
                           alignment=TA_CENTER, spaceAfter=4))
styles.add(ParagraphStyle("Capa_Meta", parent=styles["Normal"], fontSize=10.5, textColor=COR_TEXTO,
                           alignment=TA_LEFT, leading=15))


def sev_chip(label, cor, width=2.6 * cm):
    return Table(
        [[label]],
        colWidths=[width],
        style=TableStyle([
            ("BACKGROUND", (0, 0), (-1, -1), cor),
            ("TEXTCOLOR", (0, 0), (-1, -1), colors.white),
            ("ALIGN", (0, 0), (-1, -1), "CENTER"),
            ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
            ("FONTSIZE", (0, 0), (-1, -1), 7.5),
            ("FONTNAME", (0, 0), (-1, -1), "Helvetica-Bold"),
            ("TOPPADDING", (0, 0), (-1, -1), 4),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
        ]),
    )


# ---------------------------------------------------------------------------
# Cabeçalho / rodapé
# ---------------------------------------------------------------------------
def header_footer(canv: pdfcanvas.Canvas, doc):
    canv.saveState()
    canv.setFont("Helvetica", 8)
    canv.setFillColor(COR_MUTED)
    canv.drawString(MARGIN, PAGE_H - 1.2 * cm,
                     "Relatório de Auditoria de Segurança — apostamegasena")
    canv.drawRightString(PAGE_W - MARGIN, PAGE_H - 1.2 * cm, DATA_HOJE)
    canv.setStrokeColor(COR_FUNDO_CLARO)
    canv.line(MARGIN, PAGE_H - 1.35 * cm, PAGE_W - MARGIN, PAGE_H - 1.35 * cm)

    canv.line(MARGIN, 1.3 * cm, PAGE_W - MARGIN, 1.3 * cm)
    canv.drawString(MARGIN, 1.0 * cm, "docs/security-audit/relatorio-auditoria-seguranca.pdf")
    canv.drawRightString(PAGE_W - MARGIN, 1.0 * cm, f"Página {doc.page}")
    canv.restoreState()


def cover_page(canv: pdfcanvas.Canvas, doc):
    canv.saveState()
    canv.setFillColor(COR_TEXTO)
    canv.setFont("Helvetica", 8)
    canv.setFillColor(COR_MUTED)
    canv.drawRightString(PAGE_W - MARGIN, 1.0 * cm, "Página 1")
    canv.restoreState()


doc = BaseDocTemplate(PDF_PATH, pagesize=A4,
                       leftMargin=MARGIN, rightMargin=MARGIN,
                       topMargin=1.6 * cm, bottomMargin=1.6 * cm)

frame_normal = Frame(MARGIN, 1.6 * cm, PAGE_W - 2 * MARGIN, PAGE_H - 3.3 * cm, id="normal")
frame_cover = Frame(MARGIN, 1.6 * cm, PAGE_W - 2 * MARGIN, PAGE_H - 3.0 * cm, id="cover")

doc.addPageTemplates([
    PageTemplate(id="Cover", frames=frame_cover, onPage=cover_page),
    PageTemplate(id="Normal", frames=frame_normal, onPage=header_footer),
])

story = []

# ===========================================================================
# CAPA
# ===========================================================================
story.append(Spacer(1, 5.2 * cm))
accent_bar = Table([[""]], colWidths=[2.4 * cm], rowHeights=[0.18 * cm])
accent_bar.setStyle(TableStyle([("BACKGROUND", (0, 0), (-1, -1), COR_BAIXA)]))
accent_wrap = Table([[accent_bar]], colWidths=[PAGE_W - 2 * MARGIN])
accent_wrap.setStyle(TableStyle([("ALIGN", (0, 0), (-1, -1), "CENTER")]))
story.append(accent_wrap)
story.append(Spacer(1, 0.9 * cm))
story.append(Paragraph("Relatório de Auditoria de Segurança", styles["Capa_Titulo"]))
story.append(Paragraph(f"— {PROJETO}", styles["Capa_Titulo"]))
story.append(Spacer(1, 0.4 * cm))
story.append(Paragraph(f"Auditoria de código-fonte estático · {DATA_HOJE}", styles["Capa_Sub"]))
story.append(Spacer(1, 1.4 * cm))
story.append(HRFlowable(width="60%", thickness=1, color=COR_FUNDO_CLARO, hAlign="CENTER"))
story.append(Spacer(1, 1.0 * cm))

meta_tbl = Table([
    [Paragraph("<b>Escopo auditado</b>", styles["Capa_Meta"]),
     Paragraph("Repositório completo (branch atual): app Flutter/Dart "
               "<i>apostamegasena</i> — código Dart em lib/, configuração de build "
               "Android/iOS/Web/Desktop, assets, histórico do git.", styles["Capa_Meta"])],
    [Paragraph("<b>Stack detectada</b>", styles["Capa_Meta"]),
     Paragraph("Linguagem: Dart · Framework: Flutter (mobile, com alvos de build "
               "adicionais para web/desktop) · Gerência de estado/DI: flutter_bloc + "
               "flutter_modular · Persistência: shared_preferences (armazenamento local "
               "chave-valor no dispositivo) · Backend/API: nenhum · Autenticação: "
               "nenhuma · Banco de dados remoto: nenhum.", styles["Capa_Meta"])],
    [Paragraph("<b>Nota metodológica</b>", styles["Capa_Meta"]),
     Paragraph("As 5 categorias do checklist foram mapeadas para esta stack antes da "
               "varredura: como o app é 100% local/offline (sem backend, sem contas de "
               "usuário, sem rede), as categorias 1 (isolamento de tenant/RLS), 2 "
               "(permissão definida no navegador vs. backend) e 3 (IDOR) não têm "
               "equivalente aplicável — não existe fronteira de autorização "
               "servidor↔cliente nem múltiplos usuários/tenants a isolar. Essas "
               "categorias foram verificadas explicitamente como N/A, com a "
               "justificativa técnica registrada, em vez de terem achados forçados. "
               "As categorias 4 (segredos expostos) e 5 (XSS/input) foram auditadas "
               "normalmente sobre código-fonte, configs de build, assets e "
               "histórico do git.", styles["Capa_Meta"])],
], colWidths=[3.6 * cm, 11.4 * cm])
meta_tbl.setStyle(TableStyle([
    ("VALIGN", (0, 0), (-1, -1), "TOP"),
    ("TOPPADDING", (0, 0), (-1, -1), 8),
    ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
    ("LINEBELOW", (0, 0), (-1, -2), 0.5, COR_FUNDO_CLARO),
]))
story.append(meta_tbl)
story.append(NextPageTemplate("Normal"))
story.append(PageBreak())

# ===========================================================================
# RESUMO EXECUTIVO
# ===========================================================================
story.append(Paragraph("Resumo Executivo", styles["H1"]))
story.append(Paragraph(
    "A auditoria cobriu as 5 categorias solicitadas, adaptadas à stack real do projeto "
    "(ver nota metodológica na capa). O resultado é um app com <b>superfície de ataque "
    "mínima</b>: não há backend, não há autenticação, não há chamadas de rede em "
    "nenhuma linha de código, e não há renderização de HTML/Markdown/WebView. "
    "<b>1 achado informativo</b> foi registrado (armazenamento local sem criptografia); "
    "nenhum achado crítico, alto ou médio foi identificado.", styles["Corpo"]))

story.append(Spacer(1, 0.3 * cm))
img_row = Table([
    [Image(f"{OUT_DIR}/grafico_severidade.png", width=7.5 * cm, height=7.5 * cm),
     Image(f"{OUT_DIR}/grafico_categoria.png", width=8.6 * cm, height=4.6 * cm)],
], colWidths=[7.7 * cm, 8.8 * cm])
img_row.setStyle(TableStyle([("VALIGN", (0, 0), (-1, -1), "MIDDLE")]))
story.append(img_row)
story.append(Spacer(1, 0.2 * cm))

resumo_tbl = Table([
    ["Severidade", "Qtd.", "Categorias com achado"],
    ["Crítica", "0", "—"],
    ["Alta", "0", "—"],
    ["Média", "0", "—"],
    ["Baixa / Informativa", "1", "4. Segredos expostos (nota de robustez, não segredo vazado)"],
    ["N/A (categoria não se aplica à stack)", "3", "1. Isolamento de dados · 2. Permissão no frontend · 3. IDOR"],
], colWidths=[6.5 * cm, 1.6 * cm, 8.4 * cm])
resumo_tbl.setStyle(TableStyle([
    ("BACKGROUND", (0, 0), (-1, 0), COR_TEXTO),
    ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
    ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
    ("FONTSIZE", (0, 0), (-1, -1), 9),
    ("GRID", (0, 0), (-1, -1), 0.5, COR_FUNDO_CLARO),
    ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
    ("TOPPADDING", (0, 0), (-1, -1), 6),
    ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
    ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, COR_FUNDO_CLARO]),
]))
story.append(resumo_tbl)

# ===========================================================================
# PONTOS FORTES E FRACOS
# ===========================================================================
story.append(Paragraph("Pontos Fortes (verificados)", styles["H2"]))
pontos_fortes = [
    ("Sem segredos no código-fonte", "Varredura por padrões de API key/token/senha/chave privada em "
     "lib/, android/, ios/, assets/ e arquivos de configuração de raiz não encontrou nenhuma "
     "credencial embutida. O projeto não integra nenhum SDK de terceiros que exigiria chave "
     "(ads, analytics, mapas, push)."),
    ("Nenhum segredo no histórico do git", "git log --all --diff-filter=A --name-only não retornou "
     "nenhum arquivo de nome sensível (.env, key.properties, .jks, .keystore, credential*) já "
     "commitado em algum momento do histórico."),
    ("Keystore de release fora do repositório", "android/app/src/../build.gradle.kts lê "
     "android/key.properties (listado em android/.gitignore, nunca commitado) para os dados de "
     "assinatura de release; sem esse arquivo local o build cai para a chave de debug em vez de "
     "falhar de forma insegura ou expor um default público."),
    ("Sem WebView/HTML/Markdown em toda a árvore de widgets", "Nenhuma ocorrência de WebView, "
     "flutter_html, markdown, Html.fromHtml, dangerouslySetInnerHTML-equivalente ou `eval` em "
     "lib/. Todo texto é renderizado via widgets Text/TextField nativos do Flutter, que exibem "
     "conteúdo como glifos — não há parser de marcação envolvido, logo não há vetor de XSS."),
    ("Campos de entrada restritos a dígitos", "Os dois únicos TextField do app (quantidade de "
     "apostas em generator_page.dart:405 e dezenas manuais em comparison_page.dart:196) usam "
     "`FilteringTextInputFormatter.digitsOnly`, então nunca aceitam texto livre/HTML."),
    ("Compartilhamento de texto plano via share_plus", "generator_page.dart:229 usa "
     "`Share.share(buffer.toString(), ...)`, que entrega texto puro ao share sheet do SO — não "
     "há renderização HTML no caminho de compartilhamento."),
    ("Operação por ID confinada ao próprio dispositivo", "`deleteBetHistory(id)` em "
     "bet_history_repository.dart:47-54 só opera sobre a lista salva localmente via "
     "SharedPreferences do próprio aparelho — não existe servidor, conta de usuário ou outro "
     "tenant cujo dado poderia ser acessado trocando o id (pré-requisito para IDOR)."),
    ("Uso correto de aleatoriedade não-criptográfica", "`dart:math Random()` é usado em "
     "generate_bets.dart para sugerir dezenas de aposta — não há geração de token, senha ou "
     "segredo de sessão em nenhum lugar do app, então `Random()` (em vez de `Random.secure()`) "
     "é a escolha apropriada."),
]
for titulo, desc in pontos_fortes:
    story.append(Paragraph(f"✓ <b>{titulo}</b> — {desc}", styles["Corpo"]))

story.append(Paragraph("Pontos Fracos / Riscos Centrais", styles["H2"]))
story.append(Paragraph(
    "Nenhum risco de segurança explorável foi identificado. O único ponto registrado é de "
    "robustez/defesa em profundidade, não uma vulnerabilidade ativa:", styles["Corpo"]))
story.append(Paragraph(
    "⚠ <b>Histórico de apostas em texto plano no dispositivo</b> — "
    "bet_history_repository.dart armazena o histórico de apostas geradas via "
    "SharedPreferences (chave 'bet_history') sem criptografia. Isso é aceitável porque o dado "
    "não é sensível (apenas os próprios números de aposta gerados pelo usuário — não há PII, "
    "login ou dado financeiro), mas fica registrado como nota de robustez para o caso de o "
    "escopo do app crescer.", styles["Corpo"]))

story.append(PageBreak())

# ===========================================================================
# METODOLOGIA POR CATEGORIA
# ===========================================================================
story.append(Paragraph("Metodologia — Mapeamento por Categoria", styles["H1"]))

categorias_texto = [
    ("1. Banco sem tranca (isolamento de tenant/RLS)", "N/A",
     "Mecanismo de isolamento identificado: nenhum. O app não tem backend, banco remoto, "
     "Supabase, contas de usuário nem conceito de organização/tenant. Toda a persistência é "
     "local, por dispositivo, via SharedPreferences (lib/modules/generator/data/repositories/"
     "bet_history_repository.dart) — não existe consulta que precise filtrar por usuário/"
     "tenant porque não há mais de um usuário compartilhando a mesma base de dados."),
    ("2. Permissão definida no navegador", "N/A",
     "Não há papéis (isAdmin, canEdit, role), tela de administração, gestão de usuários nem "
     "qualquer operação privilegiada distinta de uso comum. Sem backend, não há endpoint "
     "correspondente a validar."),
    ("3. IDOR", "N/A",
     "Não existem handlers de rota HTTP no projeto (nenhuma dependência http/dio, nenhuma URL "
     "literal em lib/). A única operação por ID (`deleteBetHistory(id)`) foi auditada e "
     "confirmada como local ao próprio dispositivo — sem fronteira de autorização a violar."),
    ("4. Chaves expostas (hardcode)", "Auditado",
     "Varredura por padrões de segredo (api[_-]?key, secret, token, password, Bearer, "
     "private_key, BEGIN RSA/PRIVATE, AIza, sk_live/sk_test) em lib/, android/, ios/, assets/ "
     "e arquivos de configuração de raiz, mais checagem do histórico completo do git por nomes "
     "de arquivo sensíveis. Nenhum resultado positivo. Achado informativo registrado sobre "
     "armazenamento local não criptografado (ver Pontos Fracos)."),
    ("5. Inputs sem tratamento (XSS)", "N/A",
     "Não há dependência de WebView, flutter_html ou markdown no pubspec.yaml/pubspec.lock; "
     "nenhuma ocorrência de renderização de HTML/eval em lib/. O app não tem backend que "
     "gere e-mails/templates HTML. Os dois campos de texto livres são restritos a dígitos."),
]

tbl_data = [["Categoria", "Status", "Justificativa"]]
for nome, status, just in categorias_texto:
    tbl_data.append([Paragraph(f"<b>{nome}</b>", styles["CorpoPequeno"]),
                      Paragraph(status, styles["CorpoPequeno"]),
                      Paragraph(just, styles["CorpoPequeno"])])

meta_categ_tbl = Table(tbl_data, colWidths=[4.3 * cm, 1.8 * cm, 10.4 * cm], repeatRows=1)
meta_categ_tbl.setStyle(TableStyle([
    ("BACKGROUND", (0, 0), (-1, 0), COR_TEXTO),
    ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
    ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
    ("FONTSIZE", (0, 0), (-1, 0), 9),
    ("GRID", (0, 0), (-1, -1), 0.5, COR_FUNDO_CLARO),
    ("VALIGN", (0, 0), (-1, -1), "TOP"),
    ("TOPPADDING", (0, 0), (-1, -1), 6),
    ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
    ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, COR_FUNDO_CLARO]),
]))
story.append(meta_categ_tbl)
story.append(PageBreak())

# ===========================================================================
# TABELA DE ACHADOS DETALHADOS
# ===========================================================================
story.append(Paragraph("Achados Detalhados", styles["H1"]))
story.append(Paragraph(
    "Um único achado foi registrado nesta auditoria, de severidade informativa. As demais "
    "categorias não geraram achados — ver justificativas técnicas na seção de Metodologia.",
    styles["Corpo"]))

story.append(Paragraph("Categoria 4 — Chaves Expostas / Robustez de Dados", styles["H3"]))

achado_header = ["Severidade", "Arquivo:linha", "Descrição"]
achado_row = [
    sev_chip("INFORMATIVA", COR_BAIXA),
    Paragraph("lib/modules/generator/data/repositories/"
              "bet_history_repository.dart:11-18", styles["CorpoPequeno"]),
    Paragraph(
        "<b>saveBetHistory()</b> grava o histórico de apostas via "
        "<font face='Courier'>prefs.setString(_historyKey, jsonString)</font> em texto plano "
        "(SharedPreferences não é criptografado no Android/iOS por padrão). Não é uma "
        "vulnerabilidade ativa — o dado guardado (números de aposta gerados pelo próprio "
        "usuário) não é sensível — mas registra-se como nota de robustez/defesa em "
        "profundidade caso o app venha a armazenar dados mais sensíveis no futuro.",
        styles["CorpoPequeno"]),
]
achados_tbl = Table([achado_header, achado_row], colWidths=[2.9 * cm, 5.3 * cm, 8.3 * cm])
achados_tbl.setStyle(TableStyle([
    ("BACKGROUND", (0, 0), (-1, 0), COR_TEXTO),
    ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
    ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
    ("FONTSIZE", (0, 0), (-1, 0), 9),
    ("GRID", (0, 0), (-1, -1), 0.5, COR_FUNDO_CLARO),
    ("VALIGN", (0, 0), (-1, -1), "TOP"),
    ("ALIGN", (0, 1), (0, 1), "CENTER"),
    ("TOPPADDING", (0, 0), (-1, -1), 7),
    ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
]))
story.append(achados_tbl)

story.append(Spacer(1, 0.4 * cm))
story.append(Paragraph("Evidência de código", styles["H3"]))
story.append(Paragraph(
    "bet_history_repository.dart, linhas 11-18:", styles["Corpo"]))
story.append(Spacer(1, 4))
story.append(Paragraph(
    "  Future&lt;void&gt; saveBetHistory(BetHistory history) async {<br/>"
    "&nbsp;&nbsp;final prefs = await SharedPreferences.getInstance();<br/>"
    "&nbsp;&nbsp;final currentHistory = await loadBetHistory();<br/>"
    "&nbsp;&nbsp;currentHistory.insert(0, history);<br/>"
    "&nbsp;&nbsp;...<br/>"
    "&nbsp;&nbsp;final jsonString = jsonEncode(jsonList);<br/>"
    "&nbsp;&nbsp;await prefs.setString(_historyKey, jsonString);  // texto plano<br/>"
    "  }", styles["CodeBlock"]))

for nome, status, just in categorias_texto[:3] + [categorias_texto[4]]:
    story.append(Paragraph(f"<b>{nome}</b> — {status}", styles["H3"]))
    story.append(Paragraph(just, styles["Corpo"]))

story.append(PageBreak())

# ===========================================================================
# RECOMENDAÇÕES
# ===========================================================================
story.append(Paragraph("Recomendações Priorizadas", styles["H1"]))
recs = [
    ("P1", "Nenhuma ação crítica ou de alta prioridade necessária",
     "A auditoria não encontrou vulnerabilidades críticas, altas ou médias explorat"
     "áveis. Não há P1 pendente neste ciclo."),
    ("P2", "Nenhuma ação de prioridade média pendente",
     "Idem — sem achados nesta faixa de severidade."),
    ("P3", "(Opcional) Marcar o histórico local como dado não sensível, ou cifrá-lo",
     "Caso o app venha a armazenar dados mais sensíveis no futuro (ex.: dados de conta), "
     "avaliar migrar o histórico de SharedPreferences em texto plano para um storage "
     "cifrado (ex.: pacote flutter_secure_storage) antes disso acontecer. Para o "
     "conteúdo atual (números de aposta do próprio usuário), não é urgente."),
    ("P3", "Manter a disciplina de não commitar segredos",
     "O projeto já mantém key.properties fora do controle de versão corretamente — manter "
     "essa prática ao adicionar qualquer integração futura que exija API key/token."),
]
for pri, titulo, desc in recs:
    chip = sev_chip(pri, COR_TEXTO if pri != "P1" else COR_MUTED, width=1.6 * cm)
    row = Table([[chip,
                   Paragraph(f"<b>{titulo}</b><br/>{desc}", styles["Corpo"])]],
                colWidths=[2.2 * cm, 14.2 * cm])
    row.setStyle(TableStyle([("VALIGN", (0, 0), (-1, -1), "TOP"),
                              ("TOPPADDING", (0, 0), (-1, -1), 4),
                              ("BOTTOMPADDING", (0, 0), (-1, -1), 10)]))
    story.append(row)

story.append(PageBreak())

# ===========================================================================
# ISSUES PARA O GITHUB
# ===========================================================================
story.append(Paragraph("Issues para o GitHub", styles["H1"]))
story.append(Paragraph(
    "Apenas um achado desta auditoria é acionável (os demais são confirmações de N/A "
    "ou pontos fortes, que não geram issue). Texto pronto para copiar e colar:",
    styles["Corpo"]))

issue_md = """--- ISSUE 1 ---
### Título
[Segurança] Histórico de apostas armazenado em texto plano no dispositivo (SharedPreferences)

**Labels sugeridas:** security, severidade:baixa

**Descrição do problema**
`BetHistoryRepository.saveBetHistory()` (lib/modules/generator/data/repositories/bet_history_repository.dart, linhas 11-18) grava o histórico de apostas via `prefs.setString(_historyKey, jsonString)`, usando o pacote `shared_preferences`, que armazena os dados em texto plano no dispositivo (arquivo XML no Android via SharedPreferences padrão, plist no iOS via NSUserDefaults) sem criptografia.

Isso não é explorável remotamente e o dado atual (números de aposta gerados pelo próprio usuário, sem PII ou credenciais) não é sensível — por isso a severidade é baixa/informativa, não crítica. Registrado como nota de robustez/defesa em profundidade.

**Evidência**
```
lib/modules/generator/data/repositories/bet_history_repository.dart:11-18

Future<void> saveBetHistory(BetHistory history) async {
  final prefs = await SharedPreferences.getInstance();
  final currentHistory = await loadBetHistory();
  currentHistory.insert(0, history);
  ...
  final jsonString = jsonEncode(jsonList);
  await prefs.setString(_historyKey, jsonString);  // texto plano, sem criptografia
}
```

**Impacto**
Baixo no estado atual do app (dado não sensível). Se o app crescer para armazenar dados mais sensíveis (ex.: conta de usuário, dados financeiros reais), esse padrão de armazenamento precisaria ser revisado antes disso — quem tiver acesso físico/root ao dispositivo, ou a um backup não criptografado, pode ler o conteúdo.

**Sugestão de correção**
Nenhuma ação necessária para o escopo atual. Caso o escopo do app mude, considerar migrar para um storage cifrado (ex.: pacote `flutter_secure_storage`) para dados que passem a ser sensíveis, mantendo `shared_preferences` apenas para preferências não sensíveis (tema, configurações de UI, etc.).

**Critérios de aceite**
- [ ] Decisão registrada: manter `shared_preferences` para o histórico de apostas (dado não sensível) OU migrar para storage cifrado, caso o escopo do app inclua dados sensíveis no futuro
- [ ] Se migrar: `flutter_secure_storage` (ou equivalente) adotado para qualquer dado que envolva PII/credenciais/dados financeiros reais
- [ ] Nenhuma regressão nos testes existentes de `BetHistoryRepository`
--- FIM ISSUE 1 ---"""

for bloco in issue_md.split("\n\n"):
    if bloco.startswith("```"):
        code = bloco.strip("`").strip()
        story.append(Paragraph(code.replace("\n", "<br/>").replace(" ", "&nbsp;"), styles["CodeBlock"]))
    elif bloco.strip() in ("--- ISSUE 1 ---", "--- FIM ISSUE 1 ---"):
        story.append(Paragraph(f"<b>{bloco.strip()}</b>", styles["CorpoPequeno"]))
    else:
        story.append(Paragraph(bloco.replace("\n", "<br/>"), styles["CorpoPequeno"]))
    story.append(Spacer(1, 4))

doc.build(story)
print(f"PDF gerado em {PDF_PATH}")
