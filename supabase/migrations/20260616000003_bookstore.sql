-- ==============================================================================
-- KINGDOM HEIR — BOOKSTORE SCHEMA
-- Generated: 2026-06-16
-- ==============================================================================

-- 1. Bookstore Categories
CREATE TABLE public.bookstore_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.bookstore_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for bookstore categories" ON public.bookstore_categories FOR SELECT USING (true);
CREATE POLICY "Admins can manage bookstore categories" ON public.bookstore_categories FOR ALL USING (public.is_admin());

-- 2. Bookstore Products
CREATE TABLE public.bookstore_products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  author TEXT,
  price NUMERIC(10, 2) NOT NULL,
  product_type TEXT NOT NULL, -- e.g., 'Book', 'E-Book', 'CD', 'Merch'
  category_id UUID REFERENCES public.bookstore_categories(id) ON DELETE SET NULL,
  external_buy_url TEXT NOT NULL,
  image_url TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER bookstore_products_updated_at
  BEFORE UPDATE ON public.bookstore_products
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

ALTER TABLE public.bookstore_products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read for active bookstore products" ON public.bookstore_products FOR SELECT USING (is_active = true);
CREATE POLICY "Admins can manage bookstore products" ON public.bookstore_products FOR ALL USING (public.is_admin());

-- Insert Seed Data
INSERT INTO public.bookstore_categories (name, sort_order) VALUES
('All', 0),
('Books', 1),
('E-Books', 2),
('CDs/DVDs', 3),
('Merch', 4);

INSERT INTO public.bookstore_products (title, author, price, product_type, external_buy_url) VALUES
('Kingdom Identity', 'Pastor James Osei', 18.99, 'Book', 'https://example.com/buy/kingdom-identity'),
('Pray Without Ceasing', 'Rev. Sarah Mensah', 12.99, 'E-Book', 'https://example.com/buy/pray-without-ceasing'),
('Grace & Truth (CD)', 'Kingdom Heir', 9.99, 'CD', 'https://example.com/buy/grace-truth-cd'),
('Walking in Purpose', 'Bishop Emmanuel Yaw', 22.00, 'Book', 'https://example.com/buy/walking-in-purpose'),
('Kingdom Heir T-Shirt', NULL, 24.99, 'Merch', 'https://example.com/buy/kingdom-heir-tshirt'),
('Daily Devotional 2026', 'Kingdom Heir Team', 14.99, 'Book', 'https://example.com/buy/daily-devotional-2026');
