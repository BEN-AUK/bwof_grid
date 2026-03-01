-- 使用 DROP TABLE ... CASCADE 会自动删除依赖于这些表的所有对象（如外键约束）
DROP TABLE IF EXISTS public.evidence_slots CASCADE;
DROP TABLE IF EXISTS public.building_compliance_component CASCADE;
DROP TABLE IF EXISTS public.building_compliance_baseline CASCADE;
DROP TABLE IF EXISTS public.specified_systems CASCADE;
DROP TABLE IF EXISTS public.files CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP TABLE IF EXISTS public.buildings CASCADE;
DROP TABLE IF EXISTS public.organizations CASCADE;