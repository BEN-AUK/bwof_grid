


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";





SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."base_compliance_standard" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "standard_code" character varying(50) NOT NULL,
    "standard_name" "text" NOT NULL,
    "default_frequency" "jsonb" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."base_compliance_standard" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."base_main_category" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" character varying(10) NOT NULL,
    "name" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."base_main_category" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."base_sub_category" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "main_category_id" "uuid" NOT NULL,
    "ss_code" character varying(10) NOT NULL,
    "name" "text" NOT NULL,
    "default_standard_id" "uuid",
    "aliases" "text"[] DEFAULT '{}'::"text"[],
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."base_sub_category" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."building_compliance_baseline" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "building_id" "uuid" NOT NULL,
    "ss_sub_category_id" "uuid" NOT NULL,
    "specific_standard_id" "uuid",
    "is_active" boolean DEFAULT true,
    "effective_from" "date" DEFAULT CURRENT_DATE,
    "amendment_reason" "text",
    "remarks" "text",
    "last_updated_at" timestamp with time zone DEFAULT "now"(),
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."building_compliance_baseline" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."building_compliance_component" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "baseline_id" "uuid" NOT NULL,
    "component_name" "text" NOT NULL,
    "required_frequency" "jsonb" NOT NULL,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."building_compliance_component" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."buildings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "organization_id" "uuid",
    "name" "text" NOT NULL,
    "address" "text" NOT NULL,
    "compliance_rules" "jsonb" DEFAULT '[]'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."buildings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."evidence_slots" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "ss_id" "uuid",
    "target_month" "date" NOT NULL,
    "status" "text" DEFAULT 'Missing'::"text",
    "file_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "evidence_slots_status_check" CHECK (("status" = ANY (ARRAY['Missing'::"text", 'Verified'::"text", 'Defect'::"text"])))
);


ALTER TABLE "public"."evidence_slots" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."files" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "building_id" "uuid",
    "storage_path" "text" NOT NULL,
    "captured_at" timestamp with time zone NOT NULL,
    "synced_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."files" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."organizations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."organizations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "organization_id" "uuid",
    "full_name" "text",
    "role" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "profiles_role_check" CHECK (("role" = ANY (ARRAY['Admin'::"text", 'Owner'::"text"])))
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."specified_systems" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "building_id" "uuid",
    "ss_code" "text" NOT NULL,
    "name" "text",
    "frequency" "text",
    "is_custom_ss" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."specified_systems" OWNER TO "postgres";


ALTER TABLE ONLY "public"."base_compliance_standard"
    ADD CONSTRAINT "base_compliance_standard_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."base_compliance_standard"
    ADD CONSTRAINT "base_compliance_standard_standard_code_key" UNIQUE ("standard_code");



ALTER TABLE ONLY "public"."base_main_category"
    ADD CONSTRAINT "base_main_category_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."base_main_category"
    ADD CONSTRAINT "base_main_category_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."base_sub_category"
    ADD CONSTRAINT "base_sub_category_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."base_sub_category"
    ADD CONSTRAINT "base_sub_category_ss_code_key" UNIQUE ("ss_code");



ALTER TABLE ONLY "public"."building_compliance_baseline"
    ADD CONSTRAINT "building_compliance_baseline_building_id_ss_sub_category_id_key" UNIQUE ("building_id", "ss_sub_category_id", "is_active");



ALTER TABLE ONLY "public"."building_compliance_baseline"
    ADD CONSTRAINT "building_compliance_baseline_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."building_compliance_component"
    ADD CONSTRAINT "building_compliance_component_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."buildings"
    ADD CONSTRAINT "buildings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."evidence_slots"
    ADD CONSTRAINT "evidence_slots_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."files"
    ADD CONSTRAINT "files_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."organizations"
    ADD CONSTRAINT "organizations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."specified_systems"
    ADD CONSTRAINT "specified_systems_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."base_sub_category"
    ADD CONSTRAINT "base_sub_category_default_standard_id_fkey" FOREIGN KEY ("default_standard_id") REFERENCES "public"."base_compliance_standard"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."base_sub_category"
    ADD CONSTRAINT "base_sub_category_main_category_id_fkey" FOREIGN KEY ("main_category_id") REFERENCES "public"."base_main_category"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."building_compliance_baseline"
    ADD CONSTRAINT "building_compliance_baseline_specific_standard_id_fkey" FOREIGN KEY ("specific_standard_id") REFERENCES "public"."base_compliance_standard"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."building_compliance_baseline"
    ADD CONSTRAINT "building_compliance_baseline_ss_sub_category_id_fkey" FOREIGN KEY ("ss_sub_category_id") REFERENCES "public"."base_sub_category"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."building_compliance_component"
    ADD CONSTRAINT "building_compliance_component_baseline_id_fkey" FOREIGN KEY ("baseline_id") REFERENCES "public"."building_compliance_baseline"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."buildings"
    ADD CONSTRAINT "buildings_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."evidence_slots"
    ADD CONSTRAINT "evidence_slots_file_id_fkey" FOREIGN KEY ("file_id") REFERENCES "public"."files"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."evidence_slots"
    ADD CONSTRAINT "evidence_slots_ss_id_fkey" FOREIGN KEY ("ss_id") REFERENCES "public"."specified_systems"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."files"
    ADD CONSTRAINT "files_building_id_fkey" FOREIGN KEY ("building_id") REFERENCES "public"."buildings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id");



