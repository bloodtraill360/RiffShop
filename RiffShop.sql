CREATE TABLE roles (
    role_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    password_hash TEXT NOT NULL,
    role_id INT NOT NULL REFERENCES roles(role_id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE product (
    product_id SERIAL PRIMARY KEY,
    created_by INT NOT NULL REFERENCES users(user_id),
    name VARCHAR(255) NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    stock_quantity INT NOT NULL,
    color VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id),
    manager_id INT REFERENCES users(user_id), -- Может быть NULL, если заказ еще не обработан
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id),
    method VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE delivery (
    delivery_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id),
    tracking_number VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_products (
    order_id INT NOT NULL REFERENCES orders(order_id),
    product_id INT NOT NULL REFERENCES product(product_id),
    quantity INT NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL,
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE product_media (
    media_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES product(product_id),
    media_type VARCHAR(20) NOT NULL,
    url VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE review (
    review_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES users(user_id),
    product_id INT NOT NULL REFERENCES product(product_id),
    moderated_by INT REFERENCES users(user_id),
    rating INT NOT NULL,
    comment TEXT,
    is_approved BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO roles (name)
SELECT 'Role_' || i || '_' || substr(md5(random()::text), 1, 5)
FROM generate_series(1, 300) AS i;

INSERT INTO users (full_name, email, phone, password_hash, role_id)
SELECT 
    'User_' || i || ' ' || substr(md5(random()::text), 1, 8),
    'user_' || i || '@example.com',
    '+79' || floor(random() * 900000000 + 100000000)::text,
    md5(random()::text),
    floor(random() * 300 + 1)::int
FROM generate_series(1, 300) AS i;

INSERT INTO product (created_by, name, price, stock_quantity, color)
SELECT 
    floor(random() * 300 + 1)::int,
    'Product_' || i || '_' || substr(md5(random()::text), 1, 5),
    round((random() * 9900 + 100)::numeric, 2),
    floor(random() * 500)::int,
    (ARRAY['Red', 'Blue', 'Green', 'Black', 'White', 'Yellow'])[floor(random() * 6 + 1)]
FROM generate_series(1, 300) AS i;


INSERT INTO orders (user_id, manager_id, created_at, updated_at)
SELECT 
    floor(random() * 300 + 1)::int,
    CASE WHEN random() > 0.3 THEN floor(random() * 300 + 1)::int ELSE NULL END,
    NOW() - (random() * 365 || ' days')::interval, 
    NOW() - (random() * 30 || ' days')::interval   
FROM generate_series(1, 300) AS i;

INSERT INTO payment (order_id, method, status, amount)
SELECT 
    i,
    (ARRAY['Credit Card', 'PayPal', 'Cash', 'Crypto'])[floor(random() * 4 + 1)],
    (ARRAY['Pending', 'Completed', 'Failed', 'Refunded'])[floor(random() * 4 + 1)],
    round((random() * 5000 + 100)::numeric, 2)
FROM generate_series(1, 300) AS i;

INSERT INTO delivery (order_id, tracking_number, status)
SELECT 
    i,
    'TRK' || upper(substr(md5(random()::text), 1, 10)),
    (ARRAY['Processing', 'Shipped', 'In Transit', 'Delivered', 'Returned'])[floor(random() * 5 + 1)]
FROM generate_series(1, 300) AS i;

INSERT INTO order_products (order_id, product_id, quantity, unit_price)
SELECT DISTINCT
    floor(random() * 300 + 1)::int,
    floor(random() * 300 + 1)::int,
    floor(random() * 5 + 1)::int,
    round((random() * 5000 + 100)::numeric, 2)
FROM generate_series(1, 400)
LIMIT 300;

INSERT INTO product_media (product_id, media_type, url)
SELECT 
    floor(random() * 300 + 1)::int,
    (ARRAY['image', 'video'])[floor(random() * 2 + 1)],
    'https://cdn.example.com/media/' || md5(random()::text) || CASE WHEN random() > 0.5 THEN '.jpg' ELSE '.mp4' END
FROM generate_series(1, 300) AS i;

INSERT INTO review (customer_id, product_id, moderated_by, rating, comment, is_approved)
SELECT 
    floor(random() * 300 + 1)::int,
    floor(random() * 300 + 1)::int,
    CASE WHEN random() > 0.5 THEN floor(random() * 300 + 1)::int ELSE NULL END,
    floor(random() * 5 + 1)::int,
    'This is a random review text generated for testing purposes. ' || md5(random()::text),
    CASE WHEN random() > 0.4 THEN TRUE ELSE FALSE END
FROM generate_series(1, 300) AS i;