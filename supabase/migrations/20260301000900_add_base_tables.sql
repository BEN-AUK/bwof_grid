-- ==========================================
-- 8. 建筑具体系统检查记录表 (Building SS Inspections) - JSONB 重构版
-- 职责：挂载于 building_specified_systems 之下，定义检查频率、责任人及结构化指令
-- ==========================================
CREATE TABLE setup.building_specified_systems_inspections (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    
    -- [强关联] 物理连接父表 building_specified_systems
    building_specified_system_id uuid NOT NULL, 
    
    -- 核心维度
    frequency_id uuid NOT NULL,          -- [外键] 关联 base.frequencies 字典表
    inspector_role text NOT NULL,        -- [硬编码枚举] 暂时采用 CHECK 约束
    
    -- 结构化指令 (JSONB)
    -- 用于存储 Checklist 步骤，例如：{"steps": ["检查压力表", "确认阀门开启"], "tools": ["压力计"]}
    inspection_instructions jsonb DEFAULT '[]'::jsonb, 
    
    -- 严格审计基线 (由 NestJS 显式注入)
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_id uuid NOT NULL,
    last_modified_by_id uuid NOT NULL,

    CONSTRAINT building_ss_inspections_pkey PRIMARY KEY (id),
    
    -- 物理连接约束
    CONSTRAINT building_ss_inspections_parent_fkey FOREIGN KEY (building_specified_system_id) REFERENCES setup.building_specified_systems(id) ON DELETE CASCADE,
    
    -- 角色枚举约束
    CONSTRAINT check_inspector_role CHECK (inspector_role = ANY (ARRAY['Owner', 'IQP', 'Council', 'Tenant', 'PM']))
);

-- 防止重复生成相同规则的联合唯一索引
CREATE UNIQUE INDEX idx_unique_inspection_rule ON setup.building_specified_systems_inspections (building_specified_system_id, frequency_id, inspector_role);

-- 查询加速索引
CREATE INDEX idx_inspections_parent_lookup ON setup.building_specified_systems_inspections(building_specified_system_id);

-- 绑定时间戳触发器
CREATE TRIGGER handle_updated_at_ss_inspections 
    BEFORE UPDATE ON setup.building_specified_systems_inspections 
    FOR EACH ROW EXECUTE PROCEDURE setup.set_updated_at();

-- ==========================================
-- 强制安全预设 (Mandatory RLS)
-- ==========================================
ALTER TABLE setup.building_specified_systems_inspections ENABLE ROW LEVEL SECURITY;

-- 跨表鉴权策略：inspections -> systems -> buildings -> profiles.org_id
CREATE POLICY "Users can manage inspections in their organization" ON setup.building_specified_systems_inspections
    FOR ALL USING (
        building_specified_system_id IN (
            SELECT id FROM setup.building_specified_systems
            WHERE building_id IN (
                SELECT id FROM setup.buildings
                WHERE organization_id = (SELECT organization_id FROM setup.profiles WHERE id = auth.uid())
            )
        )
    );