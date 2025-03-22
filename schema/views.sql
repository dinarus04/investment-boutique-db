-- 1. Финансовая сводка клиента
-- Предоставление краткой информации о финансовом состоянии каждого клиента без персональных данных.
CREATE VIEW public."ClientFinancialSummary" AS
SELECT
    c."ClientID",
    c."FullName",
    SUM(a."Balance") AS TotalBalance
FROM
    public."Clients" c
JOIN public."Accounts" a ON c."ClientID" = a."ClientID"
GROUP BY
    c."ClientID",
    c."FullName";
   
-- 2. Детали инвестирования в проект
-- Сведения о проекте с финансовыми данными по транзакциям, обеспечивая всестороннее представление об инвестиционной активности в каждом проекте.
CREATE VIEW public."ProjectInvestmentDetails" AS
SELECT
    pr."ProjectID",
    pr."Name",
    pr."ProjectType",
    pr."Income",
    pr."CurrentValue",
    pr."Profitability",
    SUM(ti."Quantity" * COALESCE(ti."UnitPrice", 0)) AS TotalInvested
FROM
    public."Projects" pr
JOIN public."TransactionItems" ti ON pr."ProjectID" = ti."ProjectID"
GROUP BY
    pr."ProjectID";

-- 3. Обзор активов
-- Подробная информация об активах в портфелях, включая их тип, стоимость и доходность, что может быть полезно как для управления, так и для отчетности клиентов.
CREATE VIEW public."AssetOverview" AS
SELECT
    a."AssetID",
    a."PortfolioID",
    a."Name",
    a."AssetType",
    a."Value",
    a."Yield",
    a."ValidFrom",
    a."ValidTo"
FROM
    public."Assets" a;

-- 4. Краткое описание транзакции
-- Сводный обзор транзакций по каждому счету: итоговые данные и недавняя активность, что важно для финансовых аудитов и проверок клиентов.
CREATE VIEW public."TransactionSummary" AS
SELECT
    t."AccountID",
    a."AccountNumber",
    COUNT(t."TransactionID") AS TotalTransactions,
    SUM(t."Amount") AS TotalAmount,
    MAX(t."Date") AS LastTransactionDate
FROM
    public."Transactions" t
JOIN public."Accounts" a ON t."AccountID" = a."AccountID"
GROUP BY
    t."AccountID",
    a."AccountNumber";
 
   
   
   
