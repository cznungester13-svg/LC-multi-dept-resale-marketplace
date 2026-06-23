CREATE tABLE products (
    product-id UUID PRIMARY KEY DEFAULT gen-random-uuid().
    --Product Information
    sku VARCHAR(100) UNIQUE,
    title VARCHAR(255 NOT NULL,
    slug VARCHAR(255) UNIQUE,
    description TEXT,

    --Categorization
    category-id UUID NOT NULL,
    brand-id UUID,

    --Ownership
    seller-type VARCHAR(20) NOT NULL CHECK (
        seller-type IN ('STORE', "RESELLER')
    ),

    seller-id UUID NULL,

    --Pricing
    price DECIMAL(12,2) NOT NULL,
    original-price DECIMAL(12,2),
    cost DECIMAL(12,2),

    --Inventory
    quantity INTEGER NOT NULL DEFAULT 1,
    stock_status VARCHAR(20) DEFAULT 'IN_STOCK' CHECK (
        stock_status IN (
             'IN_STOCK',
             'OUT_OF_STOCK',
             'RESERVED',
             'SOLD'
        )
    ),

    --Product Condition
    condition VARCHAR(30) NOT NULL DEFAULT 'NEW' CHECK (
        condition IN (
             'NEW',
             'LIKE NEW',
             'EXCELLENT',
             'GOOD',
             'FAIR',
             'POOR',
             'FOR_PARTS'
       )
    ),

    --Marketplace Payout Tracking
    payout_amount DECIMAL(12,2),
    commission_amount DECIMAL(12,2),
    payout_status VARCHAR (20) DEFAULT 'PENDING' CHECK (
        payout_status IN (
            'PENDING',
            'PROCESSING',
            'PAID',
            'CANCELLED'
      )
  ),
  payout_date TIMESTAMP,

  --Images
  primary_image-url TEXT,

  --Product Status 
  listing_status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (
      listing_status IN (
          'DRAFT',
          'PENDING_APPROVAL','ACTIVE',
          'SOLD',
          'ARCHIVED',
          'REJECTED'
        )
    ),

  --Shipping
  weight DECIMAL(10,2),
  length DECIMAL(10,2),
  width DECIMAL(10,2),
  height DECIMAL(10,2),

  --SEO
  meta_title VARCHAR(255),
  meta description TEXT,

  --Auditingcreated_ TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

users
categories
brands
product_images
product_attributes
orders
order_items
reviews
wishlists
seller_payouts
addresses

products
product_variants
inventory
product_images
seller_listings

products
    ↓
product_variants
    ↓
seller_listings
    ↓
inventory

users
categories
brands
products
product_images

CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,

    role VARCHAR(20) DEFAULT 'CUSTOMER' CHECK (
        role IN ('CUSTOMER','SELLER','ADMIN')
    ),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(100) NOT NULL,
    parent_category_id UUID,

    FOREIGN KEY (parent_category_id)
        REFERENCES categories(category_id)
);


Apparel & Shoes
 ├─ Men's Clothing
 ├─ Women's Clothing
 ├─ Shoes

Health & Beauty
 ├─ Makeup
 ├─ Skincare

Home Decor
 ├─ Wall Art
 ├─ Rugs

 
CREATE TABLE brands (
    brand_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL UNIQUE,
    logo_url TEXT
);

CREATE TABLE product_images (
    image_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    product_id UUID NOT NULL,

    image_url TEXT NOT NULL,

    display_order INTEGER DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE CASCADE
);

CREATE TABLE seller_listings (
    listing_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    product_id UUID NOT NULL,

    seller_id UUID NOT NULL,

    asking_price DECIMAL(12,2) NOT NULL,

    quantity INTEGER DEFAULT 1,

    condition VARCHAR(30),

    status VARCHAR(20) DEFAULT 'ACTIVE',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (product_id)
        REFERENCES products(product_id),

    FOREIGN KEY (seller_id)
        REFERENCES users(user_id)
);

CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    customer_id UUID NOT NULL,

    order_total DECIMAL(12,2),

    status VARCHAR(20) DEFAULT 'PENDING',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (customer_id)
        REFERENCES users(user_id)
);

CREATE TABLE order_items (
    order_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    order_id UUID NOT NULL,

    product_id UUID NOT NULL,

    seller_id UUID,

    quantity INTEGER,

    unit_price DECIMAL(12,2),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

Customer Pays $100

Platform Fee = $15

Seller Receives = $85


CREATE TABLE seller_payouts (
    payout_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    seller_id UUID NOT NULL,

    order_id UUID NOT NULL,

    gross_amount DECIMAL(12,2),

    commission_amount DECIMAL(12,2),

    net_amount DECIMAL(12,2),

    payout_status VARCHAR(20) DEFAULT 'PENDING',

    payout_date TIMESTAMP,

    FOREIGN KEY (seller_id)
        REFERENCES users(user_id),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);

users
categories
brands

products
product_variants
product_attributes
product_attribute_values
product_images

seller_listings
inventory

orders
order_items

payments
seller_payouts

reviews
wishlists
shopping_carts
cart_items

addresses
shipments
shipment_items

             
