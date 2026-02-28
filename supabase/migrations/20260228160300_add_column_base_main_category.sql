-- 为主分类表增加 aliases 字段，默认为空数组以避免 null 处理的繁琐
ALTER TABLE public.base_main_category 
ADD COLUMN IF NOT EXISTS aliases text[] DEFAULT '{}'::text[];

-- 添加注释
COMMENT ON COLUMN public.base_main_category.aliases IS '主分类的同义词/别名，用于文档解析时的模糊匹配';