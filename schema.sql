CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE products (

    -----------------------------------------------------------------
    -- Primary Key
    -----------------------------------------------------------------
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -----------------------------------------------------------------
    -- Basic Product Information
    -----------------------------------------------------------------
    sku VARCHAR(100) UNIQUE,
    barcode VARCHAR(100),
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE,
    short_description TEXT,
    description TEXT,

    -----------------------------------------------------------------
    -- Store Department
    -----------------------------------------------------------------
    department_id UUID NOT NULL,
    category_id UUID NOT NULL,
    subcategory_id UUID,
    brand_id UUID,

    -----------------------------------------------------------------
    -- Inventory Source
    -----------------------------------------------------------------
    seller_type VARCHAR(20) NOT NULL
        CHECK (seller_type IN ('STORE','RESELLER')),

    seller_id UUID,

    -----------------------------------------------------------------
    -- Pricing
    -----------------------------------------------------------------
    price DECIMAL(10,2) NOT NULL,

    original_price DECIMAL(10,2),

    cost DECIMAL(10,2),

    compare_at_price DECIMAL(10,2),

    currency VARCHAR(5) DEFAULT 'USD',

    -----------------------------------------------------------------
    -- Quantity
    -----------------------------------------------------------------
    quantity INTEGER DEFAULT 0,

    reserved_quantity INTEGER DEFAULT 0,

    reorder_level INTEGER DEFAULT 5,

    max_order_quantity INTEGER DEFAULT 10,

    -----------------------------------------------------------------
    -- Stock Status
    -----------------------------------------------------------------
    stock_status VARCHAR(20)
        DEFAULT 'IN_STOCK'
        CHECK (
            stock_status IN
            (
                'IN_STOCK',
                'LOW_STOCK',
                'OUT_OF_STOCK',
                'PREORDER',
                'DISCONTINUED'
            )
        ),

    -----------------------------------------------------------------
    -- Product Condition
    -----------------------------------------------------------------
    condition VARCHAR(25)
        DEFAULT 'NEW'
        CHECK
        (
            condition IN
            (
                'NEW',
                'LIKE_NEW',
                'EXCELLENT',
                'VERY_GOOD',
                'GOOD',
                'FAIR',
                'POOR',
                'FOR_PARTS'
            )
        ),

    -----------------------------------------------------------------
    -- Resale Marketplace
    -----------------------------------------------------------------
    listing_status VARCHAR(20)
        DEFAULT 'ACTIVE'
        CHECK
        (
            listing_status IN
            (
                'PENDING',
                'ACTIVE',
                'SOLD',
                'REMOVED',
                'REJECTED',
                'EXPIRED'
            )
        ),

    approved_by UUID,

    approved_at TIMESTAMP,

    sold_at TIMESTAMP,

    -----------------------------------------------------------------
    -- Seller Payout
    -----------------------------------------------------------------
    payout_amount DECIMAL(10,2),

    payout_status VARCHAR(20)
        DEFAULT 'NOT_READY'
        CHECK
        (
            payout_status IN
            (
                'NOT_READY',
                'READY',
                'PROCESSING',
                'PAID',
                'FAILED'
            )
        ),

    payout_date TIMESTAMP,

    payout_transaction_id VARCHAR(255),

    commission_rate DECIMAL(5,2) DEFAULT 15.00,

    -----------------------------------------------------------------
    -- Shipping
    -----------------------------------------------------------------
    weight DECIMAL(10,2),

    length DECIMAL(10,2),

    width DECIMAL(10,2),

    height DECIMAL(10,2),

    shipping_class VARCHAR(100),

    free_shipping BOOLEAN DEFAULT FALSE,

    -----------------------------------------------------------------
    -- Tax
    -----------------------------------------------------------------
    taxable BOOLEAN DEFAULT TRUE,

    tax_code VARCHAR(50),

    -----------------------------------------------------------------
    -- Images
    -----------------------------------------------------------------
    thumbnail_url TEXT,

    image_count INTEGER DEFAULT 0,

    -----------------------------------------------------------------
    -- SEO
    -----------------------------------------------------------------
    meta_title VARCHAR(255),

    meta_description TEXT,

    keywords TEXT,

    -----------------------------------------------------------------
    -- Ratings
    -----------------------------------------------------------------
    average_rating DECIMAL(3,2) DEFAULT 0,

    review_count INTEGER DEFAULT 0,

    -----------------------------------------------------------------
    -- Visibility
    -----------------------------------------------------------------
    is_featured BOOLEAN DEFAULT FALSE,

    is_active BOOLEAN DEFAULT TRUE,

    is_deleted BOOLEAN DEFAULT FALSE,

    -----------------------------------------------------------------
    -- Automation
    -----------------------------------------------------------------
    auto_relist BOOLEAN DEFAULT FALSE,

    auto_reorder BOOLEAN DEFAULT TRUE,

    allow_backorders BOOLEAN DEFAULT FALSE,

    -----------------------------------------------------------------
    -- Dates
    -----------------------------------------------------------------
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
