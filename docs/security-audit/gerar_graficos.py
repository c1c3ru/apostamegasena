#!/usr/bin/env python3
"""Gera os gráficos (rosca por severidade, barras por categoria) usados no
relatório de auditoria de segurança. Saída: PNGs em docs/security-audit/."""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

OUT_DIR = "docs/security-audit"

COLORS = {
    "critica": "#B91C1C",
    "alta": "#EA580C",
    "media": "#D97706",
    "baixa": "#2563EB",
    "forte": "#059669",
}

# ---------------------------------------------------------------------------
# Gráfico de rosca — achados por severidade
# ---------------------------------------------------------------------------
severidades = ["Crítica", "Alta", "Média", "Baixa/Informativa"]
valores = [0, 0, 0, 1]
cores = [COLORS["critica"], COLORS["alta"], COLORS["media"], COLORS["baixa"]]

fig, ax = plt.subplots(figsize=(5, 5), dpi=200)
# donut só com fatias > 0 pra evitar rótulo poluído; usamos anotação lateral p/ zeros
valores_plot = [v if v > 0 else 0.0001 for v in valores]
wedges, _ = ax.pie(
    valores_plot,
    colors=cores,
    startangle=90,
    wedgeprops=dict(width=0.42, edgecolor="white", linewidth=2),
)
ax.text(0, 0.08, "1", ha="center", va="center", fontsize=34, fontweight="bold", color="#1f2937")
ax.text(0, -0.18, "achado total", ha="center", va="center", fontsize=12, color="#6b7280")
ax.set_aspect("equal")

legend_labels = [f"{s} ({v})" for s, v in zip(severidades, valores)]
ax.legend(
    wedges, legend_labels, loc="upper center", bbox_to_anchor=(0.5, -0.02),
    ncol=1, frameon=False, fontsize=11,
)
plt.tight_layout()
plt.savefig(f"{OUT_DIR}/grafico_severidade.png", transparent=True, bbox_inches="tight")
plt.close(fig)

# ---------------------------------------------------------------------------
# Gráfico de barras — achados/status por categoria
# ---------------------------------------------------------------------------
categorias = [
    "1. Isolamento\nde dados\n(N/A)",
    "2. Permissão\nno frontend\n(N/A)",
    "3. IDOR\n(N/A)",
    "4. Segredos\nexpostos",
    "5. XSS /\ninput\n(N/A)",
]
achados = [0, 0, 0, 0, 0]
info = [0, 0, 0, 1, 0]

fig, ax = plt.subplots(figsize=(8.6, 4.6), dpi=200)
x = range(len(categorias))
bars_info = ax.bar(x, info, color=COLORS["baixa"], label="Informativa", width=0.5, zorder=3)

for i, (a, inf) in enumerate(zip(achados, info)):
    total = a + inf
    if total == 0:
        ax.text(i, 0.04, "verificado\nsem achados", ha="center", va="bottom",
                 fontsize=8.5, color="#6b7280")

ax.set_xticks(list(x))
ax.set_xticklabels(categorias, fontsize=9)
ax.set_ylabel("Nº de achados")
ax.set_ylim(0, 2)
ax.set_yticks([0, 1, 2])
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.grid(axis="y", color="#e5e7eb", zorder=0)
ax.legend(frameon=False, loc="upper right")
plt.tight_layout()
plt.savefig(f"{OUT_DIR}/grafico_categoria.png", transparent=True, bbox_inches="tight")
plt.close(fig)

print("Gráficos gerados com sucesso.")
