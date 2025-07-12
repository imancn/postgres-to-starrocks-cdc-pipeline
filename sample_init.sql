CREATE TABLE IF NOT EXISTS public.users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO public.users (name, email) VALUES
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com');

CREATE TABLE IF NOT EXISTS public.orders (
    id SERIAL PRIMARY KEY,
    item VARCHAR(100),
    quantity INT,
    price DECIMAL(10,2),
    ordered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO public.orders (item, quantity, price) VALUES
('Widget', 5, 19.99),
('Gadget', 2, 24.99);
