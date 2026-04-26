# ----------------------------------------------------------------------------------------------------------
# PROJETO: Análise Exploratória de Desempenho Estudantil
# OBJETIVO: Identificar padrões entre hábitos, realidade socioeconômica, bem-estar e notas
# ----------------------------------------------------------------------------------------------------------

# 1. Carregar Bibliotecas
if (!require(tidyverse)) install.packages("tidyverse")
library(tidyverse)

# 2. Carregar os Dados
caminho <- "C:/Users/User/Desktop/portifolio dados/Analise estudantes/dados/student_performance_grade.csv"
dados <- read_csv(caminho)

# --- ANÁLISE EXPLORATÓRIA (AED) ---

cat("--- INICIANDO ANÁLISE EXPLORATÓRIA ---\n\n")

# 1. Alunos em Situação Crítica
cat("1. ALERTAS DE DESEMPENHO E BEM-ESTAR:\n")

# Presença menor que 70%
presenca_critica <- dados %>% filter(Attendance < 70) %>% nrow()
cat("- Alunos com presença abaixo de 70%:", presenca_critica, "\n")

# Estresse acima de 5
estresse_alto <- dados %>% filter(Stress_Level > 5) %>% nrow()
cat("- Alunos com nível de estresse elevado (>5):", estresse_alto, "\n")

# 2. Perfil dos Estudantes 
cat("\n2. PERFIL DO CORPO ESTUDANTIL:\n")

# Distribuição de Gênero
perfil_genero <- dados %>% count(Gender) %>% mutate(prop = n / sum(n) * 100)
print(perfil_genero)

# Alunos que trabalham
trabalho_job <- dados %>% count(Part_Time_Job)
cat("\n- Distribuição de alunos que trabalham meio período:\n")
print(trabalho_job)

# 3. Hábitos de Vida (Sono e Tempo de Tela)
cat("\n3. HÁBITOS E ESTILO DE VIDA:\n")

# Média de sono e tempo de tela
estilo_vida <- dados %>% 
  summarise(
    media_sono = mean(Sleep_Hours),
    media_tela = mean(Screen_Time),
    max_tela = max(Screen_Time)
  )
print(estilo_vida)

# Alunos com "Privação de Sono" (Dormem < 6h)
privacao_sono <- dados %>% filter(Sleep_Hours < 6) %>% nrow()
cat("- Alunos que dormem menos de 6 horas:", privacao_sono, "\n")

# 4. RANKING POR MÉTODO DE ESTUDO
cat("\n4. RANKING POR MÉTODO DE ESTUDO:\n")

ranking_metodos <- dados %>%
  group_by(Study_Method) %>%
  summarise(
    qtd_alunos = n(),
    media_gpa_anterior = mean(Previous_GPA, na.rm = TRUE),
    estresse_medio = mean(Stress_Level, na.rm = TRUE)
  ) %>%
  arrange(desc(media_gpa_anterior))

print(ranking_metodos)

# EXTRA: Ver as notas (Grades) por método
cat("\nDISTRIBUIÇÃO DE NOTAS POR MÉTODO:\n")
tabela_notas <- table(dados$Study_Method, dados$Grade)
print(tabela_notas)

# 5. TRANSFORMAÇÃO DE DADOS (Preparação para Correlação)
cat("\n5. TRANSFORMANDO NOTAS EM VALORES NUMÉRICOS...\n")

# Criando uma escala numérica: A=4, B=3, C=2, D=1, Fail=0
dados <- dados %>%
  mutate(Grade_Num = case_when(
    Grade == "A" ~ 4,
    Grade == "B" ~ 3,
    Grade == "C" ~ 2,
    Grade == "D" ~ 1,
    Grade == "Fail" ~ 0
  ))

# 6. MATRIZ DE CORRELAÇÃO
cat("\n6. CALCULANDO CORRELAÇÕES COM A NOTA:\n")

correlacoes <- dados %>%
  select(Grade_Num, Age, Hours_Studied, Attendance, Sleep_Hours, Stress_Level, Screen_Time, Previous_GPA) %>%
  cor(use = "complete.obs")

# Mostra apenas a relação das variáveis com a Nota (Grade_Num)
print(round(correlacoes[,"Grade_Num"], 2))

# --- VISUALIZAÇÕES ---
cat("\n--- GERANDO VISUALIZAÇÕES ---\n")

# Comando para resetar a área de gráficos e evitar o erro de viewport
#if(!is.null(dev.list())) dev.off() 


# Gráfico 1: Notas por Gênero
g1 <- ggplot(dados, aes(x = Grade, fill = Grade)) +
  geom_bar() +
  facet_wrap(~Gender) +
  scale_fill_brewer(palette = "Set1") +
  theme_minimal() +
  labs(title = "Distribuição de Notas por Gênero",
       x = "Nota", y = "Quantidade de Alunos")

# Salva o gráfico de notas
ggsave("distribuicao_notas.png", plot = g1, width = 10, height = 6, dpi = 300)

# --- Boxplot de Horas de Estudo ---
# Gráfico 2: Variação de Horas de Estudo por Nota
g2 <- ggplot(dados, aes(x = Grade, y = Hours_Studied, fill = Grade)) +
  geom_boxplot(alpha = 0.7, outlier.colour = "red", outlier.shape = 8) +
  theme_minimal() +
  scale_fill_viridis_d(option = "plasma") + # Cores vibrantes que combinam com seu estilo
  labs(title = "Horas de Estudo vs Nota Final",
       subtitle = "Análise da distribuição do tempo dedicado para cada conceito",
       x = "Nota (Grade)", 
       y = "Horas Estudadas")

# Salva o boxplot
ggsave("boxplot_estudo.png", plot = g2, width = 10, height = 6, dpi = 300)

# Gráfico 3: Heatmap de Correlação (Simples)
if (!require(corrplot)) install.packages("corrplot")
library(corrplot)

corrplot(correlacoes, method = "color", type = "upper", 
         tl.col = "black", tl.srt = 45, 
         addCoef.col = "black", number.cex = 0.7)
         # --- SALVANDO O HEATMAP ---

# 1. Abre o arquivo onde a imagem será gravada
png("heatmap_correlacao.png", width = 800, height = 800, res = 120)

# 2. Gera o gráfico (o R vai "desenhar" dentro do arquivo acima)
corrplot(correlacoes, method = "color", type = "upper", 
         tl.col = "black", tl.srt = 45, 
         addCoef.col = "black", number.cex = 0.7,
         col = colorRampPalette(c("#E41A1C", "white", "#377EB8"))(200))

# 3. Fecha o arquivo e salva no seu computador
dev.off() 

cat("\n- Heatmap salvo com sucesso como 'heatmap_correlacao.png'")

cat("\n--- ANÁLISE CONCLUÍDA COM SUCESSO ---")