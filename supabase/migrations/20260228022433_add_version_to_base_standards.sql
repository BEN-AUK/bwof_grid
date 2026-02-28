ALTER TABLE base_compliance_standard ADD COLUMN IF NOT EXISTS version TEXT;
COMMENT ON COLUMN base_compliance_standard.version IS 'Standard version year, e.g., 2007, 2018';
