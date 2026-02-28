export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.1"
  }
  public: {
    Tables: {
      base_compliance_standard: {
        Row: {
          created_at: string | null
          default_frequency: Json
          id: string
          standard_code: string
          standard_name: string
          version: string | null
        }
        Insert: {
          created_at?: string | null
          default_frequency: Json
          id?: string
          standard_code: string
          standard_name: string
          version?: string | null
        }
        Update: {
          created_at?: string | null
          default_frequency?: Json
          id?: string
          standard_code?: string
          standard_name?: string
          version?: string | null
        }
        Relationships: []
      }
      base_main_category: {
        Row: {
          code: string
          created_at: string | null
          id: string
          name: string
        }
        Insert: {
          code: string
          created_at?: string | null
          id?: string
          name: string
        }
        Update: {
          code?: string
          created_at?: string | null
          id?: string
          name?: string
        }
        Relationships: []
      }
      base_sub_category: {
        Row: {
          aliases: string[] | null
          created_at: string | null
          default_standard_id: string | null
          id: string
          main_category_id: string
          name: string
          ss_code: string
        }
        Insert: {
          aliases?: string[] | null
          created_at?: string | null
          default_standard_id?: string | null
          id?: string
          main_category_id: string
          name: string
          ss_code: string
        }
        Update: {
          aliases?: string[] | null
          created_at?: string | null
          default_standard_id?: string | null
          id?: string
          main_category_id?: string
          name?: string
          ss_code?: string
        }
        Relationships: [
          {
            foreignKeyName: "base_sub_category_default_standard_id_fkey"
            columns: ["default_standard_id"]
            isOneToOne: false
            referencedRelation: "base_compliance_standard"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "base_sub_category_main_category_id_fkey"
            columns: ["main_category_id"]
            isOneToOne: false
            referencedRelation: "base_main_category"
            referencedColumns: ["id"]
          },
        ]
      }
      building_compliance_baseline: {
        Row: {
          amendment_reason: string | null
          building_id: string
          created_at: string | null
          effective_from: string | null
          id: string
          is_active: boolean | null
          last_updated_at: string | null
          remarks: string | null
          specific_standard_id: string | null
          ss_sub_category_id: string
        }
        Insert: {
          amendment_reason?: string | null
          building_id: string
          created_at?: string | null
          effective_from?: string | null
          id?: string
          is_active?: boolean | null
          last_updated_at?: string | null
          remarks?: string | null
          specific_standard_id?: string | null
          ss_sub_category_id: string
        }
        Update: {
          amendment_reason?: string | null
          building_id?: string
          created_at?: string | null
          effective_from?: string | null
          id?: string
          is_active?: boolean | null
          last_updated_at?: string | null
          remarks?: string | null
          specific_standard_id?: string | null
          ss_sub_category_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "building_compliance_baseline_specific_standard_id_fkey"
            columns: ["specific_standard_id"]
            isOneToOne: false
            referencedRelation: "base_compliance_standard"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "building_compliance_baseline_ss_sub_category_id_fkey"
            columns: ["ss_sub_category_id"]
            isOneToOne: false
            referencedRelation: "base_sub_category"
            referencedColumns: ["id"]
          },
        ]
      }
      building_compliance_component: {
        Row: {
          baseline_id: string
          component_name: string
          created_at: string | null
          id: string
          is_active: boolean | null
          required_frequency: Json
        }
        Insert: {
          baseline_id: string
          component_name: string
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          required_frequency: Json
        }
        Update: {
          baseline_id?: string
          component_name?: string
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          required_frequency?: Json
        }
        Relationships: [
          {
            foreignKeyName: "building_compliance_component_baseline_id_fkey"
            columns: ["baseline_id"]
            isOneToOne: false
            referencedRelation: "building_compliance_baseline"
            referencedColumns: ["id"]
          },
        ]
      }
      buildings: {
        Row: {
          address: string
          compliance_rules: Json | null
          created_at: string | null
          id: string
          name: string
          organization_id: string | null
        }
        Insert: {
          address: string
          compliance_rules?: Json | null
          created_at?: string | null
          id?: string
          name: string
          organization_id?: string | null
        }
        Update: {
          address?: string
          compliance_rules?: Json | null
          created_at?: string | null
          id?: string
          name?: string
          organization_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "buildings_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      evidence_slots: {
        Row: {
          created_at: string | null
          file_id: string | null
          id: string
          ss_id: string | null
          status: string | null
          target_month: string
        }
        Insert: {
          created_at?: string | null
          file_id?: string | null
          id?: string
          ss_id?: string | null
          status?: string | null
          target_month: string
        }
        Update: {
          created_at?: string | null
          file_id?: string | null
          id?: string
          ss_id?: string | null
          status?: string | null
          target_month?: string
        }
        Relationships: [
          {
            foreignKeyName: "evidence_slots_file_id_fkey"
            columns: ["file_id"]
            isOneToOne: false
            referencedRelation: "files"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "evidence_slots_ss_id_fkey"
            columns: ["ss_id"]
            isOneToOne: false
            referencedRelation: "specified_systems"
            referencedColumns: ["id"]
          },
        ]
      }
      files: {
        Row: {
          building_id: string | null
          captured_at: string
          id: string
          storage_path: string
          synced_at: string | null
        }
        Insert: {
          building_id?: string | null
          captured_at: string
          id?: string
          storage_path: string
          synced_at?: string | null
        }
        Update: {
          building_id?: string | null
          captured_at?: string
          id?: string
          storage_path?: string
          synced_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "files_building_id_fkey"
            columns: ["building_id"]
            isOneToOne: false
            referencedRelation: "buildings"
            referencedColumns: ["id"]
          },
        ]
      }
      organizations: {
        Row: {
          created_at: string | null
          id: string
          name: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          name: string
        }
        Update: {
          created_at?: string | null
          id?: string
          name?: string
        }
        Relationships: []
      }
      profiles: {
        Row: {
          created_at: string | null
          full_name: string | null
          id: string
          organization_id: string | null
          role: string | null
        }
        Insert: {
          created_at?: string | null
          full_name?: string | null
          id: string
          organization_id?: string | null
          role?: string | null
        }
        Update: {
          created_at?: string | null
          full_name?: string | null
          id?: string
          organization_id?: string | null
          role?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "profiles_organization_id_fkey"
            columns: ["organization_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      specified_systems: {
        Row: {
          building_id: string | null
          created_at: string | null
          frequency: string | null
          id: string
          is_custom_ss: boolean | null
          name: string | null
          ss_code: string
        }
        Insert: {
          building_id?: string | null
          created_at?: string | null
          frequency?: string | null
          id?: string
          is_custom_ss?: boolean | null
          name?: string | null
          ss_code: string
        }
        Update: {
          building_id?: string | null
          created_at?: string | null
          frequency?: string | null
          id?: string
          is_custom_ss?: boolean | null
          name?: string | null
          ss_code?: string
        }
        Relationships: [
          {
            foreignKeyName: "specified_systems_building_id_fkey"
            columns: ["building_id"]
            isOneToOne: false
            referencedRelation: "buildings"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
