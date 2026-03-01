-- 添加基础表 (Add base tables)
-- 内容待填写
-- ==============================================================================
-- 阶段 1：创建建筑合规文件/档案表 (Building Compliance Documents)
-- 职责：作为 CS 文件版本的物理承载主体，收敛所有文件级元数据
-- ==============================================================================
CREATE TABLE setup.building_compliance_documents (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    organization_id uuid NOT NULL, -- [物理隔离锚点]
    building_id uuid NOT NULL,     -- [向上溯源] 挂载至具体建筑
    
    -- 文件与行政属性
    cs_number text,                -- Council 编号 (如 CS0320)
    cs_storage_path text,          -- CS 文件存储路径
    form12_storage_path text,      -- Form 12A 文件存储路径
    
    -- 版本与生命周期
    is_archived boolean DEFAULT false,
    archived_at timestamp with time zone,
    
    -- 严格审计基线
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_id uuid NOT NULL,
    last_modified_by_id uuid NOT NULL,

    CONSTRAINT bldg_comp_docs_pkey PRIMARY KEY (id),
    CONSTRAINT bldg_comp_docs_org_fkey FOREIGN KEY (organization_id) REFERENCES setup.organizations(id) ON DELETE CASCADE,
    CONSTRAINT bldg_comp_docs_bldg_fkey FOREIGN KEY (building_id) REFERENCES setup.buildings(id) ON DELETE CASCADE
);

-- 绑定时间戳触发器
CREATE TRIGGER handle_updated_at_docs 
    BEFORE UPDATE ON setup.building_compliance_documents 
    FOR EACH ROW EXECUTE PROCEDURE setup.set_updated_at();

-- ==============================================================================
-- 阶段 2：重命名并改造原 SS 表 (-> building_compliance_category)
-- ==============================================================================
-- 2.1 表更名
ALTER TABLE setup.building_specified_systems RENAME TO building_compliance_category;

-- 2.2 增加向上挂载的新外键 (Document ID)
ALTER TABLE setup.building_compliance_category 
    ADD COLUMN document_id uuid NOT NULL; -- 暂不设 NOT NULL 以防表内已有死数据报错

-- 2.3 解除旧外键约束 (假设原约束名为建表时的默认名，如遇报错需按实际名称 DROP)
ALTER TABLE setup.building_compliance_category DROP CONSTRAINT IF EXISTS building_ss_org_fkey;
ALTER TABLE setup.building_compliance_category DROP CONSTRAINT IF EXISTS building_ss_building_fkey;

-- 2.4 剥离冗余字段
ALTER TABLE setup.building_compliance_category 
    DROP COLUMN organization_id,
    DROP COLUMN building_id,
    DROP COLUMN cs_storage_path,
    DROP COLUMN form12_storage_path,
    DROP COLUMN is_archived,
    DROP COLUMN archived_at;

-- 2.5 建立新外键约束
ALTER TABLE setup.building_compliance_category
    ADD CONSTRAINT bcc_document_fkey FOREIGN KEY (document_id) REFERENCES setup.building_compliance_documents(id) ON DELETE CASCADE;

-- ==============================================================================
-- 阶段 3：重命名并改造 Inspections 子表 (-> building_compliance_category_inspections)
-- ==============================================================================
-- 3.1 表更名
ALTER TABLE setup.building_specified_systems_inspections RENAME TO building_compliance_category_inspections;

-- 3.2 修正关联字段名称以保持 ID-First 命名一致性
ALTER TABLE setup.building_compliance_category_inspections 
    RENAME COLUMN building_specified_system_id TO compliance_category_id;

-- ==============================================================================
-- 阶段 4：重建强制安全预设 (Rebuild Mandatory RLS)
-- 警告：由于移除了 organization_id 冗余，必须重建跨表查询策略
-- ==============================================================================
-- 4.1 开启 RLS
ALTER TABLE setup.building_compliance_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE setup.building_compliance_category ENABLE ROW LEVEL SECURITY;
-- (inspections 表之前已开启)

-- 4.2 Documents 层鉴权 (直连 organization_id)
CREATE POLICY "Docs isolation" ON setup.building_compliance_documents FOR ALL USING (
    organization_id = (SELECT organization_id FROM setup.profiles WHERE id = auth.uid())
);

-- 4.3 Category 层鉴权 (穿透至 Documents)
DROP POLICY IF EXISTS "Users can manage specified systems in their organization" ON setup.building_compliance_category;
CREATE POLICY "Category isolation" ON setup.building_compliance_category FOR ALL USING (
    document_id IN (
        SELECT id FROM setup.building_compliance_documents 
        WHERE organization_id = (SELECT organization_id FROM setup.profiles WHERE id = auth.uid())
    )
);

-- 4.4 Inspections 层鉴权 (穿透两级至 Documents)
DROP POLICY IF EXISTS "Users can manage inspections in their organization" ON setup.building_compliance_category_inspections;
CREATE POLICY "Inspections isolation" ON setup.building_compliance_category_inspections FOR ALL USING (
    compliance_category_id IN (
        SELECT id FROM setup.building_compliance_category WHERE document_id IN (
            SELECT id FROM setup.building_compliance_documents 
            WHERE organization_id = (SELECT organization_id FROM setup.profiles WHERE id = auth.uid())
        )
    )
);