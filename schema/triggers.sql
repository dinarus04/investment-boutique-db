-- 1. Триггер для обновления баланса счета после транзакций
-- Этот триггер автоматически обновляет баланс счета после добавления новой транзакции.
-- Это гарантирует, что баланс счета всегда синхронизирован с записями транзакций.

CREATE OR REPLACE FUNCTION update_account_balance()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public."Accounts"
    SET "Balance" = "Balance" + NEW."Amount"
    WHERE "AccountID" = NEW."AccountID";

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_balance
AFTER INSERT ON public."Transactions"
FOR EACH ROW
EXECUTE FUNCTION update_account_balance();

-- 2. Триггер для проверки дат валидности актива
-- Этот триггер гарантирует, что ValidFrom дата всегда предшествует ValidTo дате для любого актива. 
--Он предотвращает ошибки при вводе данных, которые могут привести к неверным диапазонам дат.
CREATE OR REPLACE FUNCTION check_asset_dates()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW."ValidFrom" >= NEW."ValidTo" THEN
        RAISE EXCEPTION 'ValidFrom date must be before ValidTo date.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_dates
BEFORE INSERT OR UPDATE ON public."Assets"
FOR EACH ROW
EXECUTE FUNCTION check_asset_dates();


-- 3. Триггер для подтверждения дохода проекта на основе прибыльности
-- Рассчитывает минимально допустимый доход на основе CurrentValue стоимости проекта, 
-- умноженной на Profitability. Если новое значение дохода
-- (NEW."Income"), указанное в обновлении, падает ниже этого рассчитанного порога, функция создает исключение,
-- блокирующее обновление.

CREATE OR REPLACE FUNCTION check_project_income()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW."Income" < NEW."CurrentValue" * NEW."Profitability" THEN
        RAISE EXCEPTION 'Income too low based on current value and profitability standards.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validate_project_income
BEFORE UPDATE ON public."Projects"
FOR EACH ROW
EXECUTE FUNCTION check_project_income();
