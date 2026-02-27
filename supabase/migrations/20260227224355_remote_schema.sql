drop extension if exists "pg_net";


  create table "public"."base_compliance_standard" (
    "id" uuid not null default gen_random_uuid(),
    "standard_code" character varying(50) not null,
    "standard_name" text not null,
    "default_frequency" jsonb not null,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."base_compliance_standard" enable row level security;


  create table "public"."base_main_category" (
    "id" uuid not null default gen_random_uuid(),
    "code" character varying(10) not null,
    "name" text not null,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."base_main_category" enable row level security;


  create table "public"."base_sub_category" (
    "id" uuid not null default gen_random_uuid(),
    "main_category_id" uuid not null,
    "ss_code" character varying(10) not null,
    "name" text not null,
    "default_standard_id" uuid,
    "aliases" text[] default '{}'::text[],
    "created_at" timestamp with time zone default now()
      );


alter table "public"."base_sub_category" enable row level security;


  create table "public"."building_compliance_baseline" (
    "id" uuid not null default gen_random_uuid(),
    "building_id" uuid not null,
    "ss_sub_category_id" uuid not null,
    "specific_standard_id" uuid,
    "is_active" boolean default true,
    "effective_from" date default CURRENT_DATE,
    "amendment_reason" text,
    "remarks" text,
    "last_updated_at" timestamp with time zone default now(),
    "created_at" timestamp with time zone default now()
      );


alter table "public"."building_compliance_baseline" enable row level security;


  create table "public"."building_compliance_component" (
    "id" uuid not null default gen_random_uuid(),
    "baseline_id" uuid not null,
    "component_name" text not null,
    "required_frequency" jsonb not null,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."building_compliance_component" enable row level security;


  create table "public"."buildings" (
    "id" uuid not null default gen_random_uuid(),
    "organization_id" uuid,
    "name" text not null,
    "address" text not null,
    "compliance_rules" jsonb default '[]'::jsonb,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."buildings" enable row level security;


  create table "public"."evidence_slots" (
    "id" uuid not null default gen_random_uuid(),
    "ss_id" uuid,
    "target_month" date not null,
    "status" text default 'Missing'::text,
    "file_id" uuid,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."evidence_slots" enable row level security;


  create table "public"."files" (
    "id" uuid not null default gen_random_uuid(),
    "building_id" uuid,
    "storage_path" text not null,
    "captured_at" timestamp with time zone not null,
    "synced_at" timestamp with time zone default now()
      );



  create table "public"."organizations" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "created_at" timestamp with time zone default now()
      );



  create table "public"."profiles" (
    "id" uuid not null,
    "organization_id" uuid,
    "full_name" text,
    "role" text,
    "created_at" timestamp with time zone default now()
      );



  create table "public"."specified_systems" (
    "id" uuid not null default gen_random_uuid(),
    "building_id" uuid,
    "ss_code" text not null,
    "name" text,
    "frequency" text,
    "is_custom_ss" boolean default false,
    "created_at" timestamp with time zone default now()
      );


alter table "public"."specified_systems" enable row level security;

CREATE UNIQUE INDEX base_compliance_standard_pkey ON public.base_compliance_standard USING btree (id);

CREATE UNIQUE INDEX base_compliance_standard_standard_code_key ON public.base_compliance_standard USING btree (standard_code);

CREATE UNIQUE INDEX base_main_category_code_key ON public.base_main_category USING btree (code);

CREATE UNIQUE INDEX base_main_category_pkey ON public.base_main_category USING btree (id);

CREATE UNIQUE INDEX base_sub_category_pkey ON public.base_sub_category USING btree (id);

CREATE UNIQUE INDEX base_sub_category_ss_code_key ON public.base_sub_category USING btree (ss_code);

CREATE UNIQUE INDEX building_compliance_baseline_building_id_ss_sub_category_id_key ON public.building_compliance_baseline USING btree (building_id, ss_sub_category_id, is_active);

CREATE UNIQUE INDEX building_compliance_baseline_pkey ON public.building_compliance_baseline USING btree (id);

CREATE UNIQUE INDEX building_compliance_component_pkey ON public.building_compliance_component USING btree (id);

CREATE UNIQUE INDEX buildings_pkey ON public.buildings USING btree (id);

CREATE UNIQUE INDEX evidence_slots_pkey ON public.evidence_slots USING btree (id);

CREATE UNIQUE INDEX files_pkey ON public.files USING btree (id);

CREATE UNIQUE INDEX organizations_pkey ON public.organizations USING btree (id);

CREATE UNIQUE INDEX profiles_pkey ON public.profiles USING btree (id);

CREATE UNIQUE INDEX specified_systems_pkey ON public.specified_systems USING btree (id);

alter table "public"."base_compliance_standard" add constraint "base_compliance_standard_pkey" PRIMARY KEY using index "base_compliance_standard_pkey";

alter table "public"."base_main_category" add constraint "base_main_category_pkey" PRIMARY KEY using index "base_main_category_pkey";

alter table "public"."base_sub_category" add constraint "base_sub_category_pkey" PRIMARY KEY using index "base_sub_category_pkey";

alter table "public"."building_compliance_baseline" add constraint "building_compliance_baseline_pkey" PRIMARY KEY using index "building_compliance_baseline_pkey";

alter table "public"."building_compliance_component" add constraint "building_compliance_component_pkey" PRIMARY KEY using index "building_compliance_component_pkey";

alter table "public"."buildings" add constraint "buildings_pkey" PRIMARY KEY using index "buildings_pkey";

alter table "public"."evidence_slots" add constraint "evidence_slots_pkey" PRIMARY KEY using index "evidence_slots_pkey";

alter table "public"."files" add constraint "files_pkey" PRIMARY KEY using index "files_pkey";

alter table "public"."organizations" add constraint "organizations_pkey" PRIMARY KEY using index "organizations_pkey";

alter table "public"."profiles" add constraint "profiles_pkey" PRIMARY KEY using index "profiles_pkey";

alter table "public"."specified_systems" add constraint "specified_systems_pkey" PRIMARY KEY using index "specified_systems_pkey";

alter table "public"."base_compliance_standard" add constraint "base_compliance_standard_standard_code_key" UNIQUE using index "base_compliance_standard_standard_code_key";

alter table "public"."base_main_category" add constraint "base_main_category_code_key" UNIQUE using index "base_main_category_code_key";

alter table "public"."base_sub_category" add constraint "base_sub_category_default_standard_id_fkey" FOREIGN KEY (default_standard_id) REFERENCES public.base_compliance_standard(id) ON DELETE SET NULL not valid;

alter table "public"."base_sub_category" validate constraint "base_sub_category_default_standard_id_fkey";

alter table "public"."base_sub_category" add constraint "base_sub_category_main_category_id_fkey" FOREIGN KEY (main_category_id) REFERENCES public.base_main_category(id) ON DELETE RESTRICT not valid;

alter table "public"."base_sub_category" validate constraint "base_sub_category_main_category_id_fkey";

alter table "public"."base_sub_category" add constraint "base_sub_category_ss_code_key" UNIQUE using index "base_sub_category_ss_code_key";

alter table "public"."building_compliance_baseline" add constraint "building_compliance_baseline_building_id_ss_sub_category_id_key" UNIQUE using index "building_compliance_baseline_building_id_ss_sub_category_id_key";

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

alter table "public"."evidence_slots" add constraint "evidence_slots_status_check" CHECK ((status = ANY (ARRAY['Missing'::text, 'Verified'::text, 'Defect'::text]))) not valid;

alter table "public"."evidence_slots" validate constraint "evidence_slots_status_check";

alter table "public"."files" add constraint "files_building_id_fkey" FOREIGN KEY (building_id) REFERENCES public.buildings(id) ON DELETE CASCADE not valid;

alter table "public"."files" validate constraint "files_building_id_fkey";

alter table "public"."profiles" add constraint "profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."profiles" validate constraint "profiles_id_fkey";

alter table "public"."profiles" add constraint "profiles_organization_id_fkey" FOREIGN KEY (organization_id) REFERENCES public.organizations(id) not valid;

alter table "public"."profiles" validate constraint "profiles_organization_id_fkey";

alter table "public"."profiles" add constraint "profiles_role_check" CHECK ((role = ANY (ARRAY['Admin'::text, 'Owner'::text]))) not valid;

alter table "public"."profiles" validate constraint "profiles_role_check";

alter table "public"."specified_systems" add constraint "specified_systems_building_id_fkey" FOREIGN KEY (building_id) REFERENCES public.buildings(id) ON DELETE CASCADE not valid;

alter table "public"."specified_systems" validate constraint "specified_systems_building_id_fkey";

grant delete on table "public"."base_compliance_standard" to "anon";

grant insert on table "public"."base_compliance_standard" to "anon";

grant references on table "public"."base_compliance_standard" to "anon";

grant select on table "public"."base_compliance_standard" to "anon";

grant trigger on table "public"."base_compliance_standard" to "anon";

grant truncate on table "public"."base_compliance_standard" to "anon";

grant update on table "public"."base_compliance_standard" to "anon";

grant delete on table "public"."base_compliance_standard" to "authenticated";

grant insert on table "public"."base_compliance_standard" to "authenticated";

grant references on table "public"."base_compliance_standard" to "authenticated";

grant select on table "public"."base_compliance_standard" to "authenticated";

grant trigger on table "public"."base_compliance_standard" to "authenticated";

grant truncate on table "public"."base_compliance_standard" to "authenticated";

grant update on table "public"."base_compliance_standard" to "authenticated";

grant delete on table "public"."base_compliance_standard" to "service_role";

grant insert on table "public"."base_compliance_standard" to "service_role";

grant references on table "public"."base_compliance_standard" to "service_role";

grant select on table "public"."base_compliance_standard" to "service_role";

grant trigger on table "public"."base_compliance_standard" to "service_role";

grant truncate on table "public"."base_compliance_standard" to "service_role";

grant update on table "public"."base_compliance_standard" to "service_role";

grant delete on table "public"."base_main_category" to "anon";

grant insert on table "public"."base_main_category" to "anon";

grant references on table "public"."base_main_category" to "anon";

grant select on table "public"."base_main_category" to "anon";

grant trigger on table "public"."base_main_category" to "anon";

grant truncate on table "public"."base_main_category" to "anon";

grant update on table "public"."base_main_category" to "anon";

grant delete on table "public"."base_main_category" to "authenticated";

grant insert on table "public"."base_main_category" to "authenticated";

grant references on table "public"."base_main_category" to "authenticated";

grant select on table "public"."base_main_category" to "authenticated";

grant trigger on table "public"."base_main_category" to "authenticated";

grant truncate on table "public"."base_main_category" to "authenticated";

grant update on table "public"."base_main_category" to "authenticated";

grant delete on table "public"."base_main_category" to "service_role";

grant insert on table "public"."base_main_category" to "service_role";

grant references on table "public"."base_main_category" to "service_role";

grant select on table "public"."base_main_category" to "service_role";

grant trigger on table "public"."base_main_category" to "service_role";

grant truncate on table "public"."base_main_category" to "service_role";

grant update on table "public"."base_main_category" to "service_role";

grant delete on table "public"."base_sub_category" to "anon";

grant insert on table "public"."base_sub_category" to "anon";

grant references on table "public"."base_sub_category" to "anon";

grant select on table "public"."base_sub_category" to "anon";

grant trigger on table "public"."base_sub_category" to "anon";

grant truncate on table "public"."base_sub_category" to "anon";

grant update on table "public"."base_sub_category" to "anon";

grant delete on table "public"."base_sub_category" to "authenticated";

grant insert on table "public"."base_sub_category" to "authenticated";

grant references on table "public"."base_sub_category" to "authenticated";

grant select on table "public"."base_sub_category" to "authenticated";

grant trigger on table "public"."base_sub_category" to "authenticated";

grant truncate on table "public"."base_sub_category" to "authenticated";

grant update on table "public"."base_sub_category" to "authenticated";

grant delete on table "public"."base_sub_category" to "service_role";

grant insert on table "public"."base_sub_category" to "service_role";

grant references on table "public"."base_sub_category" to "service_role";

grant select on table "public"."base_sub_category" to "service_role";

grant trigger on table "public"."base_sub_category" to "service_role";

grant truncate on table "public"."base_sub_category" to "service_role";

grant update on table "public"."base_sub_category" to "service_role";

grant delete on table "public"."building_compliance_baseline" to "anon";

grant insert on table "public"."building_compliance_baseline" to "anon";

grant references on table "public"."building_compliance_baseline" to "anon";

grant select on table "public"."building_compliance_baseline" to "anon";

grant trigger on table "public"."building_compliance_baseline" to "anon";

grant truncate on table "public"."building_compliance_baseline" to "anon";

grant update on table "public"."building_compliance_baseline" to "anon";

grant delete on table "public"."building_compliance_baseline" to "authenticated";

grant insert on table "public"."building_compliance_baseline" to "authenticated";

grant references on table "public"."building_compliance_baseline" to "authenticated";

grant select on table "public"."building_compliance_baseline" to "authenticated";

grant trigger on table "public"."building_compliance_baseline" to "authenticated";

grant truncate on table "public"."building_compliance_baseline" to "authenticated";

grant update on table "public"."building_compliance_baseline" to "authenticated";

grant delete on table "public"."building_compliance_baseline" to "service_role";

grant insert on table "public"."building_compliance_baseline" to "service_role";

grant references on table "public"."building_compliance_baseline" to "service_role";

grant select on table "public"."building_compliance_baseline" to "service_role";

grant trigger on table "public"."building_compliance_baseline" to "service_role";

grant truncate on table "public"."building_compliance_baseline" to "service_role";

grant update on table "public"."building_compliance_baseline" to "service_role";

grant delete on table "public"."building_compliance_component" to "anon";

grant insert on table "public"."building_compliance_component" to "anon";

grant references on table "public"."building_compliance_component" to "anon";

grant select on table "public"."building_compliance_component" to "anon";

grant trigger on table "public"."building_compliance_component" to "anon";

grant truncate on table "public"."building_compliance_component" to "anon";

grant update on table "public"."building_compliance_component" to "anon";

grant delete on table "public"."building_compliance_component" to "authenticated";

grant insert on table "public"."building_compliance_component" to "authenticated";

grant references on table "public"."building_compliance_component" to "authenticated";

grant select on table "public"."building_compliance_component" to "authenticated";

grant trigger on table "public"."building_compliance_component" to "authenticated";

grant truncate on table "public"."building_compliance_component" to "authenticated";

grant update on table "public"."building_compliance_component" to "authenticated";

grant delete on table "public"."building_compliance_component" to "service_role";

grant insert on table "public"."building_compliance_component" to "service_role";

grant references on table "public"."building_compliance_component" to "service_role";

grant select on table "public"."building_compliance_component" to "service_role";

grant trigger on table "public"."building_compliance_component" to "service_role";

grant truncate on table "public"."building_compliance_component" to "service_role";

grant update on table "public"."building_compliance_component" to "service_role";

grant delete on table "public"."buildings" to "anon";

grant insert on table "public"."buildings" to "anon";

grant references on table "public"."buildings" to "anon";

grant select on table "public"."buildings" to "anon";

grant trigger on table "public"."buildings" to "anon";

grant truncate on table "public"."buildings" to "anon";

grant update on table "public"."buildings" to "anon";

grant delete on table "public"."buildings" to "authenticated";

grant insert on table "public"."buildings" to "authenticated";

grant references on table "public"."buildings" to "authenticated";

grant select on table "public"."buildings" to "authenticated";

grant trigger on table "public"."buildings" to "authenticated";

grant truncate on table "public"."buildings" to "authenticated";

grant update on table "public"."buildings" to "authenticated";

grant delete on table "public"."buildings" to "service_role";

grant insert on table "public"."buildings" to "service_role";

grant references on table "public"."buildings" to "service_role";

grant select on table "public"."buildings" to "service_role";

grant trigger on table "public"."buildings" to "service_role";

grant truncate on table "public"."buildings" to "service_role";

grant update on table "public"."buildings" to "service_role";

grant delete on table "public"."evidence_slots" to "anon";

grant insert on table "public"."evidence_slots" to "anon";

grant references on table "public"."evidence_slots" to "anon";

grant select on table "public"."evidence_slots" to "anon";

grant trigger on table "public"."evidence_slots" to "anon";

grant truncate on table "public"."evidence_slots" to "anon";

grant update on table "public"."evidence_slots" to "anon";

grant delete on table "public"."evidence_slots" to "authenticated";

grant insert on table "public"."evidence_slots" to "authenticated";

grant references on table "public"."evidence_slots" to "authenticated";

grant select on table "public"."evidence_slots" to "authenticated";

grant trigger on table "public"."evidence_slots" to "authenticated";

grant truncate on table "public"."evidence_slots" to "authenticated";

grant update on table "public"."evidence_slots" to "authenticated";

grant delete on table "public"."evidence_slots" to "service_role";

grant insert on table "public"."evidence_slots" to "service_role";

grant references on table "public"."evidence_slots" to "service_role";

grant select on table "public"."evidence_slots" to "service_role";

grant trigger on table "public"."evidence_slots" to "service_role";

grant truncate on table "public"."evidence_slots" to "service_role";

grant update on table "public"."evidence_slots" to "service_role";

grant delete on table "public"."files" to "anon";

grant insert on table "public"."files" to "anon";

grant references on table "public"."files" to "anon";

grant select on table "public"."files" to "anon";

grant trigger on table "public"."files" to "anon";

grant truncate on table "public"."files" to "anon";

grant update on table "public"."files" to "anon";

grant delete on table "public"."files" to "authenticated";

grant insert on table "public"."files" to "authenticated";

grant references on table "public"."files" to "authenticated";

grant select on table "public"."files" to "authenticated";

grant trigger on table "public"."files" to "authenticated";

grant truncate on table "public"."files" to "authenticated";

grant update on table "public"."files" to "authenticated";

grant delete on table "public"."files" to "service_role";

grant insert on table "public"."files" to "service_role";

grant references on table "public"."files" to "service_role";

grant select on table "public"."files" to "service_role";

grant trigger on table "public"."files" to "service_role";

grant truncate on table "public"."files" to "service_role";

grant update on table "public"."files" to "service_role";

grant delete on table "public"."organizations" to "anon";

grant insert on table "public"."organizations" to "anon";

grant references on table "public"."organizations" to "anon";

grant select on table "public"."organizations" to "anon";

grant trigger on table "public"."organizations" to "anon";

grant truncate on table "public"."organizations" to "anon";

grant update on table "public"."organizations" to "anon";

grant delete on table "public"."organizations" to "authenticated";

grant insert on table "public"."organizations" to "authenticated";

grant references on table "public"."organizations" to "authenticated";

grant select on table "public"."organizations" to "authenticated";

grant trigger on table "public"."organizations" to "authenticated";

grant truncate on table "public"."organizations" to "authenticated";

grant update on table "public"."organizations" to "authenticated";

grant delete on table "public"."organizations" to "service_role";

grant insert on table "public"."organizations" to "service_role";

grant references on table "public"."organizations" to "service_role";

grant select on table "public"."organizations" to "service_role";

grant trigger on table "public"."organizations" to "service_role";

grant truncate on table "public"."organizations" to "service_role";

grant update on table "public"."organizations" to "service_role";

grant delete on table "public"."profiles" to "anon";

grant insert on table "public"."profiles" to "anon";

grant references on table "public"."profiles" to "anon";

grant select on table "public"."profiles" to "anon";

grant trigger on table "public"."profiles" to "anon";

grant truncate on table "public"."profiles" to "anon";

grant update on table "public"."profiles" to "anon";

grant delete on table "public"."profiles" to "authenticated";

grant insert on table "public"."profiles" to "authenticated";

grant references on table "public"."profiles" to "authenticated";

grant select on table "public"."profiles" to "authenticated";

grant trigger on table "public"."profiles" to "authenticated";

grant truncate on table "public"."profiles" to "authenticated";

grant update on table "public"."profiles" to "authenticated";

grant delete on table "public"."profiles" to "service_role";

grant insert on table "public"."profiles" to "service_role";

grant references on table "public"."profiles" to "service_role";

grant select on table "public"."profiles" to "service_role";

grant trigger on table "public"."profiles" to "service_role";

grant truncate on table "public"."profiles" to "service_role";

grant update on table "public"."profiles" to "service_role";

grant delete on table "public"."specified_systems" to "anon";

grant insert on table "public"."specified_systems" to "anon";

grant references on table "public"."specified_systems" to "anon";

grant select on table "public"."specified_systems" to "anon";

grant trigger on table "public"."specified_systems" to "anon";

grant truncate on table "public"."specified_systems" to "anon";

grant update on table "public"."specified_systems" to "anon";

grant delete on table "public"."specified_systems" to "authenticated";

grant insert on table "public"."specified_systems" to "authenticated";

grant references on table "public"."specified_systems" to "authenticated";

grant select on table "public"."specified_systems" to "authenticated";

grant trigger on table "public"."specified_systems" to "authenticated";

grant truncate on table "public"."specified_systems" to "authenticated";

grant update on table "public"."specified_systems" to "authenticated";

grant delete on table "public"."specified_systems" to "service_role";

grant insert on table "public"."specified_systems" to "service_role";

grant references on table "public"."specified_systems" to "service_role";

grant select on table "public"."specified_systems" to "service_role";

grant trigger on table "public"."specified_systems" to "service_role";

grant truncate on table "public"."specified_systems" to "service_role";

grant update on table "public"."specified_systems" to "service_role";


  create policy "Public standards read access"
  on "public"."base_compliance_standard"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Public dictionary read access"
  on "public"."base_main_category"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Public sub_category read access"
  on "public"."base_sub_category"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Auth user read access on baseline"
  on "public"."building_compliance_baseline"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Auth user read access on components"
  on "public"."building_compliance_component"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Users can only view their own organization's buildings"
  on "public"."buildings"
  as permissive
  for all
  to public
using ((organization_id IN ( SELECT profiles.organization_id
   FROM public.profiles
  WHERE (profiles.id = auth.uid()))));



