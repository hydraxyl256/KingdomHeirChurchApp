-- ==============================================================================
-- KINGDOM HEIR — NEWS RPCs
-- Generated: 2026-06-15
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.increment_article_view(article_uuid UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.news_articles
  SET view_count = view_count + 1
  WHERE id = article_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.increment_article_share(article_uuid UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.news_articles
  SET share_count = share_count + 1
  WHERE id = article_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