ALTER TABLE ONLY "public"."specified_systems"
    ADD CONSTRAINT "specified_systems_building_id_fkey" FOREIGN KEY ("building_id") REFERENCES "public"."buildings"("id") ON DELETE CASCADE;



CREATE POLICY "Auth user read access on baseline" ON "public"."building_compliance_baseline" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Auth user read access on components" ON "public"."building_compliance_component" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Public dictionary read access" ON "public"."base_main_category" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Public standards read access" ON "public"."base_compliance_standard" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Public sub_category read access" ON "public"."base_sub_category" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Users can only view their own organization's buildings" ON "public"."buildings" USING (("organization_id" IN ( SELECT "profiles"."organization_id"
   FROM "public"."profiles"
  WHERE ("profiles"."id" = "auth"."uid"()))));



ALTER TABLE "public"."base_compliance_standard" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."base_main_category" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."base_sub_category" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."building_compliance_baseline" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."building_compliance_component" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."buildings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."evidence_slots" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."specified_systems" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";








































































































































































GRANT ALL ON TABLE "public"."base_compliance_standard" TO "anon";
GRANT ALL ON TABLE "public"."base_compliance_standard" TO "authenticated";
GRANT ALL ON TABLE "public"."base_compliance_standard" TO "service_role";



GRANT ALL ON TABLE "public"."base_main_category" TO "anon";
GRANT ALL ON TABLE "public"."base_main_category" TO "authenticated";
GRANT ALL ON TABLE "public"."base_main_category" TO "service_role";



GRANT ALL ON TABLE "public"."base_sub_category" TO "anon";
GRANT ALL ON TABLE "public"."base_sub_category" TO "authenticated";
GRANT ALL ON TABLE "public"."base_sub_category" TO "service_role";



GRANT ALL ON TABLE "public"."building_compliance_baseline" TO "anon";
GRANT ALL ON TABLE "public"."building_compliance_baseline" TO "authenticated";
GRANT ALL ON TABLE "public"."building_compliance_baseline" TO "service_role";



GRANT ALL ON TABLE "public"."building_compliance_component" TO "anon";
GRANT ALL ON TABLE "public"."building_compliance_component" TO "authenticated";
GRANT ALL ON TABLE "public"."building_compliance_component" TO "service_role";



GRANT ALL ON TABLE "public"."buildings" TO "anon";
GRANT ALL ON TABLE "public"."buildings" TO "authenticated";
GRANT ALL ON TABLE "public"."buildings" TO "service_role";



GRANT ALL ON TABLE "public"."evidence_slots" TO "anon";
GRANT ALL ON TABLE "public"."evidence_slots" TO "authenticated";
GRANT ALL ON TABLE "public"."evidence_slots" TO "service_role";



GRANT ALL ON TABLE "public"."files" TO "anon";
GRANT ALL ON TABLE "public"."files" TO "authenticated";
GRANT ALL ON TABLE "public"."files" TO "service_role";



GRANT ALL ON TABLE "public"."organizations" TO "anon";
GRANT ALL ON TABLE "public"."organizations" TO "authenticated";
GRANT ALL ON TABLE "public"."organizations" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



GRANT ALL ON TABLE "public"."specified_systems" TO "anon";
GRANT ALL ON TABLE "public"."specified_systems" TO "authenticated";
GRANT ALL ON TABLE "public"."specified_systems" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































drop extension if exists "pg_net";

drop policy "Users can only view their own organization's buildings" on "public"."buildings";

