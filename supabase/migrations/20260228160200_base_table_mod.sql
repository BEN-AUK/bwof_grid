-- 迁移内容待填写
-- 1. 更新 base_compliance_standard (合规标准表)
ALTER TABLE public.base_compliance_standard 
ADD COLUMN IF NOT EXISTS is_deprecated boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS description text;

-- 增加唯一性联合约束：确保同一个标准代码下的版本号不重复
ALTER TABLE public.base_compliance_standard 
ADD CONSTRAINT base_compliance_standard_code_version_key UNIQUE (standard_code, version);

-- 2. 更新 base_main_category (主分类表)
ALTER TABLE public.base_main_category 
ADD COLUMN IF NOT EXISTS sort_order int2 DEFAULT 0;


-- 增加是否强制项标记
ALTER TABLE public.base_sub_category 
ADD COLUMN IF NOT EXISTS is_mandatory boolean DEFAULT false;

-- 注释：说明 is_mandatory 的业务逻辑
COMMENT ON COLUMN public.base_sub_category.is_mandatory IS '标记该子类是否为对应大类下的法定强制检查项';