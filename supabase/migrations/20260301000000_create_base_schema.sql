-- 1. 创建新的 base schema
CREATE SCHEMA IF NOT EXISTS base;

-- 2. 迁移并重命名 compliance_standard
ALTER TABLE public.base_compliance_standard SET SCHEMA base;
ALTER TABLE base.base_compliance_standard RENAME TO compliance_standard;

-- 3. 迁移并重命名 frequency_dict
ALTER TABLE public.base_frequency_dict SET SCHEMA base;
ALTER TABLE base.base_frequency_dict RENAME TO frequency_dict;

-- 4. 迁移并重命名 main_category
ALTER TABLE public.base_main_category SET SCHEMA base;
ALTER TABLE base.base_main_category RENAME TO main_category;

-- 5. 迁移并重命名 sub_category
-- 注意：PostgreSQL 会自动处理这些表之间的外键关联引用
ALTER TABLE public.base_sub_category SET SCHEMA base;
ALTER TABLE base.base_sub_category RENAME TO sub_category;