alter table "public"."base_sub_category" drop constraint "base_sub_category_default_standard_id_fkey";

alter table "public"."base_sub_category" drop constraint "base_sub_category_main_category_id_fkey";

alter table "public"."building_compliance_baseline" drop constraint "building_compliance_baseline_specific_standard_id_fkey";

alter table "public"."building_compliance_baseline" drop constraint "building_compliance_baseline_ss_sub_category_id_fkey";

alter table "public"."building_compliance_component" drop constraint "building_compliance_component_baseline_id_fkey";

alter table "public"."buildings" drop constraint "buildings_organization_id_fkey";

alter table "public"."evidence_slots" drop constraint "evidence_slots_file_id_fkey";

alter table "public"."evidence_slots" drop constraint "evidence_slots_ss_id_fkey";

alter table "public"."files" drop constraint "files_building_id_fkey";

alter table "public"."profiles" drop constraint "profiles_organization_id_fkey";

alter table "public"."specified_systems" drop constraint "specified_systems_building_id_fkey";

alter table "public"."base_sub_category" add constraint "base_sub_category_default_standard_id_fkey" FOREIGN KEY (default_standard_id) REFERENCES public.base_compliance_standard(id) ON DELETE SET NULL not valid;

alter table "public"."base_sub_category" validate constraint "base_sub_category_default_standard_id_fkey";

alter table "public"."base_sub_category" add constraint "base_sub_category_main_category_id_fkey" FOREIGN KEY (main_category_id) REFERENCES public.base_main_category(id) ON DELETE RESTRICT not valid;

alter table "public"."base_sub_category" validate constraint "base_sub_category_main_category_id_fkey";

alter table "public"."building_compliance_baseline" add constraint "building_compliance_baseline_specific_standard_id_fkey" FOREIGN KEY (specific_standard_id) REFERENCES public.base_compliance_standard(id) ON DELETE RESTRICT not valid;

alter table "public"."building_compliance_baseline" validate constraint "building_compliance_baseline_specific_standard_id_fkey";

alter table "public"."building_compliance_baseline" add constraint "building_compliance_baseline_ss_sub_category_id_fkey" FOREIGN KEY (ss_sub_category_id) REFERENCES public.base_sub_category(id) ON DELETE CASCADE not valid;

alter table "public"."building_compliance_baseline" validate constraint "building_compliance_baseline_ss_sub_category_id_fkey";

alter table "public"."building_compliance_component" add constraint "building_compliance_component_baseline_id_fkey" FOREIGN KEY (baseline_id) REFERENCES public.building_compliance_baseline(id) ON DELETE CASCADE not valid;

alter table "public"."building_compliance_component" validate constraint "building_compliance_component_baseline_id_fkey";

alter table "public"."buildings" add constraint "buildings_organization_id_fkey" FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE not valid;

alter table "public"."buildings" validate constraint "buildings_organization_id_fkey";

alter table "public"."evidence_slots" add constraint "evidence_slots_file_id_fkey" FOREIGN KEY (file_id) REFERENCES public.files(id) ON DELETE SET NULL not valid;

alter table "public"."evidence_slots" validate constraint "evidence_slots_file_id_fkey";

alter table "public"."evidence_slots" add constraint "evidence_slots_ss_id_fkey" FOREIGN KEY (ss_id) REFERENCES public.specified_systems(id) ON DELETE CASCADE not valid;

alter table "public"."evidence_slots" validate constraint "evidence_slots_ss_id_fkey";

alter table "public"."files" add constraint "files_building_id_fkey" FOREIGN KEY (building_id) REFERENCES public.buildings(id) ON DELETE CASCADE not valid;

alter table "public"."files" validate constraint "files_building_id_fkey";

alter table "public"."profiles" add constraint "profiles_organization_id_fkey" FOREIGN KEY (organization_id) REFERENCES public.organizations(id) not valid;

alter table "public"."profiles" validate constraint "profiles_organization_id_fkey";

alter table "public"."specified_systems" add constraint "specified_systems_building_id_fkey" FOREIGN KEY (building_id) REFERENCES public.buildings(id) ON DELETE CASCADE not valid;

alter table "public"."specified_systems" validate constraint "specified_systems_building_id_fkey";


  create policy "Users can only view their own organization's buildings"
  on "public"."buildings"
  as permissive
  for all
  to public
using ((organization_id IN ( SELECT profiles.organization_id
   FROM public.profiles
  WHERE (profiles.id = auth.uid()))));



