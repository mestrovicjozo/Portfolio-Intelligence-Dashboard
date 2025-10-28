--
-- PostgreSQL database dump
--

\restrict lhtXidmiREBekiPSXezwg8rUVHLHrWCqeMw2ASaqZ1NcMN73MzzP1XIXBXbhN4j

-- Dumped from database version 16.10
-- Dumped by pg_dump version 16.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: article_stocks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.article_stocks (
    id integer NOT NULL,
    article_id integer NOT NULL,
    stock_id integer NOT NULL
);


ALTER TABLE public.article_stocks OWNER TO postgres;

--
-- Name: article_stocks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.article_stocks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.article_stocks_id_seq OWNER TO postgres;

--
-- Name: article_stocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.article_stocks_id_seq OWNED BY public.article_stocks.id;


--
-- Name: news_articles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.news_articles (
    id integer NOT NULL,
    title character varying(500) NOT NULL,
    source character varying(100),
    url text,
    published_at timestamp with time zone,
    summary text,
    sentiment_score double precision,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.news_articles OWNER TO postgres;

--
-- Name: news_articles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.news_articles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.news_articles_id_seq OWNER TO postgres;

--
-- Name: news_articles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.news_articles_id_seq OWNED BY public.news_articles.id;


--
-- Name: portfolios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.portfolios (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(500),
    is_active boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.portfolios OWNER TO postgres;

--
-- Name: portfolios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.portfolios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.portfolios_id_seq OWNER TO postgres;

--
-- Name: portfolios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.portfolios_id_seq OWNED BY public.portfolios.id;


--
-- Name: positions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.positions (
    id integer NOT NULL,
    portfolio_id integer NOT NULL,
    stock_id integer NOT NULL,
    shares double precision NOT NULL,
    average_cost double precision NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.positions OWNER TO postgres;

--
-- Name: positions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.positions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.positions_id_seq OWNER TO postgres;

--
-- Name: positions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.positions_id_seq OWNED BY public.positions.id;


--
-- Name: stock_prices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_prices (
    id integer NOT NULL,
    stock_id integer NOT NULL,
    date date NOT NULL,
    open double precision NOT NULL,
    close double precision NOT NULL,
    high double precision NOT NULL,
    low double precision NOT NULL,
    volume integer NOT NULL
);


ALTER TABLE public.stock_prices OWNER TO postgres;

--
-- Name: stock_prices_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stock_prices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stock_prices_id_seq OWNER TO postgres;

--
-- Name: stock_prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stock_prices_id_seq OWNED BY public.stock_prices.id;


--
-- Name: stocks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stocks (
    id integer NOT NULL,
    symbol character varying(10) NOT NULL,
    name character varying(255) NOT NULL,
    sector character varying(100),
    added_at timestamp with time zone DEFAULT now(),
    logo_filename character varying(255)
);


ALTER TABLE public.stocks OWNER TO postgres;

--
-- Name: stocks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stocks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stocks_id_seq OWNER TO postgres;

--
-- Name: stocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stocks_id_seq OWNED BY public.stocks.id;


--
-- Name: article_stocks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.article_stocks ALTER COLUMN id SET DEFAULT nextval('public.article_stocks_id_seq'::regclass);


--
-- Name: news_articles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.news_articles ALTER COLUMN id SET DEFAULT nextval('public.news_articles_id_seq'::regclass);


--
-- Name: portfolios id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.portfolios ALTER COLUMN id SET DEFAULT nextval('public.portfolios_id_seq'::regclass);


--
-- Name: positions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.positions ALTER COLUMN id SET DEFAULT nextval('public.positions_id_seq'::regclass);


--
-- Name: stock_prices id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_prices ALTER COLUMN id SET DEFAULT nextval('public.stock_prices_id_seq'::regclass);


--
-- Name: stocks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stocks ALTER COLUMN id SET DEFAULT nextval('public.stocks_id_seq'::regclass);


--
-- Data for Name: article_stocks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.article_stocks (id, article_id, stock_id) FROM stdin;
26929	2121	19
26930	2122	22
26931	2123	26
26932	2124	26
26933	2125	26
26934	2126	26
26935	2127	26
26936	2128	29
26937	2129	29
26938	2130	29
26939	2131	29
26940	2132	29
26941	2133	29
26942	2134	29
26943	2135	29
26944	2136	29
26945	2137	29
26946	2138	29
26947	2139	29
26948	2140	29
26949	2141	29
26950	2142	29
26951	2143	29
26952	2144	29
26953	2145	29
26954	2146	29
26955	2147	29
26956	2148	29
26957	2149	29
26958	2150	29
26959	2151	29
26960	2152	29
26961	2153	29
26962	2154	29
26963	2155	29
26964	2156	29
26965	2157	29
26966	2158	30
26967	2159	30
26968	2160	30
26969	2161	30
26970	2162	30
26971	2163	30
26972	2164	30
26973	2165	30
\.


--
-- Data for Name: news_articles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.news_articles (id, title, source, url, published_at, summary, sentiment_score, created_at) FROM stdin;
1446	International Business Machines Corporation (IBM) Q3 2025 Earnings Call Transcript	Seeking Alpha Top Stock Ideas	https://seekingalpha.com/article/4832132-international-business-machines-corporation-ibm-q3-2025-earnings-call-transcript?source=feed_all_articles	2025-10-22 23:43:50+00	International Business Machines Corporation (IBM) Q3 2025 Earnings Call Transcript	0	2025-10-23 13:09:02.607057+00
1447	Unfortunate News for Nvidia Stock, AMD Stock, Microsoft Stock, and Oracle Stock Investors!	Motley Fool	https://www.fool.com/investing/2025/10/22/unfortunate-news-for-nvidia-stock-amd-stock-micros/?source=iedfolrf0000001	2025-10-22 21:08:27+00	The driving force behind the growth in computing demand could be hitting its peak.	-0.8	2025-10-23 13:09:02.607057+00
1448	IBM Stock Slides Despite Earnings Beat, Boost To Sales Forecast	IBD Stock Market	https://www.investors.com/news/technology/ibm-stock-q3-2025-earnings-news-ai/	2025-10-22 20:24:48+00	The tech giant offered positive commentary on AI demand.\nThe post IBM Stock Slides Despite Earnings Beat, Boost To Sales Forecast appeared first on Investor's Business Daily.	-0.25	2025-10-23 13:09:02.607057+00
1449	Meta Stock Took A Hit After Red-Hot Run. Why These Analysts Remain Bullish.	IBD Stock Market	https://www.investors.com/news/technology/meta-stock-analysts-q3-earnings-report-2025/	2025-10-21 19:00:40+00	Meta stock has pulled back from the highs it reached following second-quarter results that "blew the doors off" in July.\nThe post Meta Stock Took A Hit After Red-Hot Run. Why These Analysts Remain Bullish. appeared first on Investor's Business Daily.	0.65	2025-10-23 13:09:02.607057+00
1450	ASML Stock, Another Chip Play, Near Highs On Robust Relative Strength	IBD Stock Market	https://www.investors.com/research/asml-stock-chip-testing-emcor-eme-ase-technology-asx/	2025-10-21 14:07:21+00	ASML stock is extended from the buy zone of a base, but shares also show a second buy point. A building services stock is in a buy zone. \nThe post ASML Stock, Another Chip Play, Near Highs On Robust Relative Strength appeared first on Investor's Business Daily.	0.75	2025-10-23 13:09:02.607057+00
1451	Analyst Says Amazon.com (AMZN) Stock Rebound Coming Soon – Here’s Why	Yahoo Finance	https://finance.yahoo.com/news/analyst-says-amazon-com-amzn-125019483.html	2025-10-21 12:50:19+00	Analyst Says Amazon.com (AMZN) Stock Rebound Coming Soon – Here’s Why	0.65	2025-10-23 13:09:02.607057+00
1452	IBM Stock Near Highs With Earnings Due. Here's What Investors Are Watching.	IBD Stock Market	https://www.investors.com/news/technology/ibm-stock-ibm-q3-earnings-preview-ibm-news/	2025-10-20 16:18:37+00	IBM will report its third-quarter earnings late Wednesday, with IBM stock having recently pulled back following a breakout. \nThe post IBM Stock Near Highs With Earnings Due. Here's What Investors Are Watching. appeared first on Investor's Business Daily.	0.1	2025-10-23 13:09:02.607057+00
1453	Analyst Explains Why NVIDIA (NVDA) is Investing In Its Own Customers	Yahoo Finance	https://finance.yahoo.com/news/analyst-explains-why-nvidia-nvda-131720993.html	2025-10-20 13:17:20+00	Analyst Explains Why NVIDIA (NVDA) is Investing In Its Own Customers	0.4	2025-10-23 13:09:02.607057+00
1454	Jim Cramer Calls It 'Ironic' That IBM Slides Despite 'Most Advanced Quantum Product' As Trump-Linked Rivals IONQ, RGTI, QBTS Soar - IBM  ( NYSE:IBM ) 	Benzinga	https://www.benzinga.com/markets/equities/25/10/48377344/jim-cramer-calls-it-ironic-that-ibm-slides-despite-most-advanced-quantum-product-as-trump-linked	2025-10-23 12:22:50+00	CNBC's 'Mad Money' host Jim Cramer called the market's behavior in the quantum computing sector "ironic" on Thursday, highlighting a stark divergence between legacy giant International Business Machines Corp. ( NYSE:IBM ) and its pure-play rivals.	0.144772	2025-10-23 13:31:46.645483+00
1455	IonQ, D-Wave Quantum, Rigetti Computing Surge Over 11% Pre-Market: What's Going On? - D-Wave Quantum  ( NYSE:QBTS ) , IonQ  ( NYSE:IONQ ) 	Benzinga	https://www.benzinga.com/markets/equities/25/10/48375001/ionq-d-wave-quantum-rigetti-computing-surge-over-11-pre-market-whats-going-on	2025-10-23 10:33:12+00	Shares of IonQ Inc. ( NYSE:IONQ ) , Rigetti Computing ( NASDAQ:RGTI ) , and D-Wave Quantum ( NYSE:QBTS ) surged 13.71%, 11.67% and 15.90%, respectively, in premarket trading on Thursday, on reports that the Trump administration was exploring the possibility of acquiring stakes in U.S. quantum ...	0.179904	2025-10-23 13:31:46.645483+00
1456	First rare earths and chips, now quantum computers: Trump reportedly eyes new U.S. stakes	CNBC	https://www.cnbc.com/2025/10/23/first-rare-earths-and-chips-now-quantum-computers-trump-reportedly-eyes-new-us-stakes.html	2025-10-23 09:27:52+00	The Trump administration is reportedly in talks with several quantum-computing firms about government taking equity stakes in exchange for funding.	0.220023	2025-10-23 13:31:46.645483+00
1457	Why LendingClub Shares Are Trading Higher By Around 13%; Here Are 20 Stocks Moving Premarket - ReAlpha Tech  ( NASDAQ:AIRE ) , Amazon.com  ( NASDAQ:AMZN ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/10/48373692/why-lendingclub-shares-are-trading-higher-by-around-13-here-are-20-stocks-moving-premarket	2025-10-23 08:55:01+00	Shares of LendingClub Corp ( NYSE:LC ) rose sharply in pre-market trading after the company reported better-than-expected third-quarter financial results. LendingClub reported quarterly earnings of 37 cents per share which beat the analyst consensus estimate of 30 cents per share.	0.045814	2025-10-23 13:31:46.645483+00
1458	Trump Administration Reportedly Exploring Taking Stakes In Quantum Computing Companies- IonQ, Rigetti And D-Wave Discussing Move - Alphabet  ( NASDAQ:GOOG ) , Alphabet  ( NASDAQ:GOOGL ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48371538/trump-administration-reportedly-exploring-taking-stakes-in-quantum-computing-companies-ionq-rigetti-	2025-10-23 03:13:12+00	The Donald Trump administration is reportedly in talks with several U.S. quantum computing companies to take ownership stakes in exchange for federal funding.	0.278102	2025-10-23 13:31:46.645483+00
1459	Where Will D-Wave Quantum Stock Be in 3 Years?	Motley Fool	https://www.fool.com/investing/2025/10/22/where-will-d-wave-quantum-stock-be-in-3-years/	2025-10-23 00:15:00+00	Is this speculative industry finally ready for primetime?	0.181792	2025-10-23 13:31:46.645483+00
1460	Why D-Wave Quantum  ( QBTS )  Stock Is Getting Hammered Today - D-Wave Quantum  ( NYSE:QBTS ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/10/48361894/why-d-wave-quantum-qbts-stock-is-getting-hammered-today	2025-10-22 17:41:28+00	Shares of D-Wave Quantum Inc ( NYSE:QBTS ) are trading lower Wednesday afternoon, caught in a broader market downturn. The broader tech sector is facing headwinds from a Reuters report that the United States is considering new restrictions on exports to China involving U.S. software and ...	0.181736	2025-10-23 13:31:46.645483+00
1461	Billionaires Are Piling Into This Quantum Computing Stock That Gained Over 2,640% in the Past Year	Motley Fool	https://www.fool.com/investing/2025/10/22/billionaire-pile-into-quantum-computing-stock/	2025-10-22 08:25:00+00	When a group of billionaires buys a stock, it can be a bullish indicator.	0.22199	2025-10-23 13:31:46.645483+00
1462	IonQ, Rigetti Computing, D-Wave Quantum, and Quantum Computing Inc. Stocks Can Soar Up to 118%, According to Select Wall Street Analysts	Motley Fool	https://www.fool.com/investing/2025/10/22/ionq-rgti-qbts-qubt-soar-118-wall-street-analysts/	2025-10-22 07:51:00+00	Though high-water price targets portend additional upside in quantum computing's hottest stocks, history offers another side to the story.	0.165103	2025-10-23 13:31:46.645483+00
1463	Jim Cramer Warns 'Don't Be Fooled' Because Speculators In Gold, Quantum And Nuclear Energy Aren't Going Down 'Without A Fight' - IREN  ( NASDAQ:IREN ) , CoreWeave  ( NASDAQ:CRWV ) 	Benzinga	https://www.benzinga.com/markets/equities/25/10/48345270/jim-cramer-warns-dont-be-fooled-because-speculators-in-gold-quantum-and-nuclear-energy-arent-goi	2025-10-22 03:31:09+00	Former hedge fund manager and renowned CNBC TV host Jim Cramer is sounding the alarm on certain speculative pockets of the market, urging investors to sell into the "snapback" momentum if they haven't already done so.	0.096426	2025-10-23 13:31:46.645483+00
1464	IonQ Claims New Quantum High With 99.99% Gate Fidelity - IonQ  ( NYSE:IONQ ) 	Benzinga	https://www.benzinga.com/markets/equities/25/10/48334653/ionq-claims-new-quantum-high-with-99-99-gate-fidelity	2025-10-21 16:58:01+00	IonQ, Inc. ( IONQ ) shares traded higher on Tuesday after announcing a record-breaking technical milestone in quantum computing. The Maryland-based quantum technology claimed it achieved 99.99% two-qubit gate fidelity.	0.23584	2025-10-23 13:31:57.839508+00
1465	Smart Money Sells Quantum, Nuclear And Space Stocks; Earnings, Inflation Data Awaited - Apple  ( NASDAQ:AAPL ) 	Benzinga	https://www.benzinga.com/Opinion/25/10/48334214/smart-money-sells-quantum-nuclear-and-space-stocks-earnings-and-inflation-data-awaited	2025-10-21 16:38:41+00	Please click here for an enlarged chart of Rigetti Computing Inc ( NASDAQ:RGTI ) . This article is about the big picture, not an individual stock. The chart of RGTI stock is being used to illustrate the point. The chart shows our buy zone for quantum computing stock RGTI.	0.221617	2025-10-23 13:31:57.839508+00
1466	Here's Warren Buffett's Favorite Quantum Computing Stock  ( Hint: It's Not IonQ, D-Wave Quantum, or Rigetti Computing ) 	Motley Fool	https://www.fool.com/investing/2025/10/21/heres-warren-buffetts-favorite-quantum-computing-s/	2025-10-21 10:44:00+00	Quantum computing may not be in Buffett's wheelhouse. But he owns a stake in a quantum computing stock anyway.	0.216359	2025-10-23 13:31:57.839508+00
1467	IONQ Stock Before Q3 Earnings: Should You Buy Now or Wait?	Zacks Commentary	https://www.zacks.com/stock/news/2772502/ionq-stock-before-q3-earnings-should-you-buy-now-or-wait	2025-10-20 18:00:00+00	IonQ's 53% stock surge and bold quantum expansion set the stage for Q3 results, but high costs and valuation risks loom large.	0.175721	2025-10-23 13:31:57.839508+00
1468	Gold's Path To $10K May Start With Blow-Off Top; Market Bets On Trump-China Deal - Apple  ( NASDAQ:AAPL ) 	Benzinga	https://www.benzinga.com/Opinion/25/10/48307363/golds-path-to-usd-10k-may-start-with-blow-off-top-market-bets-on-trump-china-deal	2025-10-20 15:30:23+00	Please click here for an enlarged chart of SPDR Gold Trust ( NYSE:GLD ) . The chart shows the rapid rise in gold as gold now becomes a meme trade. The pattern shown on the chart is one of the many factors that, according to our algorithms show a high probability of a blow-off top in the ...	0.234132	2025-10-23 13:31:57.839508+00
1469	Are Quantum Computing Stocks IonQ, Rigetti Computing, and D-Wave Quantum Wall Street's Most Dangerous Investment? History Says Yes.	Motley Fool	https://www.fool.com/investing/2025/10/20/quantum-computing-stocks-ionq-rgti-qbts-dangerous/	2025-10-20 07:51:00+00	While the long-term prospects for quantum computers are bright, historical precedent is no friend of game-changing innovations in the very early stage of their expansion.	0.124475	2025-10-23 13:31:57.839508+00
1470	What Is One of the Best Quantum Computing Stocks to Buy Now?	Motley Fool	https://www.fool.com/investing/2025/10/19/one-of-the-best-quantum-computing-stocks-to-buy/	2025-10-19 14:15:00+00	It's not too late to buy one quantum computing stock that's soared over 500% in six months -- but there's a catch.	0.250242	2025-10-23 13:31:57.839508+00
1471	JPMorgan Chase Just Injected a Shot of Adrenaline into Quantum Computing Stocks	Motley Fool	https://www.fool.com/investing/2025/10/19/jpmorgan-chase-just-injected-a-shot-of-adrenaline/	2025-10-19 12:05:00+00	Quantum computing stocks have soared over the past year.	0.21216	2025-10-23 13:31:57.839508+00
1472	Quantum Stocks: Rally Fades, Rigetti & D-Wave Still Up This Week - Rigetti Computing  ( NASDAQ:RGTI ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/10/48287524/quantum-stock-tracker-early-rally-fades-rigetti-and-d-wave-still-up-on-the-week	2025-10-17 20:23:56+00	Quantum stocks pulled back on Thursday and Friday after a strong rally earlier in the week. Here's a look at what drove the early rally and the pull-back that followed. RGTI stock is climbing. See the real-time chart here.	0.17585	2025-10-23 13:31:57.839508+00
1473	QBTS Investment Check Before Q3 Earnings: Liquidity Solid Amid Risks	Zacks Commentary	https://www.zacks.com/stock/news/2771402/qbts-investment-check-before-q3-earnings-liquidity-solid-amid-risks	2025-10-17 18:00:00+00	D-Wave Quantum's liquidity looks solid ahead of Q3 earnings, but stretched valuation and ongoing losses cloud its near-term appeal.	0.189248	2025-10-23 13:31:57.839508+00
1474	Billionaire Paul Tudor Jones Just Sold All of His Palantir Shares and Is Piling Into This Quantum Computing Stock With a Massive Catalyst on the Horizon	Motley Fool	https://www.fool.com/investing/2025/10/17/billionaire-paul-tudor-jones-just-sold-all-of-his/	2025-10-17 08:52:00+00	Tudor Investment Corporation just exited its stake in Palantir and initiated a position in Rigetti Computing.	0.330346	2025-10-23 13:32:02.071471+00
1475	IonQ, Rigetti Computing, D-Wave Quantum, and Quantum Computing, Inc. Have Served Up an $875 Million Warning to Wall Street	Motley Fool	https://www.fool.com/investing/2025/10/17/ionq-rgti-qbts-qubt-875-million-warning-to-wall-st/	2025-10-17 07:51:00+00	The stock market's leading quantum computing pure-plays are giving investors a clear reason to be cautious.	0.228495	2025-10-23 13:32:02.071471+00
1476	Why D-Wave Quantum Stock Fell as Much as 11.5% on Thursday	Motley Fool	https://www.fool.com/investing/2025/10/16/why-d-wave-quantum-stock-fell-115-on-thursday/	2025-10-16 18:50:03+00	Why did D-Wave Quantum shares tumble after hitting all-time highs? The stock fell despite no bad news whatsoever. Here's why that actually makes perfect sense.	0.298027	2025-10-23 13:32:02.071471+00
1477	Is IonQ a Better Pick Than RGTI and QBTS Amid the 2025 Quantum Boom?	Zacks Commentary	https://www.zacks.com/stock/news/2770535/is-ionq-a-better-pick-than-rgti-and-qbts-amid-the-2025-quantum-boom	2025-10-16 18:00:00+00	IonQ's $2B equity raise, Oxford Ionics acquisition and rapid tech advances cement its 2025 lead in scalable quantum computing.	0.290366	2025-10-23 13:32:02.071471+00
1478	A Closer Look at D-Wave Quantum's Options Market Dynamics - D-Wave Quantum  ( NYSE:QBTS ) 	Benzinga	https://www.benzinga.com/insights/options/25/10/48255348/a-closer-look-at-d-wave-quantums-options-market-dynamics	2025-10-16 16:01:07+00	Whales with a lot of money to spend have taken a noticeably bullish stance on D-Wave Quantum. Looking at options history for D-Wave Quantum ( NYSE:QBTS ) we detected 68 trades. If we consider the specifics of each trade, it is accurate to state that 52% of the investors opened trades with ...	0.14113	2025-10-23 13:32:02.071471+00
1479	What Is One of the Best Quantum Computing Stocks to Buy Right Now?	Motley Fool	https://www.fool.com/investing/2025/10/16/what-is-one-of-the-best-quantum-computing-stocks/	2025-10-16 12:32:00+00	Is the best option really a quantum pure-play?	0.132755	2025-10-23 13:32:02.071471+00
1480	Want to Invest in Quantum Computing? 5 Stocks That Are Great Buys Right Now	Motley Fool	https://www.fool.com/investing/2025/10/16/want-to-invest-in-quantum-computing/	2025-10-16 10:03:00+00	Quantum computing is quickly becoming the hottest sector in the market.	0.281356	2025-10-23 13:32:02.071471+00
1481	Big Banks Are Leaning Into Quantum Computing Stocks -- Should Investors Follow?	Motley Fool	https://www.fool.com/investing/2025/10/16/big-banks-are-leaning-into-quantum-computing-stock/	2025-10-16 08:37:00+00	Curious whether the buzzy field of quantum computing finally deserves a spot in your portfolio? Here's what the new money signals for investors -- and how to size your bets.	0.202448	2025-10-23 13:32:02.071471+00
1482	RGTI Surges 192% in a Month: Should You Hop Onto the Rally or Wait?	Zacks Commentary	https://www.zacks.com/stock/news/2769567/rgti-surges-192-in-a-month-should-you-hop-onto-the-rally-or-wait	2025-10-15 17:50:00+00	Rigetti stock's surge highlights growing momentum from new defense contracts and global quantum partnerships, but revenue scalability remains a hurdle.	0.401962	2025-10-23 13:32:02.071471+00
1483	Powell-Triggered Stock Buying Outweighs Trump Post On Soybeans And Cooking Oil; Walmart Moves to Agentic Commerce - Apple  ( NASDAQ:AAPL ) 	Benzinga	https://www.benzinga.com/Opinion/25/10/48230173/powell-triggered-stock-buying-outweighs-trump-post-on-soybeans-and-cooking-oil-walmart-moves-to-agentic-c	2025-10-15 15:56:41+00	To gain an edge, this is what you need to know today. Please click here for an enlarged chart of SPDR S&P 500 ETF Trust ( NYSE:SPY ) which represents the benchmark stock market index S&P 500 ( SPX ) .	0.122059	2025-10-23 13:32:02.071471+00
1484	Quantum Computing Market Forecast Highlights Rapid Expansion at 41.8% CAGR Reaching $20.20 Billion by 2030	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48226689/quantum-computing-market-forecast-highlights-rapid-expansion-at-41-8-cagr-reaching-20-20-billion-b	2025-10-15 14:30:00+00	Delray Beach, FL, Oct. 15, 2025 ( GLOBE NEWSWIRE ) -- The quantum computing market is projected to reach USD 20.20 billion by 2030 from USD 3.52 billion in 2025, at a CAGR of 41.8% during the forecast period.	0.272005	2025-10-23 13:32:05.364102+00
1485	Think It's Too Late to Buy IonQ? Here's the 1 Reason Why There's Still Time	Motley Fool	https://www.fool.com/investing/2025/10/15/too-late-to-buy-ionq-heres-reason-still-time/	2025-10-15 12:00:00+00	With quantum computing in the early stages, you still have time to invest in one of the industry's top companies.	0.215605	2025-10-23 13:32:05.364102+00
1486	Beyond the Hype: 4 Monumental Risks to Quantum Computing Pure-Plays IonQ, Rigetti Computing, and D-Wave Quantum	Motley Fool	https://www.fool.com/investing/2025/10/15/4-risks-to-quantum-computing-ionq-rgti-qbts-qubt/	2025-10-15 07:06:00+00	Undeniable risk factors threaten to upend the parabolic rally in Wall Street's hottest quantum computing stocks.	0.181768	2025-10-23 13:32:05.364102+00
1487	Why D-Wave Quantum Stock Zoomed 6% Skyward on Tuesday	Motley Fool	https://www.fool.com/investing/2025/10/14/why-d-wave-quantum-stock-zoomed-6-skyward-on-tuesd/	2025-10-14 23:19:57+00	The stock earned some free publicity by receiving a high-profile mention in the media.	0.400776	2025-10-23 13:32:05.364102+00
1488	Shkreli's Quantum Shorts Are 'Pretty F***kn Far From Okay' - Rigetti Computing  ( NASDAQ:RGTI ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/10/48212626/quantum-stock-rally-leaves-shkrelis-short-pretty-fn-far-from-okay	2025-10-14 20:27:23+00	Martin Shkreli, known for his outspoken views in finance, has been shorting quantum computing stocks IonQ, Inc. ( NYSE:IONQ ) , D-Wave Quantum, Inc. ( NYSE:QBTS ) , Rigetti Computing, Inc. ( NASDAQ:RGTI ) , and Quantum Computing Inc. ( NASDAQ:QUBT ) , regularly mocking what he sees as ...	-0.238869	2025-10-23 13:32:05.364102+00
1489	Could Investing $10,000 in D-Wave Quantum Make You a Millionaire?	Motley Fool	https://www.fool.com/investing/2025/10/14/could-investing-10000-in-d-wave-quantum-make-you-a/	2025-10-14 08:42:00+00	The path to making a lot of money just might begin with investing in the hottest stock in the hottest tech space.	0.289613	2025-10-23 13:32:05.364102+00
1490	The Zacks Analyst Blog Highlights IonQ, Rigetti Computing, D-Wave Quantum and IBM	Zacks Commentary	https://www.zacks.com/stock/news/2767960/the-zacks-analyst-blog-highlights-ionq-rigetti-computing-d-wave-quantum-and-ibm	2025-10-14 08:01:00+00	Quantum computing heats up as Q3 approaches, spotlighting IONQ, RGTI, QBTS, and IBM for strategic and tech advances.	0.248713	2025-10-23 13:32:05.364102+00
1491	Is D-Wave Quantum a Millionaire-Maker Stock?	Motley Fool	https://www.fool.com/investing/2025/10/13/is-d-wave-quantum-a-millionaire-maker-stock/	2025-10-14 02:00:00+00	Quantum computing is the next big tech hype cycle.	0.197897	2025-10-23 13:32:05.364102+00
1492	Why Is D-Wave Quantum Stock Skyrocketing Today?	Motley Fool	https://www.fool.com/investing/2025/10/13/why-is-d-wave-quantum-stock-skyrocketing-today/	2025-10-13 18:08:28+00	D-Wave stock is moving higher. Here's why.	0.199014	2025-10-23 13:32:05.364102+00
1493	Investing in Quantum: IONQ, Rigetti & D-Wave Ahead of Q3 2025 Earnings	Zacks Commentary	https://www.zacks.com/stock/news/2767631/investing-in-quantum-ionq-rigetti-d-wave-ahead-of-q3-2025-earnings	2025-10-13 16:03:00+00	IONQ, RGTI, and QBTS strengthen liquidity, hit key tech milestones and expand partnerships ahead of Q3 earnings.	0.259978	2025-10-23 13:32:05.364102+00
1494	Bloom Energy, USA Rare Earth, Broadcom, Tesla And Other Big Stocks Moving Higher On Monday - Broadcom  ( NASDAQ:AVGO ) , American Battery Tech  ( NASDAQ:ABAT ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/10/48177597/bloom-energy-usa-rare-earth-broadcom-tesla-and-other-big-stocks-moving-higher-on-monday	2025-10-13 14:44:49+00	U.S. stocks were higher, with the Dow Jones index gaining around 500 points on Monday. Shares of Bloom Energy Corporation ( NYSE:BE ) rose sharply during Monday's session after the company announced a $5 billion partnership with Brookfield Asset Management Inc. ( NYSE:BAM ) to implement a ...	0.375929	2025-10-23 13:32:08.691615+00
1495	3 Quantum Computing Stocks That Could Help Make You a Fortune	Motley Fool	https://www.fool.com/investing/2025/10/13/3-quantum-computing-stocks-that-could-help-make-yo/	2025-10-13 04:05:00+00	Quantum computing is starting to become increasingly viable.	0.309519	2025-10-23 13:32:08.691615+00
1496	2 Top Stocks in Quantum Computing and Robotics That Could Soar in 2026	Motley Fool	https://www.fool.com/investing/2025/10/12/2-top-stocks-in-quantum-computing-and-robotics-tha/	2025-10-12 09:39:00+00	D-Wave Quantum and Rigetti Computing have established themselves as early movers in a disruptive opportunity.	0.152675	2025-10-23 13:32:08.691615+00
1497	2 Quantum Artificial Intelligence  ( AI )  Stocks to Watch Right Now	Motley Fool	https://www.fool.com/investing/2025/10/10/2-quantum-artificial-intelligence-ai-stocks-to-wat/	2025-10-10 23:33:00+00	The next breakout technology may be a combination of two already-emerging ones: quantum computing and generative AI.	0.176722	2025-10-23 13:32:08.691615+00
1498	Quantum Computing Stocks IonQ, Rigetti, and D-Wave Have Soared Up to 5,400% Over the Trailing Year -- but History Offers a Dire Warning	Motley Fool	https://www.fool.com/investing/2025/10/10/quantum-computing-ionq-rgti-qbts-history-warning/	2025-10-10 07:06:00+00	History has a flawless track record of foreshadowing trouble for next-big-thing technologies and innovations -- and quantum computing just made the list.	0.225307	2025-10-23 13:32:08.691615+00
1499	If You'd Invested $10,000 in D-Wave Quantum Stock  ( QBTS )  a Year Ago, Here's How Much You'd Have Today	Motley Fool	https://www.fool.com/investing/2025/10/09/if-youd-invested-10000-in-d-wave-quantum-stock-qbt/	2025-10-09 15:52:09+00	D-Wave stock has been on quite a run.	0.087456	2025-10-23 13:32:08.691615+00
1500	The Zacks Analyst Blog Highlights Rigetti Computing, D-Wave Quantum and Quantum Computing	Zacks Commentary	https://www.zacks.com/stock/news/2765518/the-zacks-analyst-blog-highlights-rigetti-computing-d-wave-quantum-and-quantum-computing	2025-10-09 13:32:00+00	Rigetti Computing secures $5.7M in orders for its 9-qubit Novera systems, signaling momentum in commercial quantum hardware.	0.276678	2025-10-23 13:32:08.691615+00
1501	Can RGTI's $5.7M Novera System Purchase Orders Signal Rising Demand?	Zacks Commentary	https://www.zacks.com/stock/news/2764811/can-rgtis-57m-novera-system-purchase-orders-signal-rising-demand	2025-10-08 16:50:00+00	Rigetti secures $5.7M in orders for its 9-qubit Novera systems, signaling growing traction in commercial quantum hardware.	0.271838	2025-10-23 13:32:08.691615+00
1502	IonQ Stock Gains on #AQ 64 Score & Expansion Moves: Upside Ahead?	Zacks Commentary	https://www.zacks.com/stock/news/2764269/ionq-stock-gains-on-aq-64-score-expansion-moves-upside-ahead	2025-10-08 12:37:00+00	IonQ's record-breaking #AQ 64 milestone, strategic acquisitions and expanding quantum ecosystem fuel optimism for its next growth phase.	0.331681	2025-10-23 13:32:08.691615+00
1503	What Is One of the Best Quantum Computing Stocks for Growth Investors?	Motley Fool	https://www.fool.com/investing/2025/10/08/one-of-the-best-quantum-computing-stocks-growth/	2025-10-08 11:05:00+00	This pure-play quantum computing company takes a unique technological approach and has been out-earning its competitors.	0.201554	2025-10-23 13:32:08.691615+00
1504	Should Schwab U.S. Mid-Cap ETF  ( SCHM )  Be on Your Investing Radar?	Zacks Commentary	https://www.zacks.com/stock/news/2774839/should-schwab-us-mid-cap-etf-schm-be-on-your-investing-radar	2025-10-23 10:20:02+00	Style Box ETF report for ...	0.205249	2025-10-23 13:32:11.830303+00
1505	Should You Buy IonQ Stock Before Nov. 5?	Motley Fool	https://www.fool.com/investing/2025/10/23/should-you-buy-ionq-stock-before-nov-5/	2025-10-23 10:00:12+00	The quantum computing company has notched exciting accomplishments in 2025.	0.045726	2025-10-23 13:32:11.830303+00
1506	2 of the Fastest-Growing Stocks on the Planet in 2026	Motley Fool	https://www.fool.com/investing/2025/10/23/fastest-growing-stocks-planet-2026-ionq-iren/	2025-10-23 08:30:00+00	These innovative tech companies are building the future.	0.17386	2025-10-23 13:32:11.830303+00
1507	IonQ, Inc.  ( IONQ )  Sees a More Significant Dip Than Broader Market: Some Facts to Know	Zacks Commentary	https://www.zacks.com/stock/news/2774652/ionq-inc-ionq-sees-a-more-significant-dip-than-broader-market-some-facts-to-know	2025-10-22 22:00:03+00	In the closing of the recent trading day, IonQ, Inc. (IONQ) stood at $55.45, denoting a -6.81% move from the preceding trading day.	0.158529	2025-10-23 13:32:11.830303+00
1508	IBM  ( IBM )  Beats Q3 Earnings and Revenue Estimates	Zacks Commentary	https://www.zacks.com/stock/news/2774541/ibm-ibm-beats-q3-earnings-and-revenue-estimates	2025-10-22 21:15:01+00	IBM (IBM) delivered earnings and revenue surprises of +8.61% and +1.43%, respectively, for the quarter ended September 2025. Do the numbers hold clues to what lies ahead for the stock?	0.173614	2025-10-23 13:32:11.830303+00
1509	Federal Funding Fuels Quantum: Big Gains for IBM, IONQ, RGTI in 2025?	Zacks Commentary	https://www.zacks.com/stock/news/2774503/federal-funding-fuels-quantum-big-gains-for-ibm-ionq-rgti-in-2025	2025-10-22 19:00:00+00	Federal funding and rising demand are propelling IBM, IonQ and Rigetti as quantum computing turns commercial in 2025.	0.22714	2025-10-23 13:32:11.830303+00
1510	IonQ Shares Are Trading Lower Monday: What's Going On? - IonQ  ( NYSE:IONQ ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/10/48317796/ionq-shares-are-trading-lower-monday-whats-going-on	2025-10-20 22:24:12+00	IonQ, Inc. ( NYSE:IONQ ) shares were trading higher Monday but have since reversed and began trading lower. The company announced the founding of Q-Alliance to establish a quantum computing hub in Lombardy, Italy.	0.319251	2025-10-23 13:32:11.830303+00
1511	Stock-Split Watch: Could IonQ Be the Next Quantum Computing Stock to Split?	Motley Fool	https://www.fool.com/investing/2025/10/20/stock-split-watch-could-ionq-be-the-next-quantum-c/	2025-10-20 20:21:00+00	Quantum computing stocks have been hot.	0.140718	2025-10-23 13:32:11.830303+00
1512	3 Top Stocks to Buy to Benefit From the AI and Quantum Computing Revolution	Motley Fool	https://www.fool.com/investing/2025/10/20/3-top-stocks-to-buy-to-benefit-from-the-ai-and-qua/	2025-10-20 15:15:00+00	AI and quantum computing could revolutionize the way business is done.	0.305256	2025-10-23 13:32:11.830303+00
1513	Why Is IonQ Stock Climbing Monday? - IonQ  ( NYSE:IONQ ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/10/48301610/ionq-partners-with-italy-to-launch-q-alliance-quantum-hub	2025-10-20 13:24:37+00	IonQ, Inc. ( NYSE:IONQ ) stock rose on Monday after the company announced its participation as a founding member of Q-Alliance. Q-Alliance is a new initiative aimed at developing a premier quantum computing hub in Lombardy, Italy.	0.292213	2025-10-23 13:32:11.830303+00
1514	Better Artificial Intelligence Stock: IonQ vs. Nvidia	Motley Fool	https://www.fool.com/investing/2025/10/20/better-artificial-intelligence-stock-ionq-vs-nvidi/	2025-10-20 09:15:00+00	These companies boast technologies ideal for the next stage of AI evolution.	0.307342	2025-10-23 13:32:15.227002+00
1515	Should You Sell Nvidia Stock and Buy This Supercharged Quantum Computing Stock?	Motley Fool	https://www.fool.com/investing/2025/10/20/should-you-sell-nvidia-stock-and-buy-this-supercha/	2025-10-20 04:00:00+00	IonQ has outperformed Nvidia since the start of the AI arms race.	0.269781	2025-10-23 13:32:15.227002+00
1516	Is It Time to Sell Your Quantum Computing Stocks? Warren Buffett Has Some Great Advice for You	Motley Fool	https://www.fool.com/investing/2025/10/19/is-it-time-to-sell-your-quantum-computing-stocks-w/	2025-10-19 19:00:00+00	Quantum computing stocks have risen dramatically over the past few weeks.	0.154415	2025-10-23 13:32:15.227002+00
1517	Amazon Is Backing This Genius Quantum Computing Leader	Motley Fool	https://www.fool.com/investing/2025/10/19/amazon-is-backing-this-genius-quantum-computing-le/	2025-10-19 09:42:00+00	Seeing which company a big tech player is investing in is a wise move by investors.	0.163301	2025-10-23 13:32:15.227002+00
1518	IonQ: Is It Too Late to Buy After Its 1,200% Gain?	Motley Fool	https://www.fool.com/investing/2025/10/18/ionq-is-it-too-late-to-buy-after-its-1200-gain/	2025-10-18 13:15:00+00	Investors have identified IonQ as a potential winner of the quantum computing boom.	0.04321	2025-10-23 13:32:15.227002+00
1519	3 Top Quantum Computing Stocks to Buy in 2025	Motley Fool	https://www.fool.com/investing/2025/10/17/3-top-quantum-computing-stocks-to-buy-in-2025/	2025-10-17 12:00:00+00	These companies are making significant strides in their respective areas of the quantum computing market.	0.247521	2025-10-23 13:32:15.227002+00
1520	2 Tech Stocks That Could Go Parabolic	Motley Fool	https://www.fool.com/investing/2025/10/16/2-tech-stocks-that-could-go-parabolic/	2025-10-16 19:10:00+00	IonQ and Applied Digital both have big potential upside.	0.155645	2025-10-23 13:32:15.227002+00
1521	Can Rigetti's 264% Year-to-Date Rally Hold as Quantum Race Heats Up?	Zacks Commentary	https://www.zacks.com/stock/news/2770494/can-rigettis-264-year-to-date-rally-hold-as-quantum-race-heats-up	2025-10-16 17:07:00+00	RGTI's 264% surge reflects fresh momentum from new contracts, global collaborations, and scalable chiplet tech, but can the rally last?	0.411325	2025-10-23 13:32:15.227002+00
1522	Great News for IonQ Stock, Rigetti Stock, and Quantum Computing Stock Investors	Motley Fool	https://www.fool.com/investing/2025/10/16/great-news-for-ionq-stock-rigetti-stock-and-quantu/	2025-10-16 09:00:00+00	The quantum computing industry might still be in its infancy, but it is innovating rapidly.	-0.213794	2025-10-23 13:32:15.227002+00
1523	The Zacks Analyst Blog Highlights Amazon, Microsoft, IonQ, Google, IBM	Zacks Commentary	https://www.zacks.com/stock/news/2769796/the-zacks-analyst-blog-highlights-amazon-microsoft-ionq-google-ibm	2025-10-16 07:35:00+00	Zacks highlights Amazon, Microsoft, IonQ, Google, and IBM as key beneficiaries of rising quantum computing investments fueled by renewed U.S. government support and global funding momentum.	0.345676	2025-10-23 13:32:15.227002+00
1524	IonQ, Inc.  ( IONQ )  Stock Drops Despite Market Gains: Important Facts to Note	Zacks Commentary	https://www.zacks.com/stock/news/2769659/ionq-inc-ionq-stock-drops-despite-market-gains-important-facts-to-note	2025-10-15 21:50:05+00	In the closing of the recent trading day, IonQ, Inc. (IONQ) stood at $72.41, denoting a -6.63% move from the preceding trading day.	0.230643	2025-10-23 13:32:18.533061+00
1525	Trump Era Funding Boosts Quantum: AMZN, MSFT, IONQ Poised for Gains	Zacks Commentary	https://www.zacks.com/stock/news/2769578/trump-era-funding-boosts-quantum-amzn-msft-ionq-poised-for-gains	2025-10-15 18:00:00+00	Trump-era quantum funding plans could supercharge Amazon, Microsoft and IonQ as government and private investments accelerate commercialization.	0.347836	2025-10-23 13:32:18.533061+00
1526	Here's Why IonQ, Inc.  ( IONQ )  Fell More Than Broader Market	Zacks Commentary	https://www.zacks.com/stock/news/2768778/heres-why-ionq-inc-ionq-fell-more-than-broader-market	2025-10-14 22:00:02+00	In the latest trading session, IonQ, Inc. (IONQ) closed at $77.55, marking a -5.53% move from the previous day.	0.248706	2025-10-23 13:32:18.533061+00
1527	The Case for Small Caps: Technicals, Rates, & RS Align	Zacks Commentary	https://www.zacks.com/commentary/2768674/the-case-for-small-caps-technicals-rates-rs-align	2025-10-14 18:54:00+00	After years of lagging behind their large-cap peers, small caps are finally poised for a meaningful move higher.	0.163584	2025-10-23 13:32:18.533061+00
1528	Market Whales and Their Recent Bets on IONQ Options - IonQ  ( NYSE:IONQ ) 	Benzinga	https://www.benzinga.com/insights/options/25/10/48206199/market-whales-and-their-recent-bets-on-ionq-options	2025-10-14 17:01:25+00	Investors with a lot of money to spend have taken a bearish stance on IonQ ( NYSE:IONQ ) . We noticed this today when the trades showed up on publicly available options history that we track here at Benzinga. Whether these are institutions or just wealthy individuals, we don't know.	0.04975	2025-10-23 13:32:18.533061+00
1529	Check Point Named to Newsweek and Statista's "America's Most Reliable Companies 2026" List - Check Point Software  ( NASDAQ:CHKP ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48378123/check-point-named-to-newsweek-and-statistas-americas-most-reliable-companies-2026-list	2025-10-23 13:00:00+00	REDWOOD CITY, Calif., Oct. 23, 2025 ( GLOBE NEWSWIRE ) -- Check Point Software Technologies Ltd. ( NASDAQ:CHKP ) , a pioneer and global leader of cyber security solutions, today announced its inclusion in Newsweek and Statista's ranking of America's Most Reliable Companies 2026.	0.315198	2025-10-23 13:32:18.533061+00
1530	Entera Bio Presents Positive New Clinical Data from EB613 Phase 2 Trial Demonstrating Significant Bone Density Improvements in Early Postmenopausal Women	GlobeNewswire	https://www.globenewswire.com/news-release/2025/10/23/3172057/0/en/Entera-Bio-Presents-Positive-New-Clinical-Data-from-EB613-Phase-2-Trial-Demonstrating-Significant-Bone-Density-Improvements-in-Early-Postmenopausal-Women.html	2025-10-23 12:50:00+00	Consistency of BMD gains presented at NAMS 2025 demonstrate EB613's efficacy in both young postmenopausal women and in women 10 years ...	0.114146	2025-10-23 13:32:18.533061+00
1531	Entera Bio Presents Positive New Clinical Data from EB613 Phase 2 Trial Demonstrating Significant Bone Density Improvements in Early Postmenopausal Women - Entera Bio  ( NASDAQ:ENTX ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48377888/entera-bio-presents-positive-new-clinical-data-from-eb613-phase-2-trial-demonstrating-significant-	2025-10-23 12:50:00+00	Consistency of BMD gains presented at NAMS 2025 demonstrate EB613's efficacy in both young postmenopausal women and in women 10 years post-menopause Data further support EB613 potential as a first-in-class oral anabolic treatment option that could dramatically expand patient access to ...	0.111539	2025-10-23 13:32:18.533061+00
1532	Alibaba Unveils New AI Chatbot For ChatGPT Like AI Push - Alibaba Gr Hldgs  ( NYSE:BABA ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48377578/alibaba-unveils-new-ai-chatbot-for-chatgpt-like-ai-push	2025-10-23 12:35:29+00	Alibaba Group Holding Limited ( NYSE:BABA ) stock rose on Thursday after the company announced the launch of a new artificial intelligence chatbot assistant. The Chinese e-commerce juggernaut integrated the new chat assistant directly into its Quark app.	0.366203	2025-10-23 13:32:18.533061+00
1533	UMass Athletics Teams Up with Event Tickets Center as Official Partner of Athletics Through 2028	Benzinga	https://www.benzinga.com/pressreleases/25/10/n48377521/umass-athletics-teams-up-with-event-tickets-center-as-official-partner-of-athletics-through-2028	2025-10-23 12:30:00+00	AMHERST, Mass., Oct. 23, 2025 /PRNewswire/ -- Event Tickets Center ( ETC ) , the trusted marketplace for live event tickets that connects fans with unforgettable live experiences, and Massachusetts Athletics are thrilled to announce an exciting new partnership.	0.529863	2025-10-23 13:32:18.533061+00
1534	Legendary Reggae Artist Maxi Priest and Dancehall Superstar Sean Paul "Feel So Alive" with Level Vibes Music Launch on Intercept Music	Benzinga	https://www.benzinga.com/pressreleases/25/10/n48377013/legendary-reggae-artist-maxi-priest-and-dancehall-superstar-sean-paul-feel-so-alive-with-level-vib	2025-10-23 12:10:00+00	SAN FRANCISCO, Oct. 23, 2025 /PRNewswire/ -- Maxi Priest, one of the most celebrated reggae fusion artists of all time, is making a massive move to re-ignite world music.	0.300356	2025-10-23 13:32:21.702582+00
1535	Avantor® Announces Partnership with p-Chip Corporation to Develop Solutions for Digital Traceability of Smart Consumables - Avantor  ( NYSE:AVTR ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/n48376890/avantor-announces-partnership-with-p-chip-corporation-to-develop-solutions-for-digital-traceabilit	2025-10-23 12:05:00+00	New product line will enable secure chain-of-identity, enhanced traceability, and digital process control in pharmaceutical and clinical workflows - supporting the growing demand for individualized therapies	0.363792	2025-10-23 13:32:21.702582+00
1536	Jacobs Expanding Services to Strengthen and Modernize Alaska's Vital Maritime Infrastructure Hub - Jacobs Solutions  ( NYSE:J ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/n48376295/jacobs-expanding-services-to-strengthen-and-modernize-alaskas-vital-maritime-infrastructure-hub	2025-10-23 11:45:00+00	Resiliency focus to secure state's long-term supply chain needs	0.082081	2025-10-23 13:32:21.702582+00
1537	Utility ETFs in the Spotlight as Q3 Earnings Season Kicks Off	Zacks Commentary	https://www.zacks.com/stock/news/2774892/utility-etfs-in-the-spotlight-as-q3-earnings-season-kicks-off	2025-10-23 11:45:00+00	AI-driven power demand and solid Q3 earnings from utilities like FE put ETFs such as XLU, VPU and IDU in focus.	0.17939	2025-10-23 13:32:21.702582+00
1538	Little Tikes® and Hasbro Bring PEPPA PIG to Life with New Storytelling and Playtime Collection Just in Time for Holiday Gift-Giving	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48376022/little-tikes-and-hasbro-bring-peppa-pig-to-life-with-new-storytelling-and-playtime-collection-just	2025-10-23 11:17:00+00	LOS ANGELES, Oct. 23, 2025 ( GLOBE NEWSWIRE ) -- Nearly 60 year old legacy brand The Little Tikes Company, a wholly-owned subsidiary of MGA Entertainment ( MGA ) , and Hasbro, a leading games, IP and toy company, are teaming up to bring PEPPA PIG from the screen into kids' homes this holiday ...	0.443584	2025-10-23 13:32:21.702582+00
1539	2 No-Brainer Nuclear Energy Stocks to Buy With $2,000 Right Now	Motley Fool	https://www.fool.com/investing/2025/10/23/2-no-brainer-nuclear-energy-stocks-to-buy-now/	2025-10-23 11:02:00+00	Buy this monster stock and ETF to ride the Trump and AI-driven nuclear energy boom.	0.386596	2025-10-23 13:32:21.702582+00
1540	Creator Television® Launches On-Demand Offerings on Plex and Xumo Play - Sabio Holdings  ( OTC:SABOF ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/n48375518/creator-television-launches-on-demand-offerings-on-plex-and-xumo-play	2025-10-23 11:00:00+00	TORONTO, Oct. 23, 2025 /PRNewswire/ -- Sabio Holdings ( TSXV:SBIO ) ( OTCQB:SABOF ) ( the "Company" or "Sabio" ) , a Los Angeles-based ad-tech company specializing in helping top global brands reach, engage, and validate ( R.E.V. ) streaming TV audiences, today announced its owned and operated ...	0.373631	2025-10-23 13:32:21.702582+00
1541	ScaleReady Announces multiple G-Rex® Grants have been awarded to leading investigators at Children's National Hospital - Bio-Techne  ( NASDAQ:TECH ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/n48375510/scaleready-announces-multiple-g-rex-grants-have-been-awarded-to-leading-investigators-at-childrens	2025-10-23 11:00:00+00	ST. PAUL, Minn., Oct. 23, 2025 /PRNewswire/ -- ScaleReady, in collaboration with Wilson Wolf Manufacturing, Bio-Techne Corporation ( NASDAQ:TECH ) and CellReady, announced four G-Rex Grants have been awarded to faculty members at Children's National Hospital.	0.397649	2025-10-23 13:32:21.702582+00
1542	TLX250-CDx  ( Zircaix )  Included in Leading International Guidelines for Renal Imaging - Telix Pharmaceuticals  ( NASDAQ:TLX ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48375461/tlx250-cdx-zircaix-included-in-leading-international-guidelines-for-renal-imaging	2025-10-23 11:00:00+00	MELBOURNE, Australia and INDIANAPOLIS, Oct. 23, 2025 ( GLOBE NEWSWIRE ) -- Telix Pharmaceuticals Limited ( ASX: TLX, NASDAQ:TLX, "Telix" ) today welcomes updated guidelines from the Society of Nuclear Medicine and Molecular Imaging ( SNMMI ) , the European Association of Nuclear Medicine ( EANM ...	0.164387	2025-10-23 13:32:21.702582+00
1543	What Lies Ahead for Mag-7 ETFs in Q3 Earnings Season?	Zacks Commentary	https://www.zacks.com/stock/news/2774835/what-lies-ahead-for-mag-7-etfs-in-q3-earnings-season	2025-10-23 10:23:00+00	Mag-7 earnings season heats up. Will AAPL, MSFT, NVDA, AMZN & META lift ETFs like MAGS, FNGS, MGK & XLG? Find out what's next for these market movers.	0.171994	2025-10-23 13:32:21.702582+00
1544	CoreWeave's Next Act: Where the Growth Will Come From	Motley Fool	https://www.fool.com/investing/2025/10/23/coreweaves-next-act-where-the-growth-will-come/	2025-10-23 10:00:00+00	CoreWeave is evolving into a full-stack artificial intelligence (AI) infrastructure company, and it's not stopping anytime soon.	0.256786	2025-10-23 13:32:24.775357+00
1545	David Altmejd. Agora: An Assembly of Fabulous Creatures at Galerie de l'UQAM	Benzinga	https://www.benzinga.com/pressreleases/25/10/n48374335/david-altmejd-agora-an-assembly-of-fabulous-creatures-at-galerie-de-luqam	2025-10-23 10:00:00+00	Curator: Louise DéryDates: November 7, 2025 - January 17, 2026Opening: Thursday, November 6, 2025, 5:30 p.m. MONTREAL, Oct. 23, 2025 /CNW/ - This fall, Galerie de l'UQAM invites visitors to the highly-anticipated exhibition by UQAM alumnus David Altmejd.	0.218284	2025-10-23 13:32:24.775357+00
1546	GEN Korean BBQ Expands Ready-to-Cook Line to 600 Grocery Stores With the Addition of 300 Safeway Grocery Stores	GlobeNewswire	https://www.globenewswire.com/news-release/2025/10/23/3171830/0/en/GEN-Korean-BBQ-Expands-Ready-to-Cook-Line-to-600-Grocery-Stores-With-the-Addition-of-300-Safeway-Grocery-Stores.html	2025-10-23 10:00:00+00	CERRITOS, Calif., Oct. 23, 2025 ( GLOBE NEWSWIRE ) -- GEN, the innovative leader in Korean BBQ dining and ready-to-cook meal consumer packaged goods ( "CPG" ) solutions, proudly announces another major expansion of its grocery retail footprint through a new partnership with 300 Safeway stores, ...	0.304	2025-10-23 13:32:24.775357+00
1547	Is the Vanguard S&P 500 ETF a Buy?	Motley Fool	https://www.fool.com/investing/2025/10/23/is-the-vanguard-sp-500-etf-a-buy/	2025-10-23 09:30:00+00	This $1.41 trillion index fund has morphed into a concentrated tech play trading at a premium valuation.	0.174785	2025-10-23 13:32:24.775357+00
1548	3 Epic Artificial Intelligence  ( AI )  Stocks to Load Up on Before 2026 Arrives	Motley Fool	https://www.fool.com/investing/2025/10/23/3-epic-artificial-intelligence-ai-stocks-to-load-u/	2025-10-23 09:15:00+00	2026 is right around the corner, it's time to start planning accordingly.	0.276802	2025-10-23 13:32:24.775357+00
1549	RSM US and RSM UK Decisively Approve Transatlantic Partnership	Benzinga	https://www.benzinga.com/pressreleases/25/10/n48373724/rsm-us-and-rsm-uk-decisively-approve-transatlantic-partnership	2025-10-23 09:00:00+00	Near-unanimous vote paves way for partner-owned future with enhanced reach and resources to serve global clients Creates scalable multinational platform with aggregate annual revenue of $5 billion ( USD )	0.349777	2025-10-23 13:32:24.775357+00
1550	Share Buyback Transaction Details October 16 - October 22, 2025	GlobeNewswire	https://www.globenewswire.com/news-release/2025/10/23/3171738/0/en/Share-Buyback-Transaction-Details-October-16-October-22-2025.html	2025-10-23 08:00:00+00	PRESS RELEASE ...	0.170913	2025-10-23 13:32:24.775357+00
1551	argenx to Report Third Quarter 2025 Financial Results and Business Update on October 30, 2025 - argenx  ( NASDAQ:ARGX ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48372119/argenx-to-report-third-quarter-2025-financial-results-and-business-update-on-october-30-2025	2025-10-23 05:00:00+00	October 23, 2025 Amsterdam, the Netherlands - argenx ( ( Euronext &, NASDAQ:ARGX ) , a global immunology company committed to improving the lives of people suffering from severe autoimmune diseases, today announced that it will host a conference call and audio webcast on Thursday, October 30, ...	0.178739	2025-10-23 13:32:24.775357+00
1552	ROSEN, A LEADING INVESTOR RIGHTS LAW FIRM, Encourages Jasper Therapeutics, Inc. Investors to Secure Counsel Before Important Deadline in Securities Class Action - JSPR - Jasper Therapeutics  ( NASDAQ:JSPR ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48371535/rosen-a-leading-investor-rights-law-firm-encourages-jasper-therapeutics-inc-investors-to-secure-co	2025-10-23 03:11:00+00	NEW YORK, Oct. 22, 2025 ( GLOBE NEWSWIRE ) -- WHY: Rosen Law Firm, a global investor rights law firm, reminds purchasers of securities of Jasper Therapeutics, Inc. ( NASDAQ:JSPR ) between November 30, 2023 and July 3, 2025, both dates inclusive ( the "Class Period" ) , of the important ...	0.117776	2025-10-23 13:32:24.775357+00
1553	ROSEN, NATIONALLY REGARDED INVESTOR COUNSEL, Encourages Sina Corporation Investors to Secure Counsel Before Important Deadline in Securities Class Action - SINA	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48371184/rosen-nationally-regarded-investor-counsel-encourages-sina-corporation-investors-to-secure-counsel	2025-10-23 01:45:38+00	NEW YORK, Oct. 22, 2025 ( GLOBE NEWSWIRE ) --	0.205005	2025-10-23 13:32:24.775357+00
1554	ROSEN, A RESPECTED AND LEADING FIRM, Encourages Cepton, Inc. Investors to Secure Counsel Before Important Deadline in Securities Class Action - CPTN	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48371004/rosen-a-respected-and-leading-firm-encourages-cepton-inc-investors-to-secure-counsel-before-import	2025-10-23 01:36:36+00	NEW YORK, Oct. 22, 2025 ( GLOBE NEWSWIRE ) -- WHY: Rosen Law Firm, a global investor rights law firm, reminds purchasers or sellers of common stock of Cepton, Inc. ( NASDAQ:CPTN ) between July 29, 2024 and January 6, 2025, both dates inclusive ( the "Class Period" ) , of the important ...	0.107608	2025-10-23 13:32:27.918815+00
1582	The Meme ETF is back. Is it late to the party again?	CNBC	https://www.cnbc.com/2025/10/08/the-meme-etf-is-back-is-it-late-to-the-party-again.html	2025-10-08 19:06:53+00	In its first go around, the ETF's launch coincided with the Nasdaq Composite's peak.	0.004784	2025-10-23 13:32:34.887737+00
1555	ROSEN, NATIONAL TRIAL COUNSEL, Encourages Cytokinetics, Inc. Investors to Secure Counsel Before Important Deadline in Securities Class Action - CYTK - Cytokinetics  ( NASDAQ:CYTK ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48371002/rosen-national-trial-counsel-encourages-cytokinetics-inc-investors-to-secure-counsel-before-import	2025-10-23 01:32:02+00	NEW YORK, Oct. 22, 2025 ( GLOBE NEWSWIRE ) -- WHY: Rosen Law Firm, a global investor rights law firm, reminds purchasers of common stock of Cytokinetics, Inc. ( NASDAQ:CYTK ) between December 27, 2023 and May 6, 2025, both dates inclusive ( the "Class Period" ) , of the important November 17, ...	0.114569	2025-10-23 13:32:27.918815+00
1556	DOW DEADLINE: ROSEN, A GLOBAL AND LEADING LAW FIRM, Encourages Dow Inc. Investors to Secure Counsel Before Important October 28 Deadline in Securities Class Action - DOW - Dow  ( NYSE:DOW ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48370970/dow-deadline-rosen-a-global-and-leading-law-firm-encourages-dow-inc-investors-to-secure-counsel-be	2025-10-23 01:21:37+00	NEW YORK, Oct. 22, 2025 ( GLOBE NEWSWIRE ) -- WHY: Rosen Law Firm, a global investor rights law firm, reminds purchasers of securities of Dow Inc. ( NYSE:DOW ) between January 30, 2025 and July 23, 2025, both dates inclusive ( the "Class Period" ) , of the important October 28, 2025 lead ...	0.132059	2025-10-23 13:32:27.918815+00
1557	ROSEN, A TOP-RANKED INVESTOR RIGHTS COUNSEL, Encourages V.F. Corporation Investors to Secure Counsel Before Important Deadline in Securities Fraud Lawsuit - VFC - VF  ( NYSE:VFC ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48370805/rosen-a-top-ranked-investor-rights-counsel-encourages-v-f-corporation-investors-to-secure-counsel-	2025-10-23 00:44:52+00	NEW YORK, Oct. 22, 2025 ( GLOBE NEWSWIRE ) -- WHY: Rosen Law Firm, a global investor rights law firm, reminds purchasers of securities of V.F. Corporation ( NYSE:VFC ) between October 30, 2023 and May 20, 2025, both dates inclusive ( the "Class Period" ) , of the important November 12, 2025 ...	0.18731	2025-10-23 13:32:27.918815+00
1558	JEFFERIES INVESTIGATION ALERT: Bragar Eagel & Squire, P.C. Continues Investigation into Jefferies Financial Group Inc. on Behalf of Jefferies Stockholders and Encourages Investors to Contact the Firm - Jefferies Financial Gr  ( NYSE:JEF ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48369269/jefferies-investigation-alert-bragar-eagel-squire-p-c-continues-investigation-into-jefferies-finan	2025-10-22 21:48:00+00	Bragar Eagel & Squire, P.C. Litigation Partner Brandon Walker Encourages Investors Who Suffered Losses In Jefferies ( JEF ) To Contact Him Directly To Discuss Their Options Click here to participate in the action. NEW YORK, Oct. 22, 2025 ( GLOBE NEWSWIRE ) --	-0.036089	2025-10-23 13:32:27.918815+00
1559	BRUNELLO CUCINELLI INVESTIGATION REMINDER: Bragar Eagel & Squire, P.C. Continues Investigation into Brunello Cucinelli S.p.A. on Behalf of Stockholders and Encourages Investors to Contact the Firm - Brunello Cucinelli  ( OTC:BCUCY ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48369260/brunello-cucinelli-investigation-reminder-bragar-eagel-squire-p-c-continues-investigation-into-bru	2025-10-22 21:46:00+00	Bragar Eagel & Squire, P.C. Litigation Partner Brandon Walker Encourages Investors Who Suffered Losses In Brunello Cucinelli ( BCUCY ) To Contact Him Directly To Discuss Their Options Click here to participate in the action. NEW YORK, Oct. 22, 2025 ( GLOBE NEWSWIRE ) --	-0.091302	2025-10-23 13:32:27.918815+00
1560	STRIDE INVESTIGATION REMINDER: Bragar Eagel & Squire, P.C. Continues Investigating Stride, Inc. on Behalf of Stride Stockholders and Encourages Investors to Contact the Firm - Stride  ( NYSE:LRN ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48369238/stride-investigation-reminder-bragar-eagel-squire-p-c-continues-investigating-stride-inc-on-behalf	2025-10-22 21:43:00+00	Bragar Eagel & Squire, P.C. Litigation Partner Brandon Walker Encourages Investors Who Suffered Losses In Stride ( LRN ) To Contact Him Directly To Discuss Their Options Click here to participate in the action. NEW YORK, Oct. 22, 2025 ( GLOBE NEWSWIRE ) --	-0.122767	2025-10-23 13:32:27.918815+00
1561	CAR-MART INVESTIGATION ALERT: Bragar Eagel & Squire, P.C. Continues Investigating America's Car-Mart, Inc. and Urges Investors to Contact the Firm Regarding their Rights - America's Car-Mart  ( NASDAQ:CRMT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48369093/car-mart-investigation-alert-bragar-eagel-squire-p-c-continues-investigating-americas-car-mart-inc	2025-10-22 21:40:00+00	Bragar Eagel & Squire, P.C. Litigation Partner Brandon Walker Encourages Investors Who Suffered Losses In Car-Mart ( CRMT ) To Contact Him Directly To Discuss Their Options Click here to participate in the action. NEW YORK, Oct. 22, 2025 ( GLOBE NEWSWIRE ) --	-0.069399	2025-10-23 13:32:27.918815+00
1562	FIREFLY AEROSPACE INVESTIGATION REMINDER: Bragar Eagel & Squire, P.C. Urges FLY Investors to Contact the Firm Regarding the Ongoing Investigation - Firefly Aerospace  ( NASDAQ:FLY ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48369076/firefly-aerospace-investigation-reminder-bragar-eagel-squire-p-c-urges-fly-investors-to-contact-th	2025-10-22 21:37:00+00	Bragar Eagel & Squire, P.C. Litigation Partner Brandon Walker Encourages Investors Who Suffered Losses In Firefly ( FLY ) To Contact Him Directly To Discuss Their Options Click here to participate in the action. NEW YORK, Oct. 22, 2025 ( GLOBE NEWSWIRE ) --	0.012092	2025-10-23 13:32:27.918815+00
1563	StorageVault Reports 2025 Third Quarter Results and Increases Dividend	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48369075/storagevault-reports-2025-third-quarter-results-and-increases-dividend	2025-10-22 21:35:46+00	TORONTO, Oct. 22, 2025 ( GLOBE NEWSWIRE ) -- STORAGEVAULT CANADA INC. ( "StorageVault" or the "Corporation" ) ( SVI-TSX ) reported the Corporation's 2025 third quarter results and increases dividend. Iqbal Khan, Chief Financial Officer, commented:	0.233713	2025-10-23 13:32:27.918815+00
1564	SYNOPSYS INVESTIGATION ALERT: Bragar Eagel & Squire, P.C. Reminds Synopsys Investors to Contact the Firm Regarding the Ongoing Investigation on Behalf of Stockholders - Synopsys  ( NASDAQ:SNPS ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48369044/synopsys-investigation-alert-bragar-eagel-squire-p-c-reminds-synopsys-investors-to-contact-the-fir	2025-10-22 21:34:00+00	Bragar Eagel & Squire, P.C. Litigation Partner Brandon Walker Encourages Investors Who Suffered Losses In Synopsys ( SNPS ) To Contact Him Directly To Discuss Their Options	0.00967	2025-10-23 13:32:31.196664+00
1565	COTY INVESTIGATION ALERT: Bragar Eagel & Squire, P.C Encourages Coty Investors to Contact the Firm Regarding Investigation - Coty  ( NYSE:COTY ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48369019/coty-investigation-alert-bragar-eagel-squire-p-c-encourages-coty-investors-to-contact-the-firm-reg	2025-10-22 21:31:00+00	Bragar Eagel & Squire, P.C. Litigation Partner Brandon Walker Encourages Investors Who Suffered Losses In Coty ( COTY ) To Contact Him Directly To Discuss Their Options Click here to participate in the action. NEW YORK, Oct. 22, 2025 ( GLOBE NEWSWIRE ) --	-0.021946	2025-10-23 13:32:31.196664+00
1566	BELLRING BRANDS INVESTIGATION REMINDER: Bragar Eagel & Squire, P.C. Urges BRBR Investors to Contact the Firm Regarding Ongoing Investigation - BellRing Brands  ( NYSE:BRBR ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48368953/bellring-brands-investigation-reminder-bragar-eagel-squire-p-c-urges-brbr-investors-to-contact-the	2025-10-22 21:27:00+00	Bragar Eagel & Squire, P.C. Litigation Partner Brandon Walker Encourages Investors Who Suffered Losses In BellRing Brands ( BRBR ) To Contact Him Directly To Discuss Their Options	0.019457	2025-10-23 13:32:31.196664+00
1567	Bragar Eagel & Squire, P.C. Reminds Investors of aTyr, Marex, Cepton, and MoonLake to Contact the Firm About their Rights in Filed Class Action Lawsuits - aTyr Pharma  ( NASDAQ:ATYR ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48368777/bragar-eagel-squire-p-c-reminds-investors-of-atyr-marex-cepton-and-moonlake-to-contact-the-firm-ab	2025-10-22 21:14:00+00	NEW YORK, Oct. 22, 2025 ( GLOBE NEWSWIRE ) -- Bragar Eagel & Squire, P.C., a nationally recognized shareholder rights law firm, reminds investors that class actions have been commenced on behalf of stockholders of aTyr Pharma, Inc. ( NASDAQ:ATYR ) , Marex Group PLC ( NASDAQ:MRX ) , Cepton, Inc. ...	-0.162884	2025-10-23 13:32:31.196664+00
1568	MOLINA CLASS ACTION ALERT: Bragar Eagel & Squire, P.C. Announces that a Class Action Lawsuit Has Been Filed Against Molina Healthcare, Inc. and Encourages Investors to Contact the Firm - Molina Healthcare  ( NYSE:MOH ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48368190/molina-class-action-alert-bragar-eagel-squire-p-c-announces-that-a-class-action-lawsuit-has-been-f	2025-10-22 21:03:00+00	Bragar Eagel & Squire, P.C. Litigation Partner Brandon Walker Encourages Investors Who Suffered Losses In Molina ( MOH ) To Contact Him Directly To Discuss Their Options Click here to participate in the action. NEW YORK, Oct. 22, 2025 ( GLOBE NEWSWIRE ) --	-0.055643	2025-10-23 13:32:31.196664+00
1569	No Credit Check Loans from ASAP Finance Have Become a Lifeline for U.S. Borrowers with Bad Credit	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48367867/no-credit-check-loans-from-asap-finance-have-become-a-lifeline-for-u-s-borrowers-with-bad-credit	2025-10-22 20:49:50+00	ASAP Finance has unveiled enhanced No Credit Check Loans up to $5,000, featuring Guaranteed Approval, Flexible Repayment Options, and Same-Day Deposits convenience - even for Bad Credit clients.	0.260132	2025-10-23 13:32:31.196664+00
1570	Great American Media to Broadcast the 2025 National Christmas Tree Lighting Ceremony	Benzinga	https://www.benzinga.com/pressreleases/25/10/n48366935/great-american-media-to-broadcast-the-2025-national-christmas-tree-lighting-ceremony	2025-10-22 20:22:00+00	Special Holiday Event Will Premiere Exclusively on Great American Family on Dec. 5 and Stream on Great American Pure Flix until Jan. 31, 2026. WASHINGTON, Oct. 22, 2025 /PRNewswire/ -- Great American Media is honored to partner with the National Park Foundation ( NPF ) to bring the 2025 National ...	0.553032	2025-10-23 13:32:31.196664+00
1571	Telix Doses First Patient in SOLACE Trial for Metastatic Bone Pain - Telix Pharmaceuticals  ( NASDAQ:TLX ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48365791/telix-doses-first-patient-in-solace-trial-for-metastatic-bone-pain	2025-10-22 20:00:19+00	MELBOURNE, Australia and INDIANAPOLIS, Oct. 23, 2025 ( GLOBE NEWSWIRE ) -- Telix Pharmaceuticals Limited ( ASX: TLX, NASDAQ:TLX, "Telix" ) today announces that it has dosed the first patient in a Phase 1 clinical trial of TLX090 ( 153Samarium ( Sm ) -DOTMP ) , a therapeutic radiopharmaceutical ...	0.068118	2025-10-23 13:32:31.196664+00
1572	ROSEN, LEADING TRIAL ATTORNEYS, Encourages MoonLake Immunotherapeutics Investors to Secure Counsel Before Important Deadline in Securities Class Action - MLTX - MoonLake  ( NASDAQ:MLTX ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48365436/rosen-leading-trial-attorneys-encourages-moonlake-immunotherapeutics-investors-to-secure-counsel-b	2025-10-22 19:45:10+00	NEW YORK, Oct. 22, 2025 ( GLOBE NEWSWIRE ) -- WHY: Rosen Law Firm, a global investor rights law firm, announces the filing of a class action lawsuit on behalf of purchasers of common stock of MoonLake Immunotherapeutics ( NASDAQ:MLTX ) between March 10, 2024 and September 29, 2025, both dates ...	0.140863	2025-10-23 13:32:31.196664+00
1573	Meta's AI Shakeup: 600 Jobs Cut To Speed Up Progress - Meta Platforms  ( NASDAQ:META ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48365306/metas-ai-shakeup-600-jobs-cut-to-speed-up-progress	2025-10-22 19:41:54+00	Meta Platforms, Inc. ( NASDAQ:META ) confirmed on Wednesday that about 600 roles will be eliminated from its artificial intelligence division as part of an effort to streamline operations and become more agile. META stock is moving. See the real-time price action here.	0.07478	2025-10-23 13:32:31.196664+00
1574	ROSEN, NATIONAL INVESTOR COUNSEL, Encourages Quanex Building Products Corporation Investors to Secure Counsel Before Important Deadline in Securities Class Action - NX - Quanex Building Prods  ( NYSE:NX ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48365304/rosen-national-investor-counsel-encourages-quanex-building-products-corporation-investors-to-secur	2025-10-22 19:41:45+00	NEW YORK, Oct. 22, 2025 ( GLOBE NEWSWIRE ) -- WHY: Rosen Law Firm, a global investor rights law firm, reminds purchasers of securities of Quanex Building Products Corporation ( NYSE:NX ) between December 12, 2024 and September 5, 2025, both dates inclusive ( the "Class Period" ) , of the ...	0.138337	2025-10-23 13:32:34.887737+00
1575	It's Day 22 of the Government Shutdown. Here Are 3 Sectors and Stocks That Are Struggling	Motley Fool	https://www.fool.com/investing/2025/10/22/its-day-22-of-the-government-shutdown-here-are-3-s/	2025-10-22 19:41:12+00	The broader markets are little changed so far in October, but the same cannot be said for these lagging sectors.	0.041152	2025-10-23 13:32:34.887737+00
1576	Experience North Dakota Like a Local: Where Creative Cities Meet Legendary Landscapes	Benzinga	https://www.benzinga.com/pressreleases/25/10/n48364188/experience-north-dakota-like-a-local-where-creative-cities-meet-legendary-landscapes	2025-10-22 19:05:00+00	BISMARCK, N.D., Oct. 22, 2025 /PRNewswire/ -- From artsy downtown streets to sweeping badlands vistas, North Dakota invites travelers to discover a vibrant mix of creativity, culture, and wide-open adventure on a fall road trip.	0.309013	2025-10-23 13:32:34.887737+00
1577	Vail Mountain Unveils 2025/26 Winter Season Music Lineup Featuring 50+ Live Performances	Benzinga	https://www.benzinga.com/pressreleases/25/10/n48361756/vail-mountain-unveils-202526-winter-season-music-lineup-featuring-50-live-performances	2025-10-22 17:33:00+00	The world's premier mountain destination becomes the ultimate alpine stage Expanded après and dining options celebrate the social side of skiing Vail Mountain plans to open Nov. 14; Epic Passes still on sale	0.312924	2025-10-23 13:32:34.887737+00
1578	NETMARBLE'S BRUTAL DARK FANTASY MMORPG "RAVEN2" LAUNCHES WORLDWIDE	Benzinga	https://www.benzinga.com/pressreleases/25/10/n48361686/netmarbles-brutal-dark-fantasy-mmorpg-raven2-launches-worldwide	2025-10-22 17:30:00+00	Available Now on Mobile and PC across 150 Countries; Special In-Game Launch Events Are Now Live	0.31705	2025-10-23 13:32:34.887737+00
1579	1 No-Brainer Technology Vanguard ETF to Buy Right Now for Less Than $1,000	Motley Fool	https://www.fool.com/investing/2025/10/23/1-no-brainer-technology-vanguard-etf-to-buy-right/	2025-10-23 10:47:00+00	The Vanguard Information Technology ETF offers you a low-cost way to benefit from the booming tech sector.	0.220714	2025-10-23 13:32:34.887737+00
1580	Why QUBT Stock May Not Be a Buy Now Despite Quantum Boom	Zacks Commentary	https://www.zacks.com/stock/news/2773473/why-qubt-stock-may-not-be-a-buy-now-despite-quantum-boom	2025-10-21 19:00:00+00	QCi's quantum momentum is real, but widening losses, dilution risks and global headwinds make QUBT a cautious hold for now.	0.094467	2025-10-23 13:32:34.887737+00
1581	Why Is Quantum Computing Inc. Stock Jumping Today?	Motley Fool	https://www.fool.com/investing/2025/10/13/why-is-quantum-computing-inc-stock-jumping-today/	2025-10-13 18:56:33+00	Quantum Computing Inc. stock is moving higher. Here's why.	0.01925	2025-10-23 13:32:34.887737+00
1583	Revenue Decline and Widening Losses Raise Concerns for QUBT	Zacks Commentary	https://www.zacks.com/stock/news/2763382/revenue-decline-and-widening-losses-raise-concerns-for-qubt	2025-10-07 12:23:00+00	Quantum Computing's revenue plunge and widening losses highlight mounting financial strain, even as its photonic chip ambitions remain 12 to 18 months away from payoff.	-0.127201	2025-10-23 13:32:34.887737+00
1584	Quantum Computing  ( QUBT )  Shares Are Sliding Today: Here's Why - Quantum Computing  ( NASDAQ:QUBT ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/10/48053260/quantum-computing-qubt-shares-are-sliding-today-heres-why	2025-10-06 18:38:38+00	Quantum Computing Inc ( NASDAQ:QUBT ) shares are trading lower on Monday after the company announced a $750 million oversubscribed private placement.	0.137207	2025-10-23 13:32:38.199522+00
1585	Nasdaq Jumps Over 150 Points; Skye Bioscience Shares Plunge - Critical Metals  ( NASDAQ:CRML ) , Advanced Micro Devices  ( NASDAQ:AMD ) 	Benzinga	https://www.benzinga.com/markets/market-summary/25/10/48050881/nasdaq-jumps-over-150-points-skye-bioscience-shares-plunge	2025-10-06 17:09:01+00	U.S. stocks traded mixed midway through trading, with the Nasdaq Composite gaining more than 150 points on Monday. The Dow traded down 0.16% to 46,684.03 while the NASDAQ rose 0.71% to 22,941.69. The S&P 500 also rose, gaining, 0.40% to 6,742.80. Information technology shares jumped by 0.9% on ...	0.128427	2025-10-23 13:32:38.199522+00
1586	Why Quantum Computing Inc. Stock Was Sliding Today	Motley Fool	https://www.fool.com/investing/2025/10/06/why-quantum-computing-inc-stock-was-sliding-today/	2025-10-06 16:11:08+00	A stock sale turned off investors.	0.112182	2025-10-23 13:32:38.199522+00
1587	Why AMD Shares Are Trading Higher By Over 34%; Here Are 20 Stocks Moving Premarket - Arteris  ( NASDAQ:AIP ) , Advanced Micro Devices  ( NASDAQ:AMD ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/10/48040074/why-amd-shares-are-trading-higher-by-over-34-here-are-20-stocks-moving-premarket	2025-10-06 13:01:08+00	Shares of Advanced Micro Devices, Inc. ( NASDAQ:AMD ) rose sharply in pre-market trading following a landmark agreement with OpenAI to deploy up to 6 gigawatts of AMD Instinct GPU power for the tech giant's next-generation AI infrastructure.	0.083151	2025-10-23 13:32:38.199522+00
1588	Quantum Computing, Mesoblast And Other Big Stocks Moving Lower In Monday's Pre-Market Session - Rich Sparkle Holdings  ( NASDAQ:ANPA ) , International Paper  ( NYSE:IP ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/10/48039034/quantum-computing-mesoblast-and-other-big-stocks-moving-lower-in-mondays-pre-market-session	2025-10-06 12:09:29+00	U.S. stock futures were higher this morning, with the Dow futures gaining around 100 points on Monday. Shares of Quantum Computing Inc. ( NASDAQ:QUBT ) fell sharply in pre-market trading. Quantum Computing raised $750 million from institutional investors in market-priced private placement ...	-0.101375	2025-10-23 13:32:38.199522+00
1589	What Does the Market Think About Quantum Computing Inc? - Quantum Computing  ( NASDAQ:QUBT ) 	Benzinga	https://www.benzinga.com/insights/short-sellers/25/10/48024581/what-does-the-market-think-about-quantum-computing-inc	2025-10-03 18:01:19+00	Quantum Computing Inc's ( NYSE:QUBT ) short interest as a percent of float has risen 4.5% since its last report. According to exchange reported data, there are now 27.37 million shares sold short, which is 20.22% of all regular shares that are available for trading.	0.280582	2025-10-23 13:32:38.199522+00
1590	This Is What Whales Are Betting On Quantum Computing - Quantum Computing  ( NASDAQ:QUBT ) 	Benzinga	https://www.benzinga.com/insights/options/25/10/48022877/this-is-what-whales-are-betting-on-quantum-computing	2025-10-03 17:01:10+00	Investors with a lot of money to spend have taken a bullish stance on Quantum Computing ( NASDAQ:QUBT ) . We noticed this today when the trades showed up on publicly available options history that we track here at Benzinga. Whether these are institutions or just wealthy individuals, we don't ...	0.186606	2025-10-23 13:32:38.199522+00
1591	Trending Quantum Stocks-Rigetti And D-Wave Are Popping - Rigetti Computing  ( NASDAQ:RGTI ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/10/48019438/trending-quantum-stocks-rigetti-and-d-wave-are-popping	2025-10-03 15:13:24+00	Quantum stocks were popping on Friday after trending across social media for most of the week. Here's a look at what's going on in the quantum computing sector. RGTI stock is climbing. See the real-time chart here.	0.235249	2025-10-23 13:32:38.199522+00
1592	Was Quantum Computing Stock's News Good or Bad?	Motley Fool	https://www.fool.com/investing/2025/10/03/was-quantum-computing-stocks-news-good-or-bad/	2025-10-03 14:40:11+00	Are the same people who bought Quantum Computing stock last week selling it this week?	0.062163	2025-10-23 13:32:38.199522+00
1593	Where Will Quantum Computing Inc. Be in 1 Year?	Motley Fool	https://www.fool.com/investing/2025/10/02/where-will-quantum-computing-inc-be-in-1-year/	2025-10-02 19:29:00+00	Hope and hype could last longer than you think with this popular quantum computing play.	0.103541	2025-10-23 13:32:38.199522+00
1594	Will Rigetti's $5.8M AFRL Deal With QphoX Advance Quantum Networking?	Zacks Commentary	https://www.zacks.com/stock/news/2760737/will-rigettis-58m-afrl-deal-with-qphox-advance-quantum-networking	2025-10-02 13:40:00+00	RGTI secures a $5.8M AFRL contract with QphoX to tackle quantum networking bottlenecks and advance superconducting scalability.	0.319196	2025-10-23 13:32:41.4534+00
1595	How Quantum Computing Is Positioned to Drive Long-Term Growth	Zacks Commentary	https://www.zacks.com/stock/news/2759558/how-quantum-computing-is-positioned-to-drive-long-term-growth	2025-09-30 13:40:00+00	QUBT expands government ties, ships new products, and scales its Tempe chip foundry to drive growth.	0.29844	2025-10-23 13:32:41.4534+00
1596	Quantum Stock News: Rigetti, D-Wave, IonQ, Quantum Computing - D-Wave Quantum  ( NYSE:QBTS ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/09/47898286/quantum-stock-tracker-rigetti-d-wave-climb-on-bullish-coverage	2025-09-26 18:25:50+00	Some quantum stocks pulled back from all-time highs this week as investors rotated out of speculative names and into more defensive positions. Other quantum names maintained the upward momentum as the sector remained in the spotlight. QBTS stock is climbing. See the real-time chart here.	0.282497	2025-10-23 13:32:41.4534+00
1597	Why Quantum Computing Stock Popped, Then Dropped	Motley Fool	https://www.fool.com/investing/2025/09/26/why-quantum-computing-stock-popped-then-dropped/	2025-09-26 15:50:43+00	Quantum Computing stock has the money it needs to keep burning cash for years -- and it will.	0.300805	2025-10-23 13:32:41.4534+00
1598	Crinetics Pharmaceuticals, BlackBerry, Perpetua Resources And Other Big Stocks Moving Higher On Friday - Robo.ai  ( NASDAQ:AIIO ) , Aquestive Therapeutics  ( NASDAQ:AQST ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/09/47890720/crinetics-pharmaceuticals-blackberry-perpetua-resources-and-other-big-stocks-moving-higher-o	2025-09-26 14:23:15+00	U.S. stocks were higher, with the Dow Jones index gaining more than 200 points on Friday. Shares of Crinetics Pharmaceuticals, Inc. ( NASDAQ: CRNX ) rose sharply during Friday's session after the FDA approved PALSONIFY. Also, Baird and JMP Securities raised their respective price targets on ...	0.304205	2025-10-23 13:32:41.4534+00
1599	Could This Small-Cap Artificial Intelligence  ( AI )  Stock Become the Next Nvidia?	Motley Fool	https://www.fool.com/investing/2025/09/25/could-this-small-cap-ai-stock-become-next-nvidia/	2025-09-25 10:45:00+00	Nvidia has become one of the best-known businesses in the world thanks to the artificial intelligence revolution.	0.293884	2025-10-23 13:32:41.4534+00
1600	IONQ or QUBT: Which Quantum Stock Is the Better Investment in 2025?	Zacks Commentary	https://www.zacks.com/stock/news/2756652/ionq-or-qubt-which-quantum-stock-is-the-better-investment-in-2025	2025-09-24 19:00:00+00	IonQ's acquisitions, partnerships and space-based quantum networking give it an edge over QUBT's chip-driven momentum.	0.318383	2025-10-23 13:32:41.4534+00
1601	Powell Said Stocks 'Highly Valued' - Remember After 'Irrational Exuberance' Stock Bubble Inflated More Before Crash - Apple  ( NASDAQ:AAPL ) 	Benzinga	https://www.benzinga.com/Opinion/25/09/47844936/powell-said-stocks-highly-valued-remember-after-irrational-exuberance-stock-bubble-inflated-more-before-c	2025-09-24 15:24:59+00	To gain an edge, this is what you need to know today. Please click here for an enlarged chart of Micron Technology Inc MU. This article is about the big picture, not an individual stock. The chart of MU stock is being used to illustrate the point.	0.207283	2025-10-23 13:32:41.4534+00
1602	Micron To Test AI Rally After Nvidia-Open AI Deal Drove AI Trade Higher, Quantum Breakthrough, China Gold Move	Benzinga	https://www.benzinga.com/news/25/09/47822238/micron-to-test-ai-rally-after-nvidia-open-ai-deal-drove-ai-trade-higher-quantum-breakthrough-china-gold-move	2025-09-23 15:25:28+00	To gain an edge, this is what you need to know today. Please click here for an enlarged chart of Micron Technology Inc MU. This article is about the big picture, not an individual stock. The chart of MU stock is being used to illustrate the point. The trendline on the chart shows MU stock has ...	0.195527	2025-10-23 13:32:41.4534+00
1603	Johnson Fistel, PLLP Continues Investigation on Behalf of Quantum Computing Inc.  ( QUBT ) , Acadia Healthcare Company, Inc.  ( ACHC ) , Treace Medical Concepts, Inc.  ( TMCI ) , and BigBear.ai Holdings, Inc.  ( BBAI )  Long-Term Shareholders - Acadia Healthcare Co  ( NASDAQ:ACHC ) , BigBear.ai Hldgs  ( NYSE:BBAI ) 	Benzinga	https://www.benzinga.com/pressreleases/25/09/g47799718/johnson-fistel-pllp-continues-investigation-on-behalf-of-quantum-computing-inc-qubt-acadia-healthc	2025-09-22 17:22:59+00	SAN DIEGO, Sept. 22, 2025 ( GLOBE NEWSWIRE ) -- Johnson Fistel, PLLP is investigating potential violations of federal and state securities laws by certain officers and directors of Quantum Computing Inc. QUBT, Acadia Healthcare Company, Inc. ACHC, Treace Medical Concepts, Inc.	-0.07327	2025-10-23 13:32:41.4534+00
1604	Why Quantum Computing Inc. Stock Was Sliding Double Digits Today	Motley Fool	https://www.fool.com/investing/2025/09/22/why-quantum-computing-inc-stock-was-sliding-double/	2025-09-22 16:24:44+00	Investors balked at a follow-on offering in the hot quantum stock.	0.257262	2025-10-23 13:32:44.792639+00
1605	Why Quantum Computing  ( QUBT )  Stock Is Falling Sharply Monday - Quantum Computing  ( NASDAQ:QUBT ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/09/47795045/why-quantum-computing-qubt-stock-is-falling-sharply-monday	2025-09-22 16:19:36+00	Shares of Quantum Computing Inc QUBT are trading sharply lower Monday morning after the company's announcement of a $500 million oversubscribed private placement of common stock.	0.169049	2025-10-23 13:32:44.792639+00
1606	Gold Gains Over 1%; Quantum Computing Shares Plunge - AgriFORCE Growing Systems  ( NASDAQ:AGRI ) , Chijet Motor Co  ( NASDAQ:CJET ) 	Benzinga	https://www.benzinga.com/markets/market-summary/25/09/47793862/gold-gains-over-1-quantum-computing-shares-plunge	2025-09-22 16:06:02+00	U.S. stocks traded mostly higher midway through trading, with the Nasdaq Composite gaining over 50 points on Monday. The Dow traded up 0.01% to 46,321.12 while the NASDAQ rose 0.24% to 22,685.77. The S&P 500 also rose, gaining, 0.15% to 6,674.60. Information technology shares jumped by 0.4% on ...	0.081304	2025-10-23 13:32:44.792639+00
1607	Quantum Stocks On Fire Ahead Of Trump's Next Tech Order - Quantum Computing  ( NASDAQ:QUBT ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/09/47788546/trumps-next-tech-order-could-set-quantum-stocks-on-fire	2025-09-22 13:59:09+00	Quantum computing stocks have boomed in 2025, and a new catalyst is adding fuel to the fire: The Trump administration is looking to bolster the industry in the name of national security. QUBT stock is pulling back. See the real-time price action here.	0.286813	2025-10-23 13:32:44.792639+00
1608	QUBT Prepares for Aggressive Growth With Robust Capital Position	Zacks Commentary	https://www.zacks.com/stock/news/2754736/qubt-prepares-for-aggressive-growth-with-robust-capital-position	2025-09-22 13:32:00+00	Quantum Computing ends Q2 with $349M cash, trims liabilities, and eyes growth with hiring, foundry scaling, and quantum commercialization.	0.301364	2025-10-23 13:32:44.792639+00
1609	American Battery Technology, Quantum Computing, CEA Industries And Other Big Stocks Moving Lower In Monday's Pre-Market Session - Amer Sports  ( NYSE:AS ) , American Battery Tech  ( NASDAQ:ABAT ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/09/47785756/american-battery-technology-quantum-computing-cea-industries-and-other-big-stocks-moving-low	2025-09-22 12:18:04+00	U.S. stock futures were lower this morning, with the Dow futures falling more than 100 points on Monday. Shares of American Battery Technology Company ABAT fell sharply in pre-market trading. American Battery Technology filed for mixed shelf offering of up to $250 million.	0.004952	2025-10-23 13:32:44.792639+00
1610	Quantum Computing Stock  ( QUBT )  Declines Over 12% In Monday Pre-Market: What's Going On? - D-Wave Quantum  ( NYSE:QBTS ) , IonQ  ( NYSE:IONQ ) 	Benzinga	https://www.benzinga.com/markets/tech/25/09/47785147/quantum-computing-stock-qubt-declines-over-12-in-monday-pre-market-whats-going-on	2025-09-22 11:51:39+00	Shares of Quantum Computing Inc. QUBT fell 12.25% following the company's completion of an oversubscribed private placement, raising a substantial $500 million. QUBT has entered into securities purchase agreements with institutional investors.	0.216239	2025-10-23 13:32:44.792639+00
1611	Better Quantum Computing Stock: D-Wave Quantum  ( QBTS )  vs. Quantum Computing  ( QUBT ) 	Motley Fool	https://www.fool.com/investing/2025/09/20/better-quantum-computing-stocks-qubt-and-qbts/	2025-09-20 13:15:00+00	Quantum investing is heating up, but not all quantum computing stocks are created equal.	0.164782	2025-10-23 13:32:44.792639+00
1612	Why Quantum Computing Stock Keeps Going Up	Motley Fool	https://www.fool.com/investing/2025/09/19/why-quantum-computing-stock-keeps-going-up/	2025-09-19 14:48:25+00	Momentum traders love Quantum Computing stock. Should you?	0.218876	2025-10-23 13:32:44.792639+00
1613	CoreWeave, Barrick Mining, FedEx And Other Big Stocks Moving Higher On Friday - Barrick Mining  ( NYSE:B ) , Aquestive Therapeutics  ( NASDAQ:AQST ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/09/47763389/coreweave-barrick-mining-fedex-and-other-big-stocks-moving-higher-on-friday	2025-09-19 14:31:28+00	U.S. stocks were higher, with the Nasdaq Composite gaining more than 100 points on Friday. Shares of CoreWeave, Inc. CRWV rose sharply during Friday's session after Loop Capital initiated coverage with a Buy rating and announced a $165 price target. CoreWeave shares jumped 4.8% to $127.15 on ...	0.262896	2025-10-23 13:32:44.792639+00
1614	Can This Stock Be the New Snowflake of the Next Decade?	Motley Fool	https://www.fool.com/investing/2025/10/23/can-this-stock-be-the-new-snowflake-of-the-next/	2025-10-23 12:23:00+00	This under-the-radar AI infrastructure stock may prove to be an exceptional pick for long-term investors.	0.174723	2025-10-23 13:32:47.987927+00
1632	Prediction: These Stocks Could Be the Next Nvidia for Patient Investors	Motley Fool	https://www.fool.com/investing/2025/10/22/prediction-these-stocks-could-be-the-next-nvidia/	2025-10-22 12:30:00+00	Long-term investors can benefit from picking stakes in core artificial intelligence (AI) infrastructure players besides Nvidia.	0.283687	2025-10-23 13:32:53.273754+00
1615	Micron's Stratospheric Rally Illuminates Direxion's MUU And MUD ETFs - Advanced Micro Devices  ( NASDAQ:AMD ) , Micron Technology  ( NASDAQ:MU ) 	Benzinga	https://www.benzinga.com/etfs/specialty-etfs/25/10/48377296/microns-stratospheric-rally-illuminates-direxions-muu-and-mud-etfs	2025-10-23 12:17:18+00	Micron Technology Inc ( NASDAQ:MU ) easily ranks among the top-performing equities, gaining over 140% since the start of the year. For context, Advanced Micro Devices Inc ( NASDAQ:AMD ) - another high-flying enterprise in the advanced semiconductor space - has swung up 97% during the same frame.	0.088083	2025-10-23 13:32:47.987927+00
1616	Could This Be the Most Underrated AI Infrastructure Play of the Decade?	Motley Fool	https://www.fool.com/investing/2025/10/23/could-this-be-the-most-underrated-ai-infrastructur/	2025-10-23 11:44:00+00	Here's why Micron might not be receiving its due in the AI infrastructure world.	0.214814	2025-10-23 13:32:47.987927+00
1617	Nvidia's New Partner And Rival: Intel, AMD Witness Improving Technical Indicators Amid Solid Momentum Gains - NVIDIA  ( NASDAQ:NVDA ) 	Benzinga	https://www.benzinga.com/markets/equities/25/10/48376039/nvidias-new-partner-and-rival-intel-amd-witness-improving-technical-indicators-amid-solid-moment	2025-10-23 11:21:17+00	The semiconductor trio, which includes Nvidia Corp.'s ( NASDAQ:NVDA ) rival turned partner Intel Corp. ( INTC ) and its peer Advanced Micro Devices Inc. ( AMD ) , have been riding a wave of momentum, signaling a potential shift in the tech landscape.	0.072485	2025-10-23 13:32:47.987927+00
1618	Great News for AMD Investors: Strong Buy Rating Confirmed	Motley Fool	https://www.fool.com/investing/2025/10/23/great-news-for-amd-investors-strong-buy-rating-con/	2025-10-23 11:13:32+00	AMD and Oracle just expanded their AI partnership -- and it could be the catalyst that drives AMD stock beyond $300 faster than investors expect.	0.120404	2025-10-23 13:32:47.987927+00
1619	Prediction: This Stock Will Be the Ultimate AI Winner	Motley Fool	https://www.fool.com/investing/2025/10/23/prediction-this-stock-will-be-ultimate-ai-winner/	2025-10-23 10:57:00+00	Taiwan Semiconductor produces chips for all of the major AI hardware players.	0.342963	2025-10-23 13:32:47.987927+00
1620	Why Is Everyone Talking About Taiwan Semiconductor Stock?	Motley Fool	https://www.fool.com/investing/2025/10/23/why-is-everyone-talking-about-taiwan-semiconductor/	2025-10-23 10:15:00+00	Taiwan Semiconductor is arguably the best chip manufacturing company in the world.	-0.384956	2025-10-23 13:32:47.987927+00
1621	Nvidia's Dominance Faces New Challenge As Israeli Startup NextSilicon Develops Central Processor That Could Rival Intel, AMD - NVIDIA  ( NASDAQ:NVDA ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48373495/nvidias-dominance-faces-new-challenge-as-israeli-startup-nextsilicon-develops-central-processor-that	2025-10-23 08:27:38+00	NextSilicon, an Israeli startup, announced that it is developing a central processor aimed at challenging Intel Corp. ( NASDAQ:INTC ) and Advanced Micro Devices Inc. ( NASDAQ:AMD ) , while also positioning itself to compete with Nvidia Corp.'s ( NASDAQ:NVDA ) platforms.	0.157842	2025-10-23 13:32:47.987927+00
1622	Meet the Spectacular Vanguard ETF With 43.6% of Its Portfolio Invested in Nvidia, Apple, and Microsoft	Motley Fool	https://www.fool.com/investing/2025/10/23/meet-vanguard-etf-436-portfolio-nvidia-microsoft/	2025-10-23 08:11:00+00	Information technology is routinely the fastest-growing sector in the S&P 500.	0.177952	2025-10-23 13:32:47.987927+00
1623	Cathie Wood Bets $21 Million On Robinhood, Snaps Up Netflix, Sells These Two Hot AI Stocks - Robinhood Markets  ( NASDAQ:HOOD ) 	Benzinga	https://www.benzinga.com/etfs/broad-u-s-equity-etfs/25/10/48370867/cathie-wood-bets-21-million-on-robinhood-snaps-up-netflix-sells-these-two-hot-ai-stock	2025-10-23 01:12:39+00	On Wednesday, Cathie Wood's Ark Invest made significant trades involving Robinhood Markets Inc. ( NASDAQ:HOOD ) , Netflix Inc. ( NASDAQ:NFLX ) , Advanced Micro Devices Inc. ( NASDAQ:AMD ) , and Palantir Technologies Inc. ( NASDAQ:PLTR ) .	0.16856	2025-10-23 13:32:47.987927+00
1624	Is AMD a Buy After Investment Advisor Western Financial Initiated a Position in the Stock?	Motley Fool	https://www.fool.com/coverage/filings/2025/10/23/is-amd-a-buy-after-investment-advisor-western-financial-initiated-a-position-in-the-stock/	2025-10-23 00:59:57+00	According to a Securities and Exchange Commission ( SEC ) filing dated October 21, 2025, investment advisor Western Financial Corp/CA disclosed a new stake in Advanced Micro Devices ( NASDAQ:AMD ) . The fund purchased 25,154 shares, with an estimated transaction value of $4.07 million.	0.294029	2025-10-23 13:32:53.273754+00
1625	Advanced Micro Devices  ( AMD )  Falls More Steeply Than Broader Market: What Investors Need to Know	Zacks Commentary	https://www.zacks.com/stock/news/2774593/advanced-micro-devices-amd-falls-more-steeply-than-broader-market-what-investors-need-to-know	2025-10-22 21:45:03+00	Advanced Micro Devices (AMD) closed the most recent trading day at $230.23, moving 3.28% from the previous trading session.	0.202636	2025-10-23 13:32:53.273754+00
1626	Unfortunate News for Nvidia Stock, AMD Stock, Microsoft Stock, and Oracle Stock Investors!	Motley Fool	https://www.fool.com/investing/2025/10/22/unfortunate-news-for-nvidia-stock-amd-stock-micros/	2025-10-22 21:08:27+00	The driving force behind the growth in computing demand could be hitting its peak.	-0.16659	2025-10-23 13:32:53.273754+00
1627	Intel Q3 Preview: Nvidia, US Government Stakes Don't Change Narrative - 'Do Not Believe Valuation Is Justified' - Intel  ( NASDAQ:INTC ) 	Benzinga	https://www.benzinga.com/trading-ideas/previews/25/10/48366571/intel-q3-preview-nvidia-us-government-stakes-dont-change-narrative-do-not-believe-valuatio	2025-10-22 20:13:35+00	Intel Corporation ( NASDAQ:INTC ) has several key areas to address, including new products and growth plans, ahead of its third-quarter financial report, which is scheduled to be released on Thursday after the market closes. Here are the earnings estimates, what analysts are saying and key ...	0.296256	2025-10-23 13:32:53.273754+00
1628	Is A 'Critical Software' Ban On China Next? Trump Weighs New Sanctions - Broadcom  ( NASDAQ:AVGO ) , Advanced Micro Devices  ( NASDAQ:AMD ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48364349/is-a-critical-software-ban-on-china-next-trump-weighs-new-sanctions	2025-10-22 19:10:42+00	In a potential escalation of his trade conflict with China, President Donald Trump is exploring sanctions on a vast array of software-powered exports to Beijing. According to Reuters, the proposed plan would block global shipments of nearly any product containing or produced with U.S. software, ...	-0.00721	2025-10-23 13:32:53.273754+00
1629	After a 400%+ Surge, is Bitfarms Still Worth Buying Under $5?	Zacks Commentary	https://www.zacks.com/stock/news/2774507/after-a-400-surge-is-bitfarms-still-worth-buying-under-5	2025-10-22 19:05:00+00	BITF's 400% surge stems from a bold pivot to AI data centers and HPC, but weak fundamentals make BITF a risky bet under $5.	0.308643	2025-10-23 13:32:53.273754+00
1630	SNPS Stock Plunges 25% in 3 Months: Should You Buy, Sell or Hold?	Zacks Commentary	https://www.zacks.com/stock/news/2774283/snps-stock-plunges-25-in-3-months-should-you-buy-sell-or-hold	2025-10-22 14:43:00+00	Synopsys' AI-driven EDA push can't offset falling margins, Design IP weakness, and a stretched valuation that make the stock a sell.	0.031267	2025-10-23 13:32:53.273754+00
1631	3 "Magnificent Seven" Stock ( s )  to Buy Hand Over Fist Right Now -- Including Nvidia  ( NVDA )  Stock	Motley Fool	https://www.fool.com/investing/2025/10/22/three-magnificent-seven-stocks-to-buy-now-nvda/	2025-10-22 13:30:00+00	One of these stocks has been growing at an average annual rate of nearly 75% over the past decade.	0.347834	2025-10-23 13:32:53.273754+00
1633	Prediction: 1 AI Stock Could Be Worth More Than Nvidia and Palantir Technologies Combined by 2030	Motley Fool	https://www.fool.com/investing/2025/10/22/prediction-this-ai-stock-could-be-worth-more-than/	2025-10-22 10:30:00+00	Nvidia and Palantir have both witnessed enormous valuation expansion throughout the artificial intelligence (AI) revolution.	0.178967	2025-10-23 13:32:53.273754+00
1634	What's Going On With Taiwan Semiconductor Stock in October?	Motley Fool	https://www.fool.com/investing/2025/10/22/whats-going-on-with-taiwan-semiconductor-stock-in/	2025-10-22 09:30:00+00	The company provided an update to investors that has implications for several companies in the AI ecosystem.	-0.192517	2025-10-23 13:32:57.11533+00
1635	If I Could Only Buy and Hold a Single Stock, This Would Be It	Motley Fool	https://www.fool.com/investing/2025/10/22/if-i-could-only-buy-and-hold-a-single-stock-this/	2025-10-22 09:15:00+00	Taiwan Semiconductor is a neutral way to play the AI megatrend.	0.197079	2025-10-23 13:32:57.11533+00
1636	3 Growth Stocks to Invest $1,000 in Right Now	Motley Fool	https://www.fool.com/investing/2025/10/21/3-growth-stocks-to-invest-1000-right-now/	2025-10-21 15:03:00+00	Investors can gain exposure to leading artificial intelligence (AI) stocks with just $1,000 today.	0.267865	2025-10-23 13:32:57.11533+00
1637	Shopify and Bloomin' Brands have been highlighted as Zacks Bull and Bear of the Day	Zacks Commentary	https://www.zacks.com/stock/news/2772795/shopify-and-bloomin-brands-have-been-highlighted-as-zacks-bull-and-bear-of-the-day	2025-10-21 10:22:00+00	Shopify surges on its new OpenAI partnership, while Bloomin' Brands struggles with shrinking margins and changing diner habits.	0.271306	2025-10-23 13:32:57.11533+00
1638	Bull of the Day: Shopify  ( SHOP ) 	Zacks Commentary	https://www.zacks.com/commentary/2772382/bull-of-the-day-shopify-shop	2025-10-21 08:00:00+00	With its continued innovation, strategic partnerships, and consistent earnings outperformance, Shopfify remains at the forefront of the global e-commerce revolution.	0.324766	2025-10-23 13:32:57.11533+00
1639	Prediction: Nvidia Stock Price Will Skyrocket to This Range in 5 Years	Motley Fool	https://www.fool.com/investing/2025/10/20/nvda-stock-price-prediction-target-2030-5-years/	2025-10-21 00:00:00+00	Prediction: Nvidia stock will increase by about seven to 17 times in five years, depending upon the level of competition and assuming the U.S. economy remains at least relatively healthy for most of this period.	0.140538	2025-10-23 13:32:57.11533+00
1640	What Are the 2 Top Artificial Intelligence  ( AI )  Stocks to Buy Right Now?	Motley Fool	https://www.fool.com/investing/2025/10/20/what-are-the-2-top-artificial-intelligence-ai-stoc/	2025-10-20 20:00:00+00	These tech titans are reasonably valued and offer excellent return prospects.	0.340736	2025-10-23 13:32:57.11533+00
1641	ASML Just Shared Fantastic News for Nvidia, Broadcom, and AMD Investors	Motley Fool	https://www.fool.com/investing/2025/10/20/asml-buy-growth-stock-nvidia-broadcom-amd/	2025-10-20 17:18:00+00	ASML's most advanced machines are dominating its order volumes.	0.31683	2025-10-23 13:32:57.11533+00
1642	The AI Gold Rush: Do Semiconductor ETFs Hold the Key Opportunities?	Zacks Commentary	https://www.zacks.com/stock/news/2772241/the-ai-gold-rush-do-semiconductor-etfs-hold-the-key-opportunities	2025-10-20 13:38:00+00	AI's explosive growth is powering semiconductor stocks. Could ETFs like SMH or SOXX be the stronger plays in this tech rally?	0.208067	2025-10-23 13:32:57.11533+00
1643	Advanced Micro Devices, Inc.  ( AMD )  is Attracting Investor Attention: Here is What You Should Know	Zacks Commentary	https://www.zacks.com/stock/news/2772149/advanced-micro-devices-inc-amd-is-attracting-investor-attention-here-is-what-you-should-know	2025-10-20 13:00:02+00	Advanced Micro (AMD) has received quite a bit of attention from Zacks.com users lately. Therefore, it is wise to be aware of the facts that can impact the stock's prospects.	0.290157	2025-10-23 13:32:57.11533+00
1644	Roper Gears Up to Post Q3 Earnings: What's in the Offing?	Zacks Commentary	https://www.zacks.com/stock/news/2772116/roper-gears-up-to-post-q3-earnings-whats-in-the-offing	2025-10-20 11:50:00+00	ROP's Q3 results are likely to showcase strong software-driven growth, tempered by higher costs and currency headwinds.	0.318303	2025-10-23 13:33:00.989215+00
1645	5 Best-Performing ETF Areas of Last Week	Zacks Commentary	https://www.zacks.com/stock/news/2772048/5-best-performing-etf-areas-of-last-week	2025-10-20 10:35:00+00	ETFs like BITI, EWY, XSD, AMDW, and CNRG have fared well last week on AI momentum, trade optimism and clean energy revival.	0.237378	2025-10-23 13:33:00.989215+00
1646	2 Top Artificial Intelligence Stocks to Buy in October	Motley Fool	https://www.fool.com/investing/2025/10/20/2-top-artificial-intelligence-stocks-buy-october/	2025-10-20 08:45:00+00	These leading companies are no-brainer buys right now.	0.392798	2025-10-23 13:33:00.989215+00
1647	Nvidia, Broadcom, and AMD Each Won Deals With OpenAI. Here's the Biggest Winner of the Bunch.	Motley Fool	https://www.fool.com/investing/2025/10/20/nvidia-broadcom-and-amd-each-won-deals-with-openai/	2025-10-20 08:30:00+00	These chip rivals each aim to win as AI spending reaches into the trillions of dollars.	0.206041	2025-10-23 13:33:00.989215+00
1648	What Is One of the Best AI Hardware Stocks to Buy Today?	Motley Fool	https://www.fool.com/investing/2025/10/20/what-is-one-of-the-best-ai-hardware-stocks-to-buy/	2025-10-20 05:15:00+00	Semiconductor stocks have been the biggest beneficiaries of rising investment in artificial intelligence (AI) infrastructure over the last three years.	0.263211	2025-10-23 13:33:00.989215+00
1649	The Smartest Growth Stock to Buy With $1,000 Right Now	Motley Fool	https://www.fool.com/investing/2025/10/19/the-smartest-growth-stock-to-buy-with-1000-now/	2025-10-19 23:10:00+00	This stock, an AI player, may be at the start of its growth story.	0.330514	2025-10-23 13:33:00.989215+00
1650	Jensen Huang Just Announced Bad News for Nvidia's Rivals	Motley Fool	https://www.fool.com/investing/2025/10/19/huang-announced-bad-news-for-nvidia-rivals/	2025-10-19 17:15:00+00	A recent deal scores a double win for Nvidia.	0.19175	2025-10-23 13:33:00.989215+00
1651	Prediction: This AI Growth Stock Will Continue to Crush the S&P 500 in 2026	Motley Fool	https://www.fool.com/investing/2025/10/19/prediction-ai-growth-stock-beat-sp-500-2026/	2025-10-19 16:10:00+00	ASML just delivered great news for long-term investors in its third-quarter 2025 earnings report.	0.03848	2025-10-23 13:33:00.989215+00
1652	3 Monster Stocks to Hold for the Next 10 Years	Motley Fool	https://www.fool.com/investing/2025/10/19/3-monster-stocks-to-hold-for-the-next-10-years/	2025-10-19 12:21:00+00	These market-beating stocks delivered returns between 640% and 12,452% over the last decade. They're just getting started on their next big growth chapters.	0.246954	2025-10-23 13:33:00.989215+00
1653	Consumer Tech News  ( Oct 13-17 ) : Elon Musk's Starlink Under US Probe, Salesforce Eyes $60B Revenue, Apple Launches M5 Chip And More Consumer Tech News  ( Oct 13-17 ) : Elon Musk's Starlink Under US Probe, Salesforce Eyes $60B Revenue, Apple Launches M5 Chip An - Apple  ( NASDAQ:AAPL ) , Accenture  ( NYSE:ACN ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48293422/consumer-tech-news-oct-13-17-elon-musks-starlink-under-us-probe-salesforce-eyes-60b-revenue-apple-la	2025-10-19 12:01:42+00	A bipartisan committee in the U.S. Congress has reportedly begun a probe into Elon Musk's Starlink satellite business for its alleged involvement in providing internet access to scam centers in Myanmar.	0.166114	2025-10-23 13:33:00.989215+00
1654	The Newest Artificial Intelligence Stock Has Arrived -- and It Claims to Make Chips That Are 20x Faster Than Nvidia	Motley Fool	https://www.fool.com/investing/2025/10/19/the-newest-artificial-intelligence-stock-has-arriv/	2025-10-19 11:30:00+00	A start-up called Cerebras claims its chips are more powerful than Nvidia's GPUs.	0.185474	2025-10-23 13:33:04.396265+00
1655	The 5 Best-Performing S&P 500 Stocks of the Last Decade -- Including Nvidia and Broadcom	Motley Fool	https://www.fool.com/investing/2025/10/19/the-5-best-performing-sp-500-stocks-of-last-decade/	2025-10-19 11:15:00+00	One of these stocks is up nearly 27,000% over the last 10 years!	0.276355	2025-10-23 13:33:04.396265+00
1656	My Favorite AI Growth Stock to Invest $1,000 in Right Now	Motley Fool	https://www.fool.com/investing/2025/10/19/favorite-ai-stock-asml-buy-invest-1000-dollars/	2025-10-19 09:55:00+00	ASML is well-positioned to benefit from AI chip manufacturing growth.	0.341791	2025-10-23 13:33:04.396265+00
1657	Prediction: Global AI Competition Could Create Trillion-Dollar Winners	Motley Fool	https://www.fool.com/investing/2025/10/18/prediction-global-ai-competition-could-create-tril/	2025-10-18 20:00:00+00	These tech companies are benefiting from growing investment in AI chips and software.	0.351989	2025-10-23 13:33:04.396265+00
1658	Are AMD and Nvidia Stocks a Buy After the Pullback?	Motley Fool	https://www.fool.com/investing/2025/10/18/are-amd-and-nvidia-stocks-a-buy-after-the-pullback/	2025-10-18 11:00:00+00	Recent tariff news has brought both stocks down a bit.	0.101336	2025-10-23 13:33:04.396265+00
1659	Had You Invested $10,000 in the Vanguard S&P 500 Growth ETF 10 Years Ago, Here's How Much You'd Have Today	Motley Fool	https://www.fool.com/investing/2025/10/18/invested-10000-vanguard-sp-500-growth-etf-10-years/	2025-10-18 09:13:00+00	The Vanguard S&P 500 Growth ETF typically outperforms the S&P 500 over the long term.	0.329453	2025-10-23 13:33:04.396265+00
1660	Should You Buy, Sell or Hold INTC Stock Before Q3 Earnings?	Zacks Commentary	https://www.zacks.com/stock/news/2771036/should-you-buy-sell-or-hold-intc-stock-before-q3-earnings	2025-10-17 13:23:00+00	INTC readies its Q3 earnings as new AI partnerships, product launches and global headwinds shape investor sentiment ahead of Oct. 23.	0.237436	2025-10-23 13:33:04.396265+00
1661	AMD To Rally Around 28%? Here Are 10 Top Analyst Forecasts For Friday - Advanced Micro Devices  ( NASDAQ:AMD ) , Bank of New York Mellon  ( NYSE:BK ) 	Benzinga	https://www.benzinga.com/analyst-stock-ratings/price-target/25/10/48271676/amd-to-rally-around-28-here-are-10-top-analyst-forecasts-for-friday	2025-10-17 11:46:48+00	Top Wall Street analysts changed their outlook on these top names. For a complete view of all analyst rating changes, including upgrades and downgrades, please see our analyst ratings page. Piper Sandler raised Oracle Corporation ( NYSE:ORCL ) price target from $330 to $380.	0.125389	2025-10-23 13:33:04.396265+00
1662	Taiwan Semiconductor Manufacturing Just Announced Big News for Nvidia Stockholders	Motley Fool	https://www.fool.com/investing/2025/10/17/tsmc-just-announced-big-news-for-nvidia/	2025-10-17 11:35:00+00	Investors always look for clues about Nvidia's progress in the high-growth AI market.	0.215297	2025-10-23 13:33:04.396265+00
1663	AMD's Recent Partnerships With OpenAI and Oracle Are Getting Some Wall-Street Analysts Extremely Bullish	Motley Fool	https://www.fool.com/investing/2025/10/17/amds-recent-partnerships-with-openai-and-oracle-ar/	2025-10-17 10:45:00+00	Advanced Micro Devices is expected to see strong data center sales in the upcoming years, thanks to AI.	-0.046571	2025-10-23 13:33:04.396265+00
1664	Is It Too Late to Buy Rigetti Stock After a 5,500% Run?	Motley Fool	https://www.fool.com/investing/2025/10/23/is-it-too-late-to-buy-rigetti-stock-after-a-5500-r/	2025-10-23 11:16:59+00	This under-the-radar quantum stock just posted a 5,500% rally -- but there's more to the story than meets the eye.	0.087203	2025-10-23 13:33:07.721056+00
1665	Gold Drops After Blow-Off Top Signal; Netflix Disappoints; Tesla Earnings Ahead - Apple  ( NASDAQ:AAPL ) 	Benzinga	https://www.benzinga.com/Opinion/25/10/48360442/gold-drops-after-blow-off-top-signal-netflix-disappoints-tesla-earnings-ahead	2025-10-22 16:50:07+00	Please click here for an enlarged chart of SPDR Gold Trust ( NYSE:GLD ) . Space stock AST SpaceMobile Inc ( NASDAQ:ASTS ) stock has fallen 30.3% from its high. Nuclear stock Oklo Inc ( NYSE:OKLO ) is down 30.9% from its high. Data center stock IREN Ltd ( NASDAQ:IREN ) has fallen ...	0.205459	2025-10-23 13:33:07.721056+00
1666	Is It Too Late to Buy Rigetti Computing Stock?	Motley Fool	https://www.fool.com/investing/2025/10/21/is-it-too-late-to-buy-rigetti-computing-stock/	2025-10-21 08:34:00+00	Quantum computing stocks are even hotter than AI stocks right now, but the numbers aren't stacking up.	0.088768	2025-10-23 13:33:07.721056+00
1667	If You Invested $10,000 In Rigetti Computing 1 Year Ago, Here's How Much You'd Have Today	Motley Fool	https://www.fool.com/investing/2025/10/20/if-you-invested-10000-in-rigetti-computing-1-year/	2025-10-20 10:15:00+00	Rigetti Computing has been on a remarkable run over the past year.	0.20382	2025-10-23 13:33:07.721056+00
1668	Is It Too Late to Buy Rigetti Computing Stock?	Motley Fool	https://www.fool.com/investing/2025/10/20/is-it-too-late-to-buy-rigetti-computing-stock/	2025-10-20 09:15:00+00	Rigetti Computing's stock has been on an absolute tear over the past few weeks.	0.205448	2025-10-23 13:33:07.721056+00
1669	Rigetti Computing: Is It Too Late to Buy After a 5,000% rally?	Motley Fool	https://www.fool.com/investing/2025/10/20/rigetti-computing-is-it-too-late-to-buy-after-a-50/	2025-10-20 05:45:00+00	Quantum computing is the latest technology hype cycle.	0.191983	2025-10-23 13:33:07.721056+00
1670	Tesla, Palantir JPMorgan And More - Here's Why Investors Couldn't Stop Talking About These Stocks This Week - JPMorgan Chase  ( NYSE:JPM ) , Oklo  ( NYSE:OKLO ) 	Benzinga	https://www.benzinga.com/markets/equities/25/10/48292220/tesla-palantir-jpmorgan-and-more-heres-why-investors-couldnt-stop-talking-about-these-stocks-thi	2025-10-18 15:02:07+00	Retail investors buzzed about five stocks this week, from Oct. 13 to Oct. 17, on platforms like X and Reddit's r/WallStreetBets, amid government shutdown, banking earnings and AI enthusiasm.	0.14961	2025-10-23 13:33:07.721056+00
1671	Rigetti Computing, Inc.  ( RGTI )  Stock Sinks As Market Gains: What You Should Know	Zacks Commentary	https://www.zacks.com/stock/news/2771475/rigetti-computing-inc-rgti-stock-sinks-as-market-gains-what-you-should-know	2025-10-17 21:50:03+00	Rigetti Computing, Inc. (RGTI) concluded the recent trading session at $46.38, signifying a -3.31% move from its prior day's close.	0.258931	2025-10-23 13:33:07.721056+00
1672	Rigetti Computing Stock Is Tumbling Friday: What's Going On? - Rigetti Computing  ( NASDAQ:RGTI ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/10/48284573/rigetti-computing-stock-is-tumbling-friday-whats-going-on	2025-10-17 18:49:20+00	Shares of Rigetti Computing Inc ( NASDAQ:RGTI ) are trading lower Friday, extending a recent downturn as the broader quantum computing sector cools off from a massive rally.	0.258047	2025-10-23 13:33:07.721056+00
1673	Wall Street Analysts See Rigetti Computing  ( RGTI )  as a Buy: Should You Invest?	Zacks Commentary	https://www.zacks.com/stock/news/2771071/wall-street-analysts-see-rigetti-computing-rgti-as-a-buy-should-you-invest	2025-10-17 13:30:02+00	The average brokerage recommendation (ABR) for Rigetti Computing (RGTI) is equivalent to a Buy. The overly optimistic recommendations of Wall Street analysts make the effectiveness of this highly sought-after metric questionable. So, is it worth buying the stock?	0.290484	2025-10-23 13:33:07.721056+00
1674	Better Quantum Computing Stock: Rigetti Computing or Alphabet	Motley Fool	https://www.fool.com/investing/2025/10/17/better-quantum-computing-stock-rigetti-or-alphabet/	2025-10-17 10:03:00+00	Quantum computing is full of David-versus-Goliath competitions.	0.197501	2025-10-23 13:33:11.577135+00
1675	Why Shares of Rigetti Computing Are Surging This Week	Motley Fool	https://www.fool.com/investing/2025/10/16/why-shares-of-rigetti-computing-are-surging-this-w/	2025-10-16 17:17:46+00	Quantum computing stocks blasted higher earlier this week after a large bank announced it would look into making investments in the sector.	-0.002394	2025-10-23 13:33:11.577135+00
1676	Rigetti Computing Stock Is Sliding Thursday: What's Going On? - Rigetti Computing  ( NASDAQ:RGTI ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/10/48258099/rigetti-computing-stock-is-sliding-thursday-whats-going-on	2025-10-16 17:11:41+00	Shares of Rigetti Computing Inc ( NASDAQ:RGTI ) are trading lower Thursday amid a broader pullback in the quantum computing sector following a significant rally. Here's what investors need to know. RGTI stock is showing notable weakness. See the full story here.	0.252366	2025-10-23 13:33:11.577135+00
1677	Rigetti, Joby, QuantumScape - Meet The $0 Revenue Moonshots - QuantumScape  ( NYSE:QS ) , Rigetti Computing  ( NASDAQ:RGTI ) , Joby Aviation  ( NYSE:JOBY ) 	Benzinga	https://www.benzinga.com/trading-ideas/long-ideas/25/10/48253941/rigetti-joby-quantumscape-meet-the-0-revenue-moonshots	2025-10-16 15:23:54+00	Call it the 'Zero-Dollar Club' - quantum batteries, electric air taxis, and quantum computers. For investors willing to take a chance on the future, these are the stocks making billion-dollar promises today, even if their revenue statements remain blank.	0.152861	2025-10-23 13:33:11.577135+00
1678	Satellogic, Hewlett Packard Enterprise, Bitfarms And Other Big Stocks Moving Lower In Thursday's Pre-Market Session - Bitfarms  ( NASDAQ:BITF ) , American Battery Tech  ( NASDAQ:ABAT ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/10/48246482/satellogic-hewlett-packard-enterprise-bitfarms-and-other-big-stocks-moving-lower-in-thursday	2025-10-16 12:01:21+00	U.S. stock futures were higher this morning, with the Dow futures gaining more than 100 points on Thursday. Shares of Satellogic Inc. ( NASDAQ:SATL ) fell sharply during today's pre-market trading after the company announced a proposed public offering.	0.036212	2025-10-23 13:33:11.577135+00
1679	Rigetti CEO's Lack Of Stake Raises Concerns - Rigetti Computing  ( NASDAQ:RGTI ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48239142/rigetti-ceo-has-no-skin-in-the-game-and-thats-not-going-unnoticed	2025-10-15 20:57:35+00	Rigetti Computing Inc's ( NASDAQ:RGTI ) CEO, Subodh K. Kulkarni, exercised options to convert 1,000,000 shares on May 21, 2025, and immediately sold them, leaving him with zero shares.	0.186137	2025-10-23 13:33:11.577135+00
1680	Zacks Investment Ideas feature highlights: IBIT, MP, JPM, BE, NVTS, NVDA and RGTI	Zacks Commentary	https://www.zacks.com/stock/news/2768886/zacks-investment-ideas-feature-highlights-ibit-mp-jpm-be-nvts-nvda-and-rgti	2025-10-15 09:37:00+00	MP surges on rare-earth tensions as AI energy and quantum computing stocks like BE, NVTS, and RGTI lead the market rebound.	0.247893	2025-10-23 13:33:11.577135+00
1681	Rigetti Computing, Inc.  ( RGTI )  Advances While Market Declines: Some Information for Investors	Zacks Commentary	https://www.zacks.com/stock/news/2768762/rigetti-computing-inc-rgti-advances-while-market-declines-some-information-for-investors	2025-10-14 22:00:06+00	In the latest trading session, Rigetti Computing, Inc. (RGTI) closed at $55.95, marking a +1.9% move from the previous day.	0.199056	2025-10-23 13:33:11.577135+00
1682	How To Trade SPY, Top Tech Stocks Using Technical Analysis	Benzinga	https://www.benzinga.com/Opinion/25/10/48378025/how-to-trade-spy-top-tech-stocks-using-technical-analysis-47	2025-10-23 12:59:47+00	Today provides a fresh look at manufacturing and housing activity with September's Chicago Fed National Activity Index at 8:30 AM Eastern, Existing Home Sales at 10 AM Eastern, and the Kansas City Fed Manufacturing Activity reading at 11 AM Eastern.	0.026689	2025-10-23 13:33:11.577135+00
1683	Totaligent's Omni-Channel Digital Communications Platform Is an All-in-One Marketing Game Changer	GlobeNewswire	https://www.globenewswire.com/news-release/2025/10/23/3172058/0/en/Totaligent-s-Omni-Channel-Digital-Communications-Platform-Is-an-All-in-One-Marketing-Game-Changer.html	2025-10-23 12:50:00+00	Totaligent is preparing the commercial launch of its all-in-one AI-powered enterprise marketing platform, designed to replace fragmented tech stacks ...	0.264407	2025-10-23 13:33:11.577135+00
1684	Totaligent's Omni-Channel Digital Communications Platform Is an All-in-One Marketing Game Changer - Totaligent  ( OTC:TGNT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48377887/totaligents-omni-channel-digital-communications-platform-is-an-all-in-one-marketing-game-changer	2025-10-23 12:50:00+00	BOCA RATON, Fla., Oct. 23, 2025 ( GLOBE NEWSWIRE ) -- Totaligent, Inc. ( "Totaligent" or "the Company" ) ( OTCID: TGNT ) , a leader in intelligent business marketing and data solutions, today announces that the Company is preparing for the commercial launch of its all-in-one enterprise marketing ...	0.256958	2025-10-23 13:33:14.879214+00
1685	1 Top Vanguard Fund That Could Turn $17,000 Into $1 Million	Motley Fool	https://www.fool.com/investing/2025/10/23/top-vanguard-fund-etf-turn-17000-1-million/	2025-10-23 12:00:00+00	Investors can find great success by going the passive route.	0.175478	2025-10-23 13:33:14.879214+00
1686	Not Just Taiwan Semiconductor: Elon Musk To Also Rely On Samsung For Tesla's AI Chips - Samsung Electronics Co  ( OTC:SSNLF ) , Tesla  ( NASDAQ:TSLA ) , Taiwan Semiconductor  ( NYSE:TSM ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48376541/not-just-taiwan-semiconductor-elon-musk-to-also-rely-on-samsung-for-teslas-ai-chips	2025-10-23 11:51:22+00	Tesla, Inc. ( NASDAQ:TSLA ) chief Elon Musk announced that Samsung Electronics Co., Ltd. ( OTC:SSNLF ) will now co-produce the automaker's next-generation artificial intelligence chip, the AI5.	0.2175	2025-10-23 13:33:14.879214+00
1687	Why ASML Could Be the Ultimate AI Infrastructure Stock	Motley Fool	https://www.fool.com/investing/2025/10/23/why-asml-could-be-the-ultimate-ai-infrastructure/	2025-10-23 11:45:00+00	The lithography leader sits at the heart of the advanced semiconductor supply chain.	0.241961	2025-10-23 13:33:14.879214+00
1688	Better Artificial Intelligence  ( AI )  Stock: Palantir vs. Nvidia	Motley Fool	https://www.fool.com/investing/2025/10/23/better-artificial-intelligence-ai-stock-nvidia-vs/	2025-10-23 09:30:00+00	Both companies experienced immense success, but there's a clear long-term winner here.	0.305733	2025-10-23 13:33:14.879214+00
1689	Bull of the Day: ASML Holding  ( ASML ) 	Zacks Commentary	https://www.zacks.com/commentary/2774521/bull-of-the-day-asml-holding-asml	2025-10-23 09:20:00+00	NVIDIA and TSMC depend on this maker of photolithography machines for etching the AI boom at ...	0.117489	2025-10-23 13:33:14.879214+00
1690	This Nvidia Supplier Is Beginning To Fizzle Out After Monumental Rally: Growth Score Nosedives - Taiwan Semiconductor  ( NYSE:TSM ) 	Benzinga	https://www.benzinga.com/markets/equities/25/10/48373517/this-nvidia-supplier-is-beginning-to-fizzle-out-after-monumental-rally-growth-score-nosedives	2025-10-23 08:31:10+00	One of Nvidia Corp.'s ( NASDAQ:NVDA ) key manufacturing partners, responsible for producing much of the chipmaker's highly sought-after GPUs, is losing steam. After fueling a multi-year rally, the supplier's momentum is now fading, reflected in a sharp drop in its Growth score within ...	0.135627	2025-10-23 13:33:14.879214+00
1691	1 No-Brainer Artificial Intelligence  ( AI )  Stock to Buy Right Now	Motley Fool	https://www.fool.com/investing/2025/10/23/no-brainer-artificial-intelligence-ai-stock-buy/	2025-10-23 08:00:00+00	This company is a critical player in the global AI infrastructure market, and it recently reported a solid set of results.	0.365213	2025-10-23 13:33:14.879214+00
1727	Palantir Technologies Inc.  ( PLTR )  Exceeds Market Returns: Some Facts to Consider	Zacks Commentary	https://www.zacks.com/stock/news/2772564/palantir-technologies-inc-pltr-exceeds-market-returns-some-facts-to-consider	2025-10-20 21:45:02+00	In the most recent trading session, Palantir Technologies Inc. (PLTR) closed at $181.59, indicating a +1.93% shift from the previous trading day.	0.234237	2025-10-23 13:33:28.084924+00
1692	Tesla's Q3 Earnings Divide Analysts, But Dan Ives Says 'The Worst Is In The Rearview Mirror' For The 'Most Undervalued' Name In AI - Ford Motor  ( NYSE:F ) , General Motors  ( NYSE:GM ) 	Benzinga	https://www.benzinga.com/markets/earnings/25/10/48371692/teslas-q3-earnings-divide-analysts-but-dan-ives-says-the-worst-is-in-the-rearview-mirror-for-the	2025-10-23 03:51:44+00	Tesla Inc.'s ( NASDAQ:TSLA ) third-quarter results have sparked a range of reactions from Wall Street, with some analysts calling the report a turning point and others urging caution on near-term expectations. TSLA is among today's weakest performers. Find out why here.	0.122147	2025-10-23 13:33:14.879214+00
1693	This Small AI Stock Has Outpaced Nvidia. 1 Reason Why It's Still Rising.	Motley Fool	https://www.fool.com/investing/2025/10/22/this-small-ai-stock-has-outpaced-nvidia-1-reason-w/	2025-10-23 01:05:00+00	This company's path to profitability is getting a lot clearer.	0.061918	2025-10-23 13:33:14.879214+00
1694	Tesla  ( TSLA )  Q3 2025 Earnings Call Transcript	Motley Fool	https://www.fool.com/earnings/call-transcripts/2025/10/22/tesla-tsla-q3-2025-earnings-call-transcript/	2025-10-22 23:50:47+00	Image source: The Motley Fool.Oct. 22, 2025, 5:30 p.m. ETChief Executive Officer - Elon MuskContinue reading ...	0.235579	2025-10-23 13:33:18.728699+00
1695	Is Arista Networks a Buy After Investment Company Stanley-Laman Group Began a Position in the Stock?	Motley Fool	https://www.fool.com/coverage/filings/2025/10/22/is-arista-networks-a-buy-after-investment-company-stanley-laman-group-began-a-position-in-the-stock/	2025-10-22 23:48:42+00	Investment management company Stanley-Laman Group, Ltd. disclosed a new position in Arista Networks ( NYSE:ANET ) , acquiring 61,078 shares in the third quarter of 2025 with an estimated trade value of $8.90 million as of September 30, 2025.According to a filing with the Securities and Exchange ...	0.321679	2025-10-23 13:33:18.728699+00
1696	Motley Fool Co-Founder Tom Gardner: The Quarterly Call	Motley Fool	https://www.fool.com/investing/2025/10/22/motley-fool-co-founder-tom-gardner-the-quarterly-c/	2025-10-22 23:45:00+00	In our second Quarterly Call, Motley Fool CEO and co-founder Tom Gardner talked about the current market and what to do about it. Tom also shared five investment ideas.	0.103512	2025-10-23 13:33:18.728699+00
1697	Great News for Nvidia and Alphabet Investors	Motley Fool	https://www.fool.com/investing/2025/10/22/nvidia-and-alphabet-expand-ai-partnership/	2025-10-22 20:58:21+00	Google Cloud announces general availability of G4 virtual machines, an AI cloud solution for inference and visual applications.	0.030885	2025-10-23 13:33:18.728699+00
1698	Nvidia-Backed Nebius  ( NBIS )  Has Crashed 24%- But Whales See A Fire Sale - Nebius Group  ( NASDAQ:NBIS ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48365717/nvidia-backed-nebius-nbis-has-crashed-24-but-whales-are-treating-it-like-a-fire-sale	2025-10-22 19:58:19+00	Nebius Group NV ( NASDAQ:NBIS ) , the Nvidia Corp ( NASDAQ:NVDA ) -backed AI infrastructure company, has dropped more than 24% over the past five days - but options data suggests institutional traders are treating the slide as a buying opportunity, not a red flag.	0.114429	2025-10-23 13:33:18.728699+00
1699	ALAB Rides on Accelerating AI Infrastructure Demand: What's Ahead?	Zacks Commentary	https://www.zacks.com/stock/news/2774489/alab-rides-on-accelerating-ai-infrastructure-demand-whats-ahead	2025-10-22 17:51:00+00	Astera Labs expands its AI connectivity portfolio, targeting hyperscaler demand and a $5B market by 2030 amid rising competition.	0.339764	2025-10-23 13:33:18.728699+00
1700	Vertiv Q3 2025 Earnings Call Transcript	Motley Fool	https://www.fool.com/earnings/call-transcripts/2025/10/22/vertiv-vrt-q3-2025-earnings-call-transcript/	2025-10-22 17:37:08+00	Image source: The Motley Fool.Oct. 22, 2025 at 11 a.m. ETExecutive Chairman - David M. CoteContinue reading ...	0.323662	2025-10-23 13:33:18.728699+00
1701	The Mag 7 Stock Charts: Which are Hot?	Zacks Commentary	https://www.zacks.com/commentary/2774466/the-mag-7-stock-charts-which-are-hot	2025-10-22 17:24:00+00	The Magnificent 7 stocks are back in the spotlight with Q3 earnings. Are some better than others?	0.107418	2025-10-23 13:33:18.728699+00
1702	IREN's 8.26X P/B Suggests Stretched Valuation: Hold or Fold the Stock?	Zacks Commentary	https://www.zacks.com/stock/news/2774467/irens-826x-pb-suggests-stretched-valuation-hold-or-fold-the-stock	2025-10-22 17:17:00+00	IREN's soaring valuation at 8.26X P/B and modest earnings outlook raise doubts despite its rapid Bitcoin and AI Cloud growth.	0.047725	2025-10-23 13:33:18.728699+00
1703	Trump Wanted Clean Energy Dead-It's Crushing Nvidia And AI Instead - Bloom Energy  ( NYSE:BE ) , Amprius Technologies  ( NYSE:AMPX ) 	Benzinga	https://www.benzinga.com/news/25/10/48356705/clean-energy-stocks-beat-nvidia-under-trump	2025-10-22 15:13:56+00	Ten months into Donald Trump's second term, the sector he's fought hardest to undercut is turning out to be one of the year's most explosive trades on Wall Street-and it's doing better than artificial intelligence.	0.183043	2025-10-23 13:33:18.728699+00
1704	Micron Unveils Memory Tech For AI Data Centers, Nvidia Team Up - Micron Technology  ( NASDAQ:MU ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48356271/micron-unveils-new-memory-tech-for-ai-data-centers-nvidia-team-up	2025-10-22 15:04:18+00	Micron Technology, Inc ( NASDAQ:MU ) has begun customer sampling of its 192GB SOCAMM2 ( small outline compression attached memory modules ) , designed to accelerate adoption of low-power memory in AI data centers.	0.251353	2025-10-23 13:33:21.856931+00
1705	Assessing NVIDIA's Performance Against Competitors In Semiconductors & Semiconductor Equipment Industry - NVIDIA  ( NASDAQ:NVDA ) 	Benzinga	https://www.benzinga.com/insights/news/25/10/48356097/assessing-nvidias-performance-against-competitors-in-semiconductors-amp-semiconductor-equipment-ind	2025-10-22 15:00:25+00	Amidst today's fast-paced and highly competitive business environment, it is crucial for investors and industry enthusiasts to conduct comprehensive company evaluations.	0.306039	2025-10-23 13:33:21.856931+00
1706	Can Broadcom's Expanding Portfolio Push Up Q4 Semiconductor Sales?	Zacks Commentary	https://www.zacks.com/stock/news/2774301/can-broadcoms-expanding-portfolio-push-up-q4-semiconductor-sales	2025-10-22 14:59:00+00	AVGO is benefiting from surging AI networking portfolio demand that is expected to drive Semiconductor sales.	0.213293	2025-10-23 13:33:21.856931+00
1707	F5 Gears Up to Report Q4 Earnings: What's in the Offing?	Zacks Commentary	https://www.zacks.com/stock/news/2774266/f5-gears-up-to-report-q4-earnings-whats-in-the-offing	2025-10-22 14:31:00+00	FFIV projects higher Q4 revenues on strong hybrid and subscription demand, though earnings may slip year over year.	0.12673	2025-10-23 13:33:21.856931+00
1708	Texas Instruments Q3 Earnings Beat Estimates, Revenues Rise Y/Y	Zacks Commentary	https://www.zacks.com/stock/news/2774166/texas-instruments-q3-earnings-beat-estimates-revenues-rise-yy	2025-10-22 14:08:00+00	TXN beats Q3 estimates with 14% revenue growth and solid Analog demand, signaling steady momentum into Q4.	0.182286	2025-10-23 13:33:21.856931+00
1709	3 Reasons to Buy Taiwan Semiconductor Stock Like There's No Tomorrow	Motley Fool	https://www.fool.com/investing/2025/10/22/3-reasons-to-buy-taiwan-semiconductor-stock-like/	2025-10-22 14:07:00+00	The company is the leading manufacturer of AI chips, and spending in this space isn't slowing down yet.	0.3426	2025-10-23 13:33:21.856931+00
1748	Prediction: These 2 Stocks Will Be Worth More Than Palantir Technologies 1 Year From Now	Motley Fool	https://www.fool.com/investing/2025/10/17/prediction-2-stocks-that-will-be-worth-more-than-p/	2025-10-17 09:00:00+00	Palantir's stock has gotten overheated, which has opened the door for other tech businesses to overtake it in size.	0.303393	2025-10-23 13:33:34.692882+00
1710	Ethernet Alliance's TEF 2025 Ignites the Ethernet for AI Revolution	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48353665/ethernet-alliances-tef-2025-ignites-the-ethernet-for-ai-revolution	2025-10-22 14:02:00+00	BEAVERTON, OR, Oct. 22, 2025 ( GLOBE NEWSWIRE ) -- The Ethernet Alliance, a global consortium dedicated to the continued success and advancement of Ethernet technologies, today unveiled details of its upcoming Technology Exploration Forum ( TEF 2025 ) : Ethernet for AI, taking place December ...	0.248417	2025-10-23 13:33:21.856931+00
1711	Vicor  ( VICR )  Q3 2025 Earnings Call Transcript	Motley Fool	https://www.fool.com/earnings/call-transcripts/2025/10/22/vicor-vicr-q3-2025-earnings-call-transcript/	2025-10-22 13:52:10+00	Image source: The Motley Fool.Tuesday, October 21, 2025 at 5 p.m. ETChief Executive Officer - Patrizio VinciarelliContinue reading ...	0.199301	2025-10-23 13:33:21.856931+00
1712	Prediction: 1 Artificial Intelligence  ( AI )  Stock Will Be Worth More Than Amazon and Palantir Combined by 2030  ( Hint: It's Not Nvidia ) 	Motley Fool	https://www.fool.com/investing/2025/10/22/prediction-1-artificial-intelligence-ai-stock-will/	2025-10-22 13:45:00+00	Amazon and Palantir are two of the most popular large-cap AI stocks, but chip giant Broadcom could outgrow them in the coming years.	0.24236	2025-10-23 13:33:21.856931+00
1713	Will Nebius' AI Cloud 3.0 Rollout Strengthen its Competitive Moat?	Zacks Commentary	https://www.zacks.com/stock/news/2773915/will-nebius-ai-cloud-30-rollout-strengthen-its-competitive-moat	2025-10-22 13:08:00+00	NBIS' launch of Aether, its AI Cloud 3.0 platform, signals a leap in secure, scalable infrastructure built to power enterprise AI innovation.	0.287046	2025-10-23 13:33:21.856931+00
1714	Palantir Stock Is Falling Wednesday: What Investors Need To Know - Palantir Technologies  ( NASDAQ:PLTR ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/10/48362044/palantir-stock-is-falling-wednesday-what-investors-need-to-know	2025-10-22 17:44:30+00	Shares of Palantir Technologies Inc ( NASDAQ:PLTR ) are trading lower Wednesday morning amid overall tech stock weakness. The stock is moving against a backdrop of recent strategic validation and partnership news. PLTR is taking a hit from negative sentiment. Check the analyst take here.	0.201787	2025-10-23 13:33:25.012812+00
1715	Is BigBear.ai Building the Future of Autonomous Defense?	Zacks Commentary	https://www.zacks.com/stock/news/2774409/is-bigbearai-building-the-future-of-autonomous-defense	2025-10-22 15:09:00+00	Can BBAI's defense partnerships and AI-driven edge solutions secure its lead amid fierce competition from PLTR and AI?	0.350316	2025-10-23 13:33:25.012812+00
1716	JPMorgan Chase and 1-800-Flowers have been highlighted as Zacks Bull and Bear of the Day	Zacks Commentary	https://www.zacks.com/stock/news/2774023/jpmorgan-chase-and-1-800-flowers-have-been-highlighted-as-zacks-bull-and-bear-of-the-day	2025-10-22 12:37:00+00	JPMorgan shines as Zacks' Bull of the Day with rising earnings and national security investments, while 1-800-Flowers faces steep declines.	0.198855	2025-10-23 13:33:25.012812+00
1717	Palantir Vs. OpenAI: Why AI Underdog Might Be The Smarter Bet - Palantir Technologies  ( NASDAQ:PLTR ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48350683/palantir-vs-openai-ai-underdog-might-be-the-smarter-bet	2025-10-22 12:32:01+00	OpenAI grabs headlines with a staggering $500 billion private valuation, but Palantir Technologies Inc. ( NYSE:PLTR ) offers investors a tangible, revenue-backed way to play the AI boom - albeit at lofty multiples.	0.228773	2025-10-23 13:33:25.012812+00
1718	Here's How Much You Would Have Made Owning Palantir Technologies Stock In The Last 15 Years - Palantir Technologies  ( NASDAQ:PLTR ) 	Benzinga	https://www.benzinga.com/insights/news/25/10/48341849/heres-how-much-you-would-have-made-owning-palantir-technologies-stock-in-the-last-15-years	2025-10-21 20:45:53+00	Palantir Technologies ( NASDAQ:PLTR ) has outperformed the market over the past 15 years by 24.88% on an annualized basis producing an average annual return of 37.14%. Currently, Palantir Technologies has a market capitalization of $427.50 billion.	0.158543	2025-10-23 13:33:25.012812+00
1719	Go Big With Palantir or Bet Small With BigBear.ai?	Zacks Commentary	https://www.zacks.com/stock/news/2773477/go-big-with-palantir-or-bet-small-with-bigbearai	2025-10-21 19:05:00+00	PLTR stock surges with solid Q2 results and raised guidance, while BBAI struggles with weak revenues and widening losses.	0.212408	2025-10-23 13:33:25.012812+00
1720	Strength Seen in Vivid Seats  ( SEAT ) : Can Its 12.6% Jump Turn into More Strength?	Zacks Commentary	https://www.zacks.com/stock/news/2773388/strength-seen-in-vivid-seats-seat-can-its-126-jump-turn-into-more-strength	2025-10-21 16:20:00+00	Vivid Seats (SEAT) witnessed a jump in share price last session on above-average trading volume. The latest trend in earnings estimate revisions for the stock doesn't suggest further strength down the road.	0.206083	2025-10-23 13:33:25.012812+00
1721	Prediction: 1 Stock That Will Be Worth More Than Palantir 1 Year From Now	Motley Fool	https://www.fool.com/investing/2025/10/21/predict-stock-worth-more-palantir-alibaba/	2025-10-21 08:04:00+00	Alibaba is growing at a slower rate, but its valuations look more sustainable.	0.077006	2025-10-23 13:33:25.012812+00
1722	Billionaire Paul Tudor Jones Sees a Surge Ahead in the Stock Market. Should You Run to Buy AI Stocks?	Motley Fool	https://www.fool.com/investing/2025/10/21/billionaire-paul-tudor-jones-surge-ai-stocks/	2025-10-21 08:00:00+00	Could the market be ready to surge?	0.149651	2025-10-23 13:33:25.012812+00
1723	Billionaire Stanley Druckenmiller Dumped His Fund's Stakes in Nvidia and Palantir to Pile Into an International Growth Stock That's Rallied 243% in 2 Years	Motley Fool	https://www.fool.com/investing/2025/10/21/billionaire-stanley-druckenmiller-sold-nvidia-pltr/	2025-10-21 07:51:00+00	Duquesne Family Office's billionaire boss jettisoned two of Wall Street's hottest artificial intelligence (AI) stocks for a business whose three operating segments are all growing by double digits.	0.266552	2025-10-23 13:33:25.012812+00
1724	Prediction: 2 AI Stocks Will Be Worth More Than Palantir Technologies by 2030	Motley Fool	https://www.fool.com/investing/2025/10/21/2-ai-stocks-worth-more-than-palantir-stock-2030/	2025-10-21 07:45:00+00	Shopify and AppLovin could surpass Palantir's current market value within five years.	0.341736	2025-10-23 13:33:28.084924+00
1725	Cathie Wood Dumps $3.7 Million Of Palantir Stock Despite AI Boom - Here's What She's Buying Instead - Palantir Technologies  ( NASDAQ:PLTR ) 	Benzinga	https://www.benzinga.com/etfs/broad-u-s-equity-etfs/25/10/48319178/cathie-wood-dumps-3-7-million-of-palantir-stock-despite-ai-boom-heres-what-shes-buying	2025-10-21 02:02:10+00	On Monday, Cathie Wood-led Ark Invest made notable portfolio moves, boosting its positions in Qualcomm Inc ( NASDAQ:QCOM ) and BYD Co Ltd ( OTC:BYDDY ) , while trimming its stakes in Palantir Technologies Inc ( NASDAQ:PLTR ) and Shopify Inc ( NYSE:SHOP ) .	0.294294	2025-10-23 13:33:28.084924+00
1726	The 6th Annual Seedly Personal Finance Festival Rallies Over 3,800 Singaporeans to Offer Insights into Economic Volatility	GlobeNewswire	https://www.globenewswire.com/news-release/2025/10/21/3169893/0/en/The-6th-Annual-Seedly-Personal-Finance-Festival-Rallies-Over-3-800-Singaporeans-to-Offer-Insights-into-Economic-Volatility.html	2025-10-21 02:00:00+00	SINGAPORE, Oct. 21, 2025 ( GLOBE NEWSWIRE ) -- MoneyHero Limited ( NASDAQ: MNY ) ( "MoneyHero" or the "Company" ) , a leading personal finance aggregation and comparison platform and a digital insurance brokerage provider in Greater Southeast Asia, today announced the successful conclusion of ...	0.435102	2025-10-23 13:33:28.084924+00
1728	Snowflake Poised For Major AI Driven Growth: Analyst - Snowflake  ( NYSE:SNOW ) 	Benzinga	https://www.benzinga.com/analyst-stock-ratings/reiteration/25/10/48306360/snowflake-poised-for-major-ai-driven-growth-analyst	2025-10-20 15:07:42+00	Snowflake Inc ( NYSE:SNOW ) is gaining momentum as it sharpens its go-to-market strategy and scales its cloud platform to meet soaring enterprise demand for artificial intelligence solutions, driving stronger deal flow and deeper integration across industries.	0.318435	2025-10-23 13:33:28.084924+00
1729	Zacks Market Edge Highlights: Palantir Technologies, Oklo and Innodata	Zacks Commentary	https://www.zacks.com/stock/news/2772427/zacks-market-edge-highlights-palantir-technologies-oklo-and-innodata	2025-10-20 14:48:00+00	Palantir, Oklo, and Innodata are soaring in 2025 as AI-fueled growth stocks dominate the market???but are they too hot to handle?	0.203392	2025-10-23 13:33:28.084924+00
1730	PLTR's Dual Powerhouses: Foundry and Gotham Fuel Enterprise AI Growth	Zacks Commentary	https://www.zacks.com/stock/news/2772383/pltrs-dual-powerhouses-foundry-and-gotham-fuel-enterprise-ai-growth	2025-10-20 14:30:00+00	Palantir's Foundry and Gotham platforms are driving explosive enterprise AI adoption, fueling a 93% surge in U.S. commercial revenues.	0.296419	2025-10-23 13:33:28.084924+00
1731	Here is What to Know Beyond Why Palantir Technologies Inc.  ( PLTR )  is a Trending Stock	Zacks Commentary	https://www.zacks.com/stock/news/2772133/here-is-what-to-know-beyond-why-palantir-technologies-inc-pltr-is-a-trending-stock	2025-10-20 13:00:03+00	Palantir Technologies (PLTR) has been one of the stocks most watched by Zacks.com users lately. So, it is worth exploring what lies ahead for the stock.	0.217394	2025-10-23 13:33:28.084924+00
1732	Larry Ellison Says AI Needs Private Data - Palantir Says 'Told You So' - Palantir Technologies  ( NASDAQ:PLTR ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48300085/larry-ellison-says-ai-needs-private-data-palantir-says-told-you-so	2025-10-20 12:24:02+00	When Oracle Corp's ( NYSE:ORCL ) Larry Ellison declared that artificial intelligence will only reach its "peak value" once models train on privately owned data, it sounded like a warning shot to the open-internet AI crowd. But for Palantir Technologies Inc. ( NYSE:PLTR ) , it was validation in ...	0.331988	2025-10-23 13:33:28.084924+00
1733	Should You Buy Palantir Before Nov. 3?	Motley Fool	https://www.fool.com/investing/2025/10/20/should-you-buy-palantir-before-nov-3/	2025-10-20 11:15:00+00	This stock has soared in the quadruple-digits in recent years.	0.289053	2025-10-23 13:33:28.084924+00
1734	The Best AI Stock to Buy Right Now, According to a Wall Street Analyst  ( Hint: Not Nvidia or Palantir ) 	Motley Fool	https://www.fool.com/investing/2025/10/20/the-best-ai-stock-to-buy-right-now-according-to-a/	2025-10-20 10:53:00+00	Dan Ives of Wedbush Securities sees one member of the "Magnificent Seven" as particularly underappreciated right now.	0.220713	2025-10-23 13:33:31.693427+00
1735	2 High-Flying Growth Stocks to Sell Before They Drop 46% to 75%, According to Select Wall Street Analysts	Motley Fool	https://www.fool.com/investing/2025/10/20/2-growth-stocks-to-sell-before-they-drop-46-to-75/	2025-10-20 09:56:00+00	After a strong run, it may be time to take some profits off the table.	0.269665	2025-10-23 13:33:31.693427+00
1736	Will Palantir Be a $1 Trillion Company by 2030?	Motley Fool	https://www.fool.com/investing/2025/10/20/will-palantir-be-a-1-trillion-company-by-2030/	2025-10-20 09:30:00+00	Palantir is nearly halfway to the $1 trillion mark already.	0.200481	2025-10-23 13:33:31.693427+00
1737	Wake Up, Investors! Nvidia and Palantir Have Issued a $12.5 Billion Warning to Wall Street.	Motley Fool	https://www.fool.com/investing/2025/10/20/nvidia-palantir-125-billion-warning-wall-street/	2025-10-20 07:06:00+00	The people who know Nvidia and Palantir best are sending a very clear and cautionary signal to investors.	0.242108	2025-10-23 13:33:31.693427+00
1738	Prediction: 2 Stocks That Will Be Worth More Than Palantir 5 Years From Now	Motley Fool	https://www.fool.com/investing/2025/10/19/prediction-2-stocks-thatll-be-worth-more-than-pala/	2025-10-19 17:15:00+00	These stocks are trading at reasonable valuations and have sustainable tailwinds.	0.314125	2025-10-23 13:33:31.693427+00
1739	Should Investors Buy Palantir Stock Instead of C3.ai Stock?	Motley Fool	https://www.fool.com/investing/2025/10/18/should-investors-buy-palantir-stock-instead-of-c3a/	2025-10-18 16:51:36+00	Only one can be the better investment in this comparison of AI stocks.	-0.10065	2025-10-23 13:33:31.693427+00
1740	Meet the AI Stock That's Crushing Nvidia and Palantir in 2025	Motley Fool	https://www.fool.com/investing/2025/10/18/meet-the-ai-stock-thats-crushing-nvidia-palantir/	2025-10-18 11:15:00+00	This artificial intelligence (AI) winner has seen its shares jump more than 300% this year.	0.23876	2025-10-23 13:33:31.693427+00
1741	Billionaires Are Selling Palantir Stock and Buying a Stock-Split AI Stock Up 1,530% in 3 Years	Motley Fool	https://www.fool.com/investing/2025/10/17/billionaires-are-selling-palantir-stock-and-buying/	2025-10-17 21:00:00+00	Some of Wall Street's largest money managers are locking in gains in Palantir and doubling down on an AI chip stock.	0.261372	2025-10-23 13:33:31.693427+00
1742	3 Red-Hot Growth Stocks for Your Watch List	Zacks Commentary	https://www.zacks.com/stock/news/2771434/3-red-hot-growth-stocks-for-your-watch-list	2025-10-17 20:50:00+00	Traders are talking about these three stocks in October 2025. Are they too hot to handle?	0.18777	2025-10-23 13:33:31.693427+00
1743	Atwood & Palmer Unload $34 Million of Palantir  ( NASDAQ: PLTR )  Stock: Should Investors Sell Too?	Motley Fool	https://www.fool.com/coverage/filings/2025/10/17/atwood-and-palmer-unload-usd34-million-of-palantir-nasdaq-pltr-stock-should-investors-sell-too/	2025-10-17 19:33:48+00	Atwood & Palmer Inc. reported a significant reduction in its Palantir Technologies position, selling 211,505 shares for an estimated $34.28 million, based on the average price during Q3 2025, per its October 15, 2025, SEC filing.According to a filing with the Securities and Exchange Commission ...	0.258538	2025-10-23 13:33:31.693427+00
1744	Snowflake's Palantir Deal Is Key To Unlock Massive AI, Government Data Opportunities: Analyst - Snowflake  ( NYSE:SNOW ) 	Benzinga	https://www.benzinga.com/analyst-stock-ratings/reiteration/25/10/48280459/snowflakes-palantir-deal-is-key-to-unlock-massive-ai-government-data-opportunit	2025-10-17 16:35:23+00	Snowflake Inc. ( NYSE:SNOW ) deepened its artificial intelligence ( AI ) push with a new partnership with Palantir Technologies Inc. ( NYSE:PLTR ) , aiming to simplify and accelerate enterprise AI development across industries.	0.275893	2025-10-23 13:33:34.692882+00
1745	2 Millionaire-Maker Artificial Intelligence  ( AI )  Stocks	Motley Fool	https://www.fool.com/investing/2025/10/17/2-millionaire-maker-artificial-intelligence-stocks/	2025-10-17 14:15:00+00	These high-quality stocks can generate life-changing returns for patient investors.	0.333517	2025-10-23 13:33:34.692882+00
1746	Better Artificial Intelligence  ( AI )  Stock: Snowflake vs. Palantir	Motley Fool	https://www.fool.com/investing/2025/10/17/better-artificial-intelligence-ai-stock-snowflake/	2025-10-17 13:45:00+00	Which one of these high-flying AI stocks should you be putting your money in right now?	0.418328	2025-10-23 13:33:34.692882+00
1747	Zacks Investment Ideas feature highlights: Palantir, Nvidia and Vertiv	Zacks Commentary	https://www.zacks.com/stock/news/2770795/zacks-investment-ideas-feature-highlights-palantir-nvidia-and-vertiv	2025-10-17 09:08:00+00	Palantir stock is coiling near a key technical level, with momentum building for what could be its next major breakout.	0.248585	2025-10-23 13:33:34.692882+00
1825	3 Warren Buffett Stocks to Hold Forever	Motley Fool	https://www.fool.com/investing/2025/10/21/3-warren-buffett-stocks-to-hold-forever/	2025-10-21 07:12:00+00	These Buffett stocks are perfect for "set-it-and-forget-it" investing.	0.269543	2025-10-23 13:34:00.049577+00
1749	Palantir Stock is About to Breakout... Again	Zacks Commentary	https://www.zacks.com/commentary/2770480/palantir-stock-is-about-to-breakout-again	2025-10-16 16:58:00+00	Palantir Technologies, one of the market's clear leaders has been consolidating for the last few months and now the stock appears ready to break out again ...	0.232936	2025-10-23 13:33:34.692882+00
1750	Does SoundHound's Interactions Deal Cement Agentic Dominance?	Zacks Commentary	https://www.zacks.com/stock/news/2770451/does-soundhounds-interactions-deal-cement-agentic-dominance	2025-10-16 16:26:00+00	SOUN's Interactions deal boosts its enterprise reach, tech stack and agentic AI dominance in voice automation.	0.357829	2025-10-23 13:33:34.692882+00
1751	Snowflake Teams Up With Palantir To Make AI Work Smarter - Snowflake  ( NYSE:SNOW ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/10/48250648/snowflake-teams-up-with-palantir-to-make-ai-work-smarter	2025-10-16 14:06:34+00	Snowflake Inc. ( NYSE:SNOW ) shares are trading higher after the company disclosed a partnership with Palantir Technologies Inc. ( NASDAQ:PLTR ) . According to the agreement, Snowflake intends to integrate its AI Data Cloud with Palantir Foundry and the Palantir Artificial Intelligence ...	0.294292	2025-10-23 13:33:34.692882+00
1752	Prediction: These 2 Companies Will Be Worth More Than Palantir 5 Years From Now	Motley Fool	https://www.fool.com/investing/2025/10/16/prediction-these-2-companies-will-be-worth-more-th/	2025-10-16 11:52:00+00	Home Depot and AMD are well positioned to benefit from some major economic trends.	0.262493	2025-10-23 13:33:34.692882+00
1753	Lockheed Martin, Microsoft, Meta, Google, Amazon And Palantir Join Trump's Lavish White House Dinner To Fund His $250 Million Ballroom - Palantir Technologies  ( NASDAQ:PLTR ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48244153/lockheed-martin-microsoft-meta-google-amazon-and-palantir-join-trumps-lavish-white-house-dinner-to-f	2025-10-16 09:23:46+00	Executives from tech and defense firms - including Lockheed Martin ( NYSE:LMT ) , Microsoft Corp. ( NASDAQ:MSFT ) , Meta Platforms Inc. ( NASDAQ:META ) , Alphabet Inc.'s ( NASDAQ:GOOG ) ( NASDAQ:GOOGL ) Google, Amazon.com, Inc. ( NASDAQ:AMZN ) and Palantir Technologies Inc. ( NASDAQ:PLTR ) - ...	0.144524	2025-10-23 13:33:34.692882+00
1754	3 Brilliant AI Growth Stocks with Massive Upside Potential	Motley Fool	https://www.fool.com/investing/2025/10/23/3-brilliant-ai-growth-stocks-with-massive-upside-p/	2025-10-23 12:00:00+00	Galaxy Digital shared some risks about the current state of the AI market.	-0.112395	2025-10-23 13:33:37.813093+00
1755	Is Now the Time to Sell Oracle Stock After Investment Company Ascent Wealth Partners Dumped Shares Worth $6.6 Million?	Motley Fool	https://www.fool.com/coverage/filings/2025/10/23/is-now-the-time-to-sell-oracle-stock-after-investment-company-ascent-wealth-partners-dumped-shares-worth-usd6-6-million/	2025-10-23 04:18:23+00	According to a filing with the Securities and Exchange Commission dated October 21, 2025, Ascent Wealth Partners reduced its stake in Oracle Corporation ( NYSE:ORCL ) by 26,178 shares. The estimated transaction value was $6.64 million.	0.389326	2025-10-23 13:33:37.813093+00
1756	Top Analyst Reports for Oracle, Toyota & Morgan Stanley	Zacks Commentary	https://www.zacks.com/research-daily/2774267/top-analyst-reports-for-oracle-toyota-morgan-stanley	2025-10-22 22:45:00+00	Oracle gains from cloud momentum and AI contracts, Toyota drives hybrid and hydrogen growth, while Morgan Stanley thrives on IB strength.	0.209807	2025-10-23 13:33:37.813093+00
1757	Why Is Wall Street So Bullish on Oracle? There's 1 Key Reason.	Motley Fool	https://www.fool.com/investing/2025/10/22/why-is-wall-street-so-bullish-on-oracle-theres-1-k/	2025-10-22 13:10:00+00	Oracle's cloud revenue forecast is incredible.	0.197938	2025-10-23 13:33:37.813093+00
1758	Oracle Corporation  ( ORCL )  is Attracting Investor Attention: Here is What You Should Know	Zacks Commentary	https://www.zacks.com/stock/news/2773878/oracle-corporation-orcl-is-attracting-investor-attention-here-is-what-you-should-know	2025-10-22 13:00:05+00	Recently, Zacks.com users have been paying close attention to Oracle (ORCL). This makes it worthwhile to examine what the stock has in store.	0.223943	2025-10-23 13:33:37.813093+00
1759	Unfortunate News for Oracle Stock Investors!	Motley Fool	https://www.fool.com/investing/2025/10/22/unfortunate-news-for-oracle-stock-investors/	2025-10-22 09:00:00+00	Investors are concerned about the company's profit margins as the management team is highlighting massive deals.	-0.407858	2025-10-23 13:33:37.813093+00
1760	Prediction: This Artificial Intelligence  ( AI )  Stock Could Be the Next Trillion-Dollar Giant	Motley Fool	https://www.fool.com/investing/2025/10/22/prediction-this-artificial-intelligence-ai-stock-c/	2025-10-22 08:44:00+00	Oracle appears to be in the best position to become the next AI stock to attain a 13-digit valuation.	0.175692	2025-10-23 13:33:37.813093+00
1761	A Closer Look at Oracle's Options Market Dynamics - Oracle  ( NYSE:ORCL ) 	Benzinga	https://www.benzinga.com/insights/options/25/10/48340086/a-closer-look-at-oracles-options-market-dynamics	2025-10-21 20:01:09+00	Financial giants have made a conspicuous bearish move on Oracle. Our analysis of options history for Oracle ( NYSE:ORCL ) revealed 183 unusual trades. Delving into the details, we found 38% of traders were bullish, while 42% showed bearish tendencies.	0.166839	2025-10-23 13:33:37.813093+00
1762	Big Money Moves: Investment Advisor Stocks Up on Often-Overlooked Artificial Intelligence  ( AI )  Stock	Motley Fool	https://www.fool.com/coverage/filings/2025/10/21/big-money-moves-investment-advisor-stocks-up-on-often-overlooked-artificial-intelligence-ai-stock/	2025-10-21 15:33:20+00	Sander Capital Advisors Inc disclosed the purchase of 18,880 Oracle ( NYSE:ORCL ) shares for an estimated $4.81 million during the third quarter of 2025, according to an SEC filing dated October 20, 2025.Sander Capital Advisors Inc increased its position in Oracle by 18,880 shares during the ...	0.228372	2025-10-23 13:33:37.813093+00
1763	My Top 5 Growth Stocks to Buy for 2026	Motley Fool	https://www.fool.com/investing/2025/10/21/top-5-growth-stocks-buy-ai-invest-2026/	2025-10-21 08:55:00+00	Investors looking for a blend of red-hot winners and beaten-down cash cows have come to the right place.	0.175475	2025-10-23 13:33:37.813093+00
1764	Meet the Unstoppable Dark Horse Stock That Could Join Nvidia, Microsoft, Apple, Alphabet, and Amazon in the $2 Trillion Club Before 2030	Motley Fool	https://www.fool.com/investing/2025/10/21/unstoppable-growth-stock-2-trillion-2030/	2025-10-21 07:02:00+00	Decades of information technology (IT) and cloud expertise could vault this AI contender to new heights.	0.222639	2025-10-23 13:33:41.059559+00
1765	Justin Wolfers Says AI's Soaring Energy Demand Is Like Egg Shortage - But Predicts Market Will 'Hatch More Watts' As Prices Rise - Oracle  ( NYSE:ORCL ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48319903/justin-wolfers-says-ais-soaring-energy-demand-is-like-egg-shortage-but-predicts-market-will-hatch-mo	2025-10-21 05:13:15+00	Economist Justin Wolfers compared the current surge in electricity demand driven by artificial intelligence to a temporary "egg shortage," arguing that rising prices will spur new investment and stabilize power supply over time.	0.090115	2025-10-23 13:33:41.059559+00
1766	Oracle  ( ORCL )  Stock Dips While Market Gains: Key Facts	Zacks Commentary	https://www.zacks.com/stock/news/2772562/oracle-orcl-stock-dips-while-market-gains-key-facts	2025-10-20 21:45:02+00	Oracle (ORCL) concluded the recent trading session at $277.18, signifying a -4.85% move from its prior day's close.	0.189437	2025-10-23 13:33:41.059559+00
1767	My Top 5 Growth Stocks to Buy for 2026	Motley Fool	https://www.fool.com/investing/2025/10/20/top-5-growth-stocks-buy-ai-invest-2026/	2025-10-20 18:00:22+00	Investors looking for a blend of red-hot winners and beaten-down cash cows have come to the right place.	0.175475	2025-10-23 13:33:41.059559+00
1768	Bloom Energy's Brookfield Deal Brings Prestige, Not Profit-Yet - Bloom Energy  ( NYSE:BE ) 	Benzinga	https://www.benzinga.com/analyst-stock-ratings/price-target/25/10/48309073/bloom-energys-brookfield-deal-brings-prestige-not-profit-yet	2025-10-20 16:32:17+00	Bloom Energy Corporation ( NYSE:BE ) is energizing investor interest with a bold partnership poised to reshape AI infrastructure. The company is scheduled to release its third-quarter 2025 financial results on Oct. 28.	0.235878	2025-10-23 13:33:41.059559+00
1769	Minnesota First Responder Agency Modernizes Public Safety with Oracle - Oracle  ( NYSE:ORCL ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/n48299544/minnesota-first-responder-agency-modernizes-public-safety-with-oracle	2025-10-20 12:00:00+00	Wright County Sheriff's Office adopts Oracle real-time video and recording capabilities, enhancing AI-based situational awareness and accountability	0.367057	2025-10-23 13:33:41.059559+00
1770	PineStone Sells $41.1 Million in Oracle Stock After Rally - Here's What Long-Term Investors Should Know	Motley Fool	https://www.fool.com/coverage/filings/2025/10/19/pinestone-sells-usd41-1-million-in-oracle-stock-after-rally-here-s-what-long-term-investors-should-know/	2025-10-19 23:49:48+00	PineStone Asset Management Inc. disclosed the sale of 161,430 Oracle Corporation shares for an estimated $41.11 million in the third quarter, according to an SEC filing released on Friday.PineStone Asset Management Inc. reduced its position in Oracle Corporation ( NYSE:ORCL ) by 161,430 shares ...	0.210246	2025-10-23 13:33:41.059559+00
1771	Is Now the Time to Buy Oracle Stock?	Motley Fool	https://www.fool.com/investing/2025/10/19/is-now-the-time-to-buy-oracle-stock/	2025-10-19 21:31:00+00	A sharp pullback after a euphoric run leaves Oracle looking more balanced, with reasons to be optimistic and a few arguing for caution.	0.142679	2025-10-23 13:33:41.059559+00
1772	Prediction: Palantir  ( PLTR )  Will Be Worth More Than Oracle  ( ORCL )  by 2030	Motley Fool	https://www.fool.com/investing/2025/10/19/prediction-palantir-worth-more-oracle-2030/	2025-10-19 17:02:00+00	The battle for artificial intelligence (AI) supremacy rages on.	0.097968	2025-10-23 13:33:41.059559+00
1773	Oracle Stock Investors -- You'll Love This Update!	Motley Fool	https://www.fool.com/investing/2025/10/19/oracle-stock-investors-youll-love-this-update/	2025-10-19 11:33:00+00	The management team expects revenue to soar over the next several years.	-0.215897	2025-10-23 13:33:41.059559+00
1774	Billionaire Steven Cohen Sold 100% of Point72's Stake in SoundHound AI and Is Piling Into This Supercharged Stock-Split Stock	Motley Fool	https://www.fool.com/investing/2025/10/18/billionaire-steven-cohen-sold-100-of-point72s-stak/	2025-10-18 22:00:00+00	During the second quarter, Steven Cohen's hedge fund completely exited its position in SoundHound AI in favor of the biggest name in the market.	0.278926	2025-10-23 13:33:44.290688+00
1775	Why Oracle Fell Hard Today	Motley Fool	https://www.fool.com/investing/2025/10/17/why-oracle-fell-hard-today/	2025-10-17 20:19:48+00	After yesterday's presentation, investors "sold the news" after a strong run in the stock over the past two months.	0	2025-10-23 13:33:44.290688+00
1776	Stocks Shrug Off Bank Fears, AMEX Jumps: What's Moving Markets Friday? - American Express  ( NYSE:AXP ) 	Benzinga	https://www.benzinga.com/markets/equities/25/10/48282938/stocks-today-wall-street-friday-regional-banks-american-express-oracle-gold-bitcoin	2025-10-17 17:56:35+00	Wall Street shrugged off credit concerns that battered bank stocks on Wednesday, with large-cap indices posting slight gains by midday trading in New York, setting up for a positive weekly close. The S&P 500 rose 0.2% to 6,650 points, nearly erasing Thursday's losses, while both the Nasdaq 100 ...	-0.026679	2025-10-23 13:33:44.290688+00
1777	Intuit Partners With Aprio to Boost Mid-Market Business Growth	Zacks Commentary	https://www.zacks.com/stock/news/2771389/intuit-partners-with-aprio-to-boost-mid-market-business-growth	2025-10-17 17:11:00+00	INTU partners with Aprio to deliver AI-powered ERP and advisory solutions designed to accelerate growth for mid-market businesses.	0.385157	2025-10-23 13:33:44.290688+00
1778	Wall Street Divided As Oracle's $225 Billion Growth Vision Sparks Optimism - And Concern - Oracle  ( NYSE:ORCL ) 	Benzinga	https://www.benzinga.com/analyst-stock-ratings/reiteration/25/10/48278949/wall-street-divided-as-oracles-225-billion-growth-vision-sparks-optimism-and-co	2025-10-17 15:43:10+00	Oracle Corporation ( NYSE:ORCL ) has set aggressive long-term growth targets as it ramps up its cloud and artificial intelligence infrastructure ambitions, signaling confidence.	0.200021	2025-10-23 13:33:44.290688+00
1779	Can Oracle's Expanding Contract Pipeline Drive Its Next Growth Phase?	Zacks Commentary	https://www.zacks.com/stock/news/2771178/can-oracles-expanding-contract-pipeline-drive-its-next-growth-phase	2025-10-17 12:50:00+00	ORCL's expanding AI and cloud contracts, including major deals with Meta and OpenAI, signal a powerful new growth phase ahead.	0.216804	2025-10-23 13:33:44.290688+00
1780	Stock Market Today: S&P 500, Nasdaq Futures Dragged By Financial Stocks-American Express, CSX Corp, Standard Lithium In Focus - SPDR S&P 500  ( ARCA:SPY ) 	Benzinga	https://www.benzinga.com/markets/equities/25/10/48270211/stock-market-today-sp-500-nasdaq-futures-dragged-by-financial-stocks-american-express-csx-corp-s	2025-10-17 10:01:54+00	U.S. stock futures slumped on Friday following Thursday's declines. Futures of major benchmark indices dropped by nearly 1%. Banking and financial stocks plunged on Thursday after Zions Bancorporation NA ( NASDAQ:ZION ) announced that it had incurred a sizable charge due to bad loans of a couple ...	-0.031729	2025-10-23 13:33:44.290688+00
1781	What AMD, Oracle, Nvidia, and Intel Shareholders Should Know About the Recent Flood of AI Updates	Motley Fool	https://www.fool.com/investing/2025/10/17/what-amd-oracle-nvidia-and-intel-shareholders-shou/	2025-10-17 10:00:00+00	Oracle is placing a massive order for Advanced Micro Devices' next-generation AI Chip, the MI450.	0.094439	2025-10-23 13:33:44.290688+00
1782	Big Tech Keeps Spending Despite Rising AI Bubble Fears: ETFs in Focus	Zacks Commentary	https://www.zacks.com/stock/news/2770809/big-tech-keeps-spending-despite-rising-ai-bubble-fears-etfs-in-focus	2025-10-17 10:00:00+00	Big Tech boosts spending despite AI bubble fears. Chip, utility & tech ETFs like SOXX, XLU, IYW should gain amid Big Tech spending spree.	0.212967	2025-10-23 13:33:44.290688+00
1783	2 Top Artificial Intelligence Stocks to Buy in October	Motley Fool	https://www.fool.com/investing/2025/10/17/2-top-artificial-intelligence-stocks-to-buy-in-oct/	2025-10-17 09:20:00+00	AI stocks are powering the market into the fourth quarter.	0.21285	2025-10-23 13:33:44.290688+00
1784	Oracle Delivers Massive News for AMD Stock and Nvidia Stock Investors	Motley Fool	https://www.fool.com/investing/2025/10/17/oracle-delivers-massive-news-for-amd-stock-and-nvi/	2025-10-17 09:00:00+00	AMD is finally gaining momentum in selling its products into the data centers optimized for AI.	-0.369982	2025-10-23 13:33:47.410875+00
1785	What Can History Teach Us About Investing in 2025?	Motley Fool	https://www.fool.com/retirement/2025/10/16/what-can-history-teach-us-about-investing-in-2025/	2025-10-16 19:44:00+00	While history doesn't repeat, it often rhymes.	0.129912	2025-10-23 13:33:47.410875+00
1786	Oracle Shares Rise 4% After Key Trading Signal, Hitting Intraday High - Oracle  ( NYSE:ORCL ) 	Benzinga	https://www.benzinga.com/Opinion/25/10/48261661/oracle-shares-rise-4-percent-after-key-trading-signal-hitting-intraday-high	2025-10-16 19:06:22+00	Oracle Corporation ( NYSE:ORCL ) experienced a significant Power Inflow alert, a key bullish indicator that is closely tracked by traders who value order flow analytics, specifically institutional and retail order flow data. At 10:28 AM EST on October 16, ORCL triggered a Power Inflow signal at a ...	0.349339	2025-10-23 13:33:47.410875+00
1787	Salesforce's AI Push Makes Cloud & CRM ETFs A Hot Play For Investors - Salesforce  ( NYSE:CRM ) 	Benzinga	https://www.benzinga.com/etfs/sector-etfs/25/10/48259407/salesforces-ai-push-makes-cloud-crm-etfs-a-hot-play-for-investors	2025-10-16 18:00:19+00	Salesforce Inc ( NYSE:CRM ) may be down over 25% year-to-date, but its aggressive AI and cloud growth ambitions are attracting revived attention from investors looking for diversified exposure in the form of ETFs.	0.190384	2025-10-23 13:33:47.410875+00
1788	IBM Stock Before Q3 Earnings Release: A Smart Buy or Risky Investment?	Zacks Commentary	https://www.zacks.com/stock/news/2770523/ibm-stock-before-q3-earnings-release-a-smart-buy-or-risky-investment	2025-10-16 17:41:00+00	IBM readies for its Q3 earnings with AI, hybrid cloud, and quantum partnerships driving optimism despite rising competition.	0.328487	2025-10-23 13:33:47.410875+00
1789	NOW's AI Offerings Boost Enterprise Footprint: What Lies Ahead?	Zacks Commentary	https://www.zacks.com/stock/news/2770478/nows-ai-offerings-boost-enterprise-footprint-what-lies-ahead	2025-10-16 16:51:00+00	ServiceNow expands its AI footprint with strong enterprise adoption of Now Assist, Pro Plus, and Workflow Data Fabric despite mounting competition.	0.368587	2025-10-23 13:33:47.410875+00
1790	ORCL vs. ADBE: Which Software Powerhouse Has Better AI & Cloud Edge?	Zacks Commentary	https://www.zacks.com/stock/news/2770462/orcl-vs-adbe-which-software-powerhouse-has-better-ai-cloud-edge	2025-10-16 16:34:00+00	Oracle's AI infrastructure dominance and $455B contract backlog position it for superior returns vs Adobe. Buy ORCL, hold ADBE amid competitive pressures.	0.21088	2025-10-23 13:33:47.410875+00
1791	What's Going On With IBM Stock Thursday? - IBM  ( NYSE:IBM ) , Oracle  ( NYSE:ORCL ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48245876/ibm-rolls-out-three-new-ai-agents-on-oracle-platform	2025-10-16 11:25:51+00	International Business Machines Corporation ( NYSE:IBM ) on Thursday launched three new AI agents on Oracle Corporation's ( NYSE:ORCL ) Oracle Fusion Applications AI Agent Marketplace. The three Oracle-validated AI agents launched are the Intercompany Agent, Smart Sales Order Entry Agent, ...	0.166305	2025-10-23 13:33:47.410875+00
1792	Stock Split Watch: Is Oracle Next?	Motley Fool	https://www.fool.com/investing/2025/10/16/stock-split-watch-is-oracle-next/	2025-10-16 08:08:00+00	A stock split makes a stock more accessible to a wider range of investors.	0.117681	2025-10-23 13:33:47.410875+00
1793	Jim Cramer Envies AMD, Dell Shareholders Because He Likes Those Stocks 'So Much' - Unfortunately, They 'Left The Train' Without Him - Advanced Micro Devices  ( NASDAQ:AMD ) , Dell Technologies  ( NYSE:DELL ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48242217/jim-cramer-envies-amd-dell-shareholders-because-he-likes-those-stocks-so-much-unfortunately-they-lef	2025-10-16 03:40:59+00	On Wednesday, Jim Cramer said he is envious of Advanced Micro Devices Inc. ( NASDAQ:AMD ) and Dell Technologies Inc. ( NYSE:DELL ) shareholders after missing out on their explosive stock rallies this year.	0.253068	2025-10-23 13:33:47.410875+00
1794	Prediction: This Hypergrowth Stock Will Be the First $10 Trillion Stock  ( Hint: It's Not Nvidia ) 	Motley Fool	https://www.fool.com/investing/2025/10/15/prediction-this-hypergrowth-stock-will-be-the-firs/	2025-10-16 00:00:00+00	This cloud computing giant could beat Nvidia to the $10 trillion milestone.	0.19152	2025-10-23 13:33:50.447757+00
1795	Is NextEra  ( NEE )  a Must-Buy AI Energy Stock Before Earnings?	Zacks Commentary	https://www.zacks.com/commentary/2774527/is-nextera-nee-a-must-buy-ai-energy-stock-before-earnings	2025-10-23 12:00:00+00	NextEra is a best-in-class AI energy stock to buy for strong earnings and revenue growth, great value, dividends (2.7% yield), and breakout potential.	0.310814	2025-10-23 13:33:50.447757+00
1796	What Are the 2 Top Artificial Intelligence  ( AI )  Stocks to Buy Right Now?	Motley Fool	https://www.fool.com/investing/2025/10/23/top-artificial-intelligence-ai-stock-buy-goog-amzn/	2025-10-23 10:05:00+00	Alphabet and Amazon both have big growth opportunities ahead and trade at attractive valuations.	0.274111	2025-10-23 13:33:50.447757+00
1797	3 Artificial Intelligence Stocks You Can Buy and Hold for the Next Decade	Motley Fool	https://www.fool.com/investing/2025/10/23/3-artificial-intelligence-stocks-you-can-buy-and-h/	2025-10-23 07:52:00+00	These AI giants have staying power.	0.217	2025-10-23 13:33:50.447757+00
1798	Safe & Green Shares Surge 35% After Hours - Here's Why - Safe & Green Holdings  ( NASDAQ:SGBX ) 	Benzinga	https://www.benzinga.com/markets/equities/25/10/48372959/safe-green-shares-surge-35-after-hours-heres-why	2025-10-23 06:52:52+00	Safe & Green Holdings Corp. ( NASDAQ:SGBX ) jumped 34.65% in after-hours trading on Wednesday, reaching $3.07. Check out the current price of SGBX stock here. According to Benzinga Pro data, the stock of the modular solutions company declined 3.8% during Wednesday's regular session, closing ...	0.149317	2025-10-23 13:33:50.447757+00
1799	Marjorie Taylor Greene Buys 6 Stocks And Bitcoin ETF: Here's Her Latest Shopping List - iShares Bitcoin Trust  ( NASDAQ:IBIT ) 	Benzinga	https://www.benzinga.com/news/politics/25/10/48369294/marjorie-taylor-greene-buys-6-stocks-and-bitcoin-etf-heres-her-latest-shopping-list	2025-10-22 21:52:46+00	Congresswoman Marjorie Taylor Greene ( R-Ga. ) is among the most active traders in Congress. Here's a look at her latest trades disclosed, which comes with increased attention on Congress Trades from retail traders.	0.133204	2025-10-23 13:33:50.447757+00
1800	AWS Goes AWOL: Are We Too Dependent on the Cloud?	Motley Fool	https://www.fool.com/investing/2025/10/22/aws-goes-awol-are-we-too-dependent-on-the-cloud/	2025-10-22 20:56:00+00	Is it time to reassess risk in the cloud and AI era?	0.028964	2025-10-23 13:33:50.447757+00
1801	Checking In on The Trade Desk, Bristol Myers Squibb, and Other Stocks	Motley Fool	https://www.fool.com/investing/2025/10/22/checking-in-on-the-trade-desk-bristol-myers-squibb/	2025-10-22 20:55:00+00	Motley Fool analysts Karl Thiel, Rick Munarriz, and Tim Beyers offer up three stocks that face dark clouds they can see through.	0.122944	2025-10-23 13:33:50.447757+00
1802	Pricing & Ad Momentum Lift Netflix's Q4 View: Is Upside Sustainable?	Zacks Commentary	https://www.zacks.com/stock/news/2774496/pricing-ad-momentum-lift-netflixs-q4-view-is-upside-sustainable	2025-10-22 17:09:00+00	NFLX's ad surge and strategic price hikes fuel double-digit growth, setting up a strong Q4 and full-year outlook.	0.297849	2025-10-23 13:33:50.447757+00
1803	Will Alibaba's Rising CapEx Pressure Weigh on Free Cash Flow Ahead?	Zacks Commentary	https://www.zacks.com/stock/news/2774490/will-alibabas-rising-capex-pressure-weigh-on-free-cash-flow-ahead	2025-10-22 16:54:00+00	BABA's surging AI and cloud investments are straining its near-term cash flow, even as it chases long-term growth and defends its market lead.	0.026706	2025-10-23 13:33:50.447757+00
1804	Amazon: The Next Big AI Winner? Why Wall Street Is Wrong - Amazon.com  ( NASDAQ:AMZN ) 	Benzinga	https://www.benzinga.com/analyst-stock-ratings/reiteration/25/10/48359419/amazon-the-next-big-ai-winner-one-analyst-thinks-wall-street-is-wrong	2025-10-22 16:20:24+00	Amazon.com Inc ( NASDAQ:AMZN ) expects to report strong third-quarter results driven by online retail sales and its artificial intelligence capabilities. The Seattle-based company's retail business is showing renewed strength. Plus, its cloud unit is set for a rebound.	0.371299	2025-10-23 13:33:53.672779+00
1844	Think It's Too Late to Buy This Leading Tech Stock? Here's 1 Reason Why There's Still Time.	Motley Fool	https://www.fool.com/investing/2025/10/20/think-its-too-late-to-buy-this-leading-tech-stock/	2025-10-20 12:17:00+00	Shares may look pricey, but Broadcom is still one of the top AI investments.	0.252505	2025-10-23 13:34:07.209976+00
1805	What's Going On With Amazon Stock Wednesday? - Amazon.com  ( NASDAQ:AMZN ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/10/48358557/whats-going-on-with-amazon-stock-wednesday-4	2025-10-22 15:59:18+00	Shares of Amazon.com, Inc. ( NASDAQ:AMZN ) are falling on Wednesday. The stock appears to be down following reports of a potential deal between Google and Anthropic. AMZN stock is trending lower. Get the scoop here.	0.050571	2025-10-23 13:33:53.672779+00
1806	NFLX Q3 Earnings Miss on Brazilian Tax Dispute, Posts Record Ad Sales	Zacks Commentary	https://www.zacks.com/stock/news/2774352/nflx-q3-earnings-miss-on-brazilian-tax-dispute-posts-record-ad-sales	2025-10-22 15:42:00+00	Netflix's Q3 earnings miss on Brazil tax but deliver record ad sales, highest-ever engagement. KPop Demon Hunters becomes the most-watched film as AI strategy accelerates.	0.246636	2025-10-23 13:33:53.672779+00
1807	Investigating Amazon.com's Standing In Broadline Retail Industry Compared To Competitors - Amazon.com  ( NASDAQ:AMZN ) 	Benzinga	https://www.benzinga.com/insights/news/25/10/48356136/investigating-amazon-coms-standing-in-broadline-retail-industry-compared-to-competitors	2025-10-22 15:01:07+00	In the fast-paced and highly competitive business world of today, conducting thorough company analysis is essential for investors and industry observers. In this article, we will conduct an extensive industry comparison, evaluating Amazon.com ( NASDAQ:AMZN ) in relation to its major competitors ...	0.336969	2025-10-23 13:33:53.672779+00
1808	How to Find Strong Retail and Wholesale Stocks Slated for Positive Earnings Surprises	Zacks Commentary	https://www.zacks.com/stock/news/2773869/how-to-find-strong-retail-and-wholesale-stocks-slated-for-positive-earnings-surprises	2025-10-22 12:50:03+00	Finding stocks expected to beat quarterly earnings estimates becomes an easier task with our Zacks Earnings ESP.	0.345934	2025-10-23 13:33:53.672779+00
1809	Meet The Unstoppable Stock That Could Join Nvidia, Amazon, Meta Platforms, and Alphabet in the Trillion-Dollar Club in 20 Years	Motley Fool	https://www.fool.com/investing/2025/10/22/meet-the-unstoppable-stock-that-could-join-nvidia/	2025-10-22 10:45:00+00	This industry disruptor is still just getting started.	0.25388	2025-10-23 13:33:53.672779+00
1810	Is iShares Core S&P U.S. Value ETF  ( IUSV )  a Strong ETF Right Now?	Zacks Commentary	https://www.zacks.com/stock/news/2773754/is-ishares-core-sp-us-value-etf-iusv-a-strong-etf-right-now	2025-10-22 10:20:02+00	Smart Beta ETF report for ...	0.3403	2025-10-23 13:33:53.672779+00
1811	Should iShares S&P 500 Value ETF  ( IVE )  Be on Your Investing Radar?	Zacks Commentary	https://www.zacks.com/stock/news/2773743/should-ishares-sp-500-value-etf-ive-be-on-your-investing-radar	2025-10-22 10:20:02+00	Style Box ETF report for IVE ...	0.29995	2025-10-23 13:33:53.672779+00
1812	Elon Musk Says X Messages Are Fully Encrypted With No 'AWS Dependencies' Or Advertising Hooks - Amazon.com  ( NASDAQ:AMZN ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48347354/elon-musk-says-x-messages-are-fully-encrypted-with-no-aws-dependencies-or-advertising-hooks	2025-10-22 09:14:27+00	On Tuesday, Elon Musk said that X, formerly Twitter, is fully encrypted, free from ads and operates independently of Amazon.com Inc.'s ( NASDAQ:AMZN ) Web Services.	-0.099794	2025-10-23 13:33:53.672779+00
1813	Should You Buy Amazon Stock Before Oct. 30?	Motley Fool	https://www.fool.com/investing/2025/10/22/should-you-buy-amazon-stock-before-oct-30/	2025-10-22 08:53:00+00	Amazon is about to give investors an update on its various artificial intelligence projects.	0.223068	2025-10-23 13:33:53.672779+00
1814	5 Stocks That Could Create Lasting Generational Wealth	Motley Fool	https://www.fool.com/investing/2025/10/22/stocks-could-create-lasting-generational-wealth/	2025-10-22 08:10:00+00	The dominant consumer-facing companies should continue winning for the foreseeable future.	0.303235	2025-10-23 13:33:56.945968+00
1815	2 Trillion-Dollar Artificial Intelligence  ( AI )  Stocks to Buy Before They Soar in 2026, According to Wall Street	Motley Fool	https://www.fool.com/investing/2025/10/22/2-trillion-dollar-ai-stocks-buy-before-soar-2026/	2025-10-22 08:02:00+00	These Wall Street analysts view Nvidia and Microsoft as strong buys as the buildout of artificial intelligence infrastructure continues.	0.315306	2025-10-23 13:33:56.945968+00
1816	Bear of the Day: 1-800 Flowers  ( FLWS ) 	Zacks Commentary	https://www.zacks.com/commentary/2773641/bear-of-the-day-1-800-flowers-flws	2025-10-22 08:00:00+00	Free-falling from a 52-week high of $9 a share, the technical analysis for 1-800 Flowers stock reflects a very bearish outlook with limited short-term support levels.	-0.002447	2025-10-23 13:33:56.945968+00
1817	Bernie Sanders Slams Jeff Bezos For Reportedly Replacing 600,000 Amazon Jobs With Robots: 'That's The Direction Of Every Major Corporation' - Tesla  ( NASDAQ:TSLA ) , Amazon.com  ( NASDAQ:AMZN ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48345766/bernie-sanders-slams-jeff-bezos-for-reportedly-replacing-600000-amazon-jobs-with-robots-thats-the-di	2025-10-22 05:33:06+00	On Tuesday, Sen. Bernie Sanders ( I-Vt. ) criticized Amazon.com, Inc. ( NASDAQ:AMZN ) founder Jeff Bezos for potentially replacing hundreds of thousands of jobs with robots, while Elon Musk weighed in on AI's broader impact on the workforce.	0.198871	2025-10-23 13:33:56.945968+00
1818	The Streaming Pivot No One Saw Coming: Netflix Embraces Spotify's Premium Podcasts	Motley Fool	https://www.fool.com/investing/2025/10/21/the-streaming-pivot-no-one-saw-coming/	2025-10-21 15:43:00+00	Find out what this Netflix-Spotify move could mean for sports, entertainment, and your portfolio.	0.251558	2025-10-23 13:33:56.945968+00
1819	Exploring The Competitive Space: Amazon.com Versus Industry Peers In Broadline Retail - Amazon.com  ( NASDAQ:AMZN ) 	Benzinga	https://www.benzinga.com/insights/news/25/10/48330549/exploring-the-competitive-space-amazon-com-versus-industry-peers-in-broadline-retail	2025-10-21 15:00:45+00	Amidst today's fast-paced and highly competitive business environment, it is crucial for investors and industry enthusiasts to conduct comprehensive company evaluations.	0.297028	2025-10-23 13:33:56.945968+00
1820	SNOW Benefits From Expanding Partner Base: A Sign for More Upside?	Zacks Commentary	https://www.zacks.com/stock/news/2773260/snow-benefits-from-expanding-partner-base-a-sign-for-more-upside	2025-10-21 14:56:00+00	Snowflake's expanding partner network, rising enterprise adoption, and AI-driven alliances signal steady growth momentum.	0.226427	2025-10-23 13:33:56.945968+00
1821	UPS,Teamsters Expedite AC Rollout: What's Ahead on the Labor Front?	Zacks Commentary	https://www.zacks.com/stock/news/2773237/upsteamsters-expedite-ac-rollout-whats-ahead-on-the-labor-front	2025-10-21 13:31:00+00	United Parcel Service fast-tracks air-conditioned delivery trucks under a new Teamsters deal, aiming to boost safety, morale and retention amid labor shifts.	0.256817	2025-10-23 13:33:56.945968+00
1822	Best Stock to Buy Right Now: Amazon vs. Alphabet	Motley Fool	https://www.fool.com/investing/2025/10/21/best-stock-to-buy-right-now-amazon-vs-alphabet/	2025-10-21 10:00:00+00	Both companies have the growth to beat the market.	0.23367	2025-10-23 13:33:56.945968+00
1823	My 2 Favorite Stocks to Buy Right Now	Motley Fool	https://www.fool.com/investing/2025/10/21/my-2-favorite-stocks-to-buy-right-now/	2025-10-21 08:40:00+00	Investors appear to be sleeping on Amazon and Dutch Bros.	0.307455	2025-10-23 13:33:56.945968+00
1824	What Is One of the Best Consumer Goods Stocks to Buy Right Now?	Motley Fool	https://www.fool.com/investing/2025/10/21/what-is-one-of-the-best-consumer-goods-stocks-to-b/	2025-10-21 07:15:00+00	Walmart continues to maintain its competitive edge.	0.362709	2025-10-23 13:34:00.049577+00
1826	Elizabeth Warren Blasts Amazon For Internet Meltdown, Says 'If A Company Can Break The Entire Internet, They Are Too Big' - Amazon.com  ( NASDAQ:AMZN ) , Walt Disney  ( NYSE:DIS ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48319150/elizabeth-warren-blasts-amazon-for-internet-meltdown-says-if-a-company-can-break-the-entire-internet	2025-10-21 01:52:46+00	On Monday, Sen. Elizabeth Warren ( D-Mass. ) called to break up Big Tech after a massive Amazon.com, Inc. ( NASDAQ:AMZN ) Web Services outage disrupted access to dozens of major platforms, including Amazon delivery services, Walt Disney Co. ( NYSE:DIS ) Disney+ and McDonald Corporation ( NYSE:MCD ...	-0.083225	2025-10-23 13:34:00.049577+00
1827	Amazon  ( AMZN )  Beats Stock Market Upswing: What Investors Need to Know	Zacks Commentary	https://www.zacks.com/stock/news/2772559/amazon-amzn-beats-stock-market-upswing-what-investors-need-to-know	2025-10-20 21:45:03+00	In the latest trading session, Amazon (AMZN) closed at $216.48, marking a +1.61% move from the previous day.	0.195548	2025-10-23 13:34:00.049577+00
1828	A Few Years From Now, You'll Wish You Had Bought This Undervalued Stock	Motley Fool	https://www.fool.com/investing/2025/10/20/a-few-years-from-now-youll-wish-you-had-bought-thi/	2025-10-20 15:28:00+00	In the middle of a turnaround, this company's service is vital to the world and very hard to replace or replicate.	0.041467	2025-10-23 13:34:00.049577+00
1829	Zacks Investment Ideas feature highlights: Netflix, Amazon and Disney	Zacks Commentary	https://www.zacks.com/stock/news/2772462/zacks-investment-ideas-feature-highlights-netflix-amazon-and-disney	2025-10-20 15:06:00+00	Netflix eyes new highs ahead of Q3 earnings, fueled by booming ad growth, AI-powered innovation, and expansion into gaming.	0.224826	2025-10-23 13:34:00.049577+00
1830	In-Depth Analysis: Amazon.com Versus Competitors In Broadline Retail Industry - Amazon.com  ( NASDAQ:AMZN ) 	Benzinga	https://www.benzinga.com/insights/news/25/10/48306115/in-depth-analysis-amazon-com-versus-competitors-in-broadline-retail-industry	2025-10-20 15:02:01+00	In the ever-evolving and intensely competitive business landscape, conducting a thorough company analysis is of utmost importance for investors and industry followers. In this article, we will carry out an in-depth industry comparison, assessing Amazon.com ( NASDAQ:AMZN ) alongside its primary ...	0.271721	2025-10-23 13:34:00.049577+00
1831	WW International, Replimune Group, Datavault AI, GRAIL And Other Big Stocks Moving Higher On Monday - American Battery Tech  ( NASDAQ:ABAT ) , Amazon.com  ( NASDAQ:AMZN ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/10/48304072/ww-international-replimune-group-datavault-ai-grail-and-other-big-stocks-moving-higher-on-mo	2025-10-20 14:13:22+00	U.S. stocks were higher, with the Nasdaq Composite gaining more than 1% on Monday. Shares of WW International, Inc. ( NASDAQ:WW ) rose sharply during Monday's session after announcing a partnership with Amazon.com, Inc.'s ( NASDAQ:AMZN ) Amazon Pharmacy to make weight management medications ...	0.246557	2025-10-23 13:34:00.049577+00
1832	SHOP's Merchant Solutions Revenue Growth Picks Up: More Upside Ahead?	Zacks Commentary	https://www.zacks.com/stock/news/2772373/shops-merchant-solutions-revenue-growth-picks-up-more-upside-ahead	2025-10-20 14:05:00+00	Shopify's Merchant Solutions revenues soared 37% in Q2 2025, fueled by booming GMV, rising Shop Pay use, and rapid B2B and offline commerce growth.	0.338255	2025-10-23 13:34:00.049577+00
1833	Why Is WW International Stock Soaring Monday? - WW International  ( NASDAQ:WW ) , Amazon.com  ( NASDAQ:AMZN ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/10/48302083/members-can-get-weightwatchers-prescriptions-quicker-thanks-to-amazon-pharmacy-partnership	2025-10-20 13:40:49+00	WW International, Inc. ( NASDAQ:WW ) , known as WeightWatchers, stock surged Monday after announcing a partnership with Amazon.com, Inc.'s ( NASDAQ:AMZN ) Amazon Pharmacy to make weight management medications easier to access for its clinic members.	0.397956	2025-10-23 13:34:00.049577+00
1834	Should First Trust NASDAQ-100 Equal Weighted ETF  ( QQEW )  Be on Your Investing Radar?	Zacks Commentary	https://www.zacks.com/stock/news/2773744/should-first-trust-nasdaq-100-equal-weighted-etf-qqew-be-on-your-investing-radar	2025-10-22 10:20:02+00	Style Box ETF report for ...	0.277889	2025-10-23 13:34:03.190941+00
1835	Elon Musk Just Gave Nvidia Investors 20 Billion Reasons to Cheer	Motley Fool	https://www.fool.com/investing/2025/10/22/elon-musk-just-gave-nvidia-investors-20-billion-re/	2025-10-22 10:00:00+00	xAI is placing an order for $20 billion in Nvidia GPUs.	0.209217	2025-10-23 13:34:03.190941+00
1836	Jabil's Diverse Portfolio Fuels Revenue Growth: A Sign of More Upside?	Zacks Commentary	https://www.zacks.com/stock/news/2773418/jabils-diverse-portfolio-fuels-revenue-growth-a-sign-of-more-upside	2025-10-21 16:52:00+00	JBL's broad portfolio spanning AI data center, renewables, semiconductor and retail automation is powering steady revenue gains and reinforcing its market resilience.	0.273434	2025-10-23 13:34:03.190941+00
1837	GLW's Robust Portfolio Fuels Customer Growth: Will the Trend Persist?	Zacks Commentary	https://www.zacks.com/stock/news/2773411/glws-robust-portfolio-fuels-customer-growth-will-the-trend-persist	2025-10-21 16:35:00+00	GLW's expanding partnerships with Apple, Samsung and Broadcom are fueling strong segment growth and positioning the company for long-term market gains.	0.382478	2025-10-23 13:34:03.190941+00
1838	Here's How Much You Would Have Made Owning Broadcom Stock In The Last 10 Years - Broadcom  ( NASDAQ:AVGO ) 	Benzinga	https://www.benzinga.com/insights/news/25/10/48330514/heres-how-much-you-would-have-made-owning-broadcom-stock-in-the-last-10-years	2025-10-21 15:00:21+00	Broadcom ( NASDAQ:AVGO ) has outperformed the market over the past 10 years by 27.13% on an annualized basis producing an average annual return of 39.63%. Currently, Broadcom has a market capitalization of $1.65 trillion.	0.158543	2025-10-23 13:34:03.190941+00
1839	2 No-Brainer Artificial Intelligence  ( AI )  Stocks to Buy for 2026 With $5,000 Right Now	Motley Fool	https://www.fool.com/investing/2025/10/21/2-no-brainer-artificial-intelligence-ai-stocks-to/	2025-10-21 13:37:00+00	Broadcom and TSMC look poised to have strong years in 2026 and beyond.	0.28677	2025-10-23 13:34:03.190941+00
1840	3 Red-Hot Growth Stocks to Buy in 2025 -- Including Opendoor Technologies and Broadcom	Motley Fool	https://www.fool.com/investing/2025/10/21/3-red-hot-growth-stocks-to-buy-in-2025/	2025-10-21 10:15:00+00	One of these growth stocks has grown by 293% over the past year.	0.321986	2025-10-23 13:34:03.190941+00
1841	Taiwan Semiconductor Manufacturing Gave Amazing News to AI Semiconductor Investors	Motley Fool	https://www.fool.com/investing/2025/10/21/taiwan-semiconductor-manufacturing-gave-amazing-ne/	2025-10-21 10:00:00+00	TSMC mentioned that demand for AI semiconductor solutions is much stronger than it was three months ago.	-0.083343	2025-10-23 13:34:03.190941+00
1842	Wall Street's Preeminent Stock-Split Stock of 2025 Has Gained 62,400% Since Its IPO and Sports One of the Best Share Buyback Programs on the Planet	Motley Fool	https://www.fool.com/investing/2025/10/21/wall-street-stock-split-stock-2025-gain-62400-ipo/	2025-10-21 07:06:00+00	Since initiating a repurchase program in January 2011, this industry leader has retired nearly 60% of its outstanding shares.	0.238096	2025-10-23 13:34:03.190941+00
1843	3 Dividend-Paying ETFs to Double Down On Even if the S&P 500 Sells Off in October	Motley Fool	https://www.fool.com/investing/2025/10/20/3-dividend-paying-etfs-to-double-down-on-even-if-t/	2025-10-20 12:21:00+00	One of these ETFs was recently yielding 6.5%.	0.214711	2025-10-23 13:34:03.190941+00
1845	Should Invesco Large Cap Growth ETF  ( PWB )  Be on Your Investing Radar?	Zacks Commentary	https://www.zacks.com/stock/news/2772032/should-invesco-large-cap-growth-etf-pwb-be-on-your-investing-radar	2025-10-20 10:20:02+00	Style Box ETF report for ...	0.319673	2025-10-23 13:34:07.209976+00
1846	Broadcom Set To Skyrocket With Momentum Gains Fueled By OpenAI Accelerator Deal - Broadcom  ( NASDAQ:AVGO ) 	Benzinga	https://www.benzinga.com/markets/equities/25/10/48296507/broadcom-set-to-skyrocket-with-momentum-gains-fueled-by-openai-accelerator-deal	2025-10-20 07:17:24+00	Broadcom Inc. ( NASDAQ:AVGO ) is poised for explosive growth, with its momentum ranking surging in the latest Benzinga Edge Stock Rankings report amid an AI-fueled partnership with OpenAI.	0.328371	2025-10-23 13:34:07.209976+00
1847	1 Glorious Growth Stock Down 22% You'll Regret Not Buying on the Dip, According to Wall Street	Motley Fool	https://www.fool.com/investing/2025/10/19/1-glorious-growth-stock-down-22-youll-regret-not-b/	2025-10-19 23:30:00+00	This semiconductor company has been growing at an incredible pace and trades at an attractive valuation.	0.288018	2025-10-23 13:34:07.209976+00
1848	Meet the Only Vanguard ETF That Has Turned $10,000 Into $82,000 Since 2015	Motley Fool	https://www.fool.com/investing/2025/10/19/meet-the-only-vanguard-etf-that-has-turned-10000-i/	2025-10-19 22:20:00+00	The Vanguard Information Technology ETF has crushed the market over the past decade.	0.1793	2025-10-23 13:34:07.209976+00
1849	Prediction: This Semiconductor Stock Will Beat Nvidia in 2026	Motley Fool	https://www.fool.com/investing/2025/10/19/prediction-this-semiconductor-stock-will-beat-nvid/	2025-10-19 22:00:00+00	This Nvidia competitor has just won a big contract.	0.34339	2025-10-23 13:34:07.209976+00
1850	Invesco QQQ vs. Vanguard Information Technology ETF: Which Is Better for Tech Investors?	Motley Fool	https://www.fool.com/investing/2025/10/19/invesco-qqq-vs-vanguard-information-technology-etf/	2025-10-19 16:05:00+00	Investors interested in tech stocks will find that each presents different value propositions.	0.250937	2025-10-23 13:34:07.209976+00
1851	Prediction: This Unstoppable Vanguard ETF Will Beat the S&P 500 Yet Again in 2026	Motley Fool	https://www.fool.com/investing/2025/10/19/prediction-this-unstoppable-vanguard-etf-will-beat/	2025-10-19 13:07:00+00	This ETF gives investors the best of both worlds with large-cap growth stocks.	0.34881	2025-10-23 13:34:07.209976+00
1852	Is the Vanguard Dividend Appreciation ETF a Buy Now?	Motley Fool	https://www.fool.com/investing/2025/10/19/is-the-vanguard-dividend-appreciation-etf-a-buy-no/	2025-10-19 12:15:00+00	One of the market's largest exchange-traded funds is about more than its implied income.	0.323298	2025-10-23 13:34:07.209976+00
1853	After Upbeat Outlook, Is It Time to Buy Taiwan Semiconductor Manufacturing?	Motley Fool	https://www.fool.com/investing/2025/10/19/after-upbeat-outlook-is-it-time-to-buy-taiwan-semi/	2025-10-19 12:10:00+00	The stock still looks like one of the biggest winners in AI.	0.173995	2025-10-23 13:34:07.209976+00
1854	1 Vanguard ETF That Could Soar 39% Before the End of 2026, According to a Top Wall Street Analyst	Motley Fool	https://www.fool.com/investing/2025/10/19/vanguard-etf-soar-39-percent-analyst-vug/	2025-10-19 10:25:00+00	This growth ETF has been a longtime winner.	0.287732	2025-10-23 13:34:12.470402+00
1855	Where Will Nvidia Stock Be in 3 Years?	Motley Fool	https://www.fool.com/investing/2025/10/19/where-will-nvidia-stock-be-in-3-years/	2025-10-19 09:37:00+00	Nvidia has led the AI arms race for the past three years, and is well positioned to do it again over the next three.	0.176904	2025-10-23 13:34:12.470402+00
1856	Prediction: This Artificial Intelligence  ( AI )  Stock Could Be the Next $2 Trillion Giant	Motley Fool	https://www.fool.com/investing/2025/10/19/prediction-this-artificial-intelligence-ai-stock-c/	2025-10-19 09:15:00+00	Broadcom's recent deal with OpenAI places it on the same playing field as Nvidia.	0.270125	2025-10-23 13:34:12.470402+00
1857	2 Top ETFs to Buy Now and Hold Forever	Motley Fool	https://www.fool.com/investing/2025/10/19/2-top-etfs-to-buy-now-and-hold-forever/	2025-10-19 07:55:00+00	Simple strategies are often the most lucrative.	0.485375	2025-10-23 13:34:12.470402+00
1858	Bulls And Bears: Stellantis, Papa John's, Oklo - And Trade Tensions Shake Chip Stocks Bulls And Bears: Stellantis, Papa John's, Oklo - And Trade Tensions Shake Chip Stocks - ARM Holdings  ( NASDAQ:ARM ) , Amazon.com  ( NASDAQ:AMZN ) 	Benzinga	https://www.benzinga.com/markets/market-summary/25/10/48291676/benzinga-bulls-and-bears-stellantis-papa-johns-oklo-and-trade-tensions-shake-chip-stocks	2025-10-18 11:41:17+00	Benzinga examined the prospects for many investors' favorite stocks over the last week - here's a look at some of our top stories. Wall Street slid from record highs as President Donald Trump renewed tariff threats against China, rattling investor sentiment and triggering a pullback in ...	-0.14102	2025-10-23 13:34:12.470402+00
1859	Here's How Much You Would Have Made Owning ASML Holding Stock In The Last 15 Years - ASML Holding  ( NASDAQ:ASML ) 	Benzinga	https://www.benzinga.com/insights/news/25/10/48368112/heres-how-much-you-would-have-made-owning-asml-holding-stock-in-the-last-15-years	2025-10-22 21:00:46+00	ASML Holding ( NASDAQ:ASML ) has outperformed the market over the past 15 years by 11.18% on an annualized basis producing an average annual return of 23.4%. Currently, ASML Holding has a market capitalization of $393.97 billion.	0.158543	2025-10-23 13:34:12.470402+00
1860	AMAT Stock Rises 39% in 3 Months: Should You Buy, Sell or Hold?	Zacks Commentary	https://www.zacks.com/stock/news/2774296/amat-stock-rises-39-in-3-months-should-you-buy-sell-or-hold	2025-10-22 14:57:00+00	Applied Materials gains from AI-driven demand and DRAM strength, but macro and China risks suggest a cautious hold.	0.093598	2025-10-23 13:34:12.470402+00
1861	ASML Holding Rises 45% in Three Months: Should You Still Buy the Stock?	Zacks Commentary	https://www.zacks.com/stock/news/2773963/asml-holding-rises-45-in-three-months-should-you-still-buy-the-stock	2025-10-22 14:46:00+00	ASML's 43% surge in three months highlights its EUV dominance, AI-fueled growth and margin strength. Can the rally keep going?	0.28722	2025-10-23 13:34:12.470402+00
1862	Should You Buy Lam Research Stock Before Q1 Earnings Release?	Zacks Commentary	https://www.zacks.com/stock/news/2772314/should-you-buy-lam-research-stock-before-q1-earnings-release	2025-10-20 13:45:00+00	AI-driven chip demand and rising DRAM spending are likely to help LRCX deliver another strong earnings beat in the first quarter of fiscal 2026.	0.308469	2025-10-23 13:34:12.470402+00
1863	Will AMAT's New AI-Chip Manufacturing Systems Bring Traction?	Zacks Commentary	https://www.zacks.com/stock/news/2772023/will-amats-new-ai-chip-manufacturing-systems-bring-traction	2025-10-20 08:57:00+00	Applied Materials' new AI-focused chipmaking systems aim to boost performance and efficiency, strengthening its edge in next-generation semiconductor manufacturing.	0.211698	2025-10-23 13:34:12.470402+00
1864	Got $5,000? 2 Stocks to Buy Now and Hold for the Long Term	Motley Fool	https://www.fool.com/investing/2025/10/19/got-5000-2-stocks-to-buy-now-and-hold-for-the-long/	2025-10-19 15:10:00+00	These two high-quality stocks can deliver impressive returns in the long run.	0.326182	2025-10-23 13:34:15.691857+00
1865	ASML Rally Continues. Is It Too Late to Buy the Stock?	Motley Fool	https://www.fool.com/investing/2025/10/19/asml-shares-rise-on-strong-orders-is-it-too-late/	2025-10-19 12:00:00+00	Intel and Samsung's strengthening positions could bode well for ASML in the coming years.	0.078102	2025-10-23 13:34:15.691857+00
1866	1 Top Growth Stock to Buy and Hold for the Next 10 Years	Motley Fool	https://www.fool.com/investing/2025/10/19/1-top-growth-stock-to-buy-and-hold-for-the-next-10/	2025-10-19 10:15:00+00	This company is primed to benefit from a multitrillion-dollar growth opportunity over the next decade.	0.315452	2025-10-23 13:34:15.691857+00
1867	Spotlight on ASML Holding: Analyzing the Surge in Options Activity - ASML Holding  ( NASDAQ:ASML ) 	Benzinga	https://www.benzinga.com/insights/options/25/10/48276968/spotlight-on-asml-holding-analyzing-the-surge-in-options-activity	2025-10-17 15:01:52+00	Deep-pocketed investors have adopted a bearish approach towards ASML Holding ( NASDAQ:ASML ) , and it's something market players shouldn't ignore. Our tracking of public options records at Benzinga unveiled this significant move today.	0.173384	2025-10-23 13:34:15.691857+00
1868	US Chip Stocks Tumble As Trade Tensions With China Heat Up - ARM Holdings  ( NASDAQ:ARM ) , Amazon.com  ( NASDAQ:AMZN ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48271707/us-chip-stocks-tumble-as-trade-tensions-with-china-heat-up	2025-10-17 11:52:01+00	Semiconductor equities faced sharp selling pressure on Friday, with shares of Nvidia Corporation ( NASDAQ:NVDA ) , Broadcom Inc. ( NASDAQ:AVGO ) , Marvell Technology, Inc. ( NASDAQ:MRVL ) , Taiwan Semiconductor Manufacturing Co. Ltd. ( NYSE:TSM ) , Intel Corporation ( NASDAQ:INTC ) , Arm ...	-0.069425	2025-10-23 13:34:15.691857+00
1869	US-China Trade Fight Hits Chinese Tech Stocks - Alibaba Gr Hldgs  ( NYSE:BABA ) , ASML Holding  ( NASDAQ:ASML ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/10/48270873/u-s-china-trade-fight-hits-chinese-tech-stocks	2025-10-17 10:46:22+00	U.S.-listed shares of major Chinese corporations, including Alibaba Group Holding Ltd. ( NYSE:BABA ) , Baidu Inc. ( NASDAQ:BIDU ) , PDD Holdings Inc. ( NASDAQ:PDD ) , JD.com Inc. ( NASDAQ:JD ) , NIO Inc. ( NYSE:NIO ) , Li Auto Inc. ( NASDAQ:LI ) , and XPeng Inc. ( NYSE:XPEV ) , slid on Friday ...	-0.15932	2025-10-23 13:34:15.691857+00
1870	What Could Go Wrong for ASML Stock? 3 Risks Long-Term Investors Should Watch	Motley Fool	https://www.fool.com/investing/2025/10/16/what-could-go-wrong-for-asml-stock-3-risks-long-te/	2025-10-16 19:14:00+00	The chip fabrication equipment maker's future isn't guaranteed -- but its importance is.	0.120856	2025-10-23 13:34:15.691857+00
1871	ASML Q3 Earnings Beat On Strong EUV Demand - ASML Holding  ( NASDAQ:ASML ) 	Benzinga	https://www.benzinga.com/analyst-stock-ratings/reiteration/25/10/48258056/asml-q3-earnings-beat-on-strong-euv-demand-ai-boosts-growth	2025-10-16 17:09:56+00	ASML ( NASDAQ:ASML ) reported third-quarter 2025 results showing slightly lower revenue but stronger-than-expected earnings, driven by robust demand for its Extreme Ultraviolet ( EUV ) lithography systems.	0.21851	2025-10-23 13:34:15.691857+00
1872	ASML Holding Q3 Earnings Beat Estimates, Revenues Rise Y/Y	Zacks Commentary	https://www.zacks.com/stock/news/2770367/asml-holding-q3-earnings-beat-estimates-revenues-rise-yy	2025-10-16 15:43:00+00	ASML's Q3 earnings beat forecasts with stronger margins and service growth, while full-year 2025 sales are expected to rise 15%.	0.051989	2025-10-23 13:34:15.691857+00
1873	Why Investors Are Paying Attention to ASML Stock	Motley Fool	https://www.fool.com/investing/2025/10/16/why-investors-are-paying-attention-to-asml-stock/	2025-10-16 13:54:00+00	ASML might not make the headlines like Nvidia, but it's the quiet enabler behind the entire AI revolution.	0.216587	2025-10-23 13:34:15.691857+00
1874	Company News for Oct 16, 2025	Zacks Commentary	https://www.zacks.com/stock/news/2769831/company-news-for-oct-16-2025	2025-10-16 09:58:00+00	Companies In The News Are: HWC, PGR, ABT, ASML.	-0.03905	2025-10-23 13:34:19.118214+00
1875	P/E Ratio Insights for ASML Holding - ASML Holding  ( NASDAQ:ASML ) 	Benzinga	https://www.benzinga.com/insights/news/25/10/48237519/pe-ratio-insights-for-asml-holding	2025-10-15 20:00:44+00	In the current session, the stock is trading at $1009.08, after a 2.63% spike. Over the past month, ASML Holding Inc. ( NASDAQ:ASML ) stock increased by 15.68%, and in the past year, by 44.03%.	-0.042492	2025-10-23 13:34:19.118214+00
1876	ASML  ( ASML )  Q3 2025 Earnings Call Transcript	Motley Fool	https://www.fool.com/earnings/call-transcripts/2025/10/15/asml-asml-q3-2025-earnings-call-transcript/	2025-10-15 13:48:38+00	Image source: The Motley Fool.Wednesday, Oct. 15, 2025, at 8 a.m. ETNeed a quote from a Motley Fool analyst? Email pr@fool.comContinue reading ...	0.252235	2025-10-23 13:34:19.118214+00
1877	3 Sneaky Quantum AI Stocks to Buy Now	Motley Fool	https://www.fool.com/investing/2025/10/15/3-sneaky-quantum-ai-stocks-to-buy-now/	2025-10-15 10:00:00+00	There are multiple stocks that will be winners in both the AI and quantum computing arms race.	0.268363	2025-10-23 13:34:19.118214+00
1878	Stock Market Today: Nasdaq, Dow Jones Futures Rise, Bank Of America, Morgan Stanley, Abbott In Focus-Analyst Warns US 'Going Broke Slowly' - SPDR S&P 500  ( ARCA:SPY ) 	Benzinga	https://www.benzinga.com/markets/equities/25/10/48218856/stock-market-today-nasdaq-dow-jones-futures-rise-bank-of-america-morgan-stanley-abbott-in-focus-	2025-10-15 09:59:41+00	U.S. stock futures advanced on Wednesday following Tuesday's mixed close. Futures of major benchmark indices were higher. Among the big banks that reported on Tuesday, surpassing analyst expectations were Wells Fargo & Co. ( NYSE:WFC ) , Citigroup Inc. ( NYSE:C ) , JPMorgan Chase & Co. ( NYSE:JPM ...	0.132885	2025-10-23 13:34:19.118214+00
1879	Bank of America, Morgan Stanley And 3 Stocks To Watch Heading Into Wednesday - Abbott Laboratories  ( NYSE:ABT ) 	Benzinga	https://www.benzinga.com/markets/equities/25/10/48217471/bank-of-america-morgan-stanley-and-3-stocks-to-watch-heading-into-wednesday	2025-10-15 06:40:21+00	With U.S. stock futures trading higher this morning on Wednesday, some of the stocks that may grab investor focus today are as follows: Wall Street expects Bank of America Corp. ( NYSE:BAC ) to report quarterly earnings at 95 cents per share on revenue of $27.50 billion before the opening bell, ...	0.277425	2025-10-23 13:34:19.118214+00
1880	ASML Q3 Bookings Beat Expectations At $6.3 Billion As AI Demand, EUV Adoption Drive Strong 2025 Outlook - NVIDIA  ( NASDAQ:NVDA ) , ASML Holding  ( NASDAQ:ASML ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48217038/asml-q3-bookings-beat-expectations-at-6-3-billion-as-ai-demand-euv-adoption-drive-strong-2025-outloo	2025-10-15 05:58:50+00	On Wednesday, Dutch semiconductor firm ASML Holding NV ( NASDAQ:ASML ) reported stronger-than-expected third-quarter bookings. AMSL said net bookings rose to €5.4 billion ( $6.27 billion ) in the third quarter. This topped market expectations of €5.36 billion ( $6.23 billion ) , noted ...	0.139326	2025-10-23 13:34:19.118214+00
1881	ASML reports €7.5 billion total net sales and €2.1 billion net income in Q3 2025	GlobeNewswire	https://www.globenewswire.com/news-release/2025/10/15/3166781/0/en/ASML-reports-7-5-billion-total-net-sales-and-2-1-billion-net-income-in-Q3-2025.html	2025-10-15 05:00:00+00	ASML reports €7.5 billion total net sales and €2.1 billion net income in Q3 2025 Full-year 2025 expected total net sales growth of around 15% with gross margin around 52%	0.193737	2025-10-23 13:34:19.118214+00
1882	AMAT's Logic & DRAM Offerings Gain Traction: How Long Will it Sustain?	Zacks Commentary	https://www.zacks.com/stock/news/2768469/amats-logic-dram-offerings-gain-traction-how-long-will-it-sustain	2025-10-14 14:16:00+00	Applied Materials sees momentum in Logic and DRAM as AI-driven demand, GAA transitions and HBM growth fuel its semiconductor leadership.	0.289928	2025-10-23 13:34:19.118214+00
1883	ASML Holding Before Q3 Earnings: How Should Investors Play the Stock?	Zacks Commentary	https://www.zacks.com/stock/news/2767199/asml-holding-before-q3-earnings-how-should-investors-play-the-stock	2025-10-13 12:33:00+00	ASML's Q3 performance is likely to reflect benefits from robust AI-driven demand for EUV systems, partially offset by China's trade pressures.	0.20886	2025-10-23 13:34:19.118214+00
1884	Top Stocks Earnings Playbook: Fastenal, ASML, TSMC and More - Taiwan Semiconductor  ( NYSE:TSM ) 	Benzinga	https://www.benzinga.com/markets/earnings/25/10/48172509/retail-investors-top-stocks-with-earnings-this-week-fastenal-asml-tsmc-and-more	2025-10-13 12:01:42+00	Retail investors are preparing for the kick-off of the third-quarter earnings season, with big banks and other top stocks reporting this week. Here's a look at some retail favorites that individual investors will be watching. FAST stock is moving. See the real-time price action here.	0.111898	2025-10-23 13:34:22.656167+00
1885	Stock Splits Ahead? 3 Artificial Intelligence  ( AI )  Stocks to Keep on Your Radar	Motley Fool	https://www.fool.com/investing/2025/10/13/stock-splits-ahead-3-artificial-intelligence-ai-st/	2025-10-13 08:44:00+00	None of these AI leaders has announced forthcoming stock splits -- at least not yet.	0.152687	2025-10-23 13:34:22.656167+00
1886	iShares Semiconductor ETF: Bull vs. Bear	Motley Fool	https://www.fool.com/investing/2025/10/11/ishares-semiconductor-etf-bull-vs-bear/	2025-10-11 15:45:00+00	This high-flying ETF has nearly tripled in five years, but some tech stock valuations are becoming overextended.	0.264139	2025-10-23 13:34:22.656167+00
1887	Trump's Trade War Gambit: Why America May Lose More Than China in Tariff Escalation - Apple  ( NASDAQ:AAPL ) , ASML Holding  ( NASDAQ:ASML ) 	Benzinga	https://www.benzinga.com/Opinion/25/10/48159746/trumps-trade-war-gambit-why-america-may-lose-more-than-china-in-tariff-escalation	2025-10-10 19:28:57+00	In a fiery Truth Social post Friday morning, President Donald Trump threatened China with a "massive increase of Tariffs" on imports, potentially canceling his planned meeting with Xi Jinping after Beijing unveiled sweeping rare-earth export controls.	0.034353	2025-10-23 13:34:22.656167+00
1888	1 Unstoppable Semiconductor Stock to Buy Instead of AMD	Motley Fool	https://www.fool.com/investing/2025/10/09/buy-unstoppable-semiconductor-stock-asml-amd/	2025-10-09 15:41:00+00	AMD is the latest chip company to land a massive deal with OpenAI.	0.193694	2025-10-23 13:34:22.656167+00
1889	What's Going On With ASML Stock Thursday? - ASML Holding  ( NASDAQ:ASML ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48119778/asml-taps-insider-marco-pieters-to-lead-technology-in-ai-era	2025-10-09 10:51:40+00	ASML Holding ( NASDAQ:ASML ) , the Dutch giant supplying critical equipment to the global semiconductor industry, has announced key leadership changes, naming Marco Pieters as Chief Technology Officer ( CTO ) , effective immediately.	0.115924	2025-10-23 13:34:22.656167+00
1890	ASML appoints next Chief Technology Officer	GlobeNewswire	https://www.globenewswire.com/news-release/2025/10/09/3163852/0/en/ASML-appoints-next-Chief-Technology-Officer.html	2025-10-09 06:00:00+00	• ASML Supervisory Board intends to reappoint CFO Roger Dassen and COO Frédéric Schneider-Maunoury, and to appoint CTO Marco Pieters to the Board of Management as of the April 2026 AGM	0.235221	2025-10-23 13:34:22.656167+00
1891	ASML Stock Falls As US Lawmakers Scrutinize China Dealings - ASML Holding  ( NASDAQ:ASML ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48097736/asml-stock-falls-as-us-lawmakers-scrutinize-china-dealings	2025-10-08 12:47:54+00	ASML Holding ( NASDAQ:ASML ) shares dropped on Wednesday after U.S. lawmakers accused the Dutch chip equipment giant of helping advance China's semiconductor capabilities. The criticism raised concerns about possible new export restrictions on its lithography machines, essential for producing ...	0.141521	2025-10-23 13:34:22.656167+00
1892	ASML Holding vs. Texas Instruments: Which Semi Stock Has an Edge?	Zacks Commentary	https://www.zacks.com/stock/news/2764239/asml-holding-vs-texas-instruments-which-semi-stock-has-an-edge	2025-10-08 12:11:00+00	TXN edges past ASML with steadier growth and a balanced valuation amid semiconductor market shifts.	0.262529	2025-10-23 13:34:22.656167+00
1893	Is the Market Bullish or Bearish on ASML Holding NV? - ASML Holding  ( NASDAQ:ASML ) 	Benzinga	https://www.benzinga.com/insights/short-sellers/25/10/48080983/is-the-market-bullish-or-bearish-on-asml-holding-nv	2025-10-07 16:00:53+00	ASML Holding NV's ( NYSE:ASML ) short interest as a percent of float has fallen 15.79% since its last report. According to exchange reported data, there are now 2.24 million shares sold short, which is 0.64% of all regular shares that are available for trading.	0.250562	2025-10-23 13:34:22.656167+00
1894	What the Options Market Tells Us About ASML Holding - ASML Holding  ( NASDAQ:ASML ) 	Benzinga	https://www.benzinga.com/insights/options/25/10/48048838/what-the-options-market-tells-us-about-asml-holding	2025-10-06 16:01:56+00	Deep-pocketed investors have adopted a bullish approach towards ASML Holding ( NASDAQ:ASML ) , and it's something market players shouldn't ignore. Our tracking of public options records at Benzinga unveiled this significant move today.	0.157391	2025-10-23 13:34:26.682033+00
1895	Why Is ASML Stock Trading Higher Today - ASML Holding  ( NASDAQ:ASML ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48039656/asml-ends-ties-with-former-france-fm-bruno-le-maire-stock-hits-52-week-high	2025-10-06 12:40:33+00	ASML Holding ( NASDAQ:ASML ) confirmed that France's former finance minister Bruno Le Maire is no longer serving as an advisor to its executive board, the Dutch semiconductor equipment giant told Reuters on Monday.	0.094992	2025-10-23 13:34:26.682033+00
1896	Think It's Too Late to Buy ASML Holding  ( ASML )  Stock? Here's the 1 Reason Why There's Still Time.	Motley Fool	https://www.fool.com/investing/2025/10/05/think-its-too-late-to-buy-asml-heres-the-1-reason/	2025-10-05 08:34:00+00	What would you say to average annual gains topping 27%?	0.321712	2025-10-23 13:34:26.682033+00
1897	Is SPDR MSCI EAFE StrategicFactors ETF  ( QEFA )  a Strong ETF Right Now?	Zacks Commentary	https://www.zacks.com/stock/news/2760624/is-spdr-msci-eafe-strategicfactors-etf-qefa-a-strong-etf-right-now	2025-10-02 10:20:02+00	Smart Beta ETF report for ...	0.193726	2025-10-23 13:34:26.682033+00
1898	This Beaten-Down AI Stock Could Stage a Monster Comeback by 2028	Motley Fool	https://www.fool.com/investing/2025/09/26/this-beaten-down-ai-stock-could-stage-a-monster/	2025-09-26 13:15:00+00	This semiconductor giant can sustain its impressive momentum in the long run.	0.280542	2025-10-23 13:34:26.682033+00
1899	If You Invested $1000 In ASML Holding Stock 15 Years Ago, You Would Have This Much Today - ASML Holding  ( NASDAQ:ASML ) 	Benzinga	https://www.benzinga.com/insights/news/25/09/47856294/if-you-invested-1000-in-asml-holding-stock-15-years-ago-you-would-have-this-much-today	2025-09-24 23:30:28+00	ASML Holding ASML has outperformed the market over the past 15 years by 11.35% on an annualized basis producing an average annual return of 23.78%. Currently, ASML Holding has a market capitalization of $372.58 billion.	0.160819	2025-10-23 13:34:26.682033+00
1900	Lam Research Soars 71% in Six Months: Book Profit or Hold LRCX Stock?	Zacks Commentary	https://www.zacks.com/stock/news/2756256/lam-research-soars-71-in-six-months-book-profit-or-hold-lrcx-stock	2025-09-24 13:16:00+00	LRCX surges 70% in six months, fueled by AI chip demand and strong earnings, but near-term risks cloud its outlook.	0.226434	2025-10-23 13:34:26.682033+00
1901	Better Artificial Intelligence Stock: ASML vs. Nvidia	Motley Fool	https://www.fool.com/investing/2025/09/24/better-artificial-intelligence-stock-asml-nvidia/	2025-09-24 12:30:00+00	One company owns a monopoly, while the other is the leader in AI semiconductor chips.	0.256294	2025-10-23 13:34:26.682033+00
1977	3 Unstoppable Growth ETFs That Could Turn $10,000 Into More Than $12 million With Practically Zero Effort	Motley Fool	https://www.fool.com/investing/2025/10/21/3-unstoppable-growth-etfs-that-could-turn-10000-in/	2025-10-22 00:05:00+00	Turning an initial $10,000 investment into $12 million is actually easier than it sounds.	0.357564	2025-10-23 13:34:54.083051+00
1902	Nvidia Supplier ASML Soars In Quality Rankings As BofA Sees It Winning Big From $5 Billion Intel-Nvidia Deal - Intel  ( NASDAQ:INTC ) , ASML Holding  ( NASDAQ:ASML ) 	Benzinga	https://www.benzinga.com/markets/equities/25/09/47815933/nvidia-supplier-asml-soars-in-quality-rankings-as-bofa-sees-it-winning-big-from-5-billion-intel-	2025-09-23 12:48:59+00	ASML Holding NV ASML has made a significant leap in its quality ranking, moving decisively within the top echelon of global stocks, as highlighted by the most recent quality percentile data.	0.344451	2025-10-23 13:34:26.682033+00
1903	ASML Invests 1.3B Euro in Mistral AI: Will it Deliver Growth?	Zacks Commentary	https://www.zacks.com/stock/news/2755182/asml-invests-13b-euro-in-mistral-ai-will-it-deliver-growth	2025-09-22 16:38:00+00	ASML Holding is investing 1.3B Euro in Mistral AI for an 11% stake, aiming to boost lithography tools and long-term chipmaking growth.	0.23239	2025-10-23 13:34:26.682033+00
1904	AMAT Trades 54% Above Its 52-Week Low: Time to Hold or Fold the Stock?	Zacks Commentary	https://www.zacks.com/stock/news/2755080/amat-trades-54-above-its-52-week-low-time-to-hold-or-fold-the-stock	2025-09-22 15:42:00+00	Applied Materials rides DRAM strength and R&D push, but China headwinds, weak memory demand and rivals weigh on its outlook.	0.070161	2025-10-23 13:34:30.118226+00
1905	Kessler Topaz Meltzer & Check, LLP Reminds Investors of Deadline for Securities Fraud Class Action Lawsuit Filed Against Fortinet, Inc. - Fortinet  ( NASDAQ:FTNT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48363123/kessler-topaz-meltzer-check-llp-reminds-investors-of-deadline-for-securities-fraud-class-action-la	2025-10-22 18:23:00+00	RADNOR, Pa., Oct. 22, 2025 ( GLOBE NEWSWIRE ) -- The law firm of Kessler Topaz Meltzer & Check, LLP ( www.ktmc.com ) informs investors that a securities class action lawsuit has been filed against Fortinet, Inc. ( "Fortinet" ) ( NASDAQ:FTNT ) on behalf of those who purchased or otherwise ...	0.05591	2025-10-23 13:34:30.118226+00
1906	Here's How Much a $1000 Investment in Palo Alto Networks Made 10 Years Ago Would Be Worth Today	Zacks Commentary	https://www.zacks.com/stock/news/2773845/heres-how-much-a-1000-investment-in-palo-alto-networks-made-10-years-ago-would-be-worth-today	2025-10-22 12:30:02+00	Investing in certain stocks can pay off in the long run, especially if you hold on for a decade or more.	0.227193	2025-10-23 13:34:30.118226+00
1907	3 Slam-Dunk Growth Stocks to Buy Right Now With $100	Motley Fool	https://www.fool.com/investing/2025/10/22/slam-dunk-growth-stocks-to-buy-right-now-with-100/	2025-10-22 12:10:00+00	There are still plenty of opportunities in growth stocks amid the bull market.	0.393763	2025-10-23 13:34:30.118226+00
1908	DEADLINE ALERT for FTNT, MOH, MRX: Law Offices of Howard G. Smith Reminds Shareholders of Opportunity to Lead Securities Fraud Class Actions - Fortinet  ( NASDAQ:FTNT ) , Molina Healthcare  ( NYSE:MOH ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48335157/deadline-alert-for-ftnt-moh-mrx-law-offices-of-howard-g-smith-reminds-shareholders-of-opportunity-	2025-10-21 17:09:40+00	BENSALEM, Pa. , Oct. 21, 2025 ( GLOBE NEWSWIRE ) -- Law Offices of Howard G. Smith reminds investors that class action lawsuits have been filed on behalf of shareholders of the following publicly-traded companies. Investors have until the deadlines listed below to file a lead plaintiff motion.	0.004872	2025-10-23 13:34:30.118226+00
1909	Can Prisma Access Browser Keep PANW Ahead in SASE Growth?	Zacks Commentary	https://www.zacks.com/stock/news/2772993/can-prisma-access-browser-keep-panw-ahead-in-sase-growth	2025-10-21 13:26:00+00	Palo Alto Networks' Prisma Access Browser is fueling rapid SASE growth, with soaring adoption and strong AI-era potential driving long-term momentum.	0.242898	2025-10-23 13:34:30.118226+00
1910	ROSEN, A LEADING LAW FIRM, Encourages Fortinet, Inc. Investors to Secure Counsel Before Important Deadline in Securities Class Action - FTNT - Fortinet  ( NASDAQ:FTNT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48318634/rosen-a-leading-law-firm-encourages-fortinet-inc-investors-to-secure-counsel-before-important-dead	2025-10-20 23:52:00+00	NEW YORK, Oct. 20, 2025 ( GLOBE NEWSWIRE ) -- WHY: Rosen Law Firm, a global investor rights law firm, reminds purchasers of common stock of Fortinet, Inc. ( NASDAQ:FTNT ) between November 8, 2024 and August 6, 2025, both dates inclusive ( the "Class Period" ) , of the important November 21, ...	0.187402	2025-10-23 13:34:30.118226+00
1911	Fortinet  ( FTNT )  Outperforms Broader Market: What You Need to Know	Zacks Commentary	https://www.zacks.com/stock/news/2772575/fortinet-ftnt-outperforms-broader-market-what-you-need-to-know	2025-10-20 21:50:05+00	Fortinet (FTNT) concluded the recent trading session at $84.86, signifying a +1.7% move from its prior day's close.	0.188743	2025-10-23 13:34:30.118226+00
1912	Range Financial Dumps Nearly 30,000 Fortinet Shares for $3.2 Million	Motley Fool	https://www.fool.com/coverage/filings/2025/10/19/range-financial-dumps-30k-fortinet-shares/	2025-10-19 13:47:04+00	Range Financial Group LLC fully exited its position in Fortinet ( NASDAQ:FTNT ) , selling 29,944 shares for an estimated $3.2 million, according to an SEC filing dated Oct. 17.The fund sold its entire position in Fortinet. The position previously accounted for 1.2% of the fund's AUMContinue ...	0.194231	2025-10-23 13:34:30.118226+00
1913	Fortinet, Inc. Sued for Securities Law Violations - Investors Should Contact Levi & Korsinsky Before November 21, 2025 to Discuss Your Rights - FTNT - Fortinet  ( NASDAQ:FTNT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48288594/fortinet-inc-sued-for-securities-law-violations-investors-should-contact-levi-korsinsky-before-nov	2025-10-17 20:42:00+00	NEW YORK, Oct. 17, 2025 ( GLOBE NEWSWIRE ) -- Levi & Korsinsky, LLP notifies investors in Fortinet, Inc. ( "Fortinet, Inc." or the "Company" ) ( NASDAQ:FTNT ) of a class action securities lawsuit.	0.053509	2025-10-23 13:34:30.118226+00
1914	Fortinet, Inc. INVESTOR ALERT: Kirby McInerney LLP Notifies Fortinet, Inc. Investors of Upcoming Lead Plaintiff Deadline in Class Action Lawsuit - Fortinet  ( NASDAQ:FTNT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48265730/fortinet-inc-investor-alert-kirby-mcinerney-llp-notifies-fortinet-inc-investors-of-upcoming-lead-p	2025-10-16 22:00:00+00	NEW YORK, Oct. 16, 2025 ( GLOBE NEWSWIRE ) -- Kirby McInerney LLP reminds Fortinet, Inc. ( "Fortinet" or the "Company" ) ( NASDAQ:FTNT ) investors of the November 21, 2025 deadline to seek the role of lead plaintiff in a pending federal securities class action.	0.170827	2025-10-23 13:34:34.929094+00
1915	FTNT INVESTOR ALERT: Robbins Geller Rudman & Dowd LLP Files Class Action Lawsuit Against Fortinet, Inc. and Announces Opportunity for Investors with Substantial Losses to Lead Class Action Lawsuit - Fortinet  ( NASDAQ:FTNT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48265681/ftnt-investor-alert-robbins-geller-rudman-dowd-llp-files-class-action-lawsuit-against-fortinet-inc	2025-10-16 21:49:29+00	SAN DIEGO, Oct. 16, 2025 ( GLOBE NEWSWIRE ) -- Robbins Geller Rudman & Dowd LLP announces that purchasers or acquirers of Fortinet, Inc. ( NASDAQ:FTNT ) common stock between November 8, 2024 and August 6, 2025, inclusive ( the "Class Period" ) , have until November 21, 2025 to seek appointment ...	-0.004868	2025-10-23 13:34:34.929094+00
1975	Microsoft CEO Satya Nadella's Pay Jumps To Record $96.5 Million Amid AI Growth - Microsoft  ( NASDAQ:MSFT ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48346469/microsoft-ceo-satya-nadellas-pay-jumps-to-record-96-5-million-amid-ai-growth	2025-10-22 07:24:28+00	Microsoft ( NASDAQ:MSFT ) CEO Satya Nadella's annual pay surged by 22% to a record $96.5 million for fiscal 2025, as the software giant's shares surged on the back of artificial intelligence ( AI ) advancements.	0.210063	2025-10-23 13:34:54.083051+00
1916	DEADLINE ALERT for RICK, FTNT, MOH, and MRX: The Law Offices of Frank R. Cruz Reminds Shareholders of Securities Fraud Class Actions - Fortinet  ( NASDAQ:FTNT ) , Molina Healthcare  ( NYSE:MOH ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48255561/deadline-alert-for-rick-ftnt-moh-and-mrx-the-law-offices-of-frank-r-cruz-reminds-shareholders-of-s	2025-10-16 16:06:00+00	LOS ANGELES, Oct. 16, 2025 ( GLOBE NEWSWIRE ) -- The Law Offices of Frank R. Cruz reminds investors that class action lawsuits have been filed on behalf of shareholders of the following publicly-traded companies. Investors have until the deadlines listed below to file a lead plaintiff motion.	-0.051292	2025-10-23 13:34:34.929094+00
1917	Can Fortinet's FortiCloud Expansion Unlock the Next Wave of Growth?	Zacks Commentary	https://www.zacks.com/stock/news/2769573/can-fortinets-forticloud-expansion-unlock-the-next-wave-of-growth	2025-10-15 16:57:00+00	FTNT's FortiCloud expansion, powered by AI and new services, aims to boost automation, scalability and recurring revenue growth.	0.294928	2025-10-23 13:34:34.929094+00
1918	Fortinet vs. CrowdStrike: Which Cybersecurity Stock is a Better Buy?	Zacks Commentary	https://www.zacks.com/stock/news/2769366/fortinet-vs-crowdstrike-which-cybersecurity-stock-is-a-better-buy	2025-10-15 14:59:00+00	CRWD's AI-native platform, AWS/NVIDIA partnerships, and accelerating ARR growth outshine FTNT. Buy CRWD stock for superior upside. hold or wait for FTNT.	0.383886	2025-10-23 13:34:34.929094+00
1919	Fortinet, Inc.  ( FTNT )  Investors: November 21, 2025 Filing Deadline in Securities Class Action - Contact Kessler Topaz Meltzer & Check, LLP - Fortinet  ( NASDAQ:FTNT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48214734/fortinet-inc-ftnt-investors-november-21-2025-filing-deadline-in-securities-class-action-contact-ke	2025-10-14 22:14:00+00	RADNOR, Pa., Oct. 14, 2025 ( GLOBE NEWSWIRE ) -- The law firm of Kessler Topaz Meltzer & Check, LLP ( www.ktmc.com ) informs investors that a securities class action lawsuit has been filed against Fortinet, Inc. ( "Fortinet" ) ( NASDAQ:FTNT ) on behalf of those who purchased or otherwise ...	0.05591	2025-10-23 13:34:34.929094+00
1920	Fortinet  ( FTNT )  Declines More Than Market: Some Information for Investors	Zacks Commentary	https://www.zacks.com/stock/news/2768754/fortinet-ftnt-declines-more-than-market-some-information-for-investors	2025-10-14 21:50:03+00	In the closing of the recent trading day, Fortinet (FTNT) stood at $83.08, denoting a -1.33% move from the preceding trading day.	0.172068	2025-10-23 13:34:34.929094+00
1921	ROSEN, GLOBALLY RESPECTED INVESTOR COUNSEL, Encourages Fortinet, Inc. Investors to Secure Counsel Before Important Deadline in Securities Class Action - FTNT - Fortinet  ( NASDAQ:FTNT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48210650/rosen-globally-respected-investor-counsel-encourages-fortinet-inc-investors-to-secure-counsel-befo	2025-10-14 19:30:00+00	NEW YORK, Oct. 14, 2025 ( GLOBE NEWSWIRE ) -- WHY: Rosen Law Firm, a global investor rights law firm, reminds purchasers of common stock of Fortinet, Inc. ( NASDAQ:FTNT ) between November 8, 2024 and August 6, 2025, both dates inclusive ( the "Class Period" ) , of the important November 21, ...	0.187402	2025-10-23 13:34:34.929094+00
1922	Deadline Alert: Fortinet, Inc.  ( FTNT )  Shareholders Who Lost Money Urged to Contact Glancy Prongay & Murray LLP About Securities Fraud Lawsuit - Fortinet  ( NASDAQ:FTNT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48205963/deadline-alert-fortinet-inc-ftnt-shareholders-who-lost-money-urged-to-contact-glancy-prongay-murra	2025-10-14 16:52:50+00	LOS ANGELES, Oct. 14, 2025 ( GLOBE NEWSWIRE ) -- Glancy Prongay & Murray LLP reminds investors of the upcoming November 21, 2025 deadline to file a lead plaintiff motion in the class action filed on behalf of investors who purchased or otherwise acquired Fortinet, Inc. ( "Fortinet" or the ...	0.074744	2025-10-23 13:34:34.929094+00
1923	3 Cybersecurity Stocks You Can Buy and Hold for the Next Decade	Motley Fool	https://www.fool.com/investing/2025/10/12/cybersecurity-stocks-buy-and-hold-for-decade/	2025-10-12 10:30:00+00	Fortinet, Zscaler, and Cloudflare are all reliable long-term cybersecurity plays.	0.272164	2025-10-23 13:34:34.929094+00
1924	FORTINET REMINDER: Bragar Eagel & Squire, P.C. Urges Fortinet, Inc. Investors to Contact the Firm Before the November 21st Deadline - Fortinet  ( NASDAQ:FTNT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48164718/fortinet-reminder-bragar-eagel-squire-p-c-urges-fortinet-inc-investors-to-contact-the-firm-before-	2025-10-11 15:38:00+00	Bragar Eagel & Squire, P.C. Litigation Partner Brandon Walker Encourages Investors Who Suffered Losses In Fortinet ( FTNT ) To Contact Him Directly To Discuss Their Options	0.014381	2025-10-23 13:34:38.851348+00
1925	FLYYQ CLASS ACTION REMINDER: Stockholders Should Contact Robbins LLP for Information About the Spirit Aviation Holdings, Inc. Class Action - Spirit Aviation Holdings  ( OTC:FLYYQ ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48160114/flyyq-class-action-reminder-stockholders-should-contact-robbins-llp-for-information-about-the-spir	2025-10-10 19:41:02+00	SAN DIEGO, Oct. 10, 2025 ( GLOBE NEWSWIRE ) -- Robbins LLP reminds stockholders that a class action was filed on behalf of persons and entities that purchased or otherwise acquired Spirit Aviation Holdings, Inc. ( OTC:FLYYQ ) securities between May 28, 2025 and August 29, 2025.	-0.026861	2025-10-23 13:34:38.851348+00
1926	DEADLINE ALERT for RICK, FTNT, and MOH: The Law Offices of Frank R. Cruz Reminds Shareholders of Securities Fraud Class Actions - Fortinet  ( NASDAQ:FTNT ) , Molina Healthcare  ( NYSE:MOH ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48153503/deadline-alert-for-rick-ftnt-and-moh-the-law-offices-of-frank-r-cruz-reminds-shareholders-of-secur	2025-10-10 16:06:00+00	LOS ANGELES, Oct. 10, 2025 ( GLOBE NEWSWIRE ) -- The Law Offices of Frank R. Cruz reminds investors that class action lawsuits have been filed on behalf of shareholders of the following publicly-traded companies. Investors have until the deadlines listed below to file a lead plaintiff motion.	-0.039144	2025-10-23 13:34:38.851348+00
1927	Class Action Reminder for FTNT Investors: Kessler Topaz Meltzer & Check, LLP Reminds Fortinet, Inc.  ( FTNT )  Investors of Securities Fraud Class Action Lawsuit - Fortinet  ( NASDAQ:FTNT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48147934/class-action-reminder-for-ftnt-investors-kessler-topaz-meltzer-check-llp-reminds-fortinet-inc-ftnt	2025-10-10 14:03:00+00	RADNOR, Pa., Oct. 10, 2025 ( GLOBE NEWSWIRE ) -- The law firm of Kessler Topaz Meltzer & Check, LLP ( www.ktmc.com ) informs investors that a securities class action lawsuit has been filed against Fortinet, Inc. ( "Fortinet" ) ( NASDAQ:FTNT ) on behalf of those who purchased or otherwise ...	0.05588	2025-10-23 13:34:38.851348+00
1928	Class Action Filed Against Fortinet, Inc.  ( FTNT )  Seeking Recovery for Investors - Contact Levi & Korsinsky - Fortinet  ( NASDAQ:FTNT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48137460/class-action-filed-against-fortinet-inc-ftnt-seeking-recovery-for-investors-contact-levi-korsinsky	2025-10-09 20:25:00+00	NEW YORK, Oct. 09, 2025 ( GLOBE NEWSWIRE ) -- Levi & Korsinsky, LLP notifies investors in Fortinet, Inc. ( "Fortinet, Inc." or the "Company" ) ( NASDAQ:FTNT ) of a class action securities lawsuit.	0.053509	2025-10-23 13:34:38.851348+00
1976	2 Brilliant Growth Stocks to Buy Now and Hold for the Long Term	Motley Fool	https://www.fool.com/investing/2025/10/21/2-brilliant-growth-stocks-to-buy-now-and-hold-for/	2025-10-22 01:10:00+00	These two companies stand to benefit dramatically from the multitrillion-dollar AI infrastructure opportunity.	0.272189	2025-10-23 13:34:54.083051+00
1929	NopalCyber Wins Cybersecurity Solution of the Year for Financial Services, Expanding Track Record of Industry Recognition for Protecting High-Risk Sectors	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48125746/nopalcyber-wins-cybersecurity-solution-of-the-year-for-financial-services-expanding-track-record-o	2025-10-09 14:11:36+00	NEW YORK, Oct. 09, 2025 ( GLOBE NEWSWIRE ) -- NopalCyber, a leading global provider of managed extended detection and response and attack surface management solutions, today announced it has been named Cybersecurity Solution of the Year for Financial Services in the 2025 Cybersecurity ...	0.276372	2025-10-23 13:34:38.851348+00
1930	These 2 Computer and Technology Stocks Could Beat Earnings: Why They Should Be on Your Radar	Zacks Commentary	https://www.zacks.com/stock/news/2765200/these-2-computer-and-technology-stocks-could-beat-earnings-why-they-should-be-on-your-radar	2025-10-09 12:50:03+00	Investors looking for ways to find stocks that are set to beat quarterly earnings estimates should check out the Zacks Earnings ESP.	0.429473	2025-10-23 13:34:38.851348+00
1931	Fortinet  ( FTNT )  Outpaces Stock Market Gains: What You Should Know	Zacks Commentary	https://www.zacks.com/stock/news/2764911/fortinet-ftnt-outpaces-stock-market-gains-what-you-should-know	2025-10-08 21:50:05+00	Fortinet (FTNT) concluded the recent trading session at $86.46, signifying a +1.81% move from its prior day's close.	0.218873	2025-10-23 13:34:38.851348+00
1932	Fortinet Annual Report Indicates AI Skillsets Critical to Cybersecurity Skills Gap Solution	Business Insider	https://markets.businessinsider.com/news/stocks/fortinet-annual-report-indicates-ai-skillsets-critical-to-cybersecurity-skills-gap-solution-1035282296	2025-10-08 13:00:00+00	Fortinet® ( NASDAQ: FTNT ) , the global cybersecurity leader driving the convergence of networking and security, today released its 2025 Global Cybersecurity Skills Gap Report , shedding light on the new and persistent challenges organizations face due to the cybersecurity skills gap.	0.159171	2025-10-23 13:34:38.851348+00
1933	Fortinet Annual Report Indicates AI Skillsets Critical to Cybersecurity Skills Gap Solution	GlobeNewswire	https://www.globenewswire.com/news-release/2025/10/08/3163383/0/en/Fortinet-Annual-Report-Indicates-AI-Skillsets-Critical-to-Cybersecurity-Skills-Gap-Solution.html	2025-10-08 13:00:00+00	87% of cybersecurity professionals expect AI to enhance their roles, offering efficiency and relief amid cyber skill shortages, but they require upskilling to unlock full potential 87% of cybersecurity professionals expect AI to enhance their roles, offering efficiency and relief amid cyber ...	0.159173	2025-10-23 13:34:38.851348+00
1934	FORTINET CLASS ACTION ALERT: Bragar Eagel & Squire, P.C. Reminds Fortinet, Inc. Investors of the November 21st Deadline in the Class Action Lawsuit - Fortinet  ( NASDAQ:FTNT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48085926/fortinet-class-action-alert-bragar-eagel-squire-p-c-reminds-fortinet-inc-investors-of-the-november	2025-10-07 18:50:10+00	Bragar Eagel & Squire, P.C. Litigation Partner Brandon Walker Encourages Investors Who Suffered Losses In Fortinet ( FTNT ) To Contact Him Directly To Discuss Their Options	0.014381	2025-10-23 13:34:41.84921+00
1935	Can Fortinet's SASE & SecOps Surge Reinforce Its Competitive Edge?	Zacks Commentary	https://www.zacks.com/stock/news/2763930/can-fortinets-sase-secops-surge-reinforce-its-competitive-edge	2025-10-07 16:38:00+00	FTNT boosts its competitive edge as SASE and SecOps momentum lift billings guidance and solidify its leadership in integrated cybersecurity.	0.420602	2025-10-23 13:34:41.84921+00
1936	Here's How Much You'd Have If You Invested $1000 in Fortinet a Decade Ago	Zacks Commentary	https://www.zacks.com/stock/news/2763396/heres-how-much-youd-have-if-you-invested-1000-in-fortinet-a-decade-ago	2025-10-07 12:30:02+00	Why investing for the long run, especially if you buy certain popular stocks, could reap huge rewards.	0.272152	2025-10-23 13:34:41.84921+00
1937	Kessler Topaz Meltzer & Check, LLP Reminds Fortinet, Inc. Investors of Important Deadline in Securities Fraud Class Action Lawsuit - Fortinet  ( NASDAQ:FTNT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48058821/kessler-topaz-meltzer-check-llp-reminds-fortinet-inc-investors-of-important-deadline-in-securities	2025-10-06 23:08:00+00	RADNOR, Pa., Oct. 06, 2025 ( GLOBE NEWSWIRE ) -- The law firm of Kessler Topaz Meltzer & Check, LLP ( www.ktmc.com ) informs investors that a securities class action lawsuit has been filed against Fortinet, Inc. ( "Fortinet" ) ( NASDAQ:FTNT ) on behalf of those who purchased or otherwise ...	0.055918	2025-10-23 13:34:41.84921+00
1938	Contact Levi & Korsinsky by November 21, 2025 Deadline to Join Class Action Against Fortinet, Inc.  ( FTNT )  - Fortinet  ( NASDAQ:FTNT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48056941/contact-levi-korsinsky-by-november-21-2025-deadline-to-join-class-action-against-fortinet-inc-ftnt	2025-10-06 20:53:00+00	NEW YORK, Oct. 06, 2025 ( GLOBE NEWSWIRE ) -- Levi & Korsinsky, LLP notifies investors in Fortinet, Inc. ( "Fortinet, Inc." or the "Company" ) ( NASDAQ:FTNT ) of a class action securities lawsuit.	0.053509	2025-10-23 13:34:41.84921+00
1939	Deadline Alert: Fortinet, Inc.  ( FTNT )  Shareholders Who Lost Money Urged To Contact Glancy Prongay & Murray LLP About Securities Fraud Lawsuit - Fortinet  ( NASDAQ:FTNT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48056256/deadline-alert-fortinet-inc-ftnt-shareholders-who-lost-money-urged-to-contact-glancy-prongay-murra	2025-10-06 20:28:15+00	LOS ANGELES, Oct. 06, 2025 ( GLOBE NEWSWIRE ) -- Glancy Prongay & Murray LLP reminds investors of the upcoming November 21, 2025 deadline to file a lead plaintiff motion in the class action filed on behalf of investors who purchased or otherwise acquired Fortinet, Inc. ( "Fortinet" or the ...	0.074744	2025-10-23 13:34:41.84921+00
1940	Why Fortinet  ( FTNT )  is Poised to Beat Earnings Estimates Again	Zacks Commentary	https://www.zacks.com/stock/news/2762953/why-fortinet-ftnt-is-poised-to-beat-earnings-estimates-again	2025-10-06 16:10:03+00	Fortinet (FTNT) has an impressive earnings surprise history and currently possesses the right combination of the two key ingredients for a likely beat in its next quarterly report.	0.335622	2025-10-23 13:34:41.84921+00
1941	Roche receives CE Mark for AI-based Kidney Klinrisk Algorithm ( 1 )  and launches new comprehensive chronic kidney disease  ( CKD )  algorithm panel	GlobeNewswire	https://www.globenewswire.com/news-release/2025/10/06/3161385/0/en/Roche-receives-CE-Mark-for-AI-based-Kidney-Klinrisk-Algorithm-1-and-launches-new-comprehensive-chronic-kidney-disease-CKD-algorithm-panel.html	2025-10-06 05:00:00+00	Basel, 6 October 2025 - Roche ( SIX: RO, ROG. OTCQX: RHHBY ) , in collaboration with KlinRisk, Inc., has received the CE-mark for the first AI-based risk stratification tool to assess progressive decline in kidney function.	0.182824	2025-10-23 13:34:41.84921+00
1942	ROSEN, HIGHLY RANKED INVESTOR COUNSEL, Encourages Fortinet, Inc. Investors to Secure Counsel Before Important Deadline in Securities Class Action - FTNT - Fortinet  ( NASDAQ:FTNT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48032248/rosen-highly-ranked-investor-counsel-encourages-fortinet-inc-investors-to-secure-counsel-before-im	2025-10-04 17:43:00+00	NEW YORK, Oct. 04, 2025 ( GLOBE NEWSWIRE ) -- WHY: Rosen Law Firm, a global investor rights law firm, reminds purchasers of common stock of Fortinet, Inc. ( NASDAQ:FTNT ) between November 8, 2024 and August 6, 2025, both dates inclusive ( the "Class Period" ) , of the important November 21, ...	0.187402	2025-10-23 13:34:41.84921+00
1943	FORTINET LAWSUIT ALERT: Bragar Eagel & Squire, P.C. Reminds Fortinet, Inc. Investors to Contact the Firm About Their Rights in Class Action Lawsuit - Fortinet  ( NASDAQ:FTNT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48032031/fortinet-lawsuit-alert-bragar-eagel-squire-p-c-reminds-fortinet-inc-investors-to-contact-the-firm-	2025-10-04 15:00:00+00	Bragar Eagel & Squire, P.C. Litigation Partner Brandon Walker Encourages Investors Who Suffered Losses In Fortinet ( FTNT ) To Contact Him Directly To Discuss Their Options	0.014381	2025-10-23 13:34:41.84921+00
1944	Portnoy Law Firm Announces Class Action on Behalf of Fortinet, Inc. Investors - Fortinet  ( NASDAQ:FTNT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48025598/portnoy-law-firm-announces-class-action-on-behalf-of-fortinet-inc-investors	2025-10-03 18:41:27+00	LOS ANGELES, Oct. 03, 2025 ( GLOBE NEWSWIRE ) -- The Portnoy Law Firm advises Fortinet, Inc., ( "Fortinet" or the "Company" ) ( NASDAQ:FTNT ) investors of a class action on behalf of investors that bought securities between November 8, 2024 and August 6, 2025, inclusive ( the "Class Period" ) .	0.09358	2025-10-23 13:34:44.89504+00
1945	Top Technology Executives Recognized at the 2025 Philadelphia ORBIE Awards	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48024413/top-technology-executives-recognized-at-the-2025-philadelphia-orbie-awards	2025-10-03 17:57:58+00	PHILADELPHIA, Oct. 03, 2025 ( GLOBE NEWSWIRE ) -- The 2025 Philadelphia ORBIE Awards recognized the exceptional leadership and innovation of top technology executives from Exelon, UGI Corporation, ACR, Independence Blue Cross, Weis Markets Inc, Penn Engineering & Manufacturing Corporation, ...	0.424352	2025-10-23 13:34:44.89504+00
1946	DEADLINE ALERT for RICK and FTNT: The Law Offices of Frank R. Cruz Reminds Shareholders of Securities Fraud Class Actions - Fortinet  ( NASDAQ:FTNT ) , RCI Hospitality Hldgs  ( NASDAQ:RICK ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48021319/deadline-alert-for-rick-and-ftnt-the-law-offices-of-frank-r-cruz-reminds-shareholders-of-securitie	2025-10-03 16:08:00+00	LOS ANGELES, Oct. 03, 2025 ( GLOBE NEWSWIRE ) -- The Law Offices of Frank R. Cruz reminds investors that class action lawsuits have been filed on behalf of shareholders of the following publicly-traded companies. Investors have until the deadlines listed below to file a lead plaintiff motion.	-0.026958	2025-10-23 13:34:44.89504+00
1947	Fortinet  ( FTNT )  Outpaces Stock Market Gains: What You Should Know	Zacks Commentary	https://www.zacks.com/stock/news/2761060/fortinet-ftnt-outpaces-stock-market-gains-what-you-should-know	2025-10-02 21:50:04+00	The latest trading day saw Fortinet (FTNT) settling at $86.29, representing a +1.3% change from its previous close.	0.217997	2025-10-23 13:34:44.89504+00
1948	Fortinet to Announce Third Quarter 2025 Financial Results	GlobeNewswire	https://www.globenewswire.com/news-release/2025/10/02/3160381/0/en/Fortinet-to-Announce-Third-Quarter-2025-Financial-Results.html	2025-10-02 13:00:00+00	SUNNYVALE, Calif., Oct. 02, 2025 ( GLOBE NEWSWIRE ) -- Fortinet® ( NASDAQ: FTNT ) , the global cybersecurity leader driving the convergence of networking and security, announced that it will hold a conference call to discuss its third quarter 2025 financial results on Wednesday, November 5, at ...	0.262484	2025-10-23 13:34:44.89504+00
1949	1 Growth Stock Down 26% to Buy Right Now	Motley Fool	https://www.fool.com/investing/2025/10/02/1-growth-stock-down-26-to-buy-right-now/	2025-10-02 10:30:00+00	This cybersecurity stock's fortunes could turn around thanks to its improving growth rate.	0.319841	2025-10-23 13:34:44.89504+00
1950	Robbins LLP Reminds FLYYQ Stockholders of the Class Action Lawsuit on Behalf of Spirit Aviation Holdings, Inc. Investors - Spirit Aviation Holdings  ( OTC:FLYYQ ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g47984973/robbins-llp-reminds-flyyq-stockholders-of-the-class-action-lawsuit-on-behalf-of-spirit-aviation-ho	2025-10-01 22:23:25+00	SAN DIEGO, Oct. 01, 2025 ( GLOBE NEWSWIRE ) -- Robbins LLP reminds stockholders that a class action was filed on behalf of persons and entities that purchased or otherwise acquired Spirit Aviation Holdings, Inc. ( NASDAQ:FLYYQ ) securities between May 28, 2025 and August 29, 2025.	-0.026861	2025-10-23 13:34:44.89504+00
1951	P/E Ratio Insights for Fortinet - Fortinet  ( NASDAQ:FTNT ) 	Benzinga	https://www.benzinga.com/insights/news/25/10/47974344/pe-ratio-insights-for-fortinet	2025-10-01 16:00:33+00	In the current session, the stock is trading at $84.55, after a 0.56% increase. Over the past month, Fortinet Inc. ( NASDAQ:FTNT ) stock increased by 10.41%, and in the past year, by 9.83%.	0.078142	2025-10-23 13:34:44.89504+00
1952	Shareholders who lost money in shares against Fortinet, Inc.  ( NASDAQ: FTNT )  Should Contact Wolf Haldenstein Immediately - Fortinet  ( NASDAQ:FTNT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g47965385/shareholders-who-lost-money-in-shares-against-fortinet-inc-nasdaq-ftnt-should-contact-wolf-haldens	2025-10-01 12:12:00+00	NEW YORK, Oct. 01, 2025 ( GLOBE NEWSWIRE ) -- Wolf Haldenstein Adler Freeman & Herz LLP reminds investors that a securities class action lawsuit has been filed against Fortinet, Inc. ( NASDAQ: FTNT ) ( "Fortinet " or the "Company" ) .	0.153841	2025-10-23 13:34:44.89504+00
1953	FORTINET CLASS ACTION ALERT: Bragar Eagel & Squire, P.C. Reminds Investors a Class Action Lawsuit Has Been Filed Against Fortinet, Inc. and Encourages Investors to Contact the Firm - Fortinet  ( NASDAQ:FTNT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/09/g47956904/fortinet-class-action-alert-bragar-eagel-squire-p-c-reminds-investors-a-class-action-lawsuit-has-b	2025-09-30 21:02:00+00	Bragar Eagel & Squire, P.C. Litigation Partner Brandon Walker Encourages Investors Who Suffered Losses In Fortinet ( FTNT ) To Contact Him Directly To Discuss Their Options	0.014381	2025-10-23 13:34:44.89504+00
1954	Fortinet, Inc.  ( FTNT )  Investors: November 21, 2025 Filing Deadline in Securities Class Action - Contact Kessler Topaz Meltzer & Check, LLP - Fortinet  ( NASDAQ:FTNT ) 	Benzinga	https://www.benzinga.com/pressreleases/25/09/g47949267/fortinet-inc-ftnt-investors-november-21-2025-filing-deadline-in-securities-class-action-contact-ke	2025-09-30 16:42:00+00	RADNOR, Pa., Sept. 30, 2025 ( GLOBE NEWSWIRE ) -- The law firm of Kessler Topaz Meltzer & Check, LLP ( www.ktmc.com ) informs investors that a securities class action lawsuit has been filed against Fortinet, Inc. ( "Fortinet" ) ( NASDAQ:FTNT ) on behalf of those who purchased or otherwise ...	0.051121	2025-10-23 13:34:48.035454+00
1955	Digital Brands Group Explores Quantum Computing Initiatives Using Microsoft Azure Quantum	GlobeNewswire	https://www.globenewswire.com/news-release/2025/10/23/3172135/0/en/Digital-Brands-Group-Explores-Quantum-Computing-Initiatives-Using-Microsoft-Azure-Quantum.html	2025-10-23 13:25:00+00	Austin, Texas, Oct. 23, 2025 ( GLOBE NEWSWIRE ) -- Digital Brands Group, Inc. ( NASDAQ:DBGI ) ( the "Company," "Digital Brands Group" or "DBG" ) today announces that its technology arm has begun exploring advanced quantum initiatives through Microsoft Azure Quantum, a leading cloud-based ...	0.211037	2025-10-23 13:34:48.035454+00
1956	CoreWeave Is 'Frightening… It's Unbelievable,' Says Expert, Expecting Its Revenue To Multiply Nearly 5x By 2028 - CoreWeave  ( NASDAQ:CRWV ) 	Benzinga	https://www.benzinga.com/markets/equities/25/10/48373546/coreweave-is-frightening-its-unbelievable-says-expert-expecting-its-revenue-to-multiply-nearly-5	2025-10-23 08:36:52+00	Specialist AI cloud provider CoreWeave Inc. ( NASDAQ:CRWV ) is on a "frightening" growth trajectory, with revenue projected to scale to "mid-$20s billion" by 2028, according to a leading digital infrastructure analyst. This forecast suggests its revenue could multiply "nearly 5x" from its 2025 ...	-0.002399	2025-10-23 13:34:48.035454+00
1957	Trace One and delaware Partner to Launch Legi Food: AI Solution That Cuts Food Compliance Time by 80%	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48373182/trace-one-and-delaware-partner-to-launch-legi-food-ai-solution-that-cuts-food-compliance-time-by-8	2025-10-23 07:17:00+00	PARIS and BRUSSELS, Oct. 23, 2025 ( GLOBE NEWSWIRE ) -- Trace One, a leading SaaS provider of Product Lifecycle Management ( PLM ) and compliance solutions for the food and beverage industry, today announced a strategic partnership with delaware, a global consulting company specializing in ...	0.345102	2025-10-23 13:34:48.035454+00
1958	Billionaire Bill Gates Has 79% of His $48 Billion Portfolio Invested in Just 4 Stocks	Motley Fool	https://www.fool.com/investing/2025/10/23/billionaire-bill-gates-has-79-of-his-48-billion-po/	2025-10-23 07:02:00+00	While the billionaire philanthropist owns dozens of stocks, just four make up the majority of his portfolio.	0.297623	2025-10-23 13:34:48.035454+00
1959	OpenAI To Offer UK Data Residency From Friday: What It Means - Alphabet  ( NASDAQ:GOOG ) , Alphabet  ( NASDAQ:GOOGL ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48371959/openai-to-offer-uk-data-residency-from-friday-what-it-means	2025-10-23 04:19:45+00	OpenAI will begin offering U.K. government agencies and businesses the option to store data within the country starting Friday. The initiative, launched in collaboration with the Ministry of Justice, will be announced by Deputy Prime Minister David Lammy at the OpenAI Frontiers event, reported ...	0.175412	2025-10-23 13:34:48.035454+00
1960	MSFT vs. AAPL: Which Mega-Cap Tech Stock is the Better Buy Now?	Zacks Commentary	https://www.zacks.com/stock/news/2774470/msft-vs-aapl-which-mega-cap-tech-stock-is-the-better-buy-now	2025-10-22 17:21:00+00	Microsoft outpaces Apple with 39% Azure growth, $13B AI business, and clear enterprise AI monetization, while Apple faces tariff headwinds and uncertain AI revenues.	0.380618	2025-10-23 13:34:48.035454+00
1961	IBM Expands watsonx Capabilities: Will This Boost Customer Growth?	Zacks Commentary	https://www.zacks.com/stock/news/2774370/ibm-expands-watsonx-capabilities-will-this-boost-customer-growth	2025-10-22 15:46:00+00	IBM teams up with Groq to boost watsonx speed, cost efficiency and regulatory compliance for agentic AI deployment.	0.361695	2025-10-23 13:34:48.035454+00
1962	In-Depth Analysis: Microsoft Versus Competitors In Software Industry - Microsoft  ( NASDAQ:MSFT ) 	Benzinga	https://www.benzinga.com/insights/news/25/10/48356114/in-depth-analysis-microsoft-versus-competitors-in-software-industry	2025-10-22 15:00:45+00	Amidst the fast-paced and highly competitive business environment of today, conducting comprehensive company analysis is essential for investors and industry enthusiasts.	0.231626	2025-10-23 13:34:48.035454+00
1963	Walmart pauses H-1B visas for job candidates as Trump hikes fees	CNBC	https://www.cnbc.com/2025/10/22/walmart-h-1b-visa-job-offers-trump-fee.html	2025-10-22 14:56:35+00	Walmart is one of the largest employers of H-1B visa holders in the U.S.	0.188355	2025-10-23 13:34:48.035454+00
1964	O Company Launches O Mini Server: The World's First Private Wearable Solution for Cloud-Free Data Control	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48354655/o-company-launches-o-mini-server-the-worlds-first-private-wearable-solution-for-cloud-free-data-co	2025-10-22 14:21:53+00	WASHINGTON, Oct. 22, 2025 ( GLOBE NEWSWIRE ) -- O Company today announced the official launch of the O Mini Server, the world's first mini private server in a wearable format that allows users to manage, store, access, and share data, anywhere in the world, securely and directly, right on their ...	0.181788	2025-10-23 13:34:51.136788+00
1965	Microsoft  ( MSFT )  Reports Next Week: Wall Street Expects Earnings Growth	Zacks Commentary	https://www.zacks.com/stock/news/2774147/microsoft-msft-reports-next-week-wall-street-expects-earnings-growth	2025-10-22 14:00:27+00	Microsoft (MSFT) doesn't possess the right combination of the two key ingredients for a likely earnings beat in its upcoming report. Get prepared with the key expectations.	0.147335	2025-10-23 13:34:51.136788+00
1966	Salesforce vs. Adobe: Which Cloud-Software Stock Is the Stronger Buy?	Zacks Commentary	https://www.zacks.com/stock/news/2773983/salesforce-vs-adobe-which-cloud-software-stock-is-the-stronger-buy	2025-10-22 13:32:00+00	CRM's AI momentum, profitability gains and resilient performance make it the stronger buy over ADBE in the cloud software race.	0.391008	2025-10-23 13:34:51.136788+00
1967	Why Microsoft  ( MSFT )  is a Top Stock for the Long-Term	Zacks Commentary	https://www.zacks.com/stock/news/2774017/why-microsoft-msft-is-a-top-stock-for-the-long-term	2025-10-22 13:30:01+00	Wondering how to pick strong, market-beating stocks for your investment portfolio? Look no further than the Zacks Focus List.	0.356585	2025-10-23 13:34:51.136788+00
1968	CEG Outperforms Its Industry in 6 Months: How to Play the Stock?	Zacks Commentary	https://www.zacks.com/stock/news/2774251/ceg-outperforms-its-industry-in-6-months-how-to-play-the-stock	2025-10-22 13:24:00+00	Constellation Energy's 79% surge in six months reflects its nuclear strength, clean-energy focus and shareholder-friendly growth strategy.	0.537483	2025-10-23 13:34:51.136788+00
1969	How To Trade SPY, Top Tech Stocks Using Technical Analysis - Microsoft  ( NASDAQ:MSFT ) , NVIDIA  ( NASDAQ:NVDA ) 	Benzinga	https://www.benzinga.com/Opinion/25/10/48350448/how-to-trade-spy-top-tech-stocks-using-technical-analysis-46	2025-10-22 12:11:25+00	Today brings another quiet economic session with few major data releases. The Treasury's 20-Year Bond Auction at 1 PM Eastern will attract attention from fixed income markets but is unlikely to meaningfully impact equities unless yields move sharply.	0.053257	2025-10-23 13:34:51.136788+00
1970	CanadianSME Small Business Summit 2025: AI-Driven Innovation: Empowering Canadian SMEs Join Canada's Top Entrepreneurs, Thought Leaders & Innovators on October 24, 2025	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48349971/canadiansme-small-business-summit-2025-ai-driven-innovation-empowering-canadian-smes-join-canadas-	2025-10-22 12:00:00+00	MISSISSAUGA, Ontario, Oct. 22, 2025 ( GLOBE NEWSWIRE ) -- CanadianSME Small Business Magazine is proud to announce the 6th annual Small Business Summit, returning this year in collaboration with Amazon Business for the third consecutive year on October 24, 2025, at the Metro Toronto Convention ...	0.372834	2025-10-23 13:34:51.136788+00
1971	Better Artificial Intelligence Stock: BigBear.ai vs. C3.ai	Motley Fool	https://www.fool.com/investing/2025/10/22/better-artificial-intelligence-stock-bigbearai-vs/	2025-10-22 11:00:00+00	These artificial intelligence companies hit bumps in the road as they pursue prosperity amid the AI boom.	0.226881	2025-10-23 13:34:51.136788+00
1972	Could This Underrated Stock Become the Next Nebius Group?	Motley Fool	https://www.fool.com/investing/2025/10/22/could-this-underrated-stock-become-the-next-hot-ti/	2025-10-22 10:30:00+00	Nebius Group has become a darling of the artificial intelligence (AI) revolution thanks to its cloud-based infrastructure services.	0.305455	2025-10-23 13:34:51.136788+00
1973	What Is One of the Best Artificial Intelligence  ( AI )  Stocks to Buy Now?	Motley Fool	https://www.fool.com/investing/2025/10/22/what-is-one-of-the-best-artificial-intelligence-ai/	2025-10-22 10:15:00+00	This big tech company is built to thrive long-term.	0.324116	2025-10-23 13:34:51.136788+00
1974	Is Arista Networks a Smart Buy for the Next Phase of AI Infrastructure?	Motley Fool	https://www.fool.com/investing/2025/10/22/arista-networks-smart-buy-next-ai-infrastructure/	2025-10-22 08:35:00+00	The AI-oriented networking company still has plenty of room to grow.	0.195054	2025-10-23 13:34:54.083051+00
1978	Is Fabrinet  ( FN )  Stock Outpacing Its Computer and Technology Peers This Year?	Zacks Commentary	https://www.zacks.com/stock/news/2773050/is-fabrinet-fn-stock-outpacing-its-computer-and-technology-peers-this-year	2025-10-21 13:40:03+00	Here is how Fabrinet (FN) and eGain (EGAN) have performed compared to their sector so far this year.	0.259222	2025-10-23 13:34:54.083051+00
1979	Fabrinet to Announce First Quarter Fiscal Year 2026 Financial Results on November 3, 2025	GlobeNewswire	https://www.globenewswire.com/news-release/2025/10/20/3169778/0/en/Fabrinet-to-Announce-First-Quarter-Fiscal-Year-2026-Financial-Results-on-November-3-2025.html	2025-10-20 20:15:00+00	BANGKOK, Thailand, Oct. 20, 2025 ( GLOBE NEWSWIRE ) -- Fabrinet ( NYSE: FN ) , a leading provider of advanced optical packaging and precision optical, electro-mechanical and electronic manufacturing services to original equipment manufacturers of complex products, today announced it will release ...	0.185266	2025-10-23 13:34:54.083051+00
1980	Here's How Much You Would Have Made Owning Fabrinet Stock In The Last 10 Years - Fabrinet  ( NYSE:FN ) 	Benzinga	https://www.benzinga.com/insights/news/25/10/48289480/heres-how-much-you-would-have-made-owning-fabrinet-stock-in-the-last-10-years	2025-10-17 21:16:03+00	Fabrinet ( NYSE:FN ) has outperformed the market over the past 10 years by 21.64% on an annualized basis producing an average annual return of 34.1%. Currently, Fabrinet has a market capitalization of $14.65 billion.	0.158543	2025-10-23 13:34:54.083051+00
1981	Fabrinet Announces Retirement of Founder and Chairman Tom Mitchell After 25 Years of Visionary Leadership	GlobeNewswire	https://www.globenewswire.com/news-release/2025/10/17/3168536/0/en/Fabrinet-Announces-Retirement-of-Founder-and-Chairman-Tom-Mitchell-After-25-Years-of-Visionary-Leadership.html	2025-10-17 11:00:00+00	BANGKOK, Oct. 17, 2025 ( GLOBE NEWSWIRE ) -- Fabrinet ( NYSE: FN ) , a leading provider of advanced optical packaging and precision optical, electro-mechanical and electronic manufacturing services to original equipment manufacturers of complex products, today announced the retirement of company ...	0.447078	2025-10-23 13:34:54.083051+00
1982	Fabrinet Announces Retirement of Founder and Chairman Tom Mitchell After 25 Years of Visionary Leadership - Fabrinet  ( NYSE:FN ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48270947/fabrinet-announces-retirement-of-founder-and-chairman-tom-mitchell-after-25-years-of-visionary-lea	2025-10-17 11:00:00+00	BANGKOK, Oct. 17, 2025 ( GLOBE NEWSWIRE ) -- Fabrinet ( NYSE:FN ) , a leading provider of advanced optical packaging and precision optical, electro-mechanical and electronic manufacturing services to original equipment manufacturers of complex products, today announced the retirement of company ...	0.43718	2025-10-23 13:34:54.083051+00
1983	Fabrinet Appoints Caroline Dowling to Board of Directors	GlobeNewswire	https://www.globenewswire.com/news-release/2025/10/16/3168334/0/en/Fabrinet-Appoints-Caroline-Dowling-to-Board-of-Directors.html	2025-10-16 20:15:00+00	BANGKOK, Oct. 16, 2025 ( GLOBE NEWSWIRE ) -- Fabrinet ( NYSE: FN ) , a leading provider of advanced optical packaging and precision optical, electro-mechanical and electronic manufacturing services to original equipment manufacturers of complex products, today announced that Caroline Dowling has ...	0.270488	2025-10-23 13:34:54.083051+00
1984	Fabrinet Appoints Caroline Dowling to Board of Directors - CRH  ( NYSE:CRH ) , Fabrinet  ( NYSE:FN ) 	Benzinga	https://www.benzinga.com/pressreleases/25/10/g48263735/fabrinet-appoints-caroline-dowling-to-board-of-directors	2025-10-16 20:15:00+00	BANGKOK, Oct. 16, 2025 ( GLOBE NEWSWIRE ) -- Fabrinet ( NYSE:FN ) , a leading provider of advanced optical packaging and precision optical, electro-mechanical and electronic manufacturing services to original equipment manufacturers of complex products, today announced that Caroline Dowling has ...	0.261527	2025-10-23 13:34:57.119025+00
1985	Enerpac Tool Group Posts Upbeat Results, Joins Praxis Precision Medicines, J B Hunt, Salesforce And Other Big Stocks Moving Higher On Thursday - Cellectis  ( NASDAQ:CLLS ) , Salesforce  ( NYSE:CRM ) 	Benzinga	https://www.benzinga.com/news/25/10/48251227/enerpac-tool-group-posts-upbeat-results-joins-praxis-precision-medicines-j-b-hunt-salesforce-and-other-big-s	2025-10-16 14:17:59+00	U.S. stocks were higher, with the Nasdaq Composite gaining more than 50 points on Thursday. Shares of Enerpac Tool Group Corp ( NYSE:EPAC ) rose sharply during Thursday's session following better-than-expected fourth-quarter results.	0.30241	2025-10-23 13:34:57.119025+00
1986	Micron Technology To Rally Around 25%? Here Are 10 Top Analyst Forecasts For Thursday - Bank of America  ( NYSE:BAC ) , Crane NXT  ( NYSE:CXT ) 	Benzinga	https://www.benzinga.com/analyst-stock-ratings/price-target/25/10/48248563/micron-technology-to-rally-around-25-here-are-10-top-analyst-forecasts-for-thu	2025-10-16 13:16:04+00	Top Wall Street analysts changed their outlook on these top names. For a complete view of all analyst rating changes, including upgrades and downgrades, please see our analyst ratings page. Wells Fargo cut Crane NXT, Co. ( NYSE:CXT ) price target from $31 to $29.	0.116078	2025-10-23 13:34:57.119025+00
1987	Is the Market Bullish or Bearish on Fabrinet? - Fabrinet  ( NYSE:FN ) 	Benzinga	https://www.benzinga.com/insights/short-sellers/25/10/48201620/is-the-market-bullish-or-bearish-on-fabrinet	2025-10-14 15:00:45+00	Fabrinet's ( NYSE:FN ) short interest as a percent of float has fallen 6.55% since its last report. According to exchange reported data, there are now 1.81 million shares sold short, which is 7.13% of all regular shares that are available for trading.	0.255112	2025-10-23 13:34:57.119025+00
1988	Should iShares Russell 2000 Growth ETF  ( IWO )  Be on Your Investing Radar?	Zacks Commentary	https://www.zacks.com/stock/news/2767127/should-ishares-russell-2000-growth-etf-iwo-be-on-your-investing-radar	2025-10-13 10:20:02+00	Style Box ETF report for ...	0.260339	2025-10-23 13:34:57.119025+00
1989	These Hidden AI Infrastructure Plays Could Surprise Long-Term Investors	Motley Fool	https://www.fool.com/investing/2025/10/09/hidden-ai-infrastructure-plays-could-surprise-long/	2025-10-09 11:00:00+00	Investors should consider picking stakes in hidden AI infrastructure players for long-term gains.	0.219867	2025-10-23 13:34:57.119025+00
1990	Should Vanguard Russell 2000 ETF  ( VTWO )  Be on Your Investing Radar?	Zacks Commentary	https://www.zacks.com/stock/news/2764174/should-vanguard-russell-2000-etf-vtwo-be-on-your-investing-radar	2025-10-08 10:20:03+00	Style Box ETF report for ...	0.145743	2025-10-23 13:34:57.119025+00
1991	Should Vanguard Russell 2000 Growth ETF  ( VTWG )  Be on Your Investing Radar?	Zacks Commentary	https://www.zacks.com/stock/news/2764172/should-vanguard-russell-2000-growth-etf-vtwg-be-on-your-investing-radar	2025-10-08 10:20:03+00	Style Box ETF report for ...	0.328057	2025-10-23 13:34:57.119025+00
1992	Should Global X Russell 2000 ETF  ( RSSL )  Be on Your Investing Radar?	Zacks Commentary	https://www.zacks.com/stock/news/2760002/should-global-x-russell-2000-etf-rssl-be-on-your-investing-radar	2025-10-01 10:20:03+00	Style Box ETF report for ...	0.175586	2025-10-23 13:34:57.119025+00
1993	Is FN's Diversification Beyond Optics Poised to Drive Further Upside?	Zacks Commentary	https://www.zacks.com/stock/news/2756955/is-fns-diversification-beyond-optics-poised-to-drive-further-upside	2025-09-25 13:35:00+00	Non-optical sales are now a major growth engine for Fabrinet, with momentum in EV and laser markets expected to continue.	0.348785	2025-10-23 13:34:57.119025+00
2026	Jack Henry to Report Q4 Earnings: What to Expect From the Stock?	Zacks Commentary	https://www.zacks.com/stock/news/2716707/jack-henry-to-report-q4-earnings-what-to-expect-from-the-stock	2025-08-15 13:14:00+00	JKHY's Q4 results may reflect gains from cloud migration, payments growth and strong demand for its platform.	0.277818	2025-10-23 13:35:10.067157+00
1994	If You Invested $100 In Fabrinet Stock 15 Years Ago, You Would Have This Much Today - Fabrinet  ( NYSE:FN ) 	Benzinga	https://www.benzinga.com/insights/news/25/09/47841552/if-you-invested-100-in-fabrinet-stock-15-years-ago-you-would-have-this-much-today	2025-09-24 14:00:53+00	Fabrinet FN has outperformed the market over the past 15 years by 11.09% on an annualized basis producing an average annual return of 23.54%. Currently, Fabrinet has a market capitalization of $13.61 billion.	0.160819	2025-10-23 13:35:00.270515+00
1995	Fabrinet Appreciates 74% YTD: Should You Buy, Sell, or Hold the Stock?	Zacks Commentary	https://www.zacks.com/stock/news/2755206/fabrinet-appreciates-74-ytd-should-you-buy-sell-or-hold-the-stock	2025-09-22 16:57:00+00	FN rides momentum in datacom and optics, but first-quarter fiscal 2026 guidance reveals near-term growth may slow.	0.268146	2025-10-23 13:35:00.270515+00
1996	Should iShares Russell 2000 ETF  ( IWM )  Be on Your Investing Radar?	Zacks Commentary	https://www.zacks.com/stock/news/2753779/should-ishares-russell-2000-etf-iwm-be-on-your-investing-radar	2025-09-19 10:20:01+00	Style Box ETF report for ...	0.131651	2025-10-23 13:35:00.270515+00
1997	Can Data Center Interconnect Fuel Fresh Upside for FN Stock?	Zacks Commentary	https://www.zacks.com/stock/news/2753643/can-data-center-interconnect-fuel-fresh-upside-for-fn-stock	2025-09-18 17:27:00+00	Fabrinet expands into Data Center Interconnect to capture growing AI and cloud infrastructure demand.	0.293527	2025-10-23 13:35:00.270515+00
1998	Is Fabrinet Gaining or Losing Market Support? - Fabrinet  ( NYSE:FN ) 	Benzinga	https://www.benzinga.com/insights/short-sellers/25/09/47726110/is-fabrinet-gaining-or-losing-market-support	2025-09-17 20:00:35+00	Fabrinet's FN short interest as a percent of float has risen 45.45% since its last report. According to exchange reported data, there are now 1.83 million shares sold short, which is 7.2% of all regular shares that are available for trading.	0.284971	2025-10-23 13:35:00.270515+00
1999	If You Invested $1000 In Fabrinet Stock 10 Years Ago, You Would Have This Much Today - Fabrinet  ( NYSE:FN ) 	Benzinga	https://www.benzinga.com/insights/news/25/09/47720535/if-you-invested-1000-in-fabrinet-stock-10-years-ago-you-would-have-this-much-today	2025-09-17 16:30:30+00	Fabrinet FN has outperformed the market over the past 10 years by 20.94% on an annualized basis producing an average annual return of 33.95%. Currently, Fabrinet has a market capitalization of $12.69 billion.	0.181243	2025-10-23 13:35:00.270515+00
2000	25 Stocks That Could Jump 100x According To This 40-Year Study - Argan  ( NYSE:AGX ) , Agilysys  ( NASDAQ:AGYS ) 	Benzinga	https://www.benzinga.com/trading-ideas/long-ideas/25/09/47674412/25-stocks-that-could-jump-100x-according-to-this-40-year-study	2025-09-15 17:00:03+00	If you haven't read Thomas W. Phelps's"100 to 1 in the Stock Market," you owe it to yourself to pick it up. I've read hundreds of investing books across my career, but this one stands near the top of the pile.	0.269799	2025-10-23 13:35:00.270515+00
2001	Can Fabrinet's Optical Packaging Momentum Deliver Sustainable Growth?	Zacks Commentary	https://www.zacks.com/stock/news/2751026/can-fabrinets-optical-packaging-momentum-deliver-sustainable-growth	2025-09-12 16:27:00+00	FN builds momentum as AI and data center trends drive demand for next-gen optical packaging precision.	0.269514	2025-10-23 13:35:00.270515+00
2002	Fabrinet vs. TE Connectivity: Which Electronics Stock is the Better Buy?	Zacks Commentary	https://www.zacks.com/stock/news/2750201/fabrinet-vs-te-connectivity-which-electronics-stock-is-the-better-buy	2025-09-11 15:10:00+00	FN's optical edge shines, but TEL's broad AI-fueled growth may tip the scales for investors.	0.345716	2025-10-23 13:35:00.270515+00
2003	Sell Alert: Edward T Archer Cashes Out $1.18M In Fabrinet Stock - Fabrinet  ( NYSE:FN ) 	Benzinga	https://www.benzinga.com/insights/news/25/09/47524579/sell-alert-edward-t-archer-cashes-out-1-18m-in-fabrinet-stock	2025-09-05 15:02:14+00	Edward T Archer, EVP at Fabrinet FN, disclosed an insider sell on September 5, according to a recent SEC filing. What Happened: After conducting a thorough analysis, Archer sold 3,333 shares of Fabrinet. This information was disclosed in a Form 4 filing with the U.S.	0.230595	2025-10-23 13:35:00.270515+00
2004	Edward T Archer Implements A Sell Strategy: Offloads $1.07M In Fabrinet Stock - Fabrinet  ( NYSE:FN ) 	Benzinga	https://www.benzinga.com/insights/news/25/09/47476405/edward-t-archer-implements-a-sell-strategy-offloads-1-07m-in-fabrinet-stock	2025-09-03 15:01:57+00	A substantial insider sell was reported on September 2, by Edward T Archer, EVP at Fabrinet FN, based on the recent SEC filing. What Happened: A Form 4 filing with the U.S. Securities and Exchange Commission on Tuesday outlined that Archer executed a sale of 3,200 shares of Fabrinet with a total ...	0.149211	2025-10-23 13:35:03.929963+00
2005	If You Invested $1000 In This Stock 15 Years Ago, You Would Have This Much Today - Fabrinet  ( NYSE:FN ) 	Benzinga	https://www.benzinga.com/insights/news/25/08/47418563/if-you-invested-1000-in-this-stock-15-years-ago-you-would-have-this-much-today	2025-08-29 16:00:17+00	Fabrinet FN has outperformed the market over the past 15 years by 11.07% on an annualized basis producing an average annual return of 23.6%. Currently, Fabrinet has a market capitalization of $12.72 billion.	0.181243	2025-10-23 13:35:03.929963+00
2006	Insider Selling: Csaba Sverha Unloads $3.11M Of Fabrinet Stock - Fabrinet  ( NYSE:FN ) 	Benzinga	https://www.benzinga.com/insights/news/25/08/47361133/insider-selling-csaba-sverha-unloads-3-11m-of-fabrinet-stock	2025-08-27 15:03:00+00	Disclosed on August 26, Csaba Sverha, Chief Financial Officer at Fabrinet FN, executed a substantial insider sell as per the latest SEC filing. What Happened: Sverha's decision to sell 10,000 shares of Fabrinet was revealed in a Form 4 filing with the U.S. Securities and Exchange Commission on ...	0.255221	2025-10-23 13:35:03.929963+00
2007	This Is What Whales Are Betting On Fabrinet - Fabrinet  ( NYSE:FN ) 	Benzinga	https://www.benzinga.com/insights/options/25/08/47344658/this-is-what-whales-are-betting-on-fabrinet	2025-08-26 20:03:36+00	High-rolling investors have positioned themselves bullish on Fabrinet FN, and it's important for retail traders to take note. \\This activity came to our attention today through Benzinga's tracking of publicly available options data.	0.13705	2025-10-23 13:35:03.929963+00
2008	This Okta Analyst Turns Bullish; Here Are Top 5 Upgrades For Monday - Alaska Air Gr  ( NYSE:ALK ) , FirstEnergy  ( NYSE:FE ) 	Benzinga	https://www.benzinga.com/news/25/08/47313681/this-okta-analyst-turns-bullish-here-are-top-5-upgrades-for-monday	2025-08-25 16:23:06+00	Top Wall Street analysts changed their outlook on these top names. For a complete view of all analyst rating changes, including upgrades, downgrades and initiations, please see our analyst ratings page.	0.329925	2025-10-23 13:35:03.929963+00
2009	P/E Ratio Insights for Fabrinet - Fabrinet  ( NYSE:FN ) 	Benzinga	https://www.benzinga.com/insights/news/25/08/47265394/pe-ratio-insights-for-fabrinet	2025-08-21 17:00:26+00	Looking into the current session, Fabrinet Inc. FN shares are trading at $274.47, after a 2.09% drop. Over the past month, the stock fell by 9.97%, but over the past year, it actually went up by 2.66%.	-0.071162	2025-10-23 13:35:03.929963+00
2010	These Analysts Increase Their Forecasts On Fabrinet After Upbeat Q4 Results - Fabrinet  ( NYSE:FN ) 	Benzinga	https://www.benzinga.com/analyst-stock-ratings/price-target/25/08/47217012/these-analysts-increase-their-forecasts-on-fabrinet-after-upbeat-q4-results	2025-08-19 17:45:03+00	Fabrinet FN reported better-than-expected fourth-quarter financial results for fiscal 2025 on Monday after the market close. Fabrinet reported fourth-quarter revenue of $909.69 million, beating analyst estimates of $884.87 million, according to Benzinga Pro.	0.263854	2025-10-23 13:35:03.929963+00
2011	Why Palo Alto Shares Are Trading Higher By Around 7%; Here Are 20 Stocks Moving Premarket - Color Star Tech  ( NASDAQ:ADD ) , Adecoagro  ( NYSE:AGRO ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/08/47205627/why-palo-alto-shares-are-trading-higher-by-around-7-here-are-20-stocks-moving-premarket	2025-08-19 12:01:09+00	Shares of Palo Alto Networks, Inc. PANW rose sharply in pre-market trading as the company reported better-than-expected financial results for the fourth quarter of fiscal 2025 and issued strong guidance for fiscal 2026 after the market closed on Monday.	0.193816	2025-10-23 13:35:03.929963+00
2012	Fabrinet, Adecoagro And Other Big Stocks Moving Lower In Tuesday's Pre-Market Session - Fabrinet  ( NYSE:FN ) , Adecoagro  ( NYSE:AGRO ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/08/47203882/fabrinet-adecoagro-and-other-big-stocks-moving-lower-in-tuesdays-pre-market-session	2025-08-19 10:21:33+00	U.S. stock futures were mixed this morning, with the S&P 500 futures falling around 0.1% on Monday. Shares of Fabrinet FN fell sharply in pre-market trading following fourth-quarter results. Fabrinet reported better-than-expected fourth-quarter financial results for fiscal 2025 on Monday.	0.108156	2025-10-23 13:35:03.929963+00
2013	Stock Market Today: S&P 500 Slips, Dow Futures Rise-Intel, Palo Alto, Home Depot In Focus - Fabrinet  ( NYSE:FN ) , Graphjet Technology  ( NASDAQ:GTI ) 	Benzinga	https://www.benzinga.com/markets/equities/25/08/47203307/stock-market-today-sp-500-slips-dow-futures-rise-intel-palo-alto-home-depot-in-focus	2025-08-19 09:44:19+00	U.S. stock futures were fluctuating on Tuesday following a mixed close on Monday. Futures of major benchmark indices were mixed. President Donald Trump expressed readiness to host a trilateral meeting with Russian President Vladimir Putin and Ukrainian President Volodymyr Zelenskyy to end the ...	0.20664	2025-10-23 13:35:03.929963+00
2014	Home Depot, Palo Alto Networks And 3 Stocks To Watch Heading Into Tuesday - Fabrinet  ( NYSE:FN ) , Home Depot  ( NYSE:HD ) 	Benzinga	https://www.benzinga.com/markets/equities/25/08/47202400/home-depot-palo-alto-networks-and-3-stocks-to-watch-heading-into-tuesday	2025-08-19 08:08:23+00	With U.S. stock futures trading lower this morning on Tuesday, some of the stocks that may grab investor focus today are as follows: Wall Street expects Toll Brothers Inc. TOL to report quarterly earnings at $3.60 per share on revenue of $2.86 billion after the closing bell, according to data ...	0.296324	2025-10-23 13:35:07.001965+00
2015	Fabrinet Q4 FY2025 Earnings Call Transcript - Fabrinet  ( NYSE:FN ) 	Benzinga	https://www.benzinga.com/markets/earnings/25/08/47199002/fabrinet-q4-fy2025-earnings-call-transcript	2025-08-18 23:03:34+00	Fabrinet FN reported its fourth-quarter financial results after Monday's closing bell. Below are the transcripts from the fourth quarter earnings call. FN is encountering selling pressure. Get the market research here.	0.280966	2025-10-23 13:35:07.001965+00
2016	Fabrinet  ( FN )  Q4 Earnings and Revenues Beat Estimates	Zacks Commentary	https://www.zacks.com/stock/news/2731646/fabrinet-fn-q4-earnings-and-revenues-beat-estimates	2025-08-18 21:25:01+00	Fabrinet (FN) delivered earnings and revenue surprises of +0.38% and +3.01%, respectively, for the quarter ended June 2025. Do the numbers hold clues to what lies ahead for the stock?	0.180383	2025-10-23 13:35:07.001965+00
2017	Fabrinet Posts 21% Revenue Jump in Q4	Motley Fool	https://www.fool.com/data-news/2025/08/18/fabrinet-posts-21-revenue-jump-in-q4/	2025-08-18 20:49:15+00	Fabrinet ( NYSE:FN ) , an advanced optical and precision manufacturing specialist, posted its quarterly results on August 18, 2025. The company delivered record revenue and earnings, with GAAP revenue of $909.7 million surpassed consensus expectations by over $96 million.	0.220117	2025-10-23 13:35:07.001965+00
2018	Fabrinet Q4 Earnings Beat Estimates While Demand Rises - Fabrinet  ( NYSE:FN ) 	Benzinga	https://www.benzinga.com/markets/earnings/25/08/47196982/fabrinet-beats-q4-earnings-estimates-company-highlights-growing-demand-across-all-aspects-of-bus	2025-08-18 20:37:10+00	Fabrinet reports fourth-quarter revenue of $909.69 million, beating analyst estimates of $884.87 million. Fabrinet reports fourth-quarter adjusted earnings of $2.65 per share, beating estimates of $2.64 per share.	0.258156	2025-10-23 13:35:07.001965+00
2019	Fabrinet Announces Fourth Quarter and Fiscal Year 2025 Financial Results	GlobeNewswire	https://www.globenewswire.com/news-release/2025/08/18/3135323/0/en/Fabrinet-Announces-Fourth-Quarter-and-Fiscal-Year-2025-Financial-Results.html	2025-08-18 20:15:00+00	BANGKOK, Aug. 18, 2025 ( GLOBE NEWSWIRE ) -- Fabrinet ( NYSE: FN ) , a leading provider of advanced optical packaging and precision optical, electro-mechanical and electronic manufacturing services to original equipment manufacturers of complex products, today announced its financial results for ...	0.237801	2025-10-23 13:35:07.001965+00
2020	Retail Earnings Season to Commence	Zacks Commentary	https://www.zacks.com/stock/news/2730286/retail-earnings-season-to-commence	2025-08-18 14:54:00+00	Pre-market futures are flat-to-lower this morning, after a mostly down Friday - buoyed on the Dow mostly by the positive trade on UnitedHealthcare ( UNH Quick QuoteUNH - ) , in which Warren Buffett's Berkshire Hathaway ( BRK.B Quick QuoteBRK.B - ) has taken a big stake.	0.166781	2025-10-23 13:35:07.001965+00
2021	Retailers Start to Report Earnings This Week	Zacks Commentary	https://www.zacks.com/stock/news/2730147/retailers-start-to-report-earnings-this-week	2025-08-18 14:15:00+00	It's the final leg of earnings season, in a general sense, to hear from the retailers who tend to stagger their earnings quarters.	0.166753	2025-10-23 13:35:07.001965+00
2022	S&P Settles Lower But Records Weekly Gain: Investor Sentiment Improves, Fear Index Remains In 'Greed' Zone - Intel  ( NASDAQ:INTC ) , Fabrinet  ( NYSE:FN ) 	Benzinga	https://www.benzinga.com/markets/equities/25/08/47177447/sp-settles-lower-but-records-weekly-gain-investor-sentiment-improves-fear-index-remains-in-greed	2025-08-18 07:15:53+00	The CNN Money Fear and Greed index showed some improvement in the overall market sentiment, while the index remained in the "Greed" zone on Friday.	-0.147495	2025-10-23 13:35:07.001965+00
2023	Palo Alto Networks, Fabrinet And 3 Stocks To Watch Heading Into Monday - ATN International  ( NASDAQ:ATNI ) , Allarity Therapeutics  ( NASDAQ:ALLR ) 	Benzinga	https://www.benzinga.com/markets/equities/25/08/47177435/palo-alto-networks-fabrinet-and-3-stocks-to-watch-heading-into-monday	2025-08-18 07:15:21+00	With U.S. stock futures trading higher this morning on Monday, some of the stocks that may grab investor focus today are as follows: Wall Street expects Palo Alto Networks Inc PANW to report quarterly earnings at 89 cents per share on revenue of $2.50 billion after the closing bell, according to ...	0.32225	2025-10-23 13:35:07.001965+00
2024	Fabrinet Likely To Report Higher Q4 Earnings; These Most Accurate Analysts Revise Forecasts Ahead Of Earnings Call - Fabrinet  ( NYSE:FN ) 	Benzinga	https://www.benzinga.com/analyst-stock-ratings/price-target/25/08/47159031/fabrinet-likely-to-report-higher-q4-earnings-these-most-accurate-analysts-revi	2025-08-15 15:16:40+00	Fabrinet FN will release financial results for the fourth quarter after the closing bell on Monday, Aug. 18. Analysts expect the George Town, the Cayman Islands-based company to report quarterly earnings at $2.63 per share, up from $2.41 per share in the year-ago period.	0.155706	2025-10-23 13:35:10.067157+00
2025	Zacks Investment Ideas feature highlights: Fabrinet, Nvidia and Amazon	Zacks Commentary	https://www.zacks.com/stock/news/2717394/zacks-investment-ideas-feature-highlights-fabrinet-nvidia-and-amazon	2025-08-15 14:59:00+00	Fabrinet surges nearly 100% since April, fueled by deep AI ties to Nvidia and Amazon, with more growth projected into FY26.	0.21647	2025-10-23 13:35:10.067157+00
2027	ADI Likely to Beat Q3 Earnings Estimates: How to Play the Stock	Zacks Commentary	https://www.zacks.com/stock/news/2716580/adi-likely-to-beat-q3-earnings-estimates-how-to-play-the-stock	2025-08-15 12:43:00+00	Analog Devices' Q3 results are set for strong growth on industrial and healthcare demand, with inventory recovery boosting momentum.	0.241431	2025-10-23 13:35:10.067157+00
2028	Stock Market Today: Dow Jones, Nasdaq Futures Tumble Amid US-China Trade Tensions-Tesla, IBM, American Airlines In Focus - SPDR S&P 500  ( ARCA:SPY ) 	Benzinga	https://www.benzinga.com/markets/equities/25/10/48374272/stock-market-today-dow-jones-nasdaq-futures-tumble-amid-us-china-trade-tensions-tesla-ibm-americ	2025-10-23 09:49:54+00	U.S. stock futures were swinging on Thursday following Wednesday's declines. Futures of major benchmark indices were lower. A wave of disappointing earnings guidance and escalating U.S.-China trade tensions rattled investor confidence.	0.069936	2025-10-23 13:35:10.067157+00
2029	Tesla, American Airlines And 3 Stocks To Watch Heading Into Thursday - Tesla  ( NASDAQ:TSLA ) 	Benzinga	https://www.benzinga.com/markets/equities/25/10/48372210/tesla-american-airlines-and-3-stocks-to-watch-heading-into-thursday	2025-10-23 05:18:50+00	With U.S. stock futures trading mixed this morning on Thursday, some of the stocks that may grab investor focus today are as follows: Wall Street expects American Airlines Group Inc. ( NASDAQ:AAL ) to report a quarterly loss at 28 cents per share on revenue of $13.63 billion before the opening ...	0.223568	2025-10-23 13:35:10.067157+00
2030	Zacks Investment Ideas feature highlights: International Business Machines	Zacks Commentary	https://www.zacks.com/stock/news/2774068/zacks-investment-ideas-feature-highlights-international-business-machines	2025-10-22 12:43:00+00	IBM's 114-year evolution powers ahead as hybrid cloud, AI, and quantum computing drive fresh growth and investor optimism.	0.350581	2025-10-23 13:35:10.067157+00
2031	How To Earn $500 A Month From IBM Stock Ahead Of Q3 Earnings - IBM  ( NYSE:IBM ) 	Benzinga	https://www.benzinga.com/trading-ideas/dividends/25/10/48350802/how-to-earn-500-a-month-from-ibm-stock-ahead-of-q3-earnings-2	2025-10-22 12:40:43+00	IBM ( NYSE:IBM ) will release earnings results for the third quarter after the closing bell on Wednesday. Analysts expect the company to report quarterly earnings at $2.45 per share, up from $2.30 per share in the year-ago period.	0.130198	2025-10-23 13:35:10.067157+00
2032	Is Invesco Large Cap Value ETF  ( PWV )  a Strong ETF Right Now?	Zacks Commentary	https://www.zacks.com/stock/news/2773755/is-invesco-large-cap-value-etf-pwv-a-strong-etf-right-now	2025-10-22 10:20:02+00	Smart Beta ETF report for ...	0.365608	2025-10-23 13:35:10.067157+00
2033	Stock Market Today: S&P 500, Dow Jones, Nasdaq Futures Inch Lower-Tesla, SAP And IBM In Focus - Invesco QQQ Trust, Series 1  ( NASDAQ:QQQ ) , IBM  ( NYSE:IBM ) 	Benzinga	https://www.benzinga.com/markets/equities/25/10/48347385/stock-market-today-sp-500-dow-jones-nasdaq-futures-inch-lower-tesla-sap-and-ibm-in-focus	2025-10-22 09:22:03+00	U.S. stock futures are inching lower on Wednesday, following a mixed session on Tuesday, with all major benchmark indices in the red pre-market. This comes amid President Donald Trump hinting at a de-escalation in the tariff situation with India, following his conversation with Indian Prime ...	0.101286	2025-10-23 13:35:10.067157+00
2034	From Punch Cards to Cloud: IBM's 114-Year Evolution	Zacks Commentary	https://www.zacks.com/commentary/2773392/from-punch-cards-to-cloud-ibms-114-year-evolution	2025-10-21 16:28:00+00	Top themes such as quantum computing, hybrid cloud, and storage solutions have driven outperformance.	0.34244	2025-10-23 13:35:13.371397+00
2035	5 Top Stocks to Buy in October	Motley Fool	https://www.fool.com/investing/2025/10/21/5-top-stocks-to-buy-in-october/	2025-10-21 12:15:00+00	In a booming stock market, these five stocks stand out.	0.222461	2025-10-23 13:35:13.371397+00
2036	Could IBM's Cognitus Deal Be the Spark That Reclaims Its AI Edge?	Motley Fool	https://www.fool.com/investing/2025/10/21/could-ibms-cognitus-deal-be-the-spark-that-reclaim/	2025-10-21 11:00:00+00	Cognitus is the latest in a series of cloud and AI-related acquisitions since Arvind Krishna became CEO.	0.319201	2025-10-23 13:35:13.371397+00
2037	NetApp Boosts ONTAP Security With OPSWAT Integration for Safer Data	Zacks Commentary	https://www.zacks.com/stock/news/2772173/netapp-boosts-ontap-security-with-opswat-integration-for-safer-data	2025-10-20 13:11:00+00	NTAP strengthens data defense with OPSWAT integration, enhancing ONTAP's multi-layered protection across hybrid and cloud environments.	0.189991	2025-10-23 13:35:13.371397+00
2038	What's Going On With IBM Stock Monday? - IBM  ( NYSE:IBM ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48300335/ibm-partners-with-groq-to-bring-lightning-fast-ai-to-enterprises-worldwide	2025-10-20 12:39:09+00	International Business Machines Corp. ( NYSE:IBM ) and Groq have announced a partnership to speed up enterprise use of agentic artificial intelligence.	0.220581	2025-10-23 13:35:13.371397+00
2039	Top Stocks With Earnings This Week: Tesla, Netflix, RTX and More - Tesla  ( NASDAQ:TSLA ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/10/48299369/retail-investors-top-stocks-with-earnings-this-week-tesla-netflix-intel-and-more	2025-10-20 11:53:01+00	Retail investors are preparing for the first busy week in the third-quarter earnings season, with major defense contractors and other top stocks reporting. Here's a look at some retail favorites that individual investors will be watching. TSLA stock is moving. See the real-time price action here.	0.090539	2025-10-23 13:35:13.371397+00
2040	Rubrik's Subscription Revenue Expands: A Sign for More Upside?	Zacks Commentary	https://www.zacks.com/stock/news/2771333/rubriks-subscription-revenue-expands-a-sign-for-more-upside	2025-10-17 16:09:00+00	RBRK's surging subscription and cloud ARR signal strong customer expansion and growing traction for its data security solutions.	0.384225	2025-10-23 13:35:13.371397+00
2041	Is the Market Bullish or Bearish on International Business Machines Corp? - IBM  ( NYSE:IBM ) 	Benzinga	https://www.benzinga.com/insights/short-sellers/25/10/48272894/is-the-market-bullish-or-bearish-on-international-business-machines-corp	2025-10-17 13:00:57+00	International Business Machines Corp's ( NYSE:IBM ) short interest as a percent of float has risen 10.29% since its last report. According to exchange reported data, there are now 16.20 million shares sold short, which is 1.93% of all regular shares that are available for trading.	0.276201	2025-10-23 13:35:13.371397+00
2042	What Is One of the Best Quantum Computing Stocks for the Next 10 Years?	Motley Fool	https://www.fool.com/investing/2025/10/15/best-quantum-computing-stock-next-ten-years/	2025-10-15 18:30:00+00	IBM is marching toward a multibillion-dollar quantum computing business.	0.11094	2025-10-23 13:35:13.371397+00
2043	IBM vs. Intel: Which Legacy Tech Giant is the Better Buy Today?	Zacks Commentary	https://www.zacks.com/stock/news/2769043/ibm-vs-intel-which-legacy-tech-giant-is-the-better-buy-today	2025-10-15 13:00:00+00	IBM's cloud-driven transformation and steady growth may give it an edge over Intel's AI ambitions and valuation appeal.	0.251619	2025-10-23 13:35:13.371397+00
2044	What the Options Market Tells Us About IBM - IBM  ( NYSE:IBM ) 	Benzinga	https://www.benzinga.com/insights/options/25/10/48199219/what-the-options-market-tells-us-about-ibm	2025-10-14 14:02:46+00	Financial giants have made a conspicuous bearish move on IBM. Our analysis of options history for IBM ( NYSE:IBM ) revealed 13 unusual trades. Delving into the details, we found 30% of traders were bullish, while 46% showed bearish tendencies.	0.15999	2025-10-23 13:35:16.620556+00
2045	Accenture Stock Declines 32% YTD: Here's How to Play It Now	Zacks Commentary	https://www.zacks.com/stock/news/2767765/accenture-stock-declines-32-ytd-heres-how-to-play-it-now	2025-10-13 18:01:00+00	ACN's $3B GenAI investment, deep tech alliances and new Reinvention Services mark a pivotal shift in its strategy.	0.332729	2025-10-23 13:35:16.620556+00
2046	Benson Investment Management Loads Up With 22K IBM Shares Worth $6.4 Million	Motley Fool	https://www.fool.com/coverage/filings/2025/10/11/benson-investment-management-loads-up-with-22k-ibm-shares-worth-usd6-4-million/	2025-10-11 01:13:15+00	Benson Investment Management Company, Inc. disclosed a new position in International Business Machines ( NYSE:IBM ) on October 10, 2025, acquiring shares valued at approximately $6.38 million, as reported in its Form 13F filing for the quarter ended September 30, 2025.Continue reading ...	0.292742	2025-10-23 13:35:16.620556+00
2047	Can IBM Profit From S&P Global Tie-Up For Supply Chain Management?	Zacks Commentary	https://www.zacks.com/stock/news/2764597/can-ibm-profit-from-sp-global-tie-up-for-supply-chain-management	2025-10-08 14:36:00+00	IBM's tie-up with S&P Global integrates watsonx AI into supply chain tools, promising smarter, faster decision-making for enterprises.	0.372253	2025-10-23 13:35:16.620556+00
2048	Company News for Oct 8, 2025	Zacks Commentary	https://www.zacks.com/stock/news/2764529/company-news-for-oct-8-2025	2025-10-08 13:51:00+00	Companies in The News Are: ...	0.133414	2025-10-23 13:35:16.620556+00
2049	S&P Global Uses IBM AI To Boost Efficiency - IBM  ( NYSE:IBM ) , S&P Global  ( NYSE:SPGI ) 	Benzinga	https://www.benzinga.com/markets/large-cap/25/10/48096694/sp-global-uses-ibm-ai-to-boost-efficiency	2025-10-08 12:02:04+00	International Business Machines Corporation ( NYSE:IBM ) on Wednesday disclosed a partnership with S&P Global ( NYSE:SPGI ) to integrate its watsonx Orchestrate agentic AI framework into S&P Global's product portfolio.	0.242572	2025-10-23 13:35:16.620556+00
2050	Datavault AI Stock's Face-Melting 720% Rally-What To Know - Datavault AI  ( NASDAQ:DVLT ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/10/48082767/datavault-ai-stocks-face-melting-720-rally-what-to-know	2025-10-07 16:53:38+00	Shares of Datavault AI, Inc. ( NASDAQ:DVLT ) have gained more than 720% over the past month and the stock continued to rip on Tuesday. Here's a look at what's driving the retail investor-fueled frenzy in the stock. DVLT stock is soaring. See the real-time price action here.	0.34429	2025-10-23 13:35:16.620556+00
2051	What's Going On With IBM Stock Tuesday? - IBM  ( NYSE:IBM ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48080697/ibms-spyre-accelerator-hits-market-soon-but-what-can-it-actually-do-for-you	2025-10-07 15:52:40+00	International Business Machines Corporation ( NYSE:IBM ) on Tuesday announced that its new Spyre Accelerator, designed for low-latency AI inference and secure generative AI use cases, will be generally available on October 28 for IBM z17 and LinuxONE 5 systems, and in early December for Power11 ...	0.226152	2025-10-23 13:35:16.620556+00
2052	Why IBM Shares Are Seeing Blue Skies On Tuesday? - IBM  ( NYSE:IBM ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/48076237/why-ibm-shares-are-seeing-blue-skies-on-tuesday	2025-10-07 14:13:02+00	International Business Machines Corporation ( NYSE:IBM ) shares are trading higher premarket on Tuesday following the announcement of a strategic partnership with Anthropic to advance enterprise-grade AI, integrating Anthropic's Claude LLMs into IBM's software suite.	0.296596	2025-10-23 13:35:16.620556+00
2053	Check Out What Whales Are Doing With IBM - IBM  ( NYSE:IBM ) 	Benzinga	https://www.benzinga.com/insights/options/25/10/48075499/check-out-what-whales-are-doing-with-ibm	2025-10-07 14:02:29+00	Financial giants have made a conspicuous bullish move on IBM. Our analysis of options history for IBM ( NYSE:IBM ) revealed 12 unusual trades. Delving into the details, we found 41% of traders were bullish, while 41% showed bearish tendencies.	0.198577	2025-10-23 13:35:16.620556+00
2054	Prediction: This Quantum-AI Company Will Redefine Cloud Security by 2030	Motley Fool	https://www.fool.com/investing/2025/10/05/prediction-this-quantum-ai-company-will-redefine-c/	2025-10-05 08:05:00+00	Every technological leap comes with its own unique risks and downsides. The looming advent of quantum computing is no exception.	0.183616	2025-10-23 13:35:20.144974+00
2055	Dan Ives Reveals Buyout Watchlist Including C3.ai, SanDisk, Lyft, Qualys And More: 'M&A Floodgates Are Opening' - C3.ai  ( NYSE:AI ) 	Benzinga	https://www.benzinga.com/markets/equities/25/10/48010560/dan-ives-reveals-buyout-watchlist-including-c3-ai-sandisk-lyft-qualys-and-more-ma-floodgates-are	2025-10-03 06:09:05+00	Prominent Wedbush tech analyst Dan Ives is forecasting an imminent surge of mergers and acquisitions across the technology sector, declaring that the artificial intelligence ( AI ) "M&A floodgates are ready to be opened."	0.262492	2025-10-23 13:35:20.144974+00
2056	The Zacks Analyst Blog Highlights IBM, WMB, HLT and EML	Zacks Commentary	https://www.zacks.com/stock/news/2760610/the-zacks-analyst-blog-highlights-ibm-wmb-hlt-and-eml	2025-10-02 09:38:00+00	IBM, WMB, HLT, and EML offer unique opportunities across tech, energy, hospitality, and microcap sectors, balancing growth, transformation, and income potential for diversified investors.	0.122152	2025-10-23 13:35:20.144974+00
2057	6 Stock Market Sector Metrics Investors Should Consider Before Buying S&P 500 Stocks at All-Time Highs	Motley Fool	https://www.fool.com/investing/2025/10/01/stock-market-sector-metrics-invest-buy-sp-500/	2025-10-02 00:05:00+00	Weakness in consumer-facing sectors is a painful reminder of the differences between the economy and the stock market.	0.152749	2025-10-23 13:35:20.144974+00
2058	Quantum Computing Can Generate $1 Trillion Economic Value by 2035: 2 Quantum Artificial Intelligence  ( AI )  Stocks to Buy Now	Motley Fool	https://www.fool.com/investing/2025/10/01/quantum-computing-can-generate-1-trillion-economic/	2025-10-02 00:00:00+00	Quantum computing offers a high-risk, high-reward investment opportunity.	0.20115	2025-10-23 13:35:20.144974+00
2059	Zyphra Taps IBM, AMD To Build Next-Gen AI Superagent - IBM  ( NYSE:IBM ) , Advanced Micro Devices  ( NASDAQ:AMD ) 	Benzinga	https://www.benzinga.com/markets/tech/25/10/47966908/zyphra-taps-ibm-amd-to-build-next-gen-ai-superagent	2025-10-01 13:10:51+00	International Business Machines ( NYSE:IBM ) and Advanced Micro Devices ( NASDAQ:AMD ) announced on Wednesday a strategic collaboration to provide Zyphra, a San Francisco-based open-source AI company, with advanced AI infrastructure.	0.251044	2025-10-23 13:35:20.144974+00
2060	IBM: A Century-Old Giant's Journey Into AI and Cloud Solutions	Motley Fool	https://www.fool.com/investing/2025/09/29/ibm-a-century-old-giants-journey-into-ai-and-cloud/	2025-09-29 23:00:00+00	Curious about IBM's future in the tech landscape? Tune in as our experts dissect its strengths, weaknesses, and potential for growth in the coming years.	-0.082467	2025-10-23 13:35:20.144974+00
2061	Is IBM Stock a Buy on Its Quantum Breakthrough?	Motley Fool	https://www.fool.com/investing/2025/09/29/is-ibm-stock-a-buy-on-its-quantum-breakthrough/	2025-09-29 10:45:00+00	While quantum pure plays trade at extreme multiples, this $264 billion tech giant just proved that quantum computing works in the real world.	0.275847	2025-10-23 13:35:20.144974+00
2062	This Overlooked Dividend Stock Could Be a Quiet AI Winner	Motley Fool	https://www.fool.com/investing/2025/09/28/this-overlooked-dividend-stock-could-be-a-quiet-ai/	2025-09-28 12:25:00+00	It's time for investors to pay attention to IBM stock.	0.201138	2025-10-23 13:35:20.144974+00
2063	The Smartest Dividend Stocks to Buy With $10,000 Right Now	Motley Fool	https://www.fool.com/investing/2025/09/27/the-smartest-dividend-stocks-to-buy-with-10000-rig/	2025-09-27 22:50:00+00	These four names provide solid returns in a diversified portfolio.	0.356868	2025-10-23 13:35:20.144974+00
2064	Palantir and IBM Look Poised to Ride the Pentagon's AI Spending Wave	Motley Fool	https://www.fool.com/investing/2025/09/27/palantir-and-ibm-look-poised-to-ride-the-pentagons/	2025-09-27 07:05:00+00	There's a huge opportunity for companies and investors as the Pentagon embraces artificial intelligence.	0.374156	2025-10-23 13:35:23.304835+00
2065	Why IBM Stock Popped on Friday	Motley Fool	https://www.fool.com/investing/2025/09/26/why-ibm-stock-popped-on-friday/	2025-09-26 16:32:58+00	Quantum computing companies could turn profitable sooner than you think.	0.457928	2025-10-23 13:35:23.304835+00
2066	HSBC Offloads Sri Lanka Consumer Unit, Focuses On Global Corporate Clients - HSBC Holdings  ( NYSE:HSBC ) 	Benzinga	https://www.benzinga.com/markets/equities/25/09/47888036/hsbc-offloads-sri-lanka-consumer-unit-focuses-on-global-corporate-clients	2025-09-26 13:11:09+00	HSBC Holdings' ( NYSE: HSBC ) shares are trading relatively flat in the premarket session on Friday. The banking giant recently announced plans to exit its retail banking operations in Sri Lanka, agreeing to transfer the business to Nations Trust Bank PLC.	0.414099	2025-10-23 13:35:23.304835+00
2067	IBM Just Made a Quantum Computing Breakthrough	Motley Fool	https://www.fool.com/investing/2025/09/26/ibm-just-made-a-quantum-computing-breakthrough/	2025-09-26 11:20:00+00	IBM and HSBC used a quantum system to improve a complex process.	0.150011	2025-10-23 13:35:23.304835+00
2068	3 Leading Tech Stocks to Buy in 2025	Motley Fool	https://www.fool.com/investing/2025/09/26/3-leading-tech-stocks-to-buy-in-2025/	2025-09-26 09:20:00+00	These companies are key players in artificial intelligence and should continue to deliver through 2025 and beyond.	0.237812	2025-10-23 13:35:23.304835+00
2069	Looking Into FactSet Research Systems Inc's Recent Short Interest - FactSet Research Systems  ( NYSE:FDS ) 	Benzinga	https://www.benzinga.com/insights/short-sellers/25/10/48330534/looking-into-factset-research-systems-incs-recent-short-interest	2025-10-21 15:00:30+00	FactSet Research Systems Inc's ( NYSE:FDS ) short interest as a percent of float has risen 22.56% since its last report. According to exchange reported data, there are now 2.14 million shares sold short, which is 6.41% of all regular shares that are available for trading.	0.278426	2025-10-23 13:35:23.304835+00
2070	Jim Cramer On FactSet: 'Holy Cow, It's Way Too Cheap' - Also Weighs In On Freeport-McMoRan - FactSet Research Systems  ( NYSE:FDS ) , Freeport-McMoRan  ( NYSE:FCX ) 	Benzinga	https://www.benzinga.com/trading-ideas/long-ideas/25/10/48195766/jim-cramer-on-factset-holy-cow-its-way-too-cheap-also-weighs-in-on-freeport-mcmoran	2025-10-14 12:30:32+00	On CNBC's "Mad Money Lightning Round," on Monday, Jim Cramer said he likes FactSet Research Systems Inc. ( NYSE:FDS ) . "Couldn't tell you to buy it, but holy cow, it's way too cheap," he added. On the earnings front, FactSet Research Systems released its fourth-quarter results on Sept. 18.	0.190005	2025-10-23 13:35:23.304835+00
2071	Here's How Much You Would Have Made Owning FactSet Research Systems Stock In The Last 20 Years - FactSet Research Systems  ( NYSE:FDS ) 	Benzinga	https://www.benzinga.com/insights/news/25/10/48138819/heres-how-much-you-would-have-made-owning-factset-research-systems-stock-in-the-last-20-years	2025-10-09 21:46:59+00	FactSet Research Systems ( NYSE:FDS ) has outperformed the market over the past 20 years by 2.23% on an annualized basis producing an average annual return of 11.32%. Currently, FactSet Research Systems has a market capitalization of $10.85 billion.	0.158543	2025-10-23 13:35:23.304835+00
2072	These Were the 5 Worst-Performing Stocks in the S&P 500 in September 2025 -- and One's Decline Can Be Tied to President Trump	Motley Fool	https://www.fool.com/investing/2025/10/08/the-5-worst-performing-stocks-in-the-sp-500-trump/	2025-10-08 13:13:00+00	One of these stocks lost about a quarter of its value in a single month.	-0.05907	2025-10-23 13:35:23.304835+00
2073	Chief Legal Officer At FactSet Research Systems Buys $100K of Stock - FactSet Research Systems  ( NYSE:FDS ) 	Benzinga	https://www.benzinga.com/insights/news/25/09/47892302/chief-legal-officer-at-factset-research-systems-buys-100k-of-stock	2025-09-26 15:01:11+00	Christopher McLoughlin, Chief Legal Officer at FactSet Research Systems ( NYSE: FDS ) , reported an insider buy on September 25, according to a new SEC filing. What Happened: In a recent Form 4 filing with the U.S.	0.276612	2025-10-23 13:35:23.304835+00
2074	FactSet Shares Likely To Stay In A Prolonged Downtrend - FactSet Research Systems  ( NYSE:FDS ) 	Benzinga	https://www.benzinga.com/trading-ideas/25/09/47814595/factset-shares-likely-to-stay-in-a-prolonged-downtrend	2025-09-23 11:42:47+00	FactSet Research Systems FDS is currently in Phase 9 of its 18-phase Adhishthana Cycle on the monthly charts. The stock has just broken down from its critical Cakra formation, a bearish signal that could weigh on performance for a long time. Here's what went wrong and what may lie ahead under the ...	-0.213354	2025-10-23 13:35:26.703708+00
2075	CrowdStrike To Rally More Than 9%? Here Are 10 Top Analyst Forecasts For Monday - CrowdStrike Holdings  ( NASDAQ:CRWD ) , Brinker International  ( NYSE:EAT ) 	Benzinga	https://www.benzinga.com/news/25/09/47787507/crowdstrike-to-rally-more-than-9-here-are-10-top-analyst-forecasts-for-monday	2025-09-22 13:25:57+00	Top Wall Street analysts changed their outlook on these top names. For a complete view of all analyst rating changes, including upgrades and downgrades, please see our analyst ratings page. Piper Sandler raised Steven Madden, Ltd. SHOO price target from $25 to $40.	0.241649	2025-10-23 13:35:26.703708+00
2076	This Sarepta Therapeutics Analyst Turns Bullish; Here Are Top 5 Upgrades For Monday - FactSet Research Systems  ( NYSE:FDS ) , Brinker International  ( NYSE:EAT ) 	Benzinga	https://www.benzinga.com/news/25/09/47786300/this-sarepta-therapeutics-analyst-turns-bullish-here-are-top-5-upgrades-for-monday	2025-09-22 12:43:32+00	Top Wall Street analysts changed their outlook on these top names. For a complete view of all analyst rating changes, including upgrades, downgrades and initiations, please see our analyst ratings page. Barclays analyst Eddie Kim upgraded Helmerich & Payne, Inc.	0.316099	2025-10-23 13:35:26.703708+00
2077	FactSet Research Analysts Slash Their Forecasts Following Q4 Results - FactSet Research Systems  ( NYSE:FDS ) 	Benzinga	https://www.benzinga.com/news/25/09/47764343/factset-research-analysts-slash-their-forecasts-following-q4-results	2025-09-19 14:58:35+00	FactSet Research Systems FDS posted mixed fourth-quarter results on Thursday. The company reported quarterly sales of $596.9 million, surpassing analyst expectations of $593.5 million and representing a 6.2% year-over-year gain.	0.120167	2025-10-23 13:35:26.703708+00
2078	Company News for Sep 19, 2025	Zacks Commentary	https://www.zacks.com/stock/news/2753975/company-news-for-sep-19-2025	2025-09-19 13:29:00+00	Companies in The News Are: ...	0.212271	2025-10-23 13:35:26.703708+00
2079	FactSet  ( FDS )  Q4 2025 Earnings Call Transcript	Motley Fool	https://www.fool.com/earnings/call-transcripts/2025/09/18/factset-fds-q4-2025-earnings-call-transcript/	2025-09-18 16:25:41+00	Image source: The Motley Fool.Sep. 18, 2025 at 9 a.m. ETNeed a quote from a Motley Fool analyst? Email pr@fool.comContinue reading ...	0.34899	2025-10-23 13:35:26.703708+00
2080	FactSet Earnings Miss Estimates in Q4, Revenues Increase Y/Y	Zacks Commentary	https://www.zacks.com/stock/news/2753620/factset-earnings-miss-estimates-in-q4-revenues-increase-yy	2025-09-18 15:23:00+00	FDS's fourth-quarter fiscal 2025 earnings fall short of estimates, but revenues rise 6.2% year over year, with solid growth across regions.	0.077792	2025-10-23 13:35:26.703708+00
2081	Here's How Much You Would Have Made Owning FactSet Research Systems Stock In The Last 20 Years - FactSet Research Systems  ( NYSE:FDS ) 	Benzinga	https://www.benzinga.com/insights/news/25/09/47740457/heres-how-much-you-would-have-made-owning-factset-research-systems-stock-in-the-last-20-years	2025-09-18 14:15:21+00	FactSet Research Systems FDS has outperformed the market over the past 20 years by 2.82% on an annualized basis producing an average annual return of 11.67%. Currently, FactSet Research Systems has a market capitalization of $12.17 billion.	0.181243	2025-10-23 13:35:26.703708+00
2082	Stock Market Today: S&P 500, Nasdaq, Dow Futures Jump Following Fed Rate Cut-Broadcom, Cracker Barrel, FedEx In Focus - SPDR S&P 500  ( ARCA:SPY ) 	Benzinga	https://www.benzinga.com/markets/equities/25/09/47733197/stock-market-today-sp-500-nasdaq-dow-futures-jump-following-fed-rate-cut-broadcom-cracker-barrel	2025-09-18 09:47:05+00	U.S. stock futures advanced on Thursday following Wednesday's mixed moves. Futures of major benchmark indices were higher.	0.019456	2025-10-23 13:35:26.703708+00
2083	Dow Jumps Over 250 Points As Fed Cuts Rates: Investor Sentiment Edges Lower, Fear Index Remains In 'Greed' Zone - FactSet Research Systems  ( NYSE:FDS ) , Darden Restaurants  ( NYSE:DRI ) 	Benzinga	https://www.benzinga.com/markets/equities/25/09/47732269/dow-jumps-over-250-points-as-fed-cuts-rates-investor-sentiment-edges-lower-fear-index-remains-in	2025-09-18 07:52:16+00	The CNN Money Fear and Greed index showed a slight decline in the overall market sentiment, while the index remained in the "Greed" zone on Wednesday. U.S. stocks settled mixed on Wednesday, with the Dow Jones index gaining more than 250 points during the session as the Federal Reserve ...	-0.198051	2025-10-23 13:35:26.703708+00
2084	Darden Restaurants, Factset Research And 3 Stocks To Watch Heading Into Thursday - Bullish  ( NYSE:BLSH ) , Darden Restaurants  ( NYSE:DRI ) 	Benzinga	https://www.benzinga.com/markets/equities/25/09/47732241/darden-restaurants-factset-research-and-3-stocks-to-watch-heading-into-thursday	2025-09-18 07:43:20+00	With U.S. stock futures trading higher this morning on Thursday, some of the stocks that may grab investor focus today are as follows: Wall Street expects Darden Restaurants Inc. DRI to report quarterly earnings at $2.00 per share on revenue of $3.04 billion before the opening bell, according to ...	0.430782	2025-10-23 13:35:30.194731+00
2085	FactSet to Report Q4 Earnings: What's in Store for the Stock?	Zacks Commentary	https://www.zacks.com/stock/news/2752373/factset-to-report-q4-earnings-whats-in-store-for-the-stock	2025-09-16 16:08:00+00	FDS gears up to post Q4 results, with revenues expected at $592.6M and EPS at $4.15, pointing to year-over-year growth across regions.	0.265664	2025-10-23 13:35:30.194731+00
2086	Top Wall Street Forecasters Revamp FactSet Research Expectations Ahead Of Q4 Earnings - FactSet Research Systems  ( NYSE:FDS ) 	Benzinga	https://www.benzinga.com/analyst-stock-ratings/price-target/25/09/47695653/top-wall-street-forecasters-revamp-factset-research-expectations-ahead-of-q4-e	2025-09-16 15:32:34+00	FactSet Research Systems Inc. FDS will release earnings for the fourth quarter, before the opening bell on Thursday, Sept. 18. Analysts expect the Norwalk, Connecticut-based company to report quarterly earnings at $4.13 per share. That's up from $3.74 per share in the year-ago period.	0.093017	2025-10-23 13:35:30.194731+00
2087	This Air Products and Chemicals Analyst Turns Bullish; Here Are Top 5 Upgrades For Friday - Alaska Air Gr  ( NYSE:ALK ) , Air Products  ( NYSE:APD ) 	Benzinga	https://www.benzinga.com/analyst-stock-ratings/upgrades/25/09/47640738/this-air-products-and-chemicals-analyst-turns-bullish-here-are-top-5-upgrades-for-	2025-09-12 12:32:42+00	Top Wall Street analysts changed their outlook on these top names. For a complete view of all analyst rating changes, including upgrades, downgrades and initiations, please see our analyst ratings page. Rothschild & Co analyst Russell Quelch upgraded FactSet Research Systems Inc.	0.305621	2025-10-23 13:35:30.194731+00
2088	Is FactSet Research Systems Gaining or Losing Market Support? - FactSet Research Systems  ( NYSE:FDS ) 	Benzinga	https://www.benzinga.com/insights/short-sellers/25/09/47577277/is-factset-research-systems-gaining-or-losing-market-support	2025-09-09 17:00:19+00	FactSet Research Systems's FDS short percent of float has risen 20.96% since its last report. The company recently reported that it has 2.10 million shares sold short, which is 6.29% of all regular shares that are available for trading.	0.271622	2025-10-23 13:35:30.194731+00
2089	Synopsys to Report Q3 Earnings: What's in the Cards for the Stock?	Zacks Commentary	https://www.zacks.com/stock/news/2747533/synopsys-to-report-q3-earnings-whats-in-the-cards-for-the-stock	2025-09-05 13:44:00+00	SNPS eyes Q3 earnings of $3.82-$3.87 per share, fueled by strong demand in AI, HAV systems, and IP portfolio gains.	0.305992	2025-10-23 13:35:30.194731+00
2090	Price Over Earnings Overview: FactSet Research Systems - FactSet Research Systems  ( NYSE:FDS ) 	Benzinga	https://www.benzinga.com/insights/news/25/08/47259487/price-over-earnings-overview-factset-research-systems	2025-08-21 14:00:34+00	In the current market session, FactSet Research Systems Inc. FDS price is at $389.00, after a 0.35% increase. However, over the past month, the stock fell by 8.88%, and in the past year, by 6.09%.	0.107475	2025-10-23 13:35:30.194731+00
2091	CUSIP Request Volumes for New Corporate Securities Increase in July	Benzinga	https://www.benzinga.com/pressreleases/25/08/g47255728/cusip-request-volumes-for-new-corporate-securities-increase-in-july	2025-08-21 12:00:00+00	NORWALK, Conn., Aug. 21, 2025 ( GLOBE NEWSWIRE ) -- CUSIP Global Services ( CGS ) today announced the release of its CUSIP Issuance Trends Report for July 2025.	0.152717	2025-10-23 13:35:30.194731+00
2092	How Do Investors Really Feel About FactSet Research Systems? - FactSet Research Systems  ( NYSE:FDS ) 	Benzinga	https://www.benzinga.com/insights/short-sellers/25/08/47214085/how-do-investors-really-feel-about-factset-research-systems	2025-08-19 16:00:31+00	FactSet Research Systems's FDS short percent of float has risen 10.87% since its last report. The company recently reported that it has 1.74 million shares sold short, which is 5.2% of all regular shares that are available for trading.	0.271622	2025-10-23 13:35:30.194731+00
2093	FactSet  ( FDS )  Down 4.7% Since Last Earnings Report: Can It Rebound?	Zacks Commentary	https://www.zacks.com/stock/news/2608307/factset-fds-down-47-since-last-earnings-report-can-it-rebound	2025-07-23 15:30:02+00	FactSet (FDS) reported earnings 30 days ago. What's next for the stock? We take a look at earnings estimates for some clues.	0.087314	2025-10-23 13:35:30.194731+00
2094	Witnessing An Insider Decision, James J McGonigle Exercises Options Valued At $433K At FactSet Research Systems - FactSet Research Systems  ( NYSE:FDS ) 	Benzinga	https://www.benzinga.com/insights/news/25/07/46445383/witnessing-an-insider-decision-james-j-mcgonigle-exercises-options-valued-at-433k-at-factset-resear	2025-07-16 15:00:49+00	A significant insider transaction involving the exercise of company stock options was reported on July 15, by James J McGonigle, Board Member at FactSet Research Systems FDS, as per the latest SEC filing. What Happened: Disclosed in a Form 4 filing on Tuesday with the U.S.	0.208751	2025-10-23 13:35:33.768727+00
2095	CUSIP Request Volumes for New Corporate Securities Increase in June	Benzinga	https://www.benzinga.com/pressreleases/25/07/g46439251/cusip-request-volumes-for-new-corporate-securities-increase-in-june	2025-07-16 12:00:00+00	NORWALK, Conn., July 16, 2025 ( GLOBE NEWSWIRE ) -- CUSIP Global Services ( CGS ) today announced the release of its CUSIP Issuance Trends Report for June 2025.	0.141078	2025-10-23 13:35:33.768727+00
2096	Here's How Much You Would Have Made Owning FactSet Research Systems Stock In The Last 20 Years - FactSet Research Systems  ( NYSE:FDS ) 	Benzinga	https://www.benzinga.com/insights/news/25/07/46406415/heres-how-much-you-would-have-made-owning-factset-research-systems-stock-in-the-last-20-years	2025-07-14 23:15:14+00	FactSet Research Systems FDS has outperformed the market over the past 20 years by 4.71% on an annualized basis producing an average annual return of 13.19%. Currently, FactSet Research Systems has a market capitalization of $16.73 billion.	0.164255	2025-10-23 13:35:33.768727+00
2097	Christopher R Ellis At FactSet Research Systems Decides to Exercises Options Worth $2.26M - FactSet Research Systems  ( NYSE:FDS ) 	Benzinga	https://www.benzinga.com/insights/news/25/07/46346251/christopher-r-ellis-at-factset-research-systems-decides-to-exercises-options-worth-2-26m	2025-07-10 15:00:43+00	A large exercise of company stock options by Christopher R Ellis, EVP at FactSet Research Systems FDS was disclosed in a new SEC filing on July 9, as part of an insider exercise. What Happened: In an insider options sale disclosed in a Form 4 filing on Wednesday with the U.S.	0.2123	2025-10-23 13:35:33.768727+00
2098	Consumer Tech News  ( June 23-June 27 ) : Inflation Stirs, Trade Tensions Flare, And Big Tech Makes Big Moves - Apple  ( NASDAQ:AAPL ) , Amazon.com  ( NASDAQ:AMZN ) 	Benzinga	https://www.benzinga.com/markets/large-cap/25/06/46159694/consumer-tech-news-june-23-june-27-inflation-stirs-trade-tensions-flare-and-big-tech-makes-big-	2025-06-29 16:17:39+00	May PCE inflation rose to 2.3%, renewing concerns that rising tariffs could squeeze U.S. consumers in coming months. Trump halted trade talks with Canada over a digital tax on U.S. tech firms, vowing tariffs and rattling markets late in the week.	0.052948	2025-10-23 13:35:33.768727+00
2099	What Does the Market Think About FactSet Research Systems? - FactSet Research Systems  ( NYSE:FDS ) 	Benzinga	https://www.benzinga.com/insights/short-sellers/25/06/46081562/what-does-the-market-think-about-factset-research-systems	2025-06-24 19:00:33+00	FactSet Research Systems's FDS short percent of float has risen 8.88% since its last report. The company recently reported that it has 1.56 million shares sold short, which is 4.66% of all regular shares that are available for trading.	0.291976	2025-10-23 13:35:33.768727+00
2100	These Analysts Raise Their Forecasts On FactSet Research Systems Q3 Results - FactSet Research Systems  ( NYSE:FDS ) 	Benzinga	https://www.benzinga.com/analyst-stock-ratings/price-target/25/06/46079090/these-analysts-raise-their-forecasts-on-factset-research-systems-q3-results	2025-06-24 16:50:03+00	FactSet Research Systems FDS posted mixed results for the third quarter on Monday. The company reported quarterly sales of $585.52 million, surpassing analyst expectations of $580.50 million and representing a 5.9% year-over-year gain.	0.30763	2025-10-23 13:35:33.768727+00
2101	Company News for Jun 24, 2025	Zacks Commentary	https://www.zacks.com/stock/news/2544460/company-news-for-jun-24-2025	2025-06-24 13:38:00+00	Companies in The News Are: ...	0.332915	2025-10-23 13:35:33.768727+00
2102	Stocks Rise, Oil Tumbles Despite Iran's Strikes On US Bases: What's Driving Markets Monday? - FactSet Research Systems  ( NYSE:FDS ) , SPDR Dow Jones Industrial Average ETF  ( ARCA:DIA ) 	Benzinga	https://www.benzinga.com/markets/equities/25/06/46059497/stocks-rise-oil-tumbles-despite-irans-strikes-on-us-bases-whats-driving-markets-monday	2025-06-23 18:03:44+00	Stocks rise despite Iran firing missiles at U.S. bases, with no reported damage or casualties calming investor nerves. Oil plunges over 5% to below $70, defying expectations of a spike amid Middle East tensions.	-0.002451	2025-10-23 13:35:33.768727+00
2103	FactSet Earnings Miss Estimates in Q3, Revenues Increase Y/Y	Zacks Commentary	https://www.zacks.com/stock/news/2536684/factset-earnings-miss-estimates-in-q3-revenues-increase-yy	2025-06-23 16:16:00+00	FDS's third-quarter fiscal 2025 earnings slip y/y, but rising revenues and expanding ASV signal steady momentum in core operations.	0.094357	2025-10-23 13:35:33.768727+00
2104	Kroger Posts Better-Than-Expected Earnings, Joins Couchbase, CarMax And Other Big Stocks Moving Higher On Friday - Circle Internet Group  ( NYSE:CRCL ) , AIRO Group Holdings  ( NASDAQ:AIRO ) 	Benzinga	https://www.benzinga.com/trading-ideas/movers/25/06/46054785/kroger-posts-better-than-expected-earnings-joins-couchbase-carmax-and-other-big-stocks-movin	2025-06-23 15:08:07+00	U.S. stocks were higher, with the Dow Jones index gaining around 50 points on Monday. Shares of Tesla, Inc. TSLA rose sharply during Monday's session amid the Robotaxi launch in Austin, TX.	0.27642	2025-10-23 13:35:37.484994+00
2105	Dow Jumps Over 200 Points; FactSet Research Shares Gain After Q3 Results - Compass Pathways  ( NASDAQ:CMPS ) , Cidara Therapeutics  ( NASDAQ:CDTX ) 	Benzinga	https://www.benzinga.com/markets/market-summary/25/06/46054166/dow-jumps-over-200-points-factset-research-shares-gain-after-q3-results	2025-06-23 14:51:22+00	U.S. stocks traded higher this morning, with the Dow Jones index gaining over 200 points on Monday. Following the market opening Monday, the Dow traded up 0.50% to 42,417.90 while the NASDAQ gained 0.61% to 19,566.92. The S&P 500 also rose, gaining, 0.62% to 6,004.66.	0.153217	2025-10-23 13:35:37.484994+00
2106	FactSet Reports Q3 Revenue Beat, Client Growth, Leadership Shift With JPMorgan Hire - FactSet Research Systems  ( NYSE:FDS ) 	Benzinga	https://www.benzinga.com/markets/earnings/25/06/46053063/factset-reports-q3-revenue-beat-client-growth-leadership-shift-with-jpmorgan-hire	2025-06-23 14:20:28+00	FactSet stock rises despite Q3 EPS miss; revenue beats estimates, up 5.9% YoY to $585.5M. Client count grew by 166 in Q3; FY25 outlook reaffirmed with EPS guidance of $16.80-$17.40. Get access to the leaderboards pointing to tomorrow's biggest stock movers.	0.257466	2025-10-23 13:35:37.484994+00
2107	FactSet: Modest Growth, Higher Costs	Motley Fool	https://www.fool.com/investing/2025/06/23/factset-modest-growth-higher-costs/	2025-06-23 13:50:42+00	Here's our initial take on FactSet Research Systems' ( NYSE: FDS ) financial report.Financial data and analysis vendor FactSet grew revenue in the quarter and remains a must-have vendor for its existing client base. But higher costs ate into the bottom line, leading the company to report earnings ...	0.2016	2025-10-23 13:35:37.484994+00
2108	US Stock Futures Rise As Markets Shrug Off Iran Strike Fallout: 'Worst Is Now In The Rear-View Mirror,' Says Top Analyst - FactSet Research Systems  ( NYSE:FDS ) , Commercial Metals  ( NYSE:CMC ) 	Benzinga	https://www.benzinga.com/markets/market-summary/25/06/46047848/us-stock-futures-rise-as-markets-shrug-off-iran-strike-fallout-worst-is-now-in-the-rear-vi	2025-06-23 10:09:18+00	U.S. stock futures are up Monday morning, but only marginally as tensions continue to flare in the Middle East, following American airstrikes on Iranian nuclear facilities over the weekend.	0.050301	2025-10-23 13:35:37.484994+00
2109	FactSet to Report Q3 Earnings: What's in Store for the Stock?	Zacks Commentary	https://www.zacks.com/stock/news/2520856/factset-to-report-q3-earnings-whats-in-store-for-the-stock	2025-06-20 14:58:00+00	FDS gears up to report third-quarter fiscal 2025 earnings with revenue growth across all regions, but a slight dip in EPS is expected.	0.212127	2025-10-23 13:35:37.484994+00
2128	This week's tech earnings will steer the market's direction over the next few months, Jim Cramer says	CNBC Top News	https://www.cnbc.com/2025/10/27/tech-earnings-steer-market-next-few-months-jim-cramer.html	2025-10-27 22:53:11+00	This week's tech earnings will steer the market's direction over the next few months, Jim Cramer says	0	2025-10-28 18:13:16.531236+00
2110	FactSet Research Gears Up For Q3 Print; Here Are The Recent Forecast Changes From Wall Street's Most Accurate Analysts - FactSet Research Systems  ( NYSE:FDS ) 	Benzinga	https://www.benzinga.com/analyst-stock-ratings/price-target/25/06/46022340/factset-research-gears-up-for-q3-print-here-are-the-recent-forecast-changes-fr	2025-06-20 11:01:57+00	FactSet Research Systems Inc. FDS will release earnings results for the third quarter, before the opening bell on Monday, June 23. Analysts expect the Norwalk, Connecticut-based company to report quarterly earnings at $4.30 cents per share, down from $4.37 per share in the year-ago period.	0.154554	2025-10-23 13:35:37.484994+00
2111	5 Dividend Stocks to Buy With $2,000 and Hold Forever	Motley Fool	https://www.fool.com/investing/2025/06/17/5-dividend-stocks-to-buy-with-2000-and-hold-foreve/	2025-06-17 07:41:00+00	Investing in the stock market is an excellent way to build long-term wealth. For investors seeking passive income, dividend stocks are one way to turn your portfolio into a cash-generating machine. Not only that, but companies that pay dividends consistently tend to outperform those that ...	0.419456	2025-10-23 13:35:37.484994+00
2112	CUSIP Request Volumes for New Corporate and Municipal Securities Increase in May	Benzinga	https://www.benzinga.com/pressreleases/25/06/g45902646/cusip-request-volumes-for-new-corporate-and-municipal-securities-increase-in-may	2025-06-12 12:30:00+00	NORWALK, Conn., June 12, 2025 ( GLOBE NEWSWIRE ) -- CUSIP Global Services ( CGS ) today announced the release of its CUSIP Issuance Trends Report for May 2025.	0.179677	2025-10-23 13:35:37.484994+00
2113	$100 Invested In This Stock 15 Years Ago Would Be Worth This Much Today - FactSet Research Systems  ( NYSE:FDS ) 	Benzinga	https://www.benzinga.com/insights/news/25/05/45609514/100-invested-in-this-stock-15-years-ago-would-be-worth-this-much-today	2025-05-26 23:00:17+00	FactSet Research Systems FDS has outperformed the market over the past 15 years by 1.83% on an annualized basis producing an average annual return of 13.7%. Currently, FactSet Research Systems has a market capitalization of $17.60 billion.	0.25	2025-10-23 13:35:37.484994+00
2114	Peering Into FactSet Research Systems's Recent Short Interest - FactSet Research Systems  ( NYSE:FDS ) 	Benzinga	https://www.benzinga.com/insights/short-sellers/25/05/45466540/peering-into-factset-research-systemss-recent-short-interest	2025-05-16 13:00:29+00	FactSet Research Systems's FDS short percent of float has fallen 4.43% since its last report. The company recently reported that it has 1.37 million shares sold short, which is 4.1% of all regular shares that are available for trading.	0.268767	2025-10-23 13:35:40.788708+00
2115	Zevra Files Definitive Proxy Statement and Mails Letter to Stockholders - Zevra Therapeutics  ( NASDAQ:ZVRA ) 	Benzinga	https://www.benzinga.com/pressreleases/25/04/g44894297/zevra-files-definitive-proxy-statement-and-mails-letter-to-stockholders	2025-04-21 11:22:15+00	Highlights 54.8% Total Stockholder Return Under Refreshed Board and Management Team Zevra Continues Growth Trajectory into a Global Commercial Rare Disease Company with Consistent Execution, New Product Launches, and Significant Financial Flexibility to Execute Strategic Plan	0.287283	2025-10-23 13:35:40.788708+00
2116	Zevra Files Definitive Proxy Statement and Mails Letter to Stockholders	GlobeNewswire	https://www.globenewswire.com/news-release/2025/04/21/3064576/16626/en/Zevra-Files-Definitive-Proxy-Statement-and-Mails-Letter-to-Stockholders.html	2025-04-21 11:22:00+00	Highlights 54.8% Total Stockholder Return Under Refreshed Board and Management Team ...	0.284961	2025-10-23 13:35:40.788708+00
2117	Cycurion Announces Industry Veteran Kevin O'Brien Joins Board of Directors	GlobeNewswire	https://www.globenewswire.com/news-release/2025/04/03/3055154/0/en/Cycurion-Announces-Industry-Veteran-Kevin-O-Brien-Joins-Board-of-Directors.html	2025-04-03 12:15:00+00	MCLEAN, Va., April 03, 2025 ( GLOBE NEWSWIRE ) -- Cycurion ( Nasdaq: CYCU ) ( "Cycurion" or the "Company" ) , a trusted leader in IT cybersecurity solutions and AI, announces that industry veteran Kevin O'Brien has joined its Board of Directors, effective from the close of the Company's recent ...	0.310686	2025-10-23 13:35:40.788708+00
2118	Cycurion Announces Industry Veteran Kevin O'Brien Joins Board of Directors - Cycurion  ( NASDAQ:CYCU ) 	Benzinga	https://www.benzinga.com/pressreleases/25/04/g44625815/cycurion-announces-industry-veteran-kevin-obrien-joins-board-of-directors	2025-04-03 12:15:00+00	MCLEAN, Va., April 03, 2025 ( GLOBE NEWSWIRE ) -- Cycurion CYCU ( "Cycurion" or the "Company" ) , a trusted leader in IT cybersecurity solutions and AI, announces that industry veteran Kevin O'Brien has joined its Board of Directors, effective from the close of the Company's recent de-SPAC ...	0.310743	2025-10-23 13:35:40.788708+00
2121	Why D-Wave Quantum Stock Plummeted This Week	Motley Fool	https://www.fool.com/investing/2025/10/26/why-d-wave-quantum-stock-plummeted-this-week/?source=iedfolrf0000001	2025-10-26 19:45:00+00	Why D-Wave Quantum Stock Plummeted This Week	0	2025-10-28 18:13:16.531236+00
2122	Where Will Rigetti Computing Stock Be in 10 Years?	Motley Fool	https://www.fool.com/investing/2025/10/26/where-will-rigetti-computing-stock-be-in-10-years/?source=iedfolrf0000001	2025-10-26 18:00:00+00	Where Will Rigetti Computing Stock Be in 10 Years?	0	2025-10-28 18:13:16.531236+00
2123	Dow Jones Futures: Nvidia, Microsoft, Palantir, Tesla In Buy Zones After Stock Market Rally	IBD Stock Market	https://www.investors.com/market-trend/stock-market-today/dow-jones-nvidia-nvda-stock-microsoft-palantir-tesla/	2025-10-27 20:57:30+00	Dow Jones Futures: Nvidia, Microsoft, Palantir, Tesla In Buy Zones After Stock Market Rally	0	2025-10-28 18:13:16.531236+00
2124	Palantir Stock Bolts Back Into Buy Range. Now Comes This.	IBD Stock Market	https://www.investors.com/research/how-to-find-the-best-stocks-to-buy/palantir-stock-pltr-back-into-buy-range-q3-earnings-due/	2025-10-27 15:47:45+00	Palantir Stock Bolts Back Into Buy Range. Now Comes This.	0	2025-10-28 18:13:16.531236+00
2125	Palantir Stock Hits Record High Ahead Of Earnings Report. Is Palantir Stock A Buy?	IBD Stock Market	https://www.investors.com/news/technology/palantir-stock-pltr-stock-buy-sell-october-2025/	2025-10-27 13:42:08+00	Palantir Stock Hits Record High Ahead Of Earnings Report. Is Palantir Stock A Buy?	0	2025-10-28 18:13:16.531236+00
2126	Stock Market Today: Nasdaq Jumps As Palantir Tests Entry; Tesla Up Despite This Elon Musk Warning	IBD Stock Market	https://www.investors.com/market-trend/stock-market-today/dow-jones-sp500-nasdaq-us-china-trade-optimism-nvda-tsla-stock/	2025-10-27 12:10:37+00	Stock Market Today: Nasdaq Jumps As Palantir Tests Entry; Tesla Up Despite This Elon Musk Warning	0	2025-10-28 18:13:16.531236+00
2127	Palantir to Sign Letter of Intent With Polish Defense Ministry	Bloomberg Technology	https://www.bloomberg.com/news/articles/2025-10-26/palantir-to-sign-letter-of-intent-with-polish-defense-ministry	2025-10-26 16:43:43+00	Palantir to Sign Letter of Intent With Polish Defense Ministry	0	2025-10-28 18:13:16.531236+00
2129	Alphabet, Nvidia Shares Shot Higher Monday. Which Other Top Performers Just Came Onto IBD's Best Stock Screens?	IBD Stock Market	https://www.investors.com/research/alphabet-nvidia-shares-shot-higher-monday-which-other-top-performers-just-came-onto-ibds-best-stock-screens/	2025-10-27 22:47:36+00	Alphabet, Nvidia Shares Shot Higher Monday. Which Other Top Performers Just Came Onto IBD's Best Stock Screens?	0	2025-10-28 18:13:16.531236+00
2130	3 Undervalued Tech Stocks to Buy and Hold Right Now	Motley Fool	https://www.fool.com/investing/2025/10/27/3-undervalued-tech-stocks-to-buy-and-hold-right-no/?source=iedfolrf0000001	2025-10-27 22:00:00+00	3 Undervalued Tech Stocks to Buy and Hold Right Now	0	2025-10-28 18:13:16.531236+00
2131	Qualcomm Takes Aim at Nvidia With New Chips | Bloomberg Tech 10/27/2025	Bloomberg Technology	https://www.bloomberg.com/news/videos/2025-10-27/bloomberg-tech-10-27-2025-video	2025-10-27 21:54:08+00	Qualcomm Takes Aim at Nvidia With New Chips | Bloomberg Tech 10/27/2025	0	2025-10-28 18:13:16.531236+00
2132	Google Issues ‘Security Breach’ Update For All Gmail Users	Forbes Innovation	https://www.forbes.com/sites/zakdoffman/2025/10/27/google-issues-security-breach-update-for-all-gmail-users/	2025-10-27 21:44:30+00	Google Issues ‘Security Breach’ Update For All Gmail Users	0	2025-10-28 18:13:16.531236+00
2133	Google to Buy Power From NextEra Nuclear Plant Being Revived	Bloomberg Technology	https://www.bloomberg.com/news/articles/2025-10-27/google-to-buy-power-from-nextera-reactor-that-s-being-revived	2025-10-27 20:43:42+00	Google to Buy Power From NextEra Nuclear Plant Being Revived	0	2025-10-28 18:13:16.531236+00
2134	Here's Why Alphabet Stock Popped Today	Motley Fool	https://www.fool.com/investing/2025/10/27/heres-why-alphabet-stock-popped-today/?source=iedfolrf0000001	2025-10-27 19:49:35+00	Here's Why Alphabet Stock Popped Today	0	2025-10-28 18:13:16.531236+00
2135	Why Alphabet Stock Is Jumping Today	Motley Fool	https://www.fool.com/investing/2025/10/27/why-alphabet-stock-is-jumping-today/?source=iedfolrf0000001	2025-10-27 19:21:54+00	Why Alphabet Stock Is Jumping Today	0	2025-10-28 18:13:16.531236+00
2136	Disney Content Could Be Pulled From YouTube TV This Week: Here’s What To Know	Forbes Business	https://www.forbes.com/sites/antoniopequenoiv/2025/10/27/disney-content-could-be-pulled-from-youtube-tv-this-week-heres-what-to-know/	2025-10-27 17:54:37+00	Disney Content Could Be Pulled From YouTube TV This Week: Here’s What To Know	0	2025-10-28 18:13:16.531236+00
2137	Google Photos Adds New Video Editor But Removes Key Features	Forbes Innovation	https://www.forbes.com/sites/paulmonckton/2025/10/27/google-photos-adds-new-video-editor-but-removes-key-features/	2025-10-27 15:03:04+00	Google Photos Adds New Video Editor But Removes Key Features	0	2025-10-28 18:13:16.531236+00
2138	Oppo Find X9 Series Will Have Google-Powered AI Features	Forbes Innovation	https://www.forbes.com/sites/prakharkhanna/2025/10/26/oppo-find-x9-series-will-have-google-powered-ai-features/	2025-10-26 17:52:28+00	Oppo Find X9 Series Will Have Google-Powered AI Features	0	2025-10-28 18:13:16.531236+00
2139	Prediction: This Artificial Intelligence (AI) Stock Will Join Nvidia, Microsoft, Apple, and Alphabet in the $3 Trillion Club by 2027	Motley Fool	https://www.fool.com/investing/2025/10/26/ai-stock-will-join-3-trillion-club-by-2027/?source=iedfolrf0000001	2025-10-26 17:05:00+00	Prediction: This Artificial Intelligence (AI) Stock Will Join Nvidia, Microsoft, Apple, and Alphabet in the $3 Trillion Club by 2027	0	2025-10-28 18:13:16.531236+00
2140	Why Alphabet Stock Popped Today	Motley Fool	https://www.fool.com/investing/2025/10/24/why-alphabet-stock-popped-today/?source=iedfolrf0000001	2025-10-25 00:55:57+00	Why Alphabet Stock Popped Today	0	2025-10-28 18:13:16.531236+00
2141	Stock Market Hits Record Highs On Cool CPI Inflation Data; Trump-Xi, Fed, Apple Earnings Due	IBD Stock Market	https://www.investors.com/market-trend/the-big-picture/dow-jones-stock-market-record-highs-nasdaq-sp500-cpi-inflation-trump-xi-fed-apple-microsoft-alphabet-meta/	2025-10-24 21:38:51+00	Stock Market Hits Record Highs On Cool CPI Inflation Data; Trump-Xi, Fed, Apple Earnings Due	0	2025-10-28 18:13:16.531236+00
2142	Apple, Google, Meta, Amazon, Microsoft Earnings Due; Fed Rate Cut, Trump-Xi Ahead	IBD Stock Market	https://www.investors.com/research/investing-action-plan/apple-google-meta-amazon-microsoft-earnings-fed-rate-cut-trump-xi-ahead/	2025-10-24 17:15:42+00	Apple, Google, Meta, Amazon, Microsoft Earnings Due; Fed Rate Cut, Trump-Xi Ahead	0	2025-10-28 18:13:16.531236+00
2143	Broadcom, IBD Stock Of The Day, Gains Custom AI Chip Business	IBD Stock Market	https://www.investors.com/research/ibd-stock-of-the-day/broadcom-stock-avgo-custom-ai-chip-business-2/	2025-10-24 17:07:14+00	Broadcom, IBD Stock Of The Day, Gains Custom AI Chip Business	0	2025-10-28 18:13:16.531236+00
2144	Apple Shines, Leads Parade Of Megacap Hyperscaler Earnings Reports	IBD Stock Market	https://www.investors.com/research/earnings-preview/apple-stock-shines-leads-parade-hyperscaler-earnings-reports/	2025-10-24 15:17:47+00	Apple Shines, Leads Parade Of Megacap Hyperscaler Earnings Reports	0	2025-10-28 18:13:16.531236+00
2145	Google Cloud Momentum Builds With Anthropic Deal Ahead Of Q3 Earnings. Is Google Stock A Buy?	IBD Stock Market	https://www.investors.com/news/technology/google-stock-buy-sell-alphabet-stock-october-2025/	2025-10-24 11:59:33+00	Google Cloud Momentum Builds With Anthropic Deal Ahead Of Q3 Earnings. Is Google Stock A Buy?	0	2025-10-28 18:13:16.531236+00
2146	Google TPUs Find Sweet Spot of AI Demand, a Decade After Chip’s Debut	Bloomberg Technology	https://www.bloomberg.com/news/articles/2025-10-23/google-tpus-find-sweet-spot-of-ai-demand-a-decade-after-chip-s-debut	2025-10-23 23:18:42+00	Google TPUs Find Sweet Spot of AI Demand, a Decade After Chip’s Debut	0	2025-10-28 18:13:16.531236+00
2147	Google’s new Anthropic deal is a validation moment for this under-the-radar asset	MarketWatch Top Stories	https://www.marketwatch.com/story/googles-new-anthropic-deal-is-a-validation-moment-for-this-under-the-radar-asset-e78a46ec?mod=mw_rss_topstories	2025-10-23 22:22:00+00	Google’s new Anthropic deal is a validation moment for this under-the-radar asset	0	2025-10-28 18:13:16.531236+00
2148	YouTube TV Customers Risk Losing Access to Disney’s ESPN and ABC	Bloomberg Technology	https://www.bloomberg.com/news/articles/2025-10-23/youtube-tv-customers-risk-losing-access-to-disney-s-espn-and-abc	2025-10-23 21:00:00+00	YouTube TV Customers Risk Losing Access to Disney’s ESPN and ABC	0	2025-10-28 18:13:16.531236+00
2149	Google and Anthropic announce cloud deal worth tens of billions of dollars	CNBC Top News	https://www.cnbc.com/2025/10/23/anthropic-google-cloud-deal-tpu.html	2025-10-23 20:45:07+00	Google and Anthropic announce cloud deal worth tens of billions of dollars	0	2025-10-28 18:13:16.531236+00
2150	Google, Anthropic Announce Cloud Deal Worth Tens of Billions	Bloomberg Technology	https://www.bloomberg.com/news/articles/2025-10-23/google-anthropic-announce-cloud-deal-worth-tens-of-billions	2025-10-23 20:40:18+00	Google, Anthropic Announce Cloud Deal Worth Tens of Billions	0	2025-10-28 18:13:16.531236+00
2151	Waymo to Test Vehicles With Human Drivers at Newark Airport	Bloomberg Technology	https://www.bloomberg.com/news/articles/2025-10-22/waymo-to-test-vehicles-with-human-drivers-at-newark-airport	2025-10-22 21:16:59+00	Waymo to Test Vehicles With Human Drivers at Newark Airport	0	2025-10-28 18:13:16.531236+00
2152	Great News for Nvidia and Alphabet Investors	Motley Fool	https://www.fool.com/investing/2025/10/22/nvidia-and-alphabet-expand-ai-partnership/?source=iedfolrf0000001	2025-10-22 20:58:21+00	Great News for Nvidia and Alphabet Investors	0	2025-10-28 18:13:16.531236+00
2153	Anthropic, Google Discuss Multibillion-Dollar Cloud Deal | Bloomberg Tech 10/22/2025	Bloomberg Technology	https://www.bloomberg.com/news/videos/2025-10-22/bloomberg-tech-10-22-2025-video	2025-10-22 20:09:49+00	Anthropic, Google Discuss Multibillion-Dollar Cloud Deal | Bloomberg Tech 10/22/2025	0	2025-10-28 18:13:16.531236+00
2154	Samsung Officially Enters The XR Race With Samsung Galaxy XR Headset	Forbes Innovation	https://www.forbes.com/sites/moorinsights/2025/10/22/samsung-officially-enters-the-xr-race-with-samsung-galaxy-xr-headset/	2025-10-22 17:52:21+00	Samsung Officially Enters The XR Race With Samsung Galaxy XR Headset	0	2025-10-28 18:13:16.531236+00
2155	Google Stock Climbs Amid Anthropic Cloud Talks, Quantum Advances	IBD Stock Market	https://www.investors.com/news/technology/google-stock-anthropic-quantum-computing/	2025-10-22 16:40:44+00	Google Stock Climbs Amid Anthropic Cloud Talks, Quantum Advances	0	2025-10-28 18:13:16.531236+00
2156	Google Unveils Quantum Computing Breakthrough on Willow Chip	Bloomberg Technology	https://www.bloomberg.com/news/articles/2025-10-22/google-unveils-quantum-computing-breakthrough-with-willow-chip	2025-10-22 15:00:00+00	Google Unveils Quantum Computing Breakthrough on Willow Chip	0	2025-10-28 18:13:16.531236+00
2157	GE Aerospace, Alphabet Hit Record High, Lead 17 Stocks Onto Best Stock Lists. New Names And Industry Giants Alike Qualify	IBD Stock Market	https://www.investors.com/news/best-stocks-lists-new-names-and-industry-giants-alike-qualify/	2025-10-21 23:06:37+00	GE Aerospace, Alphabet Hit Record High, Lead 17 Stocks Onto Best Stock Lists. New Names And Industry Giants Alike Qualify	0	2025-10-28 18:13:16.531236+00
2158	Is Broadcom Stock the Next Nvidia?	Motley Fool	https://www.fool.com/investing/2025/10/25/broadcom-stock-the-next-nvidia/?source=iedfolrf0000001	2025-10-25 17:02:00+00	Is Broadcom Stock the Next Nvidia?	0	2025-10-28 18:13:16.531236+00
2159	These 7 Stocks Are Analyst Favorites For Magnificent Earnings Growth; AI Related Stocks Rally	IBD Stock Market	https://www.investors.com/research/best-stocks-seven-magnificent-stocks-earnings-growth/	2025-10-25 12:30:21+00	These 7 Stocks Are Analyst Favorites For Magnificent Earnings Growth; AI Related Stocks Rally	0	2025-10-28 18:13:16.531236+00
2160	S&amp;P 500 Hits Record After Soft CPI, Led by Tech Mega-Cap Gains	Bloomberg Markets	https://www.bloomberg.com/news/articles/2025-10-24/s-p-500-rallies-after-soft-cpi-intel-soars-on-healthy-earnings	2025-10-24 13:58:38+00	S&amp;P 500 Hits Record After Soft CPI, Led by Tech Mega-Cap Gains	0	2025-10-28 18:13:16.531236+00
2161	ASML Just Shared Fantastic News for Nvidia, Broadcom, and AMD Investors	Motley Fool	https://www.fool.com/investing/2025/10/20/asml-buy-growth-stock-nvidia-broadcom-amd/?source=iedfolrf0000001	2025-10-20 17:18:00+00	ASML Just Shared Fantastic News for Nvidia, Broadcom, and AMD Investors	0	2025-10-28 18:13:16.531236+00
2162	Nvidia Peer Targets Buy Point — And Pulls Off This Unique Feat	IBD Stock Market	https://www.investors.com/research/how-to-find-the-best-stocks-to-buy/broadcom-stock-nvidia-peer-targets-buy-point-amid-wall-street-demand/	2025-10-20 16:54:48+00	Nvidia Peer Targets Buy Point — And Pulls Off This Unique Feat	0	2025-10-28 18:13:16.531236+00
2163	Think It's Too Late to Buy This Leading Tech Stock? Here's 1 Reason Why There's Still Time.	Motley Fool	https://www.fool.com/investing/2025/10/20/think-its-too-late-to-buy-this-leading-tech-stock/?source=iedfolrf0000001	2025-10-20 12:17:00+00	Think It's Too Late to Buy This Leading Tech Stock? Here's 1 Reason Why There's Still Time.	0	2025-10-28 18:13:16.531236+00
2164	Nvidia, Broadcom, and AMD Each Won Deals With OpenAI. Here's the Biggest Winner of the Bunch.	Motley Fool	https://www.fool.com/investing/2025/10/20/nvidia-broadcom-and-amd-each-won-deals-with-openai/?source=iedfolrf0000001	2025-10-20 08:30:00+00	Nvidia, Broadcom, and AMD Each Won Deals With OpenAI. Here's the Biggest Winner of the Bunch.	0	2025-10-28 18:13:16.531236+00
2165	S&P 500, Nasdaq Slide On Bad Loan Fears; Broadcom, Hims, Oracle Are Top Stocks To Watch	IBD Stock Market	https://www.investors.com/market-trend/the-big-picture/sp500-nasdaq-dow-banking-worries-broadcom-avgo-stock/	2025-10-16 21:49:43+00	S&P 500, Nasdaq Slide On Bad Loan Fears; Broadcom, Hims, Oracle Are Top Stocks To Watch	0	2025-10-28 18:13:16.531236+00
\.


--
-- Data for Name: portfolios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.portfolios (id, name, description, is_active, created_at, updated_at) FROM stdin;
5	My Portfolio	Your investment portfolio	t	2025-10-20 20:25:17.350576+00	2025-10-20 20:25:17.350576+00
\.


--
-- Data for Name: positions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.positions (id, portfolio_id, stock_id, shares, average_cost, created_at, updated_at) FROM stdin;
91	5	19	0.66926501	19.349584703374823	2025-10-28 17:33:39.788992+00	2025-10-28 17:33:39.788992+00
92	5	20	0.33175933	51.93523871657204	2025-10-28 17:43:44.473258+00	2025-10-28 17:43:44.473258+00
93	5	21	0.03371856	628.7338486578311	2025-10-28 17:50:55.659957+00	2025-10-28 17:50:55.659957+00
94	5	22	1.12691539	15.910688734138239	2025-10-28 17:53:10.994151+00	2025-10-28 17:53:10.994151+00
95	5	23	0.11004665	153.38949436443545	2025-10-28 17:53:11.514591+00	2025-10-28 17:53:11.514591+00
96	5	24	0.44464304	21.52288271508759	2025-10-28 17:53:12.046976+00	2025-10-28 17:53:12.046976+00
97	5	25	0.12809695	153.94589800928125	2025-10-28 17:53:12.835415+00	2025-10-28 17:53:12.835415+00
98	5	26	0.13758923	146.8864968573485	2025-10-28 17:53:13.369871+00	2025-10-28 17:53:13.369871+00
99	5	27	0.07831339	255.89493699608713	2025-10-28 17:53:13.892986+00	2025-10-28 17:53:13.892986+00
100	5	28	0.09108425	194.65494857782767	2025-10-28 17:53:14.415252+00	2025-10-28 17:53:14.415252+00
101	5	29	0.08246429	207.24121919924372	2025-10-28 17:53:14.944989+00	2025-10-28 17:53:14.944989+00
102	5	30	0.05618292	296.70939139510733	2025-10-28 17:53:15.191416+00	2025-10-28 17:53:15.191416+00
103	5	31	0.0205386	775.6127486780988	2025-10-28 17:53:17.236329+00	2025-10-28 17:53:17.236329+00
104	5	32	0.23803965	71.66873249897654	2025-10-28 17:53:18.82459+00	2025-10-28 17:53:18.82459+00
105	5	33	0.0390099	439.1193004852614	2025-10-28 17:53:20.466676+00	2025-10-28 17:53:20.466676+00
106	5	34	0.05229903	324.86262173504934	2025-10-28 17:53:22.135988+00	2025-10-28 17:53:22.135988+00
107	5	35	0.07185412	236.03378623243876	2025-10-28 17:53:23.811089+00	2025-10-28 17:53:23.811089+00
108	5	36	0.05608644	247.29685107487654	2025-10-28 17:53:25.392616+00	2025-10-28 17:53:25.392616+00
\.


--
-- Data for Name: stock_prices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stock_prices (id, stock_id, date, open, close, high, low, volume) FROM stdin;
3601	19	2025-10-27	31.27	32.24	34.3	30.57	65054302
3602	19	2025-10-24	30.54	30.04	32.37	29.72	67660999
3603	19	2025-10-23	29.99	28.58	30.76	27.29	114387721
3604	19	2025-10-22	27.7	25.11	28.81	24.26	79628979
3605	19	2025-10-21	30.93	29.61	31.26	28.63	40668794
3606	19	2025-10-20	36.36	31.65	36.51	30.84	43951081
3607	19	2025-10-17	35.42	35.26	36.31	33.18	45679743
3608	19	2025-10-16	41.12	37.22	41.52	36.46	55798000
3609	19	2025-10-15	42.69	41.2	43.01	37.92	77600020
3610	19	2025-10-14	37.28	39.62	41.68	35.05	73334937
3611	19	2025-10-13	31.54	37.37	38.61	30.01	89082845
3612	19	2025-10-10	32.83	30.38	32.97	29.89	58521724
3613	19	2025-10-09	31.92	32.26	33.71	30.91	66185818
3614	19	2025-10-08	33.23	31.51	36.39	29.91	83873299
3615	19	2025-10-07	34	32.86	34.87	31.14	90346459
3616	19	2025-10-06	29.45	32.22	33.5	29.3	74825255
3617	19	2025-10-03	28.15	30.08	30.62	27.55	89971277
3618	19	2025-10-02	24.1	26.87	27.24	23.95	72187886
3619	19	2025-10-01	22.44	23.58	23.75	22	43929472
3620	19	2025-09-30	22.94	22.73	23.44	21.78	46242383
3621	19	2025-09-29	24.86	23.29	26.28	22.97	68895909
3622	19	2025-09-26	24.24	24.62	26.22	23.94	60598622
3623	19	2025-09-25	23.93	24.23	25.14	22.65	65488824
3624	19	2025-09-24	26.16	25.5	26.85	24.25	66549277
3625	19	2025-09-23	23.81	25.32	25.75	23.55	66448026
3626	19	2025-09-22	22.53	23.62	24.16	21.01	69773462
3627	19	2025-09-19	21.45	24.73	25.14	21.45	102188600
3628	19	2025-09-18	21.04	22.1	22.86	20.55	80856464
3629	19	2025-09-17	17.46	20.74	21.02	17.42	126852159
3630	19	2025-09-16	16.91	17.46	17.65	16.47	39742598
3631	19	2025-09-15	16.28	16.85	17.09	15.88	44351323
3632	19	2025-09-12	15.34	16.34	16.54	15.22	59652367
3633	19	2025-09-11	14.82	15.2	15.38	14.68	38787036
3634	19	2025-09-10	14.9	14.76	15.11	14.6	29141721
3635	19	2025-09-09	14.21	14.86	14.94	14.06	34180640
3636	19	2025-09-08	14.26	14.19	14.49	14.01	22874693
3637	19	2025-09-05	14.22	14.14	14.68	13.71	32925294
3638	19	2025-09-04	14.23	14.07	14.55	13.69	27518891
3639	19	2025-09-03	14.54	14.08	14.83	13.97	31969558
3640	19	2025-09-02	13.94	14.58	14.59	13.6	29039672
3641	19	2025-08-29	14.7	14.37	14.71	14.22	20006692
3642	19	2025-08-28	14.2	14.65	14.99	14.17	32742518
3643	19	2025-08-27	14.1	14.01	14.55	13.86	26923471
3644	19	2025-08-26	13.83	14.21	14.3	13.78	23348112
3645	19	2025-08-25	14.19	13.82	14.2	13.58	21415533
3646	19	2025-08-22	13.56	14.3	14.37	13.27	31682461
3647	19	2025-08-21	13.8	13.63	13.82	13.4	24222502
3648	19	2025-08-20	14.08	13.86	14.22	13.06	36855007
3649	19	2025-08-19	15.2	14.09	15.27	14.03	33392342
3650	19	2025-08-18	15.64	15.24	15.7	14.93	27337500
3651	19	2025-08-15	16.34	15.65	16.46	15.2	45627527
3652	19	2025-08-14	16.79	16.73	17.06	16.04	42780134
3653	19	2025-08-13	17.16	17.16	17.56	16.34	52175641
3654	19	2025-08-12	16.07	17.03	17.1	15.58	47375247
3655	19	2025-08-11	15.64	15.98	16.74	15.47	43714744
3656	19	2025-08-08	15.76	15.55	16.35	15.24	44645991
3657	19	2025-08-07	15.64	15.8	16.49	15.24	65506204
3658	19	2025-08-06	17.08	16.17	17.12	16.02	38888470
3659	19	2025-08-05	16.3	16.84	17.64	16.09	58268219
3660	19	2025-08-04	15.42	15.81	16.03	15.04	33087323
3661	19	2025-08-01	15.19	15.07	15.68	14.82	31626288
3662	19	2025-07-31	16.2	15.81	17.1	15.81	37839187
3663	19	2025-07-30	16.49	15.7	16.99	15.43	37283168
3664	19	2025-07-29	17.31	16.26	17.7	16.23	30090958
3665	19	2025-07-28	17.76	16.88	17.88	16.39	34377585
3666	19	2025-07-25	18.12	17.36	18.17	17.23	31470163
3667	19	2025-07-24	18.07	18.18	18.83	17.86	49987890
3668	19	2025-07-23	16.84	18.68	18.83	16.62	77379082
3669	19	2025-07-22	16.91	16.18	16.91	15.44	43194545
3670	19	2025-07-21	17.89	16.92	18.92	16.9	81623633
3671	19	2025-07-18	17.34	17.38	17.54	16.45	52081832
3672	19	2025-07-17	15.81	17.7	17.97	15.73	101936740
3673	19	2025-07-16	15	15.56	15.62	14.46	51385889
3674	19	2025-07-15	14.64	14.86	14.97	14.27	31591745
3675	19	2025-07-14	13.87	14.56	14.61	13.7	28069694
3676	19	2025-07-11	14.59	13.63	14.77	13.58	30063513
3677	19	2025-07-10	15.07	14.73	15.27	14.66	28329995
3678	19	2025-07-09	15.06	15.08	15.7	14.43	39291356
3679	19	2025-07-08	15.63	14.71	16.14	14.68	37366711
3680	19	2025-07-07	15.37	15.42	15.8	14.66	35884392
3681	19	2025-07-03	14.91	15.45	15.48	14.82	29876920
3682	19	2025-07-02	13.92	14.7	14.79	13.58	62915396
3683	19	2025-07-01	13.98	13.63	14.09	13.15	54151519
3684	19	2025-06-30	12.99	13.47	13.59	12.72	38372521
3685	19	2025-06-27	12.97	12.9	13.25	12.48	62783379
3686	19	2025-06-26	13.04	12.94	13.26	12.83	38744616
3687	19	2025-06-25	13.87	13.05	14.2	13.03	30993682
3688	19	2025-06-24	14.06	13.77	14.13	13.52	33442485
3689	19	2025-06-23	13.82	13.74	14.12	13.07	46541766
3690	19	2025-06-20	14.69	14.4	14.85	14.24	55758444
3691	19	2025-06-18	14.48	14.45	14.95	13.97	52611096
3692	19	2025-06-17	14.71	14.31	14.81	13.82	39546578
3693	19	2025-06-16	14.26	14.72	15.45	14.22	59371520
3694	19	2025-06-13	14.11	13.96	14.41	13.65	41618731
3695	19	2025-06-12	15.26	14.61	15.64	14.51	49982450
3696	19	2025-06-11	16.04	15.21	16.29	14.88	86552097
3697	19	2025-06-10	16.56	15.58	17.43	15.51	64100890
3698	19	2025-06-09	17.37	16.51	17.4	16.25	57044253
3699	19	2025-06-06	15.28	17.13	17.29	14.96	82618030
3700	19	2025-06-05	16.13	15.15	16.25	14.8	66175450
3701	20	2025-10-27	57.96	57.78	60.26	57.3	25766729
3702	20	2025-10-24	57.05	55.48	58.98	55.13	27501685
3703	20	2025-10-23	56.21	54.62	57.9	52.44	65822796
3704	20	2025-10-22	53.54	51.01	54.6	48.09	39326803
3705	20	2025-10-21	55.6	54.74	56.03	52.63	26167022
3706	20	2025-10-20	60.09	55.14	60.26	53.99	28516149
3707	20	2025-10-17	60.17	57.9	60.46	56.31	33423292
3708	20	2025-10-16	67.96	60.34	67.96	60.26	35988426
3709	20	2025-10-15	73.54	66.62	73.81	65.14	31348014
3710	20	2025-10-14	73.46	71.35	74.59	69.85	34459560
3711	20	2025-10-13	68.18	75.52	77.87	66.98	49458815
3712	20	2025-10-10	70.84	65	71.19	64.99	41146754
3713	20	2025-10-09	68.88	71.3	71.76	67.76	25016196
3714	20	2025-10-08	72.63	68.36	75.82	66.79	40788186
3715	20	2025-10-07	74.48	72.89	76.33	69.44	47589070
3716	20	2025-10-06	66.24	72.67	72.89	66.13	36300964
3717	20	2025-10-03	64.94	67.42	67.86	62.88	37681777
3718	20	2025-10-02	59.63	64.03	64.03	59.26	37383603
3719	20	2025-10-01	56.47	58.04	59.66	55.33	33912352
3720	20	2025-09-30	58.5	56.58	59.8	55.74	22600610
3721	20	2025-09-29	62.91	59.12	63.37	58.16	27595283
3722	20	2025-09-26	62.94	61.9	64.79	60.1	32156903
3723	20	2025-09-25	65.47	63.88	66.51	61.56	44799728
3724	20	2025-09-24	69.23	67.95	69.87	65.33	33075623
3725	20	2025-09-23	68.15	69.13	70.04	65.73	40011854
3726	20	2025-09-22	62.66	66.18	67.32	60.86	35675502
3727	20	2025-09-19	60.7	64.78	65.6	60.39	50959400
3728	20	2025-09-18	63.08	61.47	64.8	60.19	45892863
3729	20	2025-09-17	58.25	60.2	61.08	56.19	49629870
3730	20	2025-09-16	54.26	57.28	57.82	52.56	30636632
3731	20	2025-09-15	52.33	54.38	55.1	51.47	34676982
3732	20	2025-09-12	43.52	51.16	51.58	43.38	68818848
3733	20	2025-09-11	40.66	43.29	43.45	39.91	21599093
3734	20	2025-09-10	40.77	40.35	41.57	40.08	14429958
3735	20	2025-09-09	38.08	40.48	40.72	37.76	17694881
3736	20	2025-09-08	38.72	37.73	39.18	37.15	10501715
3737	20	2025-09-05	39.06	38.46	39.31	37.27	11508864
3738	20	2025-09-04	37.93	38.74	39.59	37.53	13213861
3739	20	2025-09-03	39.23	37.69	39.75	37.33	10219930
3740	20	2025-09-02	37.75	39.55	39.61	37	13787121
3741	20	2025-08-29	39.15	39.32	39.81	38.47	11540586
3742	20	2025-08-28	38.23	39.84	40.23	38.13	16109085
3743	20	2025-08-27	37.74	38.11	39.26	37.51	17335745
3744	20	2025-08-26	35.74	37.49	37.65	35.61	13548859
3745	20	2025-08-25	36.52	35.59	36.63	35.45	12158678
3746	20	2025-08-22	34.13	36.6	36.73	33.72	15199384
3747	20	2025-08-21	34.27	34.2	34.39	33.53	10120963
3748	20	2025-08-20	34.39	33.85	34.42	31.99	16401257
3749	20	2025-08-19	37	33.86	37.07	33.66	18738426
3750	20	2025-08-18	36.8	37.01	37.26	35.89	8204336
3751	20	2025-08-15	37.52	37.01	37.56	36.27	10334824
3752	20	2025-08-14	37.27	37.75	37.83	36.14	16638152
3753	20	2025-08-13	39.77	37.91	40.02	37.49	20702318
3754	20	2025-08-12	41.08	39.56	41.37	39.22	20835613
3755	20	2025-08-11	38.59	41.34	43.07	38.1	35598846
3756	20	2025-08-08	37.27	38.5	38.98	37.18	20441527
3757	20	2025-08-07	35.86	37.25	38.25	35.52	27970432
3758	20	2025-08-06	40.11	37.93	40.11	37.52	23969629
3759	20	2025-08-05	37.39	38.66	39.04	36.92	22060462
3760	20	2025-08-04	35.87	36.67	37.44	35.35	16131416
3761	20	2025-08-01	35.82	35.07	36.06	34.27	20028190
3762	20	2025-07-31	37.83	36.68	38.89	36.45	21572670
3763	20	2025-07-30	37.7	36.69	38.51	36.09	17861416
3764	20	2025-07-29	39.57	37.29	40.67	37.12	21070279
3765	20	2025-07-28	40.41	38.95	40.97	38.12	16976724
3766	20	2025-07-25	40.7	39.72	40.71	39.5	13392031
3767	20	2025-07-24	39.46	40.39	41.07	38.87	18006268
3768	20	2025-07-23	39.32	39.82	40.06	38.44	14455131
3769	20	2025-07-22	40.96	38.58	40.98	37.99	18995743
3770	20	2025-07-21	43.07	40.88	43.91	40.87	23906955
3771	20	2025-07-18	41.28	42.79	43.83	40.5	25760405
3772	20	2025-07-17	39.96	41.25	41.27	39.67	20228762
3773	20	2025-07-16	38.87	40.06	40.18	37.57	24223139
3774	20	2025-07-15	39.15	38.15	39.69	37.79	15889182
3775	20	2025-07-14	38.72	39.02	39.3	38.07	16527578
3776	20	2025-07-11	41.4	38.47	41.92	38.43	23363626
3777	20	2025-07-10	41.92	42.26	42.64	40.96	19544580
3778	20	2025-07-09	42.07	41.92	43.47	40.92	24574175
3779	20	2025-07-08	42.92	41.37	44.05	41.11	25675945
3780	20	2025-07-07	42.67	41.58	43.43	39.42	33850931
3781	20	2025-07-03	40.69	40.84	41.93	39.76	13345323
3782	20	2025-07-02	37.89	41.17	41.33	37.23	24757053
3783	20	2025-07-01	38.98	36.89	39.26	36.54	21237890
3784	20	2025-06-30	37.91	39.53	40.57	37.79	29526415
3785	20	2025-06-27	38	37.03	38.52	35.85	21643333
3786	20	2025-06-26	36.4	37.83	38.36	35.89	21786403
3787	20	2025-06-25	38.38	35.06	38.76	35.02	16075718
3788	20	2025-06-24	38.55	37.59	39.39	37.29	19999091
3789	20	2025-06-23	35.76	37.85	37.91	34.39	24966065
3790	20	2025-06-20	36.44	37.13	38.12	35.81	33098968
3791	20	2025-06-18	34.52	36.46	36.5	34.33	18288650
3792	20	2025-06-17	34.83	35	35.56	33.91	18889315
3793	20	2025-06-16	34.26	35.36	36.12	33.15	29311138
3794	20	2025-06-13	34.58	34.81	36.64	34.44	19404599
3795	20	2025-06-12	36.33	35.61	37.59	35.53	20079568
3796	20	2025-06-11	38.26	36.52	40.44	35.82	53397297
3797	20	2025-06-10	37.39	36.56	40.53	36.3	31977934
3798	20	2025-06-09	39.13	36.86	39.15	35.74	36305055
3799	20	2025-06-06	34.66	35.9	36.75	33.86	16146130
3800	20	2025-06-05	35.97	33.73	36.11	33.05	17408691
3801	21	2025-10-27	689.75	690.75	695.29	688.17	11321080
3802	21	2025-10-24	677.85	679.29	681.91	672.66	9151267
3803	21	2025-10-23	675.92	675.28	683.02	674.45	9855974
3804	21	2025-10-22	675.12	674.74	681.35	666.11	8734491
3805	21	2025-10-21	677.13	674.61	679.42	670.45	7647269
3806	21	2025-10-20	663.49	673.6	675.07	662.57	8900204
3807	21	2025-10-17	650.51	659.56	661.06	649.63	12232441
3808	21	2025-10-16	660.15	655.1	667.45	647.57	9017010
3809	21	2025-10-15	659.7	660.15	665.99	652.75	10246766
3810	21	2025-10-14	651.16	651.96	658.31	643.38	8829757
3811	21	2025-10-13	655.97	658.44	662.34	651.03	9251796
3812	21	2025-10-10	672.45	648.88	676.45	648.15	16980091
3813	21	2025-10-09	660.81	674.83	674.83	655.44	12717172
3814	21	2025-10-08	656.37	660.41	662.08	651.19	10790571
3815	21	2025-10-07	660.3	656.03	661.02	649.29	12062928
3816	21	2025-10-06	648.77	658.41	659.53	635.27	21654738
3817	21	2025-10-03	671.25	653.72	672.52	653.37	16154305
3818	21	2025-10-02	664.77	668.89	669.55	660.69	11415271
3819	21	2025-10-01	663.77	659.95	664.1	653.38	20419633
3820	21	2025-09-30	682.87	675.63	683.53	668.2	16226750
3821	21	2025-09-29	688.82	683.93	690.72	680.02	9246768
3822	21	2025-09-26	690	684.25	691.78	678.36	9696338
3823	21	2025-09-25	693.17	689	696.22	684.99	10591065
3824	21	2025-09-24	696.9	699.81	700.22	692.32	8828227
3825	21	2025-09-23	707.71	694.97	708.95	690.98	10872592
3826	21	2025-09-22	719.3	703.95	722.87	703.31	11706946
3827	21	2025-09-19	723.51	716.11	727.54	707.65	23696824
3828	21	2025-09-18	718.29	717.83	725.68	711.49	10954950
3829	21	2025-09-17	717.59	713.66	720.63	705.01	9400867
3830	21	2025-09-16	705.64	716.68	718.85	703.89	11782482
3831	21	2025-09-15	696.87	703.52	712.14	691.83	10533780
3832	21	2025-09-12	688.83	695.14	696.96	684.26	8248557
3833	21	2025-09-11	694.28	690.83	696.53	688.5	7923284
3834	21	2025-09-10	703.92	691.82	704.44	690.92	12478276
3835	21	2025-09-09	696.89	704.44	705	693.16	10999026
3836	21	2025-09-08	695.52	692.12	705.19	691.86	13087816
3837	21	2025-09-05	692.41	692.25	697.31	685.43	9663441
3838	21	2025-09-04	688.68	688.76	700.27	686.15	11439078
3839	21	2025-09-03	677.12	678.09	681.03	675.27	7650495
3840	21	2025-09-02	667.96	676.3	677.12	663.99	9350857
3841	21	2025-08-29	685.66	679.6	687.37	676.52	9070546
3842	21	2025-08-28	684.48	691.02	692.81	681.53	7467955
3843	21	2025-08-27	692.12	687.59	693.82	683.41	8315435
3844	21	2025-08-26	690.74	693.77	694.48	688.1	7601800
3845	21	2025-08-25	694.43	693.04	698.17	690.12	6861158
3846	21	2025-08-22	680.09	694.41	696.35	675.64	10612667
3847	21	2025-08-21	685.13	679.97	685.86	674.46	8876307
3848	21	2025-08-20	687.76	687.9	690.18	672.52	11898190
3849	21	2025-08-19	705.75	691.36	705.8	689.41	12286690
3850	21	2025-08-18	713.08	705.98	713.75	696.04	16513737
3851	21	2025-08-15	721.42	722.41	732.55	718.35	13375361
3852	21	2025-08-14	715.65	719.56	724.79	710.71	8116193
3853	21	2025-08-13	727.86	717.67	731.82	715.97	8811750
3854	21	2025-08-12	711.16	726.8	730.18	710.64	14579765
3855	21	2025-08-11	708.47	704.6	711.58	703.5	7611964
3856	21	2025-08-08	701.73	707.76	708.31	697.89	7320755
3857	21	2025-08-07	711.61	700.88	713	698.79	9019691
3858	21	2025-08-06	708.4	710.23	711.75	699.62	9733910
3859	21	2025-08-05	714.33	702.38	720.48	701.96	11640294
3860	21	2025-08-04	699.2	714.26	714.7	697.74	15801727
3861	21	2025-08-01	699.87	690.01	704.72	685.69	19028710
3862	21	2025-07-31	713.18	711.56	721.97	704.27	38831098
3863	21	2025-07-30	651.44	639.59	651.82	635.9	27077286
3864	21	2025-07-29	662.4	644	666.51	643.92	13267032
3865	21	2025-07-28	657.98	660.22	666.76	655.67	8715743
3866	21	2025-07-25	659.56	655.67	663	654.95	8271698
3867	21	2025-07-24	659.69	657.62	665.73	656.88	10920836
3868	21	2025-07-23	649.86	656.49	657.46	648.54	8771615
3869	21	2025-07-22	658.89	648.43	659.27	645.3	8921064
3870	21	2025-07-21	650.26	655.93	659.64	649.3	9404391
3871	21	2025-07-18	646.01	647.94	648.33	636.32	12779752
3872	21	2025-07-17	648.04	645.3	649.43	641.34	11803264
3873	21	2025-07-16	656.3	646.68	656.85	643.33	13067627
3874	21	2025-07-15	665.99	653.56	666.51	653.03	11529511
3875	21	2025-07-14	660.19	663.25	669.76	659.22	8939399
3876	21	2025-07-11	664.7	660.11	667.15	652.92	10873880
3877	21	2025-07-10	673.03	669.06	676.94	662.03	9922249
3878	21	2025-07-09	664.9	674.16	678.53	664.9	11417963
3879	21	2025-07-08	663.84	663.02	665.08	657.63	7770693
3880	21	2025-07-07	660.19	660.88	668.84	656.43	9457080
3881	21	2025-07-03	668.48	661.49	670.71	657.27	8601653
3882	21	2025-07-02	658.1	656.48	662.68	655.78	9336740
3883	21	2025-07-01	677.93	661.68	678.73	658.14	13431248
3884	21	2025-06-30	684.99	679.04	688.07	675.51	15402105
3885	21	2025-06-27	668.39	674.94	676.6	667.79	18775735
3886	21	2025-06-26	657.21	668	669.96	654.17	13964793
3887	21	2025-06-25	656.25	651.99	659.25	648.95	9320436
3888	21	2025-06-24	648.49	655.22	656.13	645.94	13823180
3889	21	2025-06-23	628.99	642.65	643.13	624.45	11080055
3890	21	2025-06-20	644.69	627.76	645.67	624.38	22538640
3891	21	2025-06-18	642.33	640.11	645.46	639.31	10068255
3892	21	2025-06-17	645.84	641.45	649.49	640.38	10066110
3893	21	2025-06-16	643.38	645.95	650.58	638.03	13720288
3894	21	2025-06-13	632.91	628.24	639	626.53	9274441
3895	21	2025-06-12	637.84	637.89	639.75	632.04	7322730
3896	21	2025-06-11	647.41	638.61	652.16	636.63	9582508
3897	21	2025-06-10	645.24	646.21	646.97	636.24	10850146
3898	21	2025-06-09	642.58	638.54	648.77	638.42	12773221
3899	21	2025-06-06	640.48	641.89	646.58	636.52	11727961
3900	21	2025-06-05	636.33	629.85	638.83	627.67	13120335
3901	22	2025-10-27	14.79	14.46	15.37	14.43	45408022
3902	22	2025-10-24	15.36	14.29	15.96	14.27	37701050
3903	22	2025-10-23	15.47	14.66	15.55	14.14	55753810
3904	22	2025-10-22	14.17	13.68	14.43	12.77	51281542
3905	22	2025-10-21	15.93	14.72	16.01	14.31	46061352
3906	22	2025-10-20	17.24	15.9	17.37	15.81	39172313
3907	22	2025-10-17	17.14	16.86	17.58	16.36	40676205
3908	22	2025-10-16	19.64	17.24	19.72	17	49847962
3909	22	2025-10-15	21.36	19.53	21.89	18.92	53212871
3910	22	2025-10-14	19.51	20.04	21.47	18.52	54128368
3911	22	2025-10-13	18.34	19.74	19.78	17.88	44066282
3912	22	2025-10-10	19.84	17.49	20.03	17.49	52504007
3913	22	2025-10-09	19.5	19.61	19.69	18.75	43675358
3914	22	2025-10-08	20.27	19.15	20.92	18.6	52578762
3915	22	2025-10-07	21.96	20.25	21.96	19.32	69257525
3916	22	2025-10-06	19.92	20.39	21.52	19.26	102065492
3917	22	2025-10-03	20.01	22.65	23.77	19.24	118439619
3918	22	2025-10-02	17.77	18.38	18.82	17.67	46510584
3919	22	2025-10-01	16.87	17.45	18.11	16.56	20376985
3920	22	2025-09-30	17.34	16.94	17.75	16.75	20906552
3921	22	2025-09-29	19.04	17.34	19.6	17.18	32791761
3922	22	2025-09-26	18.91	18.53	21.57	18.17	54799884
3923	22	2025-09-25	18.77	18.93	19.49	17.67	46061104
3924	22	2025-09-24	20.17	19.7	20.65	18.4	41305336
3925	22	2025-09-23	19.33	19.69	20.46	18.32	50557946
3926	22	2025-09-22	18.7	18.59	19.24	16.94	80679923
3927	22	2025-09-19	16.73	21.41	22.06	16.72	98556687
3928	22	2025-09-18	17	16.88	17.71	16.36	42934199
3929	22	2025-09-17	15.39	16.29	16.57	15.26	35448093
3930	22	2025-09-16	15.56	15.52	15.7	14.5	29370306
3931	22	2025-09-15	15.84	15.49	16.08	15.24	19579740
3932	22	2025-09-12	14.72	15.65	15.88	14.59	28709982
3933	22	2025-09-11	14.14	14.62	14.73	13.91	14810379
3934	22	2025-09-10	14.86	14.18	14.98	14.08	19483501
3935	22	2025-09-09	14.03	14.9	14.93	13.88	17597241
3936	22	2025-09-08	13.8	14.02	14.08	13.53	12545386
3937	22	2025-09-05	13.87	13.9	14.43	13.6	13657885
3938	22	2025-09-04	13.44	13.58	13.74	13.07	14041734
3939	22	2025-09-03	13.99	13.39	14.09	13.2	15279309
3940	22	2025-09-02	14.03	13.85	14.24	13.17	15814427
3941	22	2025-08-29	14.77	14.52	14.88	14.16	14528121
3942	22	2025-08-28	13.89	14.81	14.88	13.52	24575293
3943	22	2025-08-27	13.99	13.63	14.15	13.62	12380925
3944	22	2025-08-26	13.84	14.01	14.14	13.66	13995599
3945	22	2025-08-25	14.48	13.99	14.64	13.96	12581068
3946	22	2025-08-22	13.42	14.56	14.8	13.16	18144785
3947	22	2025-08-21	13.35	13.51	13.58	13.22	9110240
3948	22	2025-08-20	13.52	13.45	13.64	12.62	13602281
3949	22	2025-08-19	14.55	13.67	14.68	13.61	12138179
3950	22	2025-08-18	14.05	14.62	14.95	13.83	16871092
3951	22	2025-08-15	13.7	14.09	14.39	13.46	15982942
3952	22	2025-08-14	14.53	14.15	14.55	13.77	20320583
3953	22	2025-08-13	15.23	14.73	15.54	14.26	23012596
3954	22	2025-08-12	15.1	15.27	15.28	14.58	15063194
3955	22	2025-08-11	14.78	15.14	15.45	14.65	14002797
3956	22	2025-08-08	14.7	14.84	15.25	14.51	12655626
3957	22	2025-08-07	14.71	14.5	15.11	14.33	12055724
3958	22	2025-08-06	15.44	14.88	15.54	14.6	12693403
3959	22	2025-08-05	15.15	15.54	15.86	14.52	32154079
3960	22	2025-08-04	13.74	14.35	14.53	13.53	12423322
3961	22	2025-08-01	13.06	13.62	13.68	12.85	12313422
3962	22	2025-07-31	14.03	13.65	14.53	13.58	14920099
3963	22	2025-07-30	14.08	13.55	14.33	13.46	12237471
3964	22	2025-07-29	14.78	14.14	15.12	13.95	13095992
3965	22	2025-07-28	15.62	14.86	15.81	14.66	12698818
3966	22	2025-07-25	15.61	15.37	15.72	15.11	10241014
3967	22	2025-07-24	15.86	15.59	15.95	15.47	13171961
3968	22	2025-07-23	15.83	16.07	16.11	15.38	15793934
3969	22	2025-07-22	16.74	15.47	16.78	14.97	20057534
3970	22	2025-07-21	18.03	16.42	18.23	16.36	24281680
3971	22	2025-07-18	18.23	17.95	18.5	17.28	22077766
3972	22	2025-07-17	17.04	18.19	18.32	16.95	25705696
3973	22	2025-07-16	16.58	16.93	17.09	16.21	21321869
3974	22	2025-07-15	17.51	16.26	17.56	16.04	33574355
3975	22	2025-07-14	16.46	17.42	17.59	16.14	16917732
3976	22	2025-07-11	17.39	16.04	17.99	15.99	16887052
3977	22	2025-07-10	17.69	17.65	17.89	17.2	10102185
3978	22	2025-07-09	17.88	17.61	18.43	17.08	13573234
3979	22	2025-07-08	18.59	17.8	18.85	17.44	15733920
3980	22	2025-07-07	19.15	18.29	20.13	17.96	21767621
3981	22	2025-07-03	18.76	19.44	19.49	18.55	18594242
3982	22	2025-07-02	17.01	19	19.26	16.74	39487429
3983	22	2025-07-01	17.23	17.15	17.52	16.5	20220665
3984	22	2025-06-30	16.16	17.64	17.74	15.77	32043185
3985	22	2025-06-27	15.64	15.91	16.89	15.08	45462845
3986	22	2025-06-26	15.62	15.45	16.08	15.4	13731488
3987	22	2025-06-25	16.5	15.4	16.96	15.12	19505668
3988	22	2025-06-24	16.72	16.12	16.73	15.92	20054612
3989	22	2025-06-23	14.62	16.1	16.37	14.26	41031555
3990	22	2025-06-20	18.49	17.37	18.71	17.32	32394089
3991	22	2025-06-18	18.7	17.56	19.84	17.21	44208732
3992	22	2025-06-17	18.28	18.21	19.37	17.65	47230271
3993	22	2025-06-16	15.97	19.52	20	15.82	65558661
3994	22	2025-06-13	15.62	15.35	16.27	15.13	21509270
3995	22	2025-06-12	18.15	16.11	18.57	15.95	60176956
3996	22	2025-06-11	15.73	17.45	19.24	15.29	131799356
3997	22	2025-06-10	13.51	13.92	16.19	13.27	66532989
3998	22	2025-06-09	13.58	13.19	13.82	12.53	35618623
3999	22	2025-06-06	11.19	12.6	12.74	10.93	35529015
4000	22	2025-06-05	11.64	10.88	11.7	10.73	14163457
4001	23	2025-10-27	237.25	238.9	239.59	229.82	65613111
4002	23	2025-10-24	223.89	232.69	233.12	222.59	71221144
4003	23	2025-10-23	211.75	216.19	217.03	210.26	39024429
4004	23	2025-10-22	217.9	211.81	220.92	206.89	59668778
4005	23	2025-10-21	220.24	218.99	222.88	215.3	47122393
4006	23	2025-10-20	217.55	221.32	223.45	215.65	56741695
4007	23	2025-10-17	214.6	214.43	216.55	209.68	55804203
4008	23	2025-10-16	217.38	215.8	221.9	213.66	69726437
4009	23	2025-10-15	204.89	219.51	220.1	203.1	108480962
4010	23	2025-10-14	201.66	200.64	206.98	198.63	71216269
4011	23	2025-10-13	202.58	199.11	206.25	197.71	63104021
4012	23	2025-10-10	214.15	197.71	215.48	196.14	118656636
4013	23	2025-10-09	217.4	214.26	220.89	211.17	94290740
4014	23	2025-10-08	195.91	216.72	217	193.84	159983459
4015	23	2025-10-07	197.66	194.59	201.39	192.54	115748143
4016	23	2025-10-06	208.33	187.41	208.57	186.77	248859576
4017	23	2025-10-03	157.03	151.5	157.03	150.09	42699147
4018	23	2025-10-02	155.18	156.15	157.38	152.83	55475228
4019	23	2025-10-01	148.06	150.89	151.05	147.65	39895177
4020	23	2025-09-30	147.93	148.85	149.3	146.58	29669331
4021	23	2025-09-29	147.31	148.45	151.16	147.11	39828794
4022	23	2025-09-26	147.68	146.7	149.14	144.49	30316931
4023	23	2025-09-25	144.56	148.37	148.7	142.4	36809877
4024	23	2025-09-24	149.94	148.01	151.89	145.76	38464120
4025	23	2025-09-23	147.68	148.03	150.32	146.47	39448320
4026	23	2025-09-22	144.83	147.01	149.67	144.83	46505480
4027	23	2025-09-19	144.79	144.8	147.05	143.43	55448076
4028	23	2025-09-18	138.88	145.29	146.07	137.86	84549468
4029	23	2025-09-17	146.54	146.43	148.7	143.3	41823842
4030	23	2025-09-16	148.46	147.62	148.99	146.48	27946478
4031	23	2025-09-15	147.21	148.27	149.32	144.99	36808726
4032	23	2025-09-12	144.44	145.88	147.58	142.53	42232777
4033	23	2025-09-11	145.93	143.22	147.39	142.59	48817715
4034	23	2025-09-10	150.46	146.78	151.36	145.36	52465270
4035	23	2025-09-09	139.83	143.35	144.13	139.78	42802472
4036	23	2025-09-08	139.66	139.3	140.43	137.28	41848995
4037	23	2025-09-05	144.55	139.05	144.57	138.17	78255950
4038	23	2025-09-04	147.14	148.85	149.09	145.17	32103496
4039	23	2025-09-03	148.87	149.16	151.57	147.73	30070421
4040	23	2025-09-02	145.75	149.33	149.4	144.09	38656131
4041	23	2025-08-29	153.47	149.62	155.08	148.95	37516824
4042	23	2025-08-28	155.02	155.09	157.31	153.32	36285192
4043	23	2025-08-27	152.76	153.76	154.27	151.48	37031044
4044	23	2025-08-26	155.16	153.29	156.19	151.72	52138562
4045	23	2025-08-25	152.31	150.29	152.34	148.78	36134684
4046	23	2025-08-22	149.2	154.34	155.05	148.86	43998605
4047	23	2025-08-21	152.59	150.61	152.61	149.28	37880461
4048	23	2025-08-20	150.97	151.98	153.32	145.59	60233226
4049	23	2025-08-19	159.25	153.23	159.32	152.81	64455006
4050	23	2025-08-18	162.61	162.05	164.49	160.41	35937528
4051	23	2025-08-15	165.66	163.31	165.73	162.15	51543136
4052	23	2025-08-14	165.44	166.47	170.6	165.2	66308821
4053	23	2025-08-13	165.52	169.67	171.72	165.03	108305129
4054	23	2025-08-12	159.45	160.95	161.15	155.02	52335746
4055	23	2025-08-11	156.44	158.5	164.51	155.83	70651033
4056	23	2025-08-08	160.12	158.94	162.36	156.88	68866692
4057	23	2025-08-07	153.49	158.61	161.69	153.36	95448310
4058	23	2025-08-06	151.85	150.07	152.89	145.18	133641835
4059	23	2025-08-05	163.36	160.37	163.75	158.06	88808520
4060	23	2025-08-04	160.64	162.64	163.63	159.68	52951044
4061	23	2025-08-01	156.55	157.96	160.45	153.47	75396130
4062	23	2025-07-31	167.45	162.21	167.9	159.16	71765285
4063	23	2025-07-30	161.56	165.15	165.94	159.9	64820291
4064	23	2025-07-29	161.19	163.24	167.73	160.71	108154838
4065	23	2025-07-28	155.55	159.77	160.72	155.18	68267835
4066	23	2025-07-25	150.42	153.15	153.8	149.37	53432260
4067	23	2025-07-24	146.39	149.15	150.82	145.69	48440112
4068	23	2025-07-23	143.81	145.96	146.69	143.52	41510896
4069	23	2025-07-22	143.7	142.34	143.73	137.39	49028017
4070	23	2025-07-21	145.01	144.44	147.51	144.37	39021130
4071	23	2025-07-18	146.82	144.43	147.96	143.35	48859835
4072	23	2025-07-17	148.87	147.58	149	145.99	50605117
4073	23	2025-07-16	142.89	147.27	147.53	140.62	59492760
4074	23	2025-07-15	141.45	143.16	145.99	141.28	93370081
4075	23	2025-07-14	133.48	134.54	135.77	130.55	44718554
4076	23	2025-07-11	131.19	134.71	135.61	130.27	50049179
4077	23	2025-07-10	131.56	132.63	134.15	130.5	61101465
4078	23	2025-07-09	127.59	127.34	129.4	126.58	37013130
4079	23	2025-07-08	126.33	126.79	128.02	125.04	36124612
4080	23	2025-07-07	125.64	124.02	126.44	122.82	37395010
4081	23	2025-07-03	127.98	126.88	128.34	126.33	28645993
4082	23	2025-07-02	124.69	127.44	128.6	124.4	39227986
4083	23	2025-07-01	127.67	125.22	129.01	124.31	55257237
4084	23	2025-06-30	132.48	130.55	134.32	129.73	42972468
4085	23	2025-06-27	132.65	132.31	135.93	130.3	61937853
4086	23	2025-06-26	134.29	132.19	134.32	130.56	58180081
4087	23	2025-06-25	129.66	131.93	132.65	128.3	74607219
4088	23	2025-06-24	122.76	127.36	127.69	122.3	78571997
4089	23	2025-06-23	120.03	119.21	122.59	116.67	65152874
4090	23	2025-06-20	118.68	117.98	122.18	117.35	79930980
4091	23	2025-06-18	117.77	116.65	118.87	115.71	49627112
4092	23	2025-06-17	117.7	116.93	120.24	116.45	86623910
4093	23	2025-06-16	109.14	116.28	117.89	108.36	100968478
4094	23	2025-06-13	106.76	106.87	108.45	105.86	39702742
4095	23	2025-06-12	110.97	109.02	112.47	108.59	44718365
4096	23	2025-06-11	114.48	111.45	114.51	110.29	32261863
4097	23	2025-06-10	111.42	113.38	114.16	111.14	41691908
4098	23	2025-06-09	109.65	111.99	112.58	109.52	55437652
4099	23	2025-06-06	108.27	106.89	108.91	106.61	27042083
4100	23	2025-06-05	109.43	106.43	109.71	105.53	34182902
4101	24	2025-10-27	36.4	37.02	39.2	36.01	71650761
4102	24	2025-10-24	37.95	35.73	39.98	35.6	87712801
4103	24	2025-10-23	37.15	36.43	38.6	34.65	164337658
4104	24	2025-10-22	35.44	33.18	36.54	31.41	114958420
4105	24	2025-10-21	39.12	36.8	40.11	35.93	82535104
4106	24	2025-10-20	43.68	39.85	43.96	38.81	87195171
4107	24	2025-10-17	41.09	42.67	44.39	40.16	112310532
4108	24	2025-10-16	50.32	44.13	50.75	43.12	138635869
4109	24	2025-10-15	53.25	51.83	53.33	46.46	136181843
4110	24	2025-10-14	50.46	51.63	53.5	46	148012813
4111	24	2025-10-13	42.74	50.52	50.81	42.66	181160717
4112	24	2025-10-10	44	40.41	45.2	40.38	138979696
4113	24	2025-10-09	39.87	43.34	44.36	39.46	155458447
4114	24	2025-10-08	40.72	39.77	44.37	38.14	166627500
4115	24	2025-10-07	40.16	40.4	42.49	37.45	174843706
4116	24	2025-10-06	35.7	38.37	39.66	35.3	110767863
4117	24	2025-10-03	34.03	36.86	37.38	32.89	155531229
4118	24	2025-10-02	28.22	32.57	32.95	28.02	146006167
4119	24	2025-10-01	26.77	27.46	28.88	26.36	84797288
4120	24	2025-09-30	26.88	27.41	28.17	26.65	72038339
4121	24	2025-09-29	29.28	27.28	29.93	26.17	95487599
4122	24	2025-09-26	29.58	28.69	31.26	28.28	100109868
4123	24	2025-09-25	27.43	29.53	30.2	26.48	129306929
4124	24	2025-09-24	30.07	29.11	31.65	27.33	141839191
4125	24	2025-09-23	27.04	28.94	29.81	26.53	103564701
4126	24	2025-09-22	24.22	26.1	27.22	23.46	87217886
4127	24	2025-09-19	22.8	26.24	26.76	22.75	127847874
4128	24	2025-09-18	21.05	22.76	24.11	20.61	113907973
4129	24	2025-09-17	18.46	20.23	20.36	18.23	77851253
4130	24	2025-09-16	17.85	18.4	18.68	17.41	43946764
4131	24	2025-09-15	17.55	17.67	18.14	17.17	43217047
4132	24	2025-09-12	15.44	17.56	18.52	15.33	112179003
4133	24	2025-09-11	14.86	15.35	15.64	14.76	38165237
4134	24	2025-09-10	15.07	14.89	15.29	14.81	32877272
4135	24	2025-09-09	14.03	15.18	15.35	13.88	45080746
4136	24	2025-09-08	13.99	13.94	14.25	13.78	24957121
4137	24	2025-09-05	14.16	13.89	14.4	13.31	33450087
4138	24	2025-09-04	14.01	13.91	14.42	13.7	29216773
4139	24	2025-09-03	14.35	13.84	14.55	13.74	27138035
4140	24	2025-09-02	14.57	14.28	14.75	13.58	64148937
4141	24	2025-08-29	15.27	14.93	15.45	14.83	42451133
4142	24	2025-08-28	14.46	15.25	15.89	14.43	75480521
4143	24	2025-08-27	14.07	14.16	14.8	13.86	43923430
4144	24	2025-08-26	13.25	14.08	14.12	13.22	39223660
4145	24	2025-08-25	13.63	13.31	13.71	12.99	23401607
4146	24	2025-08-22	13.05	13.63	13.77	12.71	29793356
4147	24	2025-08-21	13.47	13.13	13.66	13.04	22675582
4148	24	2025-08-20	13.71	13.58	13.83	12.85	26581631
4149	24	2025-08-19	15.15	13.95	15.55	13.75	37661158
4150	24	2025-08-18	15.24	15.3	15.68	14.82	26820356
4151	24	2025-08-15	16.37	15.32	16.4	14.87	48381497
4152	24	2025-08-14	15.41	16.54	16.65	14.81	63512132
4153	24	2025-08-13	14.92	15.86	16.7	14.41	92447788
4154	24	2025-08-12	14.4	14.9	15.06	14.24	36172183
4155	24	2025-08-11	14.19	14.7	14.88	14	28439055
4156	24	2025-08-08	14.55	14.2	14.87	13.97	20793267
4157	24	2025-08-07	14.39	14.41	14.77	14.03	27526384
4158	24	2025-08-06	15	14.71	15.03	14.44	24349409
4159	24	2025-08-05	14.48	15.15	15.51	14.34	45290391
4160	24	2025-08-04	13.32	14.5	14.61	13.16	50062628
4161	24	2025-08-01	12.92	12.99	13.22	12.52	31989458
4162	24	2025-07-31	13.51	13.34	14.67	13.31	50653536
4163	24	2025-07-30	13.48	13.04	13.74	12.9	24466249
4164	24	2025-07-29	14.22	13.31	14.78	13.21	31378241
4165	24	2025-07-28	14.59	14.32	15.01	13.99	33355409
4166	24	2025-07-25	14.66	14.2	14.66	14.05	21368386
4167	24	2025-07-24	14.86	14.67	15.06	14.6	34835444
4168	24	2025-07-23	14.32	14.85	15	14.12	32975135
4169	24	2025-07-22	14.81	14.2	14.85	13.57	40588221
4170	24	2025-07-21	15.78	14.79	15.99	14.75	44336589
4171	24	2025-07-18	15.37	15.79	16	14.68	56511318
4172	24	2025-07-17	14.81	15.77	15.8	14.47	83132951
4173	24	2025-07-16	12.7	15.24	15.49	12.68	193609369
4174	24	2025-07-15	11.95	11.7	11.98	11.48	22620274
4175	24	2025-07-14	11.32	11.75	11.87	11.19	26361146
4176	24	2025-07-11	11.91	11.21	12.03	11.11	30496908
4177	24	2025-07-10	12.41	11.99	12.59	11.99	25768147
4178	24	2025-07-09	12.54	12.43	12.78	11.8	31627653
4179	24	2025-07-08	12.73	12.31	13.1	12.19	37275362
4180	24	2025-07-07	12.16	12.65	12.74	11.43	50496073
4181	24	2025-07-03	11.88	12.37	12.39	11.83	35342499
4182	24	2025-07-02	10.59	12.03	12.05	10.52	65581836
4183	24	2025-07-01	10.7	10.42	10.81	10.33	28156599
4184	24	2025-06-30	10.29	10.91	11.12	10.25	48094816
4185	24	2025-06-27	10.41	10.18	10.5	9.94	52444709
4186	24	2025-06-26	10.34	10.22	10.6	10.18	27523000
4187	24	2025-06-25	10.85	10.2	11.07	10.15	29108707
4188	24	2025-06-24	10.4	10.58	10.69	10.27	30462986
4189	24	2025-06-23	9.94	9.93	10.12	9.48	33264892
4190	24	2025-06-20	10.59	10.18	10.65	10.13	27759452
4191	24	2025-06-18	10.69	10.44	10.83	10.25	30230036
4192	24	2025-06-17	11.05	10.56	11.24	10.47	33958812
4193	24	2025-06-16	10.71	11.19	11.3	10.58	47085399
4194	24	2025-06-13	10.72	10.49	10.97	10.41	45368097
4195	24	2025-06-12	11.6	11.13	12.31	11.13	93622234
4196	24	2025-06-11	11.21	11.52	12.48	10.91	178366978
4197	24	2025-06-10	10.61	10.34	11.15	10.19	61400166
4198	24	2025-06-09	10.88	10.41	10.88	10.21	43412714
4199	24	2025-06-06	10.32	10.38	10.81	10.1	38279580
4200	24	2025-06-05	10.87	10.02	10.87	9.85	35533792
4201	25	2025-10-27	174.79	176.17	176.64	173.36	153452704
4202	25	2025-10-24	169.13	171.36	172.47	168.82	131296677
4203	25	2025-10-23	165.99	167.59	168.39	165.41	111363718
4204	25	2025-10-22	166.65	165.86	168.76	162.62	162249552
4205	25	2025-10-21	168.16	166.67	168.16	165.42	124240168
4206	25	2025-10-20	168.48	168.03	170.38	167.19	128544711
4207	25	2025-10-17	165.77	168.56	169.37	165.37	173135217
4208	25	2025-10-16	167.65	167.27	168.62	165.39	179723309
4209	25	2025-10-15	170.02	165.44	170.08	163.11	214450482
4210	25	2025-10-14	169.99	165.63	170.02	165.32	205641380
4211	25	2025-10-13	172.93	173.25	174.9	171.08	153482755
4212	25	2025-10-10	178.02	168.51	179.97	167.49	268774359
4213	25	2025-10-09	176.85	177.16	179.68	175.78	182997234
4214	25	2025-10-08	171.64	173.98	174.43	171.62	130168861
4215	25	2025-10-07	171.33	170.24	173.94	169.28	140088008
4216	25	2025-10-06	170.66	170.7	172.25	168.66	157678104
4217	25	2025-10-03	174.05	172.61	175.13	170.55	137596896
4218	25	2025-10-02	174.43	173.78	175.77	173.02	136805821
4219	25	2025-10-01	170.42	172.26	173.09	169.19	173844901
4220	25	2025-09-30	167.51	171.65	172.36	166.96	236981032
4221	25	2025-09-29	165.99	167.3	169.28	165.89	193063455
4222	25	2025-09-26	163.92	163.93	165.39	160.94	148573732
4223	25	2025-09-25	160.52	163.47	165.84	159.28	191586733
4224	25	2025-09-24	165.39	162.81	165.4	161.37	143564116
4225	25	2025-09-23	167.41	164.16	167.83	162.11	192559552
4226	25	2025-09-22	161.28	168.92	169.79	160.73	269637001
4227	25	2025-09-19	161.71	162.54	163.83	161.17	237182143
4228	25	2025-09-18	160.06	162.14	162.93	159.12	191763313
4229	25	2025-09-17	158.83	156.67	159.34	154.94	211843817
4230	25	2025-09-16	162.84	160.89	163.3	160.43	140737775
4231	25	2025-09-15	161.62	163.53	164.54	160.55	147061559
4232	25	2025-09-12	163.55	163.59	164.31	162.33	124911026
4233	25	2025-09-11	165.31	163	165.86	162.36	151159274
4234	25	2025-09-10	162.51	163.14	164.95	161.43	226852020
4235	25	2025-09-09	155.56	157.1	157.3	153.4	157548392
4236	25	2025-09-08	154.15	154.85	157.28	153.96	163769133
4237	25	2025-09-05	154.59	153.66	155.51	150.94	224441435
4238	25	2025-09-04	156.92	157.93	158.11	155.86	141670144
4239	25	2025-09-03	157.38	156.97	158.62	155.37	161466040
4240	25	2025-09-02	156.4	157.12	158.59	153.84	231164853
4241	25	2025-08-29	163.86	160.25	163.9	159.29	243257873
4242	25	2025-08-28	166.35	165.76	169.71	162.3	281787824
4243	25	2025-08-27	167.42	167.07	167.89	164.77	235518949
4244	25	2025-08-26	165.65	167.23	167.8	164.51	168688186
4245	25	2025-08-25	164.08	165.43	167.36	162.44	163012789
4246	25	2025-08-22	158.8	163.75	164.3	157.5	172789427
4247	25	2025-08-21	160.86	160.98	162.75	159.91	140040850
4248	25	2025-08-20	161.15	161.37	161.92	155.3	215142725
4249	25	2025-08-19	167.84	161.59	167.9	161.45	185229219
4250	25	2025-08-18	166.15	167.45	168.3	166.14	132007959
4251	25	2025-08-15	167.33	166.01	167.35	163.8	156602161
4252	25	2025-08-14	165.37	167.46	168.38	165.1	129553959
4253	25	2025-08-13	168.01	167.06	169.25	165	179871724
4254	25	2025-08-12	168.32	168.51	169.72	165.1	145729202
4255	25	2025-08-11	167.49	167.5	169.13	165.83	138323191
4256	25	2025-08-08	167.03	168.08	168.64	165.97	123396679
4257	25	2025-08-07	167.04	166.31	169.17	164.49	151878365
4258	25	2025-08-06	162.22	165.07	165.51	162.15	137192265
4259	25	2025-08-05	165.25	164	165.84	161.83	156407621
4260	25	2025-08-04	161.15	165.6	165.78	160.56	148174609
4261	25	2025-08-01	160.16	159.82	162.42	157.22	204528985
4262	25	2025-07-31	168.27	163.64	168.64	161.86	221685446
4263	25	2025-07-30	162.39	164.93	165.5	161.96	174312208
4264	25	2025-07-29	163.72	161.47	165.03	161.02	154077512
4265	25	2025-07-28	160.1	162.61	162.84	160.05	140023521
4266	25	2025-07-25	159.72	159.62	160.74	159.12	122316792
4267	25	2025-07-24	158.64	159.84	159.92	157.6	128984628
4268	25	2025-07-23	155.97	157.12	157.56	154.53	154082197
4269	25	2025-07-22	157.63	153.67	157.68	151.41	193114327
4270	25	2025-07-21	158.93	157.67	159.51	157.32	123126136
4271	25	2025-07-18	159.75	158.62	160.31	157.56	146456416
4272	25	2025-07-17	158.26	159.16	160.23	157.16	160841119
4273	25	2025-07-16	157.38	157.66	158.01	155.39	158831509
4274	25	2025-07-15	157.49	157.04	158.61	155.66	230627350
4275	25	2025-07-14	152.14	150.94	152.25	149.06	136975754
4276	25	2025-07-11	150.62	151.73	154.46	150.39	193633263
4277	25	2025-07-10	151.17	150.97	151.34	148.68	167704075
4278	25	2025-07-09	148.32	149.85	151.27	148.27	183656443
4279	25	2025-07-08	146.58	147.2	147.4	145.72	138133025
4280	25	2025-07-07	145.54	145.58	146.57	144.75	140138975
4281	25	2025-07-03	145.7	146.59	148.1	145.15	143716055
4282	25	2025-07-02	140.74	144.67	144.99	140.73	171224111
4283	25	2025-07-01	143.79	141.04	144.62	139.37	213143621
4284	25	2025-06-30	145.73	145.35	145.97	143.48	194580316
4285	25	2025-06-27	143.56	145.13	146.01	142.83	263234539
4286	25	2025-06-26	143.5	142.62	144.18	141.68	198145746
4287	25	2025-06-25	137.33	141.97	142.09	137.32	269146471
4288	25	2025-06-24	133.92	136.07	136.12	133.86	187566121
4289	25	2025-06-23	131.1	132.64	133.2	130.67	154308941
4290	25	2025-06-20	133.81	132.34	134.5	131.24	242956157
4291	25	2025-06-18	132.48	133.84	134	131.67	161494121
4292	25	2025-06-17	132.93	132.59	133.6	132.28	139108000
4293	25	2025-06-16	131.88	133.11	134.48	131.74	183133666
4294	25	2025-06-13	131.08	130.61	132.09	129.59	180820565
4295	25	2025-06-12	130.61	133.4	133.4	130.5	162364991
4296	25	2025-06-11	133.04	131.4	133.39	130.52	167694044
4297	25	2025-06-10	131.27	132.44	132.75	130.2	155881897
4298	25	2025-06-09	131.73	131.22	133.4	130.58	185114494
4299	25	2025-06-06	131.11	130.38	131.81	130.19	153986153
4300	25	2025-06-05	130.8	128.79	132.48	127.72	232410759
4301	26	2025-10-27	173.85	174.05	177.4	172.52	47153057
4302	26	2025-10-24	168.25	169.86	171.28	168.22	34813464
4303	26	2025-10-23	161.41	166.04	167.04	161.01	35812304
4304	26	2025-10-22	167.38	161.45	167.63	155.87	58263102
4305	26	2025-10-21	167.5	166.99	167.8	164.36	27528145
4306	26	2025-10-20	165.13	167.06	168.44	163.24	31975847
4307	26	2025-10-17	163.53	163.9	167.06	160.03	43421494
4308	26	2025-10-16	167.24	163.87	170.03	162.33	42870891
4309	26	2025-10-15	167.12	165.25	169.6	161.94	37372129
4310	26	2025-10-14	161.92	165.36	167.75	157.15	49261447
4311	26	2025-10-13	164.39	163.03	164.88	159.57	41332442
4312	26	2025-10-10	170.36	161.4	172.13	159.65	55194034
4313	26	2025-10-09	168.89	170.63	172.61	165.55	45050252
4314	26	2025-10-08	168.18	168.88	169.52	166.7	36299659
4315	26	2025-10-07	165.89	167.6	171.29	165.07	58179256
4316	26	2025-10-06	164.85	165.17	168.31	163.6	52504240
4317	26	2025-10-03	171.49	159.22	171.89	157.11	105533447
4318	26	2025-10-02	171.76	172.09	173.14	168.31	39849210
4319	26	2025-10-01	166.81	170.15	171.38	165.14	45717299
4320	26	2025-09-30	164.66	167.83	168.15	163.96	43561729
4321	26	2025-09-29	165.27	164.55	166.96	162.99	38413753
4322	26	2025-09-26	164.73	163.36	165.71	160.92	44275794
4323	26	2025-09-25	161.74	164.79	169.57	160.35	72321194
4324	26	2025-09-24	169.2	165.2	170.06	162.95	45379666
4325	26	2025-09-23	167.91	167.95	170.89	162.85	62354834
4326	26	2025-09-22	166.41	164.98	167.67	164.03	45916684
4327	26	2025-09-19	162.9	167.8	169.67	162.57	109129929
4328	26	2025-09-18	156.65	162.81	164.5	155.84	70768631
4329	26	2025-09-17	155.5	154.86	156.11	148.37	69255497
4330	26	2025-09-16	157.36	156.64	157.61	155.44	34598658
4331	26	2025-09-15	156.03	157.51	158.06	154.02	45396116
4332	26	2025-09-12	152.12	157.72	157.81	150.89	54498535
4333	26	2025-09-11	153.86	151.21	154.06	150.16	42025501
4334	26	2025-09-10	152.72	153.4	155.48	150.36	62211418
4335	26	2025-09-09	144.67	149.37	149.73	143.86	61359531
4336	26	2025-09-08	142.52	143.61	145.64	142.45	47642952
4337	26	2025-09-05	145.19	140.86	146.25	136.2	81855896
4338	26	2025-09-04	142.48	143.65	144.48	140.91	53292341
4339	26	2025-09-03	145.36	142.51	148.26	140.49	65821178
4340	26	2025-09-02	139.1	144.52	145.72	138.26	65434969
4341	26	2025-08-29	144.42	144.17	145.75	140.76	45270502
4342	26	2025-08-28	145.02	145.47	145.57	140.35	57885244
4343	26	2025-08-27	149.33	144.18	149.41	143.5	76380553
4344	26	2025-08-26	142.96	148	149.16	142.2	86573715
4345	26	2025-08-25	143.61	144.6	145.9	137.42	86879821
4346	26	2025-08-22	142.89	146.04	150.14	139.63	102099177
4347	26	2025-08-21	144.6	143.69	145.33	141.51	94678639
4348	26	2025-08-20	140.12	143.53	143.94	130.95	220336359
4349	26	2025-08-19	157.65	145.13	158.52	144.35	137922722
4350	26	2025-08-18	161.25	160.11	163.67	157.68	62656597
4351	26	2025-08-15	165.35	163	165.6	159.51	60288736
4352	26	2025-08-14	167.82	166.54	170.5	164.86	53472933
4353	26	2025-08-13	173.88	169.62	174.3	168.9	53610031
4354	26	2025-08-12	169.92	172.01	174.8	167.53	54983765
4355	26	2025-08-11	171.55	168.07	172.21	167.37	56125630
4356	26	2025-08-08	169.96	172	172.95	169.66	62657935
4357	26	2025-08-07	166.53	167.62	169.72	163.92	77829184
4358	26	2025-08-06	157.48	165.18	166.13	157.33	82924849
4359	26	2025-08-05	158.07	159.41	162.22	155.68	130917543
4360	26	2025-08-04	145.85	147.81	148.49	145.3	82993558
4361	26	2025-08-01	142.65	141.93	145.53	138.97	61286993
4362	26	2025-07-31	147.19	145.68	148.02	144.19	45342610
4363	26	2025-07-30	144.78	145.92	146.63	144.04	40261681
4364	26	2025-07-29	146.02	143.74	147.33	142.52	42427214
4365	26	2025-07-28	147.09	145.25	147.46	140.8	63886935
4366	26	2025-07-25	143.18	146.1	147.56	143.13	57972341
4367	26	2025-07-24	141.66	142.47	143.18	140.37	38925748
4368	26	2025-07-23	137.76	142.26	142.6	136.42	48061985
4369	26	2025-07-22	138.78	137.14	139.65	133.46	49880762
4370	26	2025-07-21	141.57	139.65	143	139.25	45072814
4371	26	2025-07-18	142.47	141.24	142.53	139.75	45771634
4372	26	2025-07-17	139.44	141.67	143.23	138.75	60165516
4373	26	2025-07-16	137.36	138.84	139.39	135.86	57636985
4374	26	2025-07-15	137.02	136.69	138.57	135.57	59126190
4375	26	2025-07-14	131.3	137.22	137.61	130.84	81774443
4376	26	2025-07-11	130.74	130.73	133.01	130.15	52134812
4377	26	2025-07-10	131.85	131.1	133.55	128.37	64383873
4378	26	2025-07-09	128.48	131.68	131.72	126.4	68494760
4379	26	2025-07-08	127.67	128.53	128.67	124.93	59834823
4380	26	2025-07-07	123.63	127.99	128.15	121.73	71959709
4381	26	2025-07-03	123.61	123.61	124.77	121.91	41812483
4382	26	2025-07-02	120.95	121.55	122.91	119.77	59731969
4383	26	2025-07-01	124.45	120.23	125.41	118.23	91479688
4384	26	2025-06-30	126.77	125.41	127.77	124.02	97305595
4385	26	2025-06-27	133.28	120.28	133.37	120.1	202598647
4386	26	2025-06-26	133.26	132.71	136.36	131.48	69440544
4387	26	2025-06-25	132.93	131.47	135.86	130.21	61435267
4388	26	2025-06-24	129.7	131.77	132.17	126.78	58574192
4389	26	2025-06-23	127.79	128.73	130.78	125.08	70501099
4390	26	2025-06-20	129.43	126.32	130.86	125.8	87067039
4391	26	2025-06-18	127.92	128.76	129.13	126.49	58260225
4392	26	2025-06-17	130.17	127.14	130.35	125.19	70479099
4393	26	2025-06-16	128.83	130.1	133.27	128.63	80779773
4394	26	2025-06-13	123.11	126.41	128.79	122.68	93519043
4395	26	2025-06-12	125.49	124.37	126.13	123.86	56248175
4396	26	2025-06-11	123.21	125.48	128.8	122.35	97366015
4397	26	2025-06-10	120.54	122.19	123.34	119.06	69308929
4398	26	2025-06-09	116.91	121.5	121.65	114.82	74785580
4399	26	2025-06-06	113.83	117.5	117.88	112.17	87175144
4400	26	2025-06-05	118.93	110.32	122.22	109.42	132238651
4401	27	2025-10-27	263.64	258.89	264.04	257.43	13855836
4402	27	2025-10-24	263.05	260.66	264.21	259.67	13194896
4403	27	2025-10-23	251.12	257.66	260.45	250.59	16872158
4404	27	2025-10-22	252.83	250.85	255.02	247.71	16474016
4405	27	2025-10-21	255.86	253.14	257.88	250.48	18370806
4406	27	2025-10-20	265.83	255.01	266.1	253.29	32810748
4407	27	2025-10-17	279.45	268.01	279.94	264.5	37653000
4408	27	2025-10-16	281.15	287.96	296.74	278.82	32500863
4409	27	2025-10-15	280.51	279.33	286.13	275.01	13698938
4410	27	2025-10-14	279.28	275.08	280.07	268.62	17346186
4411	27	2025-10-13	274.8	283.37	285.84	273.92	21703725
4412	27	2025-10-10	276.26	269.52	283.1	268.65	28895338
4413	27	2025-10-09	268.23	273.2	276.89	264.28	26479833
4414	27	2025-10-08	262.59	265.54	268.21	260.91	18982122
4415	27	2025-10-07	269.76	261.5	269.76	249.32	31723384
4416	27	2025-10-06	268.99	268.26	272.95	267.54	14076795
4417	27	2025-10-03	266.43	263.25	271.07	261.28	13688407
4418	27	2025-10-02	268.46	265.68	271.37	263.17	16215460
4419	27	2025-10-01	256.5	265.89	266.79	255.65	23378324
4420	27	2025-09-30	260.99	258.74	261.28	253.83	23880810
4421	27	2025-09-29	261.83	260.14	263.1	257.24	25778508
4422	27	2025-09-26	269.56	260.78	270.48	260.36	25990691
4423	27	2025-09-25	271.65	268.02	274.85	265.47	39274883
4424	27	2025-09-24	286.91	283.78	287.47	276.03	33765279
4425	27	2025-09-23	298.08	288.72	299	285.25	35280199
4426	27	2025-09-22	284.86	301.9	303.14	282.37	44437549
4427	27	2025-09-19	275.08	283.97	286.22	273.53	40776201
4428	27	2025-09-18	278.79	272.89	279.51	268.64	24673116
4429	27	2025-09-17	283.07	277.3	283.97	271.43	27707949
4430	27	2025-09-16	288.94	282.12	294.37	278.09	51923268
4431	27	2025-09-15	281.93	277.97	282.47	273.51	40004004
4432	27	2025-09-12	281.33	268.81	283.33	268.41	51781914
4433	27	2025-09-11	303.91	283.23	304.52	280.23	69986027
4434	27	2025-09-10	293.65	302.06	318.06	287.12	131618085
4435	27	2025-09-09	220.74	222.19	224.01	215.8	41178697
4436	27	2025-09-08	220.7	219.4	223.03	216.49	18803046
4437	27	2025-09-05	213.95	214.18	215.85	207.81	15386096
4438	27	2025-09-04	204.24	205.16	205.68	202	10303069
4439	27	2025-09-03	207.83	205.57	207.83	204.01	8749468
4440	27	2025-09-02	204.24	207.28	207.41	201.29	10461903
4441	27	2025-08-29	218.6	208.04	219.16	205.26	16618641
4442	27	2025-08-28	216.7	221.09	222.59	216.31	8691548
4443	27	2025-08-27	216.2	216.95	217.61	214.07	5637590
4444	27	2025-08-26	216.2	215.47	217.95	214.09	11805197
4445	27	2025-08-25	218.36	216.58	219.91	216.45	6308625
4446	27	2025-08-22	215.34	217.46	219.42	212.94	9343637
4447	27	2025-08-21	214.4	214.51	217.05	213.84	7403128
4448	27	2025-08-20	213.61	216.26	217.01	209.99	11256417
4449	27	2025-08-19	229.31	215.85	229.31	213.65	16819250
4450	27	2025-08-18	226.5	229.14	229.23	224.13	6759921
4451	27	2025-08-15	227.17	228.42	230.58	223.49	11553988
4452	27	2025-08-14	225.35	225.36	229.01	223.16	10285555
4453	27	2025-08-13	236.6	224.65	237.06	223.22	14182078
4454	27	2025-08-12	232.37	233.55	237.24	230.99	10001712
4455	27	2025-08-11	228.53	232.47	234.31	225.92	9012112
4456	27	2025-08-08	230.03	230.05	230.82	228.03	8313278
4457	27	2025-08-07	237.09	229.44	237.14	226.8	11954223
4458	27	2025-08-06	236.29	235.92	236.29	231.58	9930222
4459	27	2025-08-05	234.98	235.22	237.81	231.26	11197287
4460	27	2025-08-04	226.23	232.33	232.68	226.23	8614784
4461	27	2025-08-01	228	224.87	228.54	222.64	12718218
4462	27	2025-07-31	235.3	233.47	240	233.05	15548726
4463	27	2025-07-30	228.75	230.55	230.97	225.95	8441378
4464	27	2025-07-29	228.8	229.98	232.82	226.86	8415324
4465	27	2025-07-28	226.32	227.89	227.96	223.95	6756775
4466	27	2025-07-25	222.95	225.51	225.83	222.12	7149571
4467	27	2025-07-24	223.02	223.4	224.55	221.32	8237851
4468	27	2025-07-23	220.75	222.55	223.95	219.57	7255797
4469	27	2025-07-22	222.62	219.06	222.91	216.58	11380866
4470	27	2025-07-21	225.69	224.06	227.06	223.78	7348362
4471	27	2025-07-18	228.62	225.81	229.71	225.4	9678072
4472	27	2025-07-17	223.87	228.85	231.47	222.65	17631328
4473	27	2025-07-16	216.66	222	222.02	214.53	12597452
4474	27	2025-07-15	213.81	216.16	216.75	210.86	10728795
4475	27	2025-07-14	211.09	210.94	212.19	207.11	11336967
4476	27	2025-07-11	212.86	212.12	215.28	211.48	10208178
4477	27	2025-07-10	220.74	216.2	220.85	214.82	11486345
4478	27	2025-07-09	216.67	216.95	217.59	213.44	10871629
4479	27	2025-07-08	218.16	215.74	222.12	214.53	20401777
4480	27	2025-07-07	216.3	213.68	216.43	211.14	16584266
4481	27	2025-07-03	214.56	218.33	218.95	212.7	18441376
4482	27	2025-07-02	200.27	211.58	213.35	199.38	22326900
4483	27	2025-07-01	201.76	201.44	205.32	199	16962196
4484	27	2025-06-30	208.38	201.14	209.96	200.91	31844231
4485	27	2025-06-27	196.59	193.42	197.48	193.16	14127502
4486	27	2025-06-26	195.04	195.79	197.27	193.53	10531112
4487	27	2025-06-25	197.74	193.86	199.58	193.41	11804604
4488	27	2025-06-24	193.19	198.05	199.06	191.87	19030617
4489	27	2025-06-23	189.06	190.48	190.69	186.34	13418393
4490	27	2025-06-20	196.28	188.76	196.7	188.27	20879095
4491	27	2025-06-18	194.2	194	197.54	192.8	15055390
4492	27	2025-06-17	193.81	191.53	198.61	190.88	17819162
4493	27	2025-06-16	196.14	194.21	197.96	193.18	22665299
4494	27	2025-06-13	185.45	198	199.27	185.1	53707361
4495	27	2025-06-12	174.76	183.87	186.29	173.77	54609995
4496	27	2025-06-11	163.35	162.27	165.19	162.1	18002910
4497	27	2025-06-10	163.49	163.28	163.62	160.34	11056716
4498	27	2025-06-09	160.87	162.98	164.42	159.89	9668911
4499	27	2025-06-06	160.08	160.1	160.81	158.85	6833674
4500	27	2025-06-05	155.48	157.45	158.48	155.25	7710284
4501	28	2025-10-27	209.45	208.81	210.13	207.5	38266995
4502	28	2025-10-24	204.21	206.27	207.37	204.15	38685053
4503	28	2025-10-23	201.48	203.4	203.6	200.73	31539999
4504	28	2025-10-22	201.76	200.51	202.4	199.2	44308538
4505	28	2025-10-21	200.96	204.27	205.45	200.55	50494565
4506	28	2025-10-20	196.77	199.16	199.35	196.5	38882819
4507	28	2025-10-17	197.4	196	197.62	194.15	45986944
4508	28	2025-10-16	198.42	197.31	201.1	195.79	42414591
4509	28	2025-10-15	199.29	198.32	200.29	195.65	45909469
4510	28	2025-10-14	198.31	199.08	201.77	195.59	45665580
4511	28	2025-10-13	200.28	202.46	203.03	199.68	37809650
4512	28	2025-10-10	208.11	199.06	209.99	198.72	72367511
4513	28	2025-10-09	207	209.52	209.95	204.01	46412122
4514	28	2025-10-08	205.09	207.2	208.59	203.49	46685985
4515	28	2025-10-07	203.21	204.04	205.06	202.56	31194678
4516	28	2025-10-06	203.32	203.23	203.99	198.75	43690876
4517	28	2025-10-03	205.56	201.95	206.26	201.79	43639033
4518	28	2025-10-02	203.33	204.62	204.99	201.43	41258586
4519	28	2025-10-01	199.97	202.98	204.38	199.28	43933834
4520	28	2025-09-30	204.27	202	204.46	200.46	48396369
4521	28	2025-09-29	202.47	204.4	204.79	201.76	44259177
4522	28	2025-09-26	201.55	202.2	203.37	200.58	41650098
4523	28	2025-09-25	202.46	200.7	203.02	199.15	52226328
4524	28	2025-09-24	206.22	202.59	206.6	201.89	49509033
4525	28	2025-09-23	209.6	203.05	209.63	202.46	70956193
4526	28	2025-09-22	212.12	209.42	212.12	209.31	45914506
4527	28	2025-09-19	213.78	212.96	215.43	211.32	97943172
4528	28	2025-09-18	213.9	212.73	214.8	210.49	37931738
4529	28	2025-09-17	215.07	213.09	215.56	210.41	42815230
4530	28	2025-09-16	214.3	215.33	217.03	213.65	38203912
4531	28	2025-09-15	212.18	212.92	215.03	211.89	33243328
4532	28	2025-09-12	211.92	209.9	212.33	208.19	38496218
4533	28	2025-09-11	212.97	211.55	213.01	210.99	37485598
4534	28	2025-09-10	218.51	211.9	218.67	210.77	60907714
4535	28	2025-09-09	217.45	219.18	219.74	216.27	27033778
4536	28	2025-09-08	216.14	216.97	218.59	215.05	33947104
4537	28	2025-09-05	216.37	213.74	217.12	213.38	36721802
4538	28	2025-09-04	212.69	216.83	216.91	212.32	59391779
4539	28	2025-09-03	207.19	207.91	209	206.41	26355706
4540	28	2025-09-02	205.64	207.31	208.08	204.08	38843883
4541	28	2025-08-29	212.81	210.68	213.27	209.91	26199170
4542	28	2025-08-28	210.68	213.07	214.09	209.78	33679585
4543	28	2025-08-27	210.28	210.79	211.48	209.59	21254479
4544	28	2025-08-26	208.94	210.41	210.68	207.94	26105373
4545	28	2025-08-25	209.16	209.7	211.23	209.13	22633695
4546	28	2025-08-22	204.97	210.53	210.81	203.15	37315341
4547	28	2025-08-21	204.84	204.19	204.96	202.86	32140459
4548	28	2025-08-20	208.95	205.91	209.09	203.24	36604319
4549	28	2025-08-19	211.68	209.77	212.09	208.95	29891012
4550	28	2025-08-18	211.81	212.97	213.36	210.06	25248890
4551	28	2025-08-15	213.97	212.55	215.35	211.42	39649244
4552	28	2025-08-14	209.21	212.5	214.46	208.86	61545824
4553	28	2025-08-13	204.24	206.6	206.93	204.24	36508335
4554	28	2025-08-12	204.45	203.75	205.62	201.53	37254707
4555	28	2025-08-11	204.04	203.6	205.21	202.77	31646222
4556	28	2025-08-08	205.29	204.87	205.9	204.13	32970477
4557	28	2025-08-07	203.32	205.28	208.12	203.15	40603513
4558	28	2025-08-06	197.52	204.53	204.84	196.64	54823045
4559	28	2025-08-05	196.01	196.65	199	195.84	51505121
4560	28	2025-08-04	200.01	194.72	200.04	194.51	77890146
4561	28	2025-08-01	199.83	197.57	202.8	195.78	122258801
4562	28	2025-07-31	216.91	215.38	217.61	212.89	104357263
4563	28	2025-07-30	213.11	211.77	213.26	210.95	32993273
4564	28	2025-07-29	215.42	212.53	215.94	211.89	33716220
4565	28	2025-07-28	214.68	214.17	215.55	213.67	26300138
4566	28	2025-07-25	213.64	212.92	213.88	212.69	28712095
4567	28	2025-07-24	210.84	213.65	217.12	210.35	42902266
4568	28	2025-07-23	210.19	210.03	210.49	208.92	28294852
4569	28	2025-07-22	211.31	209.27	211.6	208.24	37483702
4570	28	2025-07-21	207.77	210.96	211.31	207.6	40297556
4571	28	2025-07-18	207.13	208.04	208.29	205.14	37833807
4572	28	2025-07-17	205.45	205.97	206.54	204.71	31855831
4573	28	2025-07-16	207.81	205.33	208.01	204.41	39535926
4574	28	2025-07-15	208.1	208.24	209.09	207.42	34907294
4575	28	2025-07-14	207.06	207.63	208.53	206.3	35702597
4576	28	2025-07-11	205.69	207.02	208.55	204.58	50518307
4577	28	2025-07-10	203.83	204.48	204.97	202.12	30370591
4578	28	2025-07-09	203.38	204.74	206.35	202.83	38155121
4579	28	2025-07-08	206	201.81	206.08	200.96	45691987
4580	28	2025-07-07	205.16	205.59	206.35	204.58	36604139
4581	28	2025-07-03	204.07	205.54	206.09	203.65	29632353
4582	28	2025-07-02	202.15	202.33	203.87	201.54	30894178
4583	28	2025-07-01	201.94	202.82	204.12	200.5	39256830
4584	28	2025-06-30	205.64	201.84	205.91	201.59	58887780
4585	28	2025-06-27	202.33	205.44	205.44	199.4	119217138
4586	28	2025-06-26	196.07	199.75	200.59	195.05	50480814
4587	28	2025-06-25	197.45	195.03	198.75	194.22	31755698
4588	28	2025-06-24	195.16	195.75	197.19	194.16	38378757
4589	28	2025-06-23	193.01	191.79	193.56	190.73	37311725
4590	28	2025-06-20	197.51	192.91	197.7	191.61	75350733
4591	28	2025-06-18	197.88	195.52	200.52	195.35	44360509
4592	28	2025-06-17	197.98	197.63	200.02	197.4	32086262
4593	28	2025-06-16	195.33	198.81	199.7	194.67	33284158
4594	28	2025-06-13	193.16	195.13	196.93	192.85	29337763
4595	28	2025-06-12	194.84	196.18	196.49	194.42	27639991
4596	28	2025-06-11	200.02	196.14	200.93	195.86	39325981
4597	28	2025-06-10	199.44	200.2	200.27	197.02	31303317
4598	28	2025-06-09	197.57	199.62	200.42	195.85	38102502
4599	28	2025-06-06	195.41	196.48	196.76	193.66	39832500
4600	28	2025-06-05	192.79	191.28	195.79	190.96	51979243
4601	19	2025-10-28	32.24	32.24	32.24	32.24	0
4602	36	2025-10-28	267.1	267.1	267.1	267.1	0
4603	32	2025-10-28	78.47	78.47	78.47	78.47	0
4604	35	2025-10-28	288.04	288.04	288.04	288.04	0
4605	27	2025-10-28	258.89	258.89	258.89	258.89	0
4606	26	2025-10-28	174.05	174.05	174.05	174.05	0
4607	34	2025-10-28	389.72	389.72	389.72	389.72	0
4608	31	2025-10-28	975.18	975.18	975.18	975.18	0
4609	30	2025-10-28	333.09	333.09	333.09	333.09	0
4610	23	2025-10-28	238.9	238.9	238.9	238.9	0
4611	29	2025-10-28	247.73	247.73	247.73	247.73	0
4612	28	2025-10-28	208.81	208.81	208.81	208.81	0
4613	33	2025-10-28	489	489	489	489	0
4614	25	2025-10-28	176.17	176.17	176.17	176.17	0
4615	21	2025-10-28	690.75	690.75	690.75	690.75	0
4616	24	2025-10-28	37.02	37.02	37.02	37.02	0
4617	22	2025-10-28	14.46	14.46	14.46	14.46	0
4618	20	2025-10-28	57.78	57.78	57.78	57.78	0
\.


--
-- Data for Name: stocks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stocks (id, symbol, name, sector, added_at, logo_filename) FROM stdin;
19	QBTS	D-Wave Quantum	Unknown	2025-10-28 17:33:39.788992+00	\N
20	IONQ	IonQ	Unknown	2025-10-28 17:43:44.473258+00	\N
21	META	Meta Platforms	Unknown	2025-10-28 17:50:55.659957+00	\N
22	QUBT	Quantum Computing	Unknown	2025-10-28 17:53:10.994151+00	\N
23	AMD	Advanced Micro Devices	Unknown	2025-10-28 17:53:11.514591+00	\N
24	RGTI	Rigetti Computing	Unknown	2025-10-28 17:53:12.046976+00	\N
25	NVDA	Nvidia	Unknown	2025-10-28 17:53:12.835415+00	\N
26	PLTR	Palantir Technologies	Unknown	2025-10-28 17:53:13.369871+00	\N
27	ORCL	Oracle	Unknown	2025-10-28 17:53:13.892986+00	\N
28	AMZN	Amazon	Unknown	2025-10-28 17:53:14.415252+00	\N
29	GOOGL	Alphabet (Class A)	Unknown	2025-10-28 17:53:14.944989+00	\N
30	AVGO	Broadcom	Unknown	2025-10-28 17:53:15.191416+00	\N
31	ASML	ASML	Unknown	2025-10-28 17:53:17.236329+00	\N
32	FTNT	Fortinet	Unknown	2025-10-28 17:53:18.82459+00	\N
33	MSFT	Microsoft	Unknown	2025-10-28 17:53:20.466676+00	\N
34	FN	Fabrinet	Unknown	2025-10-28 17:53:22.135988+00	\N
35	IBM	International Business Machines (IBM)	Unknown	2025-10-28 17:53:23.811089+00	\N
36	FDS	FactSet Research Systems	Unknown	2025-10-28 17:53:25.392616+00	\N
\.


--
-- Name: article_stocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.article_stocks_id_seq', 26973, true);


--
-- Name: news_articles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.news_articles_id_seq', 2165, true);


--
-- Name: portfolios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.portfolios_id_seq', 5, true);


--
-- Name: positions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.positions_id_seq', 108, true);


--
-- Name: stock_prices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stock_prices_id_seq', 4618, true);


--
-- Name: stocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stocks_id_seq', 36, true);


--
-- Name: article_stocks article_stocks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.article_stocks
    ADD CONSTRAINT article_stocks_pkey PRIMARY KEY (id);


--
-- Name: news_articles news_articles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.news_articles
    ADD CONSTRAINT news_articles_pkey PRIMARY KEY (id);


--
-- Name: news_articles news_articles_url_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.news_articles
    ADD CONSTRAINT news_articles_url_key UNIQUE (url);


--
-- Name: portfolios portfolios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.portfolios
    ADD CONSTRAINT portfolios_pkey PRIMARY KEY (id);


--
-- Name: positions positions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT positions_pkey PRIMARY KEY (id);


--
-- Name: stock_prices stock_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_prices
    ADD CONSTRAINT stock_prices_pkey PRIMARY KEY (id);


--
-- Name: stocks stocks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stocks
    ADD CONSTRAINT stocks_pkey PRIMARY KEY (id);


--
-- Name: article_stocks uix_article_stock; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.article_stocks
    ADD CONSTRAINT uix_article_stock UNIQUE (article_id, stock_id);


--
-- Name: stock_prices uix_stock_date; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_prices
    ADD CONSTRAINT uix_stock_date UNIQUE (stock_id, date);


--
-- Name: positions unique_portfolio_stock; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT unique_portfolio_stock UNIQUE (portfolio_id, stock_id);


--
-- Name: ix_article_stocks_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_article_stocks_id ON public.article_stocks USING btree (id);


--
-- Name: ix_news_articles_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_news_articles_id ON public.news_articles USING btree (id);


--
-- Name: ix_news_articles_published_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_news_articles_published_at ON public.news_articles USING btree (published_at);


--
-- Name: ix_portfolios_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_portfolios_id ON public.portfolios USING btree (id);


--
-- Name: ix_positions_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_positions_id ON public.positions USING btree (id);


--
-- Name: ix_stock_prices_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_stock_prices_date ON public.stock_prices USING btree (date);


--
-- Name: ix_stock_prices_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_stock_prices_id ON public.stock_prices USING btree (id);


--
-- Name: ix_stocks_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_stocks_id ON public.stocks USING btree (id);


--
-- Name: ix_stocks_symbol; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_stocks_symbol ON public.stocks USING btree (symbol);


--
-- Name: article_stocks article_stocks_article_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.article_stocks
    ADD CONSTRAINT article_stocks_article_id_fkey FOREIGN KEY (article_id) REFERENCES public.news_articles(id) ON DELETE CASCADE;


--
-- Name: article_stocks article_stocks_stock_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.article_stocks
    ADD CONSTRAINT article_stocks_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES public.stocks(id) ON DELETE CASCADE;


--
-- Name: positions positions_portfolio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT positions_portfolio_id_fkey FOREIGN KEY (portfolio_id) REFERENCES public.portfolios(id) ON DELETE CASCADE;


--
-- Name: positions positions_stock_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT positions_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES public.stocks(id) ON DELETE CASCADE;


--
-- Name: stock_prices stock_prices_stock_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_prices
    ADD CONSTRAINT stock_prices_stock_id_fkey FOREIGN KEY (stock_id) REFERENCES public.stocks(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict lhtXidmiREBekiPSXezwg8rUVHLHrWCqeMw2ASaqZ1NcMN73MzzP1XIXBXbhN4j

