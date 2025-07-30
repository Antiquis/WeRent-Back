-- Таблица категорий
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

-- Таблица продуктов
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    category_id INT REFERENCES categories(id)
);

-- Таблица заказов
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(id),
    purchase_time TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Таблица статистики
CREATE TABLE statistics (
    stat_date DATE NOT NULL,
    category_id INT REFERENCES categories(id),
    product_count INT NOT NULL DEFAULT 0,
    PRIMARY KEY (stat_date, category_id)
);

-- Функция-триггер
CREATE OR REPLACE FUNCTION update_statistics() RETURNS TRIGGER AS $$
BEGIN
    -- Получаем категорию товара
    DECLARE cat_id INT;
    SELECT category_id INTO cat_id FROM products WHERE id = NEW.product_id;

    -- Обновляем статистику
    INSERT INTO statistics (stat_date, category_id, product_count)
    VALUES (DATE(NEW.purchase_time), cat_id, 1)
    ON CONFLICT (stat_date, category_id)
    DO UPDATE SET product_count = statistics.product_count + 1;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер на вставку заказа
CREATE TRIGGER orders_insert_trigger
AFTER INSERT ON orders
FOR EACH ROW EXECUTE FUNCTION update_statistics();