-- Accounts Table:  
-- ClientID: Для ускорения поиска и объединения по идентификаторам клиентов, полезно,так как часто нужно будет объединять таблицы Accounts и Clients.
CREATE INDEX idx_accounts_clientid ON public."Accounts" ("ClientID");

-- Таблица Transactions:
-- AccountID и Date: Поскольку финансовые транзакции часто проверяются по счету и диапазону дат, сделаем составной индекс.
CREATE INDEX idx_transactions_accountid_date ON public."Transactions" ("AccountID", "Date");

-- Таблица Assets
-- PortfolioID: Сведения об активах часто извлекаются из портфеля при управлении портфелем.
CREATE INDEX idx_assets_portfolioid ON public."Assets" ("PortfolioID");
