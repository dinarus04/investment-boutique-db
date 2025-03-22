import pytest
import psycopg2
from psycopg2.extras import RealDictCursor


@pytest.fixture
def db_conn(request):
    conn = psycopg2.connect(host=5433, dbname="invest_boutique", user="testuser", password="12345")
    yield conn
    conn.close()


def fetch_all(cursor):
    cursor.execute()
    return cursor.fetchall()


def test_transactions_over_1000_rub(db_conn):
    with db_conn.cursor(cursor_factory=RealDictCursor) as cursor:
        cursor.execute("""
            SELECT t."TransactionID", t."Date", t."Amount"
            FROM "Transactions" t
            WHERE t."Amount" > 1000;
        """)
        results = cursor.fetchall()
        assert all(item['Amount'] > 1000 for item in results)


def test_projects_invested_more_than_five_times(db_conn):
    with db_conn.cursor(cursor_factory=RealDictCursor) as cursor:
        cursor.execute("""
            SELECT p."ProjectID", p."Name"
            FROM "Projects" p
            JOIN "TransactionItems" ti ON p."ProjectID" = ti."ProjectID"
            GROUP BY p."ProjectID", p."Name"
            HAVING COUNT(ti."TransactionItemID") > 5;
        """)
        results = cursor.fetchall()
        assert all('ProjectID' in item for item in results)


def test_transactions_within_one_portfolio(db_conn):
    with db_conn.cursor(cursor_factory=RealDictCursor) as cursor:
        cursor.execute("""
            SELECT t."TransactionID", t."Date", t."Amount"
            FROM "Transactions" t
            JOIN "InvestPortfolios" ip ON t."PortfolioID" = ip."PortfolioID"
            WHERE ip."PortfolioID" = 1
            ORDER BY t."Date";
        """)
        results = cursor.fetchall()
        assert len(results) >= 1  # Assuming there is at least one transaction for portfolio 1


def test_average_investment_per_client(db_conn):
    with db_conn.cursor(cursor_factory=RealDictCursor) as cursor:
        cursor.execute("""
            SELECT c."FullName", AVG(t."Amount") as "AverageInvestment"
            FROM "Clients" c
            JOIN "Accounts" a ON c."ClientID" = a."ClientID"
            JOIN "Transactions" t ON a."AccountID" = t."AccountID"
            JOIN "TransactionItems" ti ON t."TransactionID" = ti."TransactionID"
            JOIN "Projects" p ON ti."ProjectID" = p."ProjectID"
            GROUP BY c."ClientID";
        """)
        results = cursor.fetchall()
        assert all('AverageInvestment' in item for item in results)


def test_top_five_projects_by_investment(db_conn):
    with db_conn.cursor(cursor_factory=RealDictCursor) as cursor:
        cursor.execute("""
            SELECT p."ProjectID", p."Name", SUM(t."Amount") as "TotalInvestment"
            FROM "Projects" p
            JOIN "TransactionItems" ti ON p."ProjectID" = ti."ProjectID"
            JOIN "Transactions" t ON ti."TransactionID" = t."TransactionID"
            GROUP BY p."ProjectID", p."Name"
            ORDER BY "TotalInvestment" DESC
            LIMIT 5;
        """)
        results = cursor.fetchall()
        assert len(results) <= 5
        if len(results) > 0:
            # Assert that the list is in descending order
            assert all(results[i]['TotalInvestment'] >= results[i+1]['TotalInvestment']
                       for i in range(len(results)-1))


def test_clients_who_have_not_invested(db_conn):
    with db_conn.cursor(cursor_factory=RealDictCursor) as cursor:
        cursor.execute("""
            SELECT c."ClientID", c."FullName"
            FROM "Clients" c
            WHERE NOT EXISTS (
              SELECT 1
              FROM "Accounts" a
              JOIN "Transactions" t ON a."AccountID" = t."AccountID"
              JOIN "TransactionItems" ti ON t."TransactionID" = ti."TransactionID"
              WHERE c."ClientID" = a."ClientID"
            )
            ORDER BY c."ClientID";
        """)
        results = cursor.fetchall()
        assert all('ClientID' in item for item in results)  # Verify each row has a ClientID


