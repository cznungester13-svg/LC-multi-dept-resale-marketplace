CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- PRODUCTS TABLE (MAIN)
CREATE TABLE products (
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sku VARCHAR(100) UNIQUE,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE,
    description TEXT,
    category_id UUID,
    brand_id UUID,
    seller_type VARCHAR(20) CHECK (seller_type IN ('STORE','RESELLER')),
    seller_id UUID,
    price DECIMAL(10,2),
    condition VARCHAR(25),
    listing_status VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- PRODUCT IMAGES TABLE (RELATED TABLE)
CREATE TABLE product_images (
    image_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL,
    image_url TEXT NOT NULL,
    display_order INTEGER DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);
