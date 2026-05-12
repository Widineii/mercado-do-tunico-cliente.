Add-Type -AssemblyName System.Drawing

$outDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$fontTitle = New-Object System.Drawing.Font("Segoe UI", 24, [System.Drawing.FontStyle]::Bold)
$fontSub = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Regular)
$fontBody = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Regular)
$fontBold = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$fontSmall = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)

function Brush($hex) {
    return New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($hex))
}

function PenColor($hex, $width = 1) {
    return New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml($hex), $width)
}

function Fill-RoundedRect($g, $brush, $x, $y, $w, $h) {
    $g.FillRectangle($brush, $x, $y, $w, $h)
}

function Draw-Card($g, $x, $y, $w, $h, $title, $value, $color) {
    Fill-RoundedRect $g (Brush "#FFFFFF") $x $y $w $h
    $g.DrawRectangle((PenColor "#DDE5DD"), $x, $y, $w, $h)
    $g.DrawString($title, $fontSmall, (Brush "#607166"), $x + 14, $y + 12)
    $g.DrawString($value, $fontTitle, (Brush $color), $x + 14, $y + 36)
}

function Draw-Table($g, $x, $y, $w, $h, $title, $headers, $rows) {
    Fill-RoundedRect $g (Brush "#FFFFFF") $x $y $w $h
    $g.DrawRectangle((PenColor "#DDE5DD"), $x, $y, $w, $h)
    Fill-RoundedRect $g (Brush "#1B5E20") $x $y $w 42
    $g.DrawString($title, $fontBold, (Brush "#FFFFFF"), $x + 14, $y + 11)
    $colW = [int](($w - 28) / $headers.Count)
    $yy = $y + 54
    for ($i = 0; $i -lt $headers.Count; $i++) {
        $g.DrawString($headers[$i], $fontBold, (Brush "#2D3A2F"), $x + 14 + ($i * $colW), $yy)
    }
    $yy += 28
    foreach ($row in $rows) {
        $g.DrawLine((PenColor "#E8EFE8"), $x + 14, $yy - 8, $x + $w - 14, $yy - 8)
        for ($i = 0; $i -lt $row.Count; $i++) {
            $g.DrawString($row[$i], $fontSmall, (Brush "#334037"), $x + 14 + ($i * $colW), $yy)
        }
        $yy += 30
        if ($yy -gt ($y + $h - 28)) { break }
    }
}

function New-PortfolioScreen($file, $title, $subtitle, $activeTab, $cards, $tableTitle, $headers, $rows, $sideNotes) {
    $bmp = New-Object System.Drawing.Bitmap(1366, 768)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.ColorTranslator]::FromHtml("#F4F7F1"))

    Fill-RoundedRect $g (Brush "#0F3D22") 0 0 1366 74
    $g.DrawString("Mercearia do Tunico", $fontTitle, (Brush "#FFFFFF"), 28, 17)
    $g.DrawString("Sistema desktop Java Swing + SQLite", $fontSub, (Brush "#D8F2DA"), 1030, 25)

    Fill-RoundedRect $g (Brush "#FFFFFF") 0 74 238 694
    $tabs = @("Painel", "PDV - Caixa", "Estoque", "Fornecedores", "XML NF-e", "Convenio", "Financeiro", "Relatorios")
    $ty = 104
    foreach ($tab in $tabs) {
        if ($tab -eq $activeTab) {
            Fill-RoundedRect $g (Brush "#E8F5E9") 18 $ty 202 42
            $g.DrawRectangle((PenColor "#8BC34A"), 18, $ty, 202, 42)
            $g.DrawString($tab, $fontBold, (Brush "#1B5E20"), 36, $ty + 11)
        } else {
            $g.DrawString($tab, $fontBody, (Brush "#435145"), 36, $ty + 11)
        }
        $ty += 52
    }

    $g.DrawString($title, $fontTitle, (Brush "#1C2E20"), 270, 108)
    $g.DrawString($subtitle, $fontSub, (Brush "#607166"), 272, 148)

    $cx = 270
    foreach ($card in $cards) {
        Draw-Card $g $cx 190 238 102 $card[0] $card[1] $card[2]
        $cx += 258
    }

    Draw-Table $g 270 320 770 380 $tableTitle $headers $rows

    Fill-RoundedRect $g (Brush "#FFFFFF") 1070 190 260 510
    $g.DrawRectangle((PenColor "#DDE5DD"), 1070, 190, 260, 510)
    Fill-RoundedRect $g (Brush "#F57C00") 1070 190 260 42
    $g.DrawString("Destaques", $fontBold, (Brush "#FFFFFF"), 1086, 201)
    $ny = 254
    foreach ($note in $sideNotes) {
        $g.FillEllipse((Brush "#1B5E20"), 1088, $ny + 7, 8, 8)
        $noteRect = New-Object System.Drawing.RectangleF(1106, $ny, 205, 46)
        $g.DrawString($note, $fontSmall, (Brush "#334037"), $noteRect)
        $ny += 58
    }

    $g.DrawString("Imagem ilustrativa gerada para documentacao do portfolio.", $fontSmall, (Brush "#7A877D"), 270, 724)
    $path = Join-Path $outDir $file
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