def test_portfolios_over_100000_rub(db_conn):
    with db_conn.cursor(cursor_factory=RealDictCursor) as cursor:
        cursor.execute("""
            SELECT ip."PortfolioID", SUM(ti."Quantity" * ti."UnitPrice") as "TotalCost"
            FROM "InvestPortfolios" ip
            JOIN "Transactions" t ON ip."PortfolioID" = t."PortfolioID"
            JOIN "TransactionItems" ti ON t."TransactionID" = ti."TransactionID"
            GROUP BY ip."PortfolioID"
            HAVING SUM(ti."Quantity" * ti."UnitPrice") > 100000
            ORDER BY ip."PortfolioID";
        """)
        results = cursor.fetchall()
        assert all(item['TotalCost'] > 100000 for item in results)


def test_transactions_last_three_years(db_conn):
    with db_conn.cursor(cursor_factory=RealDictCursor) as cursor:
        cursor.execute("""
            SELECT t."TransactionID", t."Date", t."Amount"
            FROM "Transactions" t
            WHERE t."Date" >= NOW() - INTERVAL '3 year'
            ORDER BY t."Date";
        """)
        results = cursor.fetchall()
        assert all('TransactionID' in item for item in results)  # Verify each row has a TransactionID


def test_top_three_clients_by_investment(db_conn):
    with db_conn.cursor(cursor_factory=RealDictCursor) as cursor:
        cursor.execute("""
            SELECT c."ClientID", c."FullName", SUM(t."Amount") as "TotalInvestment"
            FROM "Clients" c
            JOIN "Accounts" a ON c."ClientID" = a."ClientID"
            JOIN "Transactions" t ON a."AccountID" = t."AccountID"
            JOIN "TransactionItems" ti ON t."TransactionID" = ti."TransactionID"
            JOIN "Projects" p ON ti."ProjectID" = p."ProjectID"
            GROUP BY c."ClientID", c."FullName"
            ORDER BY "TotalInvestment" DESC
            LIMIT 3;
        """)
        results = cursor.fetchall()
        assert len(results) <= 3
        if len(results) > 1:
            assert results[0]['TotalInvestment'] >= results[1]['TotalInvestment']
            assert results[1]['TotalInvestment'] >= results[2]['TotalInvestment']


def test_average_project_profitability_per_type(db_conn):
    with db_conn.cursor(cursor_factory=RealDictCursor) as cursor:
        cursor.execute("""
            SELECT p."ProjectType", AVG(p."Profitability") as "AverageProfitability"
            FROM "Projects" p
            GROUP BY p."ProjectType";
        """)
        results = cursor.fetchall()
        assert all('AverageProfitability' in item for item in results)


def test_all_transactions_within_three_years(db_conn):
    with db_conn.cursor(cursor_factory=RealDictCursor) as cursor:
        cursor.execute("""
            SELECT t."TransactionID", t."Date", t."Amount"
            FROM "Transactions" t
            WHERE t."Date" >= NOW() - INTERVAL '3 year'
            ORDER BY t."Date";
        """)
        results = cursor.fetchall()
        assert all('TransactionID' in item for item in results)
        if len(results) > 0:
            assert results[0]['Date'] <= results[-1]['Date']  # Ensures correct order by date


def test_top_three_clients_by_total_investment(db_conn):
    with db_conn.cursor(cursor_factory=RealDictCursor) as cursor:
        cursor.execute("""
            SELECT c."ClientID", c."FullName", SUM(t."Amount") as "TotalInvestment"
            FROM "Clients" c
            JOIN "Accounts" a ON c."ClientID" = a."ClientID"
            JOIN "Transactions" t ON a."AccountID" = t."AccountID"
            JOIN "TransactionItems" ti ON t."TransactionID" = ti."TransactionID"
            JOIN "Projects" p ON ti."ProjectID" = p."ProjectID"
            GROUP BY c."ClientID", c."FullName"
            ORDER BY "TotalInvestment" DESC
            LIMIT 3;
        """)
        results = cursor.fetchall()
        assert len(results) <= 3
        if len(results) > 1:
            assert results[0]['TotalInvestment'] >= results[1]['TotalInvestment']
