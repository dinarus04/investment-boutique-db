-- 1.Вывести список всех транзакций, сумма которых превышает 1000 рублей.
SELECT t."TransactionID", t."Date", t."Amount"
FROM "Transactions" t
WHERE t."Amount" > 1000;

-- 2. Вывести список всех проектов, в которые инвестировали более 5 раз.
SELECT p."ProjectID", p."Name"
FROM "Projects" p
JOIN "TransactionItems" ti ON p."ProjectID" = ti."ProjectID"
GROUP BY p."ProjectID", p."Name"
HAVING COUNT(ti."TransactionItemID") > 5;

--3. Вывести все транзакции, проведенные в рамках одного портфеля:
SELECT t."TransactionID", t."Date", t."Amount"
FROM public."Transactions" t
JOIN public."InvestPortfolios" ip ON t."PortfolioID" = ip."PortfolioID"
WHERE ip."PortfolioID" = 1
ORDER BY t."Date";

--4. Вывести среднюю сумму инвестиций в проекты для каждого клиента:
SELECT c."FullName", AVG(t."Amount") as "AverageInvestment"
FROM public."Clients" c
JOIN public."Accounts" a ON c."ClientID" = a."ClientID"
JOIN public."Transactions" t ON a."AccountID" = t."AccountID"
JOIN public."TransactionItems" ti ON t."TransactionID" = ti."TransactionID"
JOIN public."Projects" p ON ti."ProjectID" = p."ProjectID"
GROUP BY c."ClientID";

--5. Вывести топ-5 проектов, в которые инвестировали наибольшую сумму:
SELECT p."ProjectID", p."Name", SUM(t."Amount") as "TotalInvestment"
FROM public."Projects" p
JOIN public."TransactionItems" ti ON p."ProjectID" = ti."ProjectID"
JOIN public."Transactions" t ON ti."TransactionID" = t."TransactionID"
GROUP BY p."ProjectID", p."Name"
ORDER BY "TotalInvestment" DESC
LIMIT 5;

-- 6. Вывести всех клиентов, которые не инвестировали ни в один проект:
SELECT c."ClientID", c."FullName"
FROM public."Clients" c
WHERE NOT EXISTS (
  SELECT 1
  FROM public."Accounts" a
  JOIN public."Transactions" t ON a."AccountID" = t."AccountID"
  JOIN public."TransactionItems" ti ON t."TransactionID" = ti."TransactionID"
  WHERE c."ClientID" = a."ClientID"
)
ORDER BY c."ClientID";

-- 7. Вывести все портфели, суммарная стоимость которых превышает 100000 рублей:
SELECT ip."PortfolioID", SUM(ti."Quantity" * ti."UnitPrice") as "TotalCost"
FROM public."InvestPortfolios" ip
JOIN public."Transactions" t ON ip."PortfolioID" = t."PortfolioID"
JOIN public."TransactionItems" ti ON t."TransactionID" = ti."TransactionID"
GROUP BY ip."PortfolioID"
HAVING SUM(ti."Quantity" * ti."UnitPrice") > 100000
ORDER BY ip."PortfolioID";

-- 8. Вывести все транзакции, проведенные за три года:
SELECT t."TransactionID", t."Date", t."Amount"
FROM public."Transactions" t
WHERE t."Date" >= NOW() - INTERVAL '3 year'
ORDER BY t."Date";
SELECT c."ClientID", c."FullName", SUM(t."Amount") as "TotalInvestment"
FROM public."Clients" c
JOIN public."Accounts" a ON c."ClientID" = a."ClientID"
JOIN public."Transactions" t ON a."AccountID" = t."AccountID"
JOIN public."TransactionItems" ti ON t."TransactionID" = ti."TransactionID"
JOIN public."Projects" p ON ti."ProjectID" = p."ProjectID"
GROUP BY c."ClientID", c."FullName"
ORDER BY "TotalInvestment" DESC
LIMIT 3;

--9. Вывести топ-3 клиентов, инвестировавших наибольшую сумму в проекты:
SELECT c."ClientID", c."FullName", SUM(t."Amount") as "TotalInvestment"
FROM public."Clients" c
JOIN public."Accounts" a ON c."ClientID" = a."ClientID"
JOIN public."Transactions" t ON a."AccountID" = t."AccountID"
JOIN public."TransactionItems" ti ON t."TransactionID" = ti."TransactionID"
JOIN public."Projects" p ON ti."ProjectID" = p."ProjectID"
GROUP BY c."ClientID", c."FullName"
ORDER BY "TotalInvestment" DESC
LIMIT 3;

--10. Вывести среднюю прибыльность проектов для каждого типа проекта:
SELECT p."ProjectType", AVG(p."Profitability") as "AverageProfitability"
FROM public."Projects" p
GROUP BY p."ProjectType";