New-PortfolioScreen "01-login.png" "Login seguro" "Entrada com perfis ADMIN, GERENTE, CAIXA e ESTOQUE." "Painel" `
    @(@("Seguranca", "bcrypt", "#1B5E20"), @("Perfis", "4 roles", "#F57C00"), @("Senha", "troca obrigatoria", "#2E7D32")) `
    "Acessos e permissoes" @("Perfil", "Acesso", "Controle") `
    @(@("ADMIN", "Total", "Configuracao"), @("GERENTE", "Operacao", "Autorizacoes"), @("CAIXA", "PDV", "Vendas"), @("ESTOQUE", "Produtos", "Inventario")) `
    @("Login sem senha fixa exposta.", "Senha real de ADMIN/GERENTE para autorizacoes.", "Primeiro acesso pede troca de senha.", "PIN de gerente separado para operacoes de caixa.")

New-PortfolioScreen "02-painel.png" "Painel de operacao" "Resumo diario com alertas para tomada de decisao." "Painel" `
    @(@("Vendas hoje", "R$ 1.248,90", "#1B5E20"), @("Estoque baixo", "8 itens", "#F57C00"), @("Convenio aberto", "12 clientes", "#C62828")) `
    "Alertas principais" @("Indicador", "Status", "Acao") `
    @(@("Validade proxima", "30 dias", "Conferir lote"), @("Produtos criticos", "Abaixo minimo", "Comprar"), @("Convenio", "Em aberto", "Cobrar"), @("Caixa", "Aberto", "Acompanhar")) `
    @("Cards para visao rapida do dia.", "Tabelas com estoque critico.", "Clientes com convenio em aberto.", "Produtos vencendo em 30 dias.")

New-PortfolioScreen "03-pdv-caixa.png" "PDV - Caixa" "Tela de venda rapida com pagamento combinado e controle de caixa." "PDV - Caixa" `
    @(@("Total", "R$ 86,40", "#1B5E20"), @("Itens", "7", "#F57C00"), @("Troco", "R$ 13,60", "#2E7D32")) `
    "Itens da venda" @("Produto", "Qtd", "Total") `
    @(@("Arroz 5kg", "1", "R$ 24,90"), @("Cafe 500g", "2", "R$ 31,80"), @("Leite 1L", "4", "R$ 29,70"), @("Desconto", "-", "R$ 0,00")) `
    @("Campo pronto para leitor de codigo de barras.", "Venda com dinheiro, PIX, debito, credito e convenio.", "Sangria e suprimento por atalho.", "Bloqueio de estoque insuficiente com autorizacao.")

New-PortfolioScreen "04-estoque.png" "Estoque inteligente" "Cadastro, busca, entrada, ajuste e perda/quebra de produtos." "Estoque" `
    @(@("Produtos", "250+", "#1B5E20"), @("Busca", "instantanea", "#F57C00"), @("Movimentos", "auditados", "#2E7D32")) `
    "Produtos cadastrados" @("Codigo", "Produto", "Estoque") `
    @(@("789001", "Feijao carioca", "42 un"), @("789002", "Acucar cristal", "18 un"), @("789003", "Oleo soja", "9 un"), @("789004", "Farinha trigo", "36 un")) `
    @("Busca por nome, codigo, SKU e categoria.", "Ajuste de saldo com historico.", "Perda/quebra integrada ao financeiro.", "Alertas de estoque minimo.")

New-PortfolioScreen "05-fornecedores.png" "Fornecedores" "Cadastro completo com dados comerciais e apoio a compras." "Fornecedores" `
    @(@("Fornecedores", "32", "#1B5E20"), @("CNPJ", "consulta", "#F57C00"), @("Ativos", "29", "#2E7D32")) `
    "Cadastro de fornecedores" @("Razao", "Cidade", "Status") `
    @(@("Distribuidora Central", "Sao Paulo", "Ativo"), @("Atacado Bom Preco", "Campinas", "Ativo"), @("Laticinios Serra", "Itapira", "Ativo"), @("Hortifruti Regional", "Mogi", "Inativo")) `
    @("Formulario com razao, fantasia, telefone e IE.", "Busca local por CNPJ.", "Integracao opcional com ReceitaWS.", "Base para entrada por XML NF-e.")

