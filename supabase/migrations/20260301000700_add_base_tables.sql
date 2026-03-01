
    -- ==========================================
-- 6. 建筑/物业表 (Buildings) - V2 重构版
-- 职责：存储符合 NZ Building Act 要求的核心合规属性
-- ==========================================
CREATE TABLE setup.buildings (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    organization_id uuid NOT NULL, -- 租户隔离锚点
    owner_id uuid,                 -- 关联业主表
    
    -- 基础标识
    name text NOT NULL,            -- Building Name
    address text NOT NULL,         -- Full Address (原生字符串)
    council_name text,             -- 所属议会 (如：Auckland Council)

    -- 法律与土地属性 (Legal & Land)
    legal_description text,        -- Legal description of land (如 Lot/DP 号)
    year_of_first_construction text, -- 首次建造年份

    -- 建筑生命与安全分类 (Compliance & Safety)
    intended_life text,            -- Intended life of the building (如 Indefinite 或 Specified years)
    highest_fire_hazard_category text, -- Highest fire hazard category
    risk_groups text,              -- Risk group(s) (如 WB, SM, etc.)
    compliance_schedule_location text, -- Compliance schedule is kept at (实物存放点)
    
    -- 审计字段 (由应用层 NestJS 显式注入)
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_id uuid NOT NULL,
    last_modified_by_id uuid NOT NULL,

    CONSTRAINT buildings_pkey PRIMARY KEY (id),
    CONSTRAINT buildings_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES setup.organizations(id) ON DELETE CASCADE,
    CONSTRAINT buildings_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES setup.owners(id) ON DELETE SET NULL
);

-- 绑定时间戳触发器
CREATE TRIGGER handle_updated_at_buildings 
    BEFORE UPDATE ON setup.buildings 
    FOR EACH ROW EXECUTE PROCEDURE setup.set_updated_at();

-- 开启 RLS 并设置组织隔离
ALTER TABLE setup.buildings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage buildings in their organization" ON setup.buildings
    FOR ALL
    USING (
        organization_id = (SELECT organization_id FROM setup.profiles WHERE id = auth.uid())
    );