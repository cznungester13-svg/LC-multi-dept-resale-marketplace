CREATE TABLE products (
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Product Information
    sku VARCHAR(100) UNIQUE,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE,
    description TEXT,

    -- Categorization
    category_id UUID NOT NULL,
    brand_id UUID,
    
    -- Ownership
    seller_type VARCHAR(20) NOT NULL CHECK (
        seller_type IN ('STORE', 'RESELLER')
    ),

    seller_id UUID NULL,

    -- Pricing
    price DECIMAL(12,2) NOT NULL,
    original_price DECIMAL(12,2),
    cost DECIMAL(12,2),

    -- Inventory
    quantity INTEGER NOT NULL DEFAULT 1,
    stock_status VARCHAR(20) DEFAULT 'IN_STOCK' CHECK (
        stock_status IN (
            'IN_STOCK',
            'OUT_OF_STOCK',
            'RESERVED',
            'SOLD'
        )
    ),

    -- Product Condition
    condition VARCHAR(30) NOT NULL DEFAULT 'NEW' CHECK (
        condition IN (
            'NEW',
            'LIKE_NEW',
            'EXCELLENT',
            'GOOD',
            'FAIR',
            'POOR',
            'FOR_PARTS'
        )
    ),

    -- Marketplace Payout Tracking
    payout_amount DECIMAL(12,2),
    commission_amount DECIMAL(12,2),
    payout_status VARCHAR(20) DEFAULT 'PENDING' CHECK (
        payout_status IN (
            'PENDING',
            'PROCESSING',
            'PAID',
            'CANCELLED'
        )
    ),
    payout_date TIMESTAMP,

    -- Images
    primary_image_url TEXT,

    -- Product Status
    listing_status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (
        listing_status IN (
            'DRAFT',
            'PENDING_APPROVAL',
            'ACTIVE',
            'SOLD',
            'ARCHIVED',
            'REJECTED'
        )
    ),

    -- Shipping
    weight DECIMAL(10,2),
    length DECIMAL(10,2),
    width DECIMAL(10,2),
    height DECIMAL(10,2),

    -- SEO
    meta_title VARCHAR(255),
    meta_description TEXT,

    -- Auditing
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP

    --Optional FK to users table
    CONSTRAINT fk_seller
        FOREIGN KEY (seller_id)
        REFERENCES users(user_id)
        ON DELETE SET NULL
     );
     
    CREATE TABLE product_images (
    image_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL,
    image_url TEXT NOT NULL,
    display_order INTEGER DEFAULT 0,

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE CASCADE
     );

    CREATE TABLE categories (
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_name VARCHAR(100) UNIQUE NOT NULL,
    parent_category_id UUID,

    FOREIGN KEY (parent_category_id)
        REFERENCES categories(category_id)
    );   

    CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_id UUID NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    order_status VARCHAR(30),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );

   CREATE TABLE marketplace_transactions (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL,
    order_id UUID NOT NULL,

    sale_price DECIMAL(10,2) NOT NULL,
    commission_amount DECIMAL(10,2) NOT NULL,
    seller_payout_amount DECIMAL(10,2) NOT NULL,

    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (product_id)
        REFERENCES products(product_id),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
    );


  
