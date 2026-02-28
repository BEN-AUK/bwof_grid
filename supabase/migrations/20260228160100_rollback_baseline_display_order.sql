-- Rollback: remove display_order columns from baseline tables (COMMENTs on tables are kept)
-- 回滚：移除基准表新增的 display_order 列，保留表注释

ALTER TABLE base_main_category
  DROP COLUMN IF EXISTS display_order;

ALTER TABLE base_sub_category
  DROP COLUMN IF EXISTS display_order;
