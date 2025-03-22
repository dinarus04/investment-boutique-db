CREATE SCHEMA public AUTHORIZATION pg_database_owner;

CREATE TABLE public."Clients" (
	"ClientID" int4 NOT NULL,
	"FullName" varchar(255) NOT NULL,
	"PhoneNumber" varchar(20) NOT NULL,
	"TaxId" varchar(12) NOT NULL,
	CONSTRAINT "Clients_pkey" PRIMARY KEY ("ClientID"),
	CONSTRAINT clients_unique UNIQUE ("TaxId", "PhoneNumber")
);


CREATE TABLE public."Projects" (
	"ProjectID" int4 NOT NULL,
	"Name" varchar(255) NOT NULL,
	"ProjectType" varchar(50) NOT NULL,
	"Income" numeric(15, 2) NOT NULL,
	"CurrentValue" numeric(15, 2) NOT NULL,
	"Profitability" numeric(5, 2) NOT NULL,
	"AbleToInvest" bool NOT NULL,
	CONSTRAINT "Projects_pkey" PRIMARY KEY ("ProjectID")
);


CREATE TABLE public."Accounts" (
	"AccountID" int4 NOT NULL,
	"ClientID" int4 NOT NULL,
	"AccountNumber" varchar(20) NOT NULL,
	"Currency" bpchar(3) NULL,
	"ValidFrom" timestamp NOT NULL,
	"Balance" numeric(15, 2) NOT NULL,
	CONSTRAINT "Accounts_pkey" PRIMARY KEY ("AccountID"),
	CONSTRAINT accounts_unique UNIQUE ("AccountNumber"),
	CONSTRAINT "Accounts_ClientID_fkey" FOREIGN KEY ("ClientID") REFERENCES public."Clients"("ClientID")
);


CREATE TABLE public."InvestPortfolios" (
	"PortfolioID" int4 NOT NULL,
	"ClientID" int4 NOT NULL,
	"RiskProfile" varchar(100) NOT NULL,
	CONSTRAINT "InvestPortfolios_pkey" PRIMARY KEY ("PortfolioID"),
	CONSTRAINT "InvestPortfolios_ClientID_fkey" FOREIGN KEY ("ClientID") REFERENCES public."Clients"("ClientID")
);


CREATE TABLE public."Transactions" (
	"TransactionID" int4 NOT NULL,
	"AccountID" int4 NOT NULL,
	"PortfolioID" int4 NOT NULL,
	"Date" timestamp NOT NULL,
	"Amount" numeric(15, 2) NOT NULL,
	CONSTRAINT "Transactions_pkey" PRIMARY KEY ("TransactionID"),
	CONSTRAINT "Transactions_AccountID_fkey" FOREIGN KEY ("AccountID") REFERENCES public."Accounts"("AccountID"),
	CONSTRAINT "Transactions_PortfolioID_fkey" FOREIGN KEY ("PortfolioID") REFERENCES public."InvestPortfolios"("PortfolioID")
);



CREATE TABLE public."Assets" (
	"AssetID" int4 NOT NULL,
	"PortfolioID" int4 NOT NULL,
	"Name" varchar(255) NOT NULL,
	"AssetType" varchar(50) NOT NULL,
	"Value" numeric(15, 2) NOT NULL,
	"Yield" numeric(5, 2) NOT NULL,
	"ValidFrom" timestamp NOT NULL,
	"ValidTo" timestamp NOT NULL,
	CONSTRAINT "Assets_pkey" PRIMARY KEY ("AssetID"),
	CONSTRAINT "Assets_PortfolioID_fkey" FOREIGN KEY ("PortfolioID") REFERENCES public."InvestPortfolios"("PortfolioID")
);



CREATE TABLE public."TransactionItems" (
	"TransactionItemID" int4 NOT NULL,
	"TransactionID" int4 NOT NULL,
	"ProjectID" int4 NOT NULL,
	"Quantity" int4 NOT NULL,
	"UnitPrice" numeric(15, 2) NULL,
	CONSTRAINT "TransactionItems_pkey" PRIMARY KEY ("TransactionItemID"),
	CONSTRAINT "TransactionItems_ProjectID_fkey" FOREIGN KEY ("ProjectID") REFERENCES public."Projects"("ProjectID"),
	CONSTRAINT "TransactionItems_TransactionID_fkey" FOREIGN KEY ("TransactionID") REFERENCES public."Transactions"("TransactionID")
);