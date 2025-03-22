--1. Добавление нового клиента и его учетной записи
--Эта хранимая процедура добавляет нового клиента вместе с его первоначальной учетной записью. 
CREATE OR REPLACE PROCEDURE public.add_client_and_account(
    p_fullname VARCHAR(255),
    p_phonenumber VARCHAR(20),
    p_taxid VARCHAR(12),
    p_accountnumber VARCHAR(20),
    p_currency CHAR(3),
    p_balance NUMERIC(15,2),
    p_validfrom TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_clientid INT;
BEGIN
    INSERT INTO public."Clients" ("FullName", "PhoneNumber", "TaxId")
    VALUES (p_fullname, p_phonenumber, p_taxid)
    RETURNING "ClientID" INTO v_clientid;

    INSERT INTO public."Accounts" ("ClientID", "AccountNumber", "Currency", "ValidFrom", "Balance")
    VALUES (v_clientid, p_accountnumber, p_currency, p_validfrom, p_balance);

    COMMIT;
END;
$$;


CREATE SEQUENCE public.clients_clientid_seq OWNED BY public."Clients"."ClientID";
ALTER TABLE public."Clients"
ALTER COLUMN "ClientID" SET DEFAULT nextval('public.clients_clientid_seq');

CREATE SEQUENCE public.accounts_accountid_seq;
ALTER TABLE public."Accounts"
ALTER COLUMN "AccountID" SET DEFAULT nextval('public.accounts_accountid_seq');
SELECT setval('public.accounts_accountid_seq', (SELECT MAX("AccountID") FROM public."Accounts") + 1);



-- Тест на добавление нового клиента
DO $$
DECLARE
    v_test_clientid INT;
BEGIN
    CALL public.add_client_and_account('John Doe', '555-0123', '123456789012', '1000000001', 'USD', 1000.00, '2023-01-01 00:00:00');

    -- Проверка, что клиент добавлен
    SELECT "ClientID" INTO v_test_clientid FROM public."Clients" WHERE "FullName" = 'John Doe';
    RAISE NOTICE 'New Client ID: %', v_test_clientid;

    -- Проверка, что аккаунт создан
    IF EXISTS (SELECT 1 FROM public."Accounts" WHERE "ClientID" = v_test_clientid AND "Balance" = 1000.00) THEN
        RAISE NOTICE 'Test Passed: Account created successfully.';
    ELSE
        RAISE EXCEPTION 'Test Failed: Account not created.';
    END IF;
END $$;


-- 2. Обновить баланс клиента
-- Может быть вызвана после транзакций, таких как пополнение счета или снятие средств.
CREATE OR REPLACE PROCEDURE public.update_client_balance(
    p_accountnumber VARCHAR(20),
    p_newbalance NUMERIC(15,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE public."Accounts"
    SET "Balance" = p_newbalance
    WHERE "AccountNumber" = p_accountnumber;

    COMMIT;
END;
$$;

-- Тест
DO $$
BEGIN
    CALL public.update_client_balance('1000000001', 1200.00);

    IF EXISTS (SELECT 1 FROM public."Accounts" WHERE "AccountNumber" = '1000000001' AND "Balance" = 1200.00) THEN
        RAISE NOTICE 'Test Passed: Balance updated successfully.';
    ELSE
        RAISE EXCEPTION 'Test Failed: Balance update failed.';
    END IF;
END $$;


-- 3. Рассчитайте стоимость портфеля
-- Эта функция вычисляет общую стоимость инвестиционного портфеля клиента на основе имеющихся в настоящее время активов. 
-- Она суммирует стоимость всех активов в данном портфеле.
CREATE OR REPLACE FUNCTION public.calculate_portfolio_value(p_portfolio_id INT)
RETURNS NUMERIC(15,2)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_value NUMERIC(15,2);
BEGIN
    SELECT SUM("Value")
    INTO v_total_value
    FROM public."Assets"
    WHERE "PortfolioID" = p_portfolio_id;

    RAISE NOTICE 'Total Portfolio Value for ID %: %', p_portfolio_id, COALESCE(v_total_value, 0);

    RETURN COALESCE(v_total_value, 0); -- 0, если активов нет
END;
$$;


-- Тест
DO $$
DECLARE
    v_value NUMERIC;
BEGIN
    v_value := public.calculate_portfolio_value(1);
END $$;
