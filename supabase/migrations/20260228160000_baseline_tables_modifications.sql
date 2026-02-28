-- Baseline (reference) tables modifications
-- 基准表结构调整与注释，便于配置管理与审计

-- base_main_category: 增加展示顺序，便于前端固定排序
ALTER TABLE base_main_category
  ADD COLUMN IF NOT EXISTS display_order integer NOT NULL DEFAULT 0;

COMMENT ON COLUMN base_main_category.display_order IS 'Display order for UI (lower first)';

-- base_sub_category: 增加展示顺序（在同一 main_category 下）
ALTER TABLE base_sub_category
  ADD COLUMN IF NOT EXISTS display_order integer NOT NULL DEFAULT 0;

COMMENT ON COLUMN base_sub_category.display_order IS 'Display order within main category for UI';

-- base_compliance_standard: 表注释
COMMENT ON TABLE base_compliance_standard IS 'Base compliance standards (CS); default_frequency is JSONB e.g. {"unit":"month","value":1}';
COMMENT ON TABLE base_main_category IS 'Main SS categories (e.g. AS, BW, EE)';
COMMENT ON TABLE base_sub_category IS 'Sub-categories / SS codes; ss_code is official code for Form 12A';
