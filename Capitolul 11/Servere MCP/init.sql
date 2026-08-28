-- ---------------------------------------------------------------------------
-- Online market: 3 tables + mock data.
-- Ruleaza automat la primul start (volum gol). Dupa modificari: docker compose down -v
-- ---------------------------------------------------------------------------

CREATE TABLE customers (
    customer_id   SERIAL PRIMARY KEY,
    full_name     TEXT        NOT NULL,
    email         TEXT        NOT NULL UNIQUE,
    country       TEXT        NOT NULL,
    city          TEXT        NOT NULL,
    loyalty_tier  TEXT        NOT NULL DEFAULT 'bronze'
                              CHECK (loyalty_tier IN ('bronze', 'silver', 'gold', 'platinum')),
    signup_date   DATE        NOT NULL DEFAULT CURRENT_DATE,
    is_active     BOOLEAN     NOT NULL DEFAULT TRUE
);

COMMENT ON TABLE customers IS 'Registered buyers of the online market.';

CREATE TABLE products (
    product_id      SERIAL PRIMARY KEY,
    sku             TEXT          NOT NULL UNIQUE,
    name            TEXT          NOT NULL,
    category        TEXT          NOT NULL,
    price           NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity  INTEGER       NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    rating          NUMERIC(2,1)  CHECK (rating BETWEEN 0 AND 5),
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT now()
);

COMMENT ON TABLE products IS 'Catalog of items offered in the market.';

