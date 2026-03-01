-- ==============================================================================
-- 阶段 1：创建建筑合规文件/档案表 (Building Compliance Documents)
-- ==============================================================================
CREATE TABLE setup.building_compliance_documents (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    organization_id uuid NOT NULL,
    building_id uuid NOT NULL,
    
    cs_number text,
    cs_storage_path text,
    form12_storage_path text,
    
    is_archived boolean DEFAULT false,
    archived_at timestamp with time zone,
    
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_id uuid NOT NULL,
    last_modified_by_id uuid NOT NULL,

    CONSTRAINT bldg_comp_docs_pkey PRIMARY KEY (id),
    CONSTRAINT bldg_comp_docs_org_fkey FOREIGN KEY (organization_id) REFERENCES setup.organizations(id) ON DELETE CASCADE,
    CONSTRAINT bldg_comp_docs_bldg_fkey FOREIGN KEY (building_id) REFERENCES setup.buildings(id) ON DELETE CASCADE
);

CREATE TRIGGER handle_updated_at_docs 
    BEFORE UPDATE ON setup.building_compliance_documents 
    FOR EACH ROW EXECUTE PROCEDURE setup.set_updated_at();

-- ==============================================================================
-- 阶段 2：前置清理 (Pre-Cleanup) -> 必须在改表结构前执行
-- ==============================================================================
-- 拆卸旧的 RLS 策略，解除字段依赖。注意：此时表名还是旧的
DROP POLICY IF EXISTS "Users can manage specified systems in their organization" ON setup.building_specified_systems;
DROP POLICY IF EXISTS "Users can manage inspections in their organization" ON setup.building_specified_systems_inspections;

-- ==============================================================================
-- 阶段 3：重命名并改造原 SS 表 (-> building_compliance_category)
-- ==============================================================================
ALTER TABLE setup.building_specified_systems RENAME TO building_compliance_category;

ALTER TABLE setup.building_compliance_category 
    ADD COLUMN document_id uuid;

-- 解除旧外键约束
ALTER TABLE setup.building_compliance_category DROP CONSTRAINT IF EXISTS building_ss_org_fkey;
ALTER TABLE setup.building_compliance_category DROP CONSTRAINT IF EXISTS building_ss_building_fkey;

-- 现在可以安全地删除冗余字段，因为没有任何 Policy 依赖它们了
ALTER TABLE setup.building_compliance_category 
    DROP COLUMN organization_id,
    DROP COLUMN building_id,
    DROP COLUMN cs_storage_path,
    DROP COLUMN form12_storage_path,
    DROP COLUMN is_archived,
    DROP COLUMN archived_at;

-- 建立新外键约束
ALTER TABLE setup.building_compliance_category
    ADD CONSTRAINT bcc_document_fkey FOREIGN KEY (document_id) REFERENCES setup.building_compliance_documents(id) ON DELETE CASCADE;

-- ==============================================================================
-- 阶段 4：重命名并改造 Inspections 子表
-- ==============================================================================
ALTER TABLE setup.building_specified_systems_inspections RENAME TO building_compliance_category_inspections;

ALTER TABLE setup.building_compliance_category_inspections 
    RENAME COLUMN building_specified_system_id TO compliance_category_id;

-- ==============================================================================
-- 阶段 5：重建强制安全预设 (Rebuild Mandatory RLS)
-- ==============================================================================
ALTER TABLE setup.building_compliance_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE setup.building_compliance_category ENABLE ROW LEVEL SECURITY;

-- 5.1 Documents 层鉴权
CREATE POLICY "Docs isolation" ON setup.building_compliance_documents FOR ALL USING (
    organization_id = (SELECT organization_id FROM setup.profiles WHERE id = auth.uid())
);

-- 5.2 Category 层鉴权 (穿透 1 层)
CREATE POLICY "Category isolation" ON setup.building_compliance_category FOR ALL USING (
    document_id IN (
        SELECT id FROM setup.building_compliance_documents 
        WHERE organization_id = (SELECT organization_id FROM setup.profiles WHERE id = auth.uid())
    )
);

-- 5.3 Inspections 层鉴权 (穿透 2 层)
CREATE POLICY "Inspections isolation" ON setup.building_compliance_category_inspections FOR ALL USING (
    compliance_category_id IN (
        SELECT id FROM setup.building_compliance_category WHERE document_id IN (
            SELECT id FROM setup.building_compliance_documents 
            WHERE organization_id = (SELECT organization_id FROM setup.profiles WHERE id = auth.uid())
        )
    )
);