New-PortfolioScreen "06-xml-nfe.png" "XML NF-e" "Importacao de notas com previa e baixa automatica no estoque." "XML NF-e" `
    @(@("XML pendentes", "4", "#F57C00"), @("Itens lidos", "38", "#1B5E20"), @("Entrada", "automatica", "#2E7D32")) `
    "Notas pendentes" @("Nota", "Fornecedor", "Valor") `
    @(@("000123", "Distribuidora Central", "R$ 1.250,00"), @("000124", "Atacado Bom Preco", "R$ 842,70"), @("000125", "Laticinios Serra", "R$ 516,30"), @("000126", "Hortifruti Regional", "R$ 389,90")) `
    @("Leitura de produtos, EAN, quantidade e valor.", "Previa antes da baixa.", "Entrada automatica no estoque.", "Conta a pagar opcional no financeiro.")

New-PortfolioScreen "07-convenio.png" "Convenio de clientes" "Controle de compras em aberto, limite e baixa parcial." "Convenio" `
    @(@("Em aberto", "R$ 742,30", "#C62828"), @("Clientes", "18", "#1B5E20"), @("Baixas", "parciais", "#F57C00")) `
    "Clientes com convenio" @("Cliente", "Limite", "Aberto") `
    @(@("Maria Souza", "R$ 300,00", "R$ 84,20"), @("Jose Pereira", "R$ 500,00", "R$ 126,70"), @("Ana Lima", "R$ 250,00", "R$ 39,90"), @("Carlos Silva", "R$ 400,00", "R$ 0,00")) `
    @("Venda em convenio com cliente selecionado.", "Bloqueio por limite e prazo.", "Aumento de limite com autorizacao.", "Baixa total ou parcial.")

New-PortfolioScreen "08-financeiro.png" "Financeiro" "Contas a pagar/receber, baixas e rastreabilidade." "Financeiro" `
    @(@("Receber", "R$ 2.980,00", "#1B5E20"), @("Pagar", "R$ 1.420,00", "#C62828"), @("Baixado", "R$ 830,00", "#F57C00")) `
    "Lancamentos financeiros" @("Tipo", "Descricao", "Valor") `
    @(@("RECEBER", "Convenio cliente", "R$ 84,20"), @("PAGAR", "XML fornecedor", "R$ 842,70"), @("PAGAR", "Perda/quebra estoque", "R$ 16,30"), @("RECEBER", "Venda PIX", "R$ 129,90")) `
    @("Controle de contas a pagar e receber.", "Baixa com forma de pagamento.", "Perdas de estoque viram despesa.", "Auditoria de lancamentos.")

New-PortfolioScreen "09-relatorios.png" "Relatorios gerenciais" "Vendas, estoque, ranking de produtos e curva ABC." "Relatorios" `
    @(@("Vendas", "R$ 1.248,90", "#1B5E20"), @("Ticket medio", "R$ 41,63", "#F57C00"), @("Devolucoes", "R$ 0,00", "#2E7D32")) `
    "Ranking e curva ABC" @("Produto", "Faturamento", "Classe") `
    @(@("Cafe 500g", "R$ 318,00", "A"), @("Arroz 5kg", "R$ 249,00", "A"), @("Leite 1L", "R$ 178,20", "B"), @("Acucar cristal", "R$ 92,40", "C")) `
    @("Ranking por quantidade vendida.", "Ranking por faturamento.", "Curva ABC por faturamento.", "Relatorio de movimentacao de estoque.")

New-PortfolioScreen "10-pacote-final.png" "Pacote final Windows" "Pasta limpa para uso real e demonstracao." "Painel" `
    @(@("Abrir", ".vbs sem CMD", "#1B5E20"), @("Banco", "SQLite", "#F57C00"), @("Backup", "1 clique", "#2E7D32")) `
    "Arquivos do pacote" @("Arquivo", "Funcao", "Operador") `
    @(@("ABRIR_SERVIDOR_CAIXA.vbs", "Abre sistema", "Sim"), @("BACKUP_MERCADO_TUNICO.bat", "Copia banco", "Sim"), @("RESTORE_MERCADO_TUNICO.bat", "Restaura backup", "Admin"), @("MANUAL_RAPIDO.md", "Guia de uso", "Sim")) `
    @("Atalho silencioso para Windows 11.", "Banco em data/mercado-tonico.db.", "Manual rapido incluido.", "Modelo PC1 servidor + PC2 cliente preservado.")