CREATE TABLE orders (
    order_id        SERIAL PRIMARY KEY,
    customer_id     INTEGER       NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    product_id      INTEGER       NOT NULL REFERENCES products(product_id)  ON DELETE RESTRICT,
    quantity        INTEGER       NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    total_amount    NUMERIC(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    status          TEXT          NOT NULL
                                  CHECK (status IN ('pending', 'shipped', 'delivered', 'cancelled', 'returned')),
    payment_method  TEXT          NOT NULL
                                  CHECK (payment_method IN ('card', 'paypal', 'bank_transfer', 'crypto')),
    ordered_at      TIMESTAMPTZ   NOT NULL DEFAULT now(),
    shipped_at      TIMESTAMPTZ
);

COMMENT ON TABLE orders IS 'One line per purchased product. total_amount is generated.';

CREATE INDEX idx_orders_customer   ON orders (customer_id);
CREATE INDEX idx_orders_product    ON orders (product_id);
CREATE INDEX idx_orders_ordered_at ON orders (ordered_at DESC);
CREATE INDEX idx_orders_status     ON orders (status);
CREATE INDEX idx_products_category ON products (category);
-- --- mock data (setseed => aceleasi numere la fiecare rulare) ---------------
SELECT setseed(0.42);

INSERT INTO customers (full_name, email, country, city, loyalty_tier, signup_date, is_active) VALUES
    ('Lena Hoffmann',     'lena.hoffmann@example.com',   'Germany',       'Berlin',      'gold',     '2023-01-14', TRUE),
    ('Marco Bianchi',     'marco.bianchi@example.com',   'Italy',         'Milan',       'silver',   '2023-02-03', TRUE),
    ('Sophie Dubois',     'sophie.dubois@example.com',   'France',        'Lyon',        'bronze',   '2023-02-27', TRUE),
    ('James Carter',      'james.carter@example.com',    'United States', 'Austin',      'platinum', '2022-11-08', TRUE),
    ('Aisha Khan',        'aisha.khan@example.com',      'United Kingdom','Manchester',  'gold',     '2023-03-19', TRUE),
    ('Tomas Novak',       'tomas.novak@example.com',     'Czechia',       'Prague',      'bronze',   '2023-04-02', FALSE),
    ('Yuki Tanaka',       'yuki.tanaka@example.com',     'Japan',         'Osaka',       'silver',   '2023-04-21', TRUE),
    ('Elena Petrova',     'elena.petrova@example.com',   'Bulgaria',      'Sofia',       'bronze',   '2023-05-11', TRUE),
    ('Diego Martinez',    'diego.martinez@example.com',  'Spain',         'Valencia',    'gold',     '2023-05-30', TRUE),
    ('Nora Andersen',     'nora.andersen@example.com',   'Denmark',       'Aarhus',      'silver',   '2023-06-15', TRUE),
    ('Peter Schmidt',     'peter.schmidt@example.com',   'Germany',       'Hamburg',     'bronze',   '2023-07-01', TRUE),
    ('Grace Okafor',      'grace.okafor@example.com',    'Nigeria',       'Lagos',       'gold',     '2023-07-23', TRUE),
    ('Liam O''Sullivan',  'liam.osullivan@example.com',  'Ireland',       'Cork',        'bronze',   '2023-08-09', FALSE),
    ('Maria Silva',       'maria.silva@example.com',     'Portugal',      'Porto',       'silver',   '2023-08-28', TRUE),
    ('Chen Wei',          'chen.wei@example.com',        'Singapore',     'Singapore',   'platinum', '2023-09-12', TRUE),
    ('Olivia Brown',      'olivia.brown@example.com',    'Australia',     'Melbourne',   'bronze',   '2023-10-04', TRUE),
    ('Ahmet Yilmaz',      'ahmet.yilmaz@example.com',    'Turkey',        'Izmir',       'silver',   '2023-10-25', TRUE),
    ('Isabella Rossi',    'isabella.rossi@example.com',  'Italy',         'Bologna',     'gold',     '2023-11-17', TRUE),
    ('Lucas Meyer',       'lucas.meyer@example.com',     'Switzerland',   'Zurich',      'platinum', '2023-12-05', TRUE),
    ('Fatima Zahra',      'fatima.zahra@example.com',    'Morocco',       'Casablanca',  'bronze',   '2024-01-09', TRUE),
    ('Henrik Larsson',    'henrik.larsson@example.com',  'Sweden',        'Gothenburg',  'silver',   '2024-02-14', TRUE),
    ('Priya Nair',        'priya.nair@example.com',      'India',         'Bengaluru',   'gold',     '2024-03-02', TRUE),
    ('Daniel Kim',        'daniel.kim@example.com',      'South Korea',   'Busan',       'bronze',   '2024-03-27', FALSE),
    ('Clara Nowak',       'clara.nowak@example.com',     'Poland',        'Krakow',      'silver',   '2024-04-18', TRUE);

INSERT INTO products (sku, name, category, price, stock_quantity, rating) VALUES
    ('ELEC-1001', 'Noise Cancelling Headphones',   'Electronics',  199.99, 120,  4.6),
    ('ELEC-1002', 'Wireless Mouse Pro',            'Electronics',   39.50, 480,  4.2),
    ('ELEC-1003', 'Mechanical Keyboard 87-key',    'Electronics',  129.00, 210,  4.7),
    ('ELEC-1004', '27" 4K Monitor',                'Electronics',  349.00,  64,  4.4),
    ('ELEC-1005', 'USB-C Docking Station',         'Electronics',   89.90, 150,  3.9),
    ('ELEC-1006', 'Portable SSD 1TB',              'Electronics',  109.99, 300,  4.8),
    ('HOME-2001', 'Espresso Machine Compact',      'Home',         249.00,  45,  4.3),
    ('HOME-2002', 'Ceramic Cookware Set',          'Home',         159.95,  70,  4.1),
    ('HOME-2003', 'Robot Vacuum Cleaner',          'Home',         329.00,  38,  4.0),
    ('HOME-2004', 'LED Desk Lamp',                 'Home',          34.99, 520,  4.5),
    ('HOME-2005', 'Air Purifier Mini',             'Home',         119.00,  95,  3.8),
    ('FASH-3001', 'Merino Wool Sweater',           'Fashion',       89.00, 160,  4.4),
    ('FASH-3002', 'Running Sneakers Trail',        'Fashion',      129.90, 220,  4.6),
    ('FASH-3003', 'Leather Wallet Slim',           'Fashion',       49.00, 340,  4.2),
    ('FASH-3004', 'Rain Jacket Lightweight',       'Fashion',      109.50,  85,  4.0),
    ('FASH-3005', 'Cotton T-Shirt 3-Pack',         'Fashion',       29.99, 700,  3.9),
    ('BOOK-4001', 'Designing Data-Intensive Apps', 'Books',         54.00, 130,  4.9),
    ('BOOK-4002', 'The Pragmatic Programmer',      'Books',         42.50, 180,  4.8),
    ('BOOK-4003', 'Cooking for Geeks',             'Books',         31.00,  90,  4.1),
    ('BOOK-4004', 'Atlas of Remote Islands',       'Books',         26.90,  60,  4.5),
    ('SPRT-5001', 'Yoga Mat Pro',                  'Sports',        44.90, 240,  4.3),
    ('SPRT-5002', 'Adjustable Dumbbell 20kg',      'Sports',       179.00,  52,  4.6),
    ('SPRT-5003', 'Cycling Helmet Aero',           'Sports',        99.00, 110,  4.2),
    ('SPRT-5004', 'Insulated Water Bottle',        'Sports',        24.50, 640,  4.7),
    ('TOYS-6001', 'Wooden Building Blocks',        'Toys',          39.00, 175,  4.5),
    ('TOYS-6002', 'RC Off-Road Car',               'Toys',          79.90,  88,  4.0),
    ('TOYS-6003', 'Puzzle 1000 Pieces',            'Toys',          19.99, 410,  4.4),
    ('GRDN-7001', 'Herb Garden Starter Kit',       'Garden',        27.50, 200,  4.1),
    ('GRDN-7002', 'Cordless Hedge Trimmer',        'Garden',       149.00,  40,  3.7),
    ('GRDN-7003', 'Rattan Garden Chair',           'Garden',       119.90,  33,  4.2);

-- 500 pseudo-random orders spread over the last 180 days.
-- Customers/products are picked by rank: md5() gives a stable pseudo-random
-- order and power() adds a long tail, so a few of them sell much more.
WITH cust AS (
    SELECT customer_id, row_number() OVER (ORDER BY md5(customer_id::text)) AS rn
    FROM customers
),
prod AS (
    SELECT product_id, price, row_number() OVER (ORDER BY md5(product_id::text)) AS rn
    FROM products
),
raw AS (
    SELECT
        1 + floor(power(random(), 1.7) * (SELECT count(*) FROM cust))::int AS cust_rn,
        1 + floor(power(random(), 1.5) * (SELECT count(*) FROM prod))::int AS prod_rn,
        (1 + floor(power(random(), 2) * 4))::int    AS quantity,
        random()                                    AS r_status,
        random()                                    AS r_discount,
        now() - (random() * 180) * INTERVAL '1 day' AS ordered_at,
        random()                                    AS r_ship_delay,
        random()                                    AS r_payment
    FROM generate_series(1, 500) AS g
),
typed AS (
    SELECT
        cust.customer_id,
        prod.product_id,
        quantity,
        ROUND(prod.price * (CASE WHEN r_discount < 0.25 THEN 0.90 ELSE 1.00 END), 2) AS unit_price,
        CASE
            WHEN r_status < 0.58 THEN 'delivered'
            WHEN r_status < 0.74 THEN 'shipped'
            WHEN r_status < 0.86 THEN 'pending'
            WHEN r_status < 0.94 THEN 'cancelled'
            ELSE 'returned'
        END AS status,
        CASE
            WHEN r_payment < 0.55 THEN 'card'
            WHEN r_payment < 0.80 THEN 'paypal'
            WHEN r_payment < 0.95 THEN 'bank_transfer'
            ELSE 'crypto'
        END AS payment_method,
        ordered_at,
        r_ship_delay
    FROM raw
    JOIN cust ON cust.rn = raw.cust_rn
    JOIN prod ON prod.rn = raw.prod_rn
)
INSERT INTO orders (customer_id, product_id, quantity, unit_price, status, payment_method, ordered_at, shipped_at)
SELECT
    customer_id,
    product_id,
    quantity,
    unit_price,
    status,
    payment_method,
    ordered_at,
    CASE
        WHEN status IN ('delivered', 'shipped', 'returned')
        THEN ordered_at + (1 + r_ship_delay * 4) * INTERVAL '1 day'
        ELSE NULL
    END
FROM typed;

ANALYZE;

-- --- rol read-only pentru serverul MCP -------------------------------------
-- Serverul expune si run_dml_query / run_ddl_query / run_dcl_query, deci
-- limitarea reala o face baza de date, nu serverul.
DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'mcp_ro') THEN
        CREATE ROLE mcp_ro LOGIN PASSWORD 'ro';
    END IF;
END $$;
GRANT USAGE ON SCHEMA public TO mcp_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO mcp_ro;
