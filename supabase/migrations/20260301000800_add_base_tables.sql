-- 添加基础表
-- 内容待填写
-- ==========================================
-- 7. 建筑具体合规系统表 (Building Specified Systems) - 架构纠偏版
-- ==========================================
CREATE TABLE setup.building_specified_systems (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    organization_id uuid NOT NULL,
    building_id uuid NOT NULL,
    
    ss_sub_category_id uuid NOT NULL,
    
    -- ==========================================
    -- 1. 性能标准 (Performance Standard)
    -- ==========================================
    performance_standard_id uuid,               -- [终态] 匹配到的字典库 ID
    raw_performance_standard_text text,         -- [审计] AI 在 PDF 里框出的"原文字符串" (比如："As per old sprinkler rules")
    
    -- ==========================================
    -- 2. 检查标准 (Inspection Standard)
    -- ==========================================
    inspection_standard_id uuid,                -- [终态] 匹配到的字典库 ID
    raw_inspection_standard_text text,          -- [审计] AI 在 PDF 里框出的"原文字符串"
    
    -- 文件凭证存储路径
    cs_storage_path text,
    form12_storage_path text,
    
    -- 版本更迭与生命周期控制
    is_archived boolean DEFAULT false,
    archived_at timestamp with time zone,
    
    -- 严格审计基线
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_id uuid NOT NULL,
    last_modified_by_id uuid NOT NULL,

    CONSTRAINT building_ss_pkey PRIMARY KEY (id),
    CONSTRAINT building_ss_org_fkey FOREIGN KEY (organization_id) REFERENCES setup.organizations(id) ON DELETE CASCADE,
    CONSTRAINT building_ss_building_fkey FOREIGN KEY (building_id) REFERENCES setup.buildings(id) ON DELETE CASCADE
);

-- 触发器与 RLS (同上，保持不变)
CREATE TRIGGER handle_updated_at_building_ss BEFORE UPDATE ON setup.building_specified_systems FOR EACH ROW EXECUTE PROCEDURE setup.set_updated_at();
ALTER TABLE setup.building_specified_systems ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage specified systems in their organization" ON setup.building_specified_systems FOR ALL USING (organization_id = (SELECT organization_id FROM setup.profiles WHERE id = auth.uid()));