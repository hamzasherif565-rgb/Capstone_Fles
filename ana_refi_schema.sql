-- ANA REFI database schema generated from Complete_ERD.mmd.
-- Target: PostgreSQL, run this file with psql (psql -f ana_refi_schema.sql).
-- The source ERD omits enum labels, defaults, checks, indexes, and FK actions.
-- Named enum-like ERD types are represented as TEXT-based domains because their
-- allowed values are not present in the ERD; no values or rows are invented.
-- No defaults or constraints beyond ERD-declared PK/UK/FK/NULL are added.

\set ON_ERROR_STOP on
SELECT 'CREATE DATABASE "ANA REFI"' WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'ANA REFI')\gexec
\connect "ANA REFI"

CREATE SCHEMA IF NOT EXISTS "auth";
CREATE SCHEMA IF NOT EXISTS "storage";
CREATE SCHEMA IF NOT EXISTS "vault";
CREATE SCHEMA IF NOT EXISTS "supabase_migrations";

-- ERD enum type labels are unavailable; preserve the named types as text domains.
CREATE DOMAIN "auth"."auth_aal_level" AS TEXT;
CREATE DOMAIN "auth"."auth_code_challenge_method" AS TEXT;
CREATE DOMAIN "auth"."auth_factor_status" AS TEXT;
CREATE DOMAIN "auth"."auth_factor_type" AS TEXT;
CREATE DOMAIN "auth"."auth_oauth_authorization_status" AS TEXT;
CREATE DOMAIN "auth"."auth_oauth_client_type" AS TEXT;
CREATE DOMAIN "auth"."auth_oauth_registration_type" AS TEXT;
CREATE DOMAIN "auth"."auth_oauth_response_type" AS TEXT;
CREATE DOMAIN "auth"."auth_one_time_token_type" AS TEXT;
CREATE DOMAIN "public"."app_role" AS TEXT;
CREATE DOMAIN "public"."booking_status" AS TEXT;
CREATE DOMAIN "public"."competition_status" AS TEXT;
CREATE DOMAIN "public"."item_type" AS TEXT;
CREATE DOMAIN "public"."notification_type" AS TEXT;
CREATE DOMAIN "storage"."storage_buckettype" AS TEXT;

CREATE TABLE "auth"."audit_log_entries" (
    "instance_id" UUID,
    "id" UUID NOT NULL,
    "payload" JSON,
    "created_at" TIMESTAMP WITH TIME ZONE,
    "ip_address" VARCHAR(64) NOT NULL,
    CONSTRAINT "pk_audit_log_entries" PRIMARY KEY ("id")
);

CREATE TABLE "auth"."custom_oauth_providers" (
    "id" UUID NOT NULL,
    "provider_type" TEXT NOT NULL,
    "identifier" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "client_id" TEXT NOT NULL,
    "client_secret" TEXT NOT NULL,
    "acceptable_client_ids" TEXT[] NOT NULL,
    "scopes" TEXT[] NOT NULL,
    "pkce_enabled" BOOLEAN NOT NULL,
    "attribute_mapping" JSONB NOT NULL,
    "authorization_params" JSONB NOT NULL,
    "enabled" BOOLEAN NOT NULL,
    "email_optional" BOOLEAN NOT NULL,
    "issuer" TEXT,
    "discovery_url" TEXT,
    "skip_nonce_check" BOOLEAN NOT NULL,
    "cached_discovery" JSONB,
    "discovery_cached_at" TIMESTAMP WITH TIME ZONE,
    "authorization_url" TEXT,
    "token_url" TEXT,
    "userinfo_url" TEXT,
    "jwks_uri" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "custom_claims_allowlist" TEXT[] NOT NULL,
    CONSTRAINT "pk_custom_oauth_providers" PRIMARY KEY ("id"),
    CONSTRAINT "uq_01" UNIQUE ("identifier")
);

CREATE TABLE "auth"."flow_state" (
    "id" UUID NOT NULL,
    "user_id" UUID,
    "auth_code" TEXT,
    "code_challenge_method" "auth"."auth_code_challenge_method",
    "code_challenge" TEXT,
    "provider_type" TEXT NOT NULL,
    "provider_access_token" TEXT,
    "provider_refresh_token" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE,
    "updated_at" TIMESTAMP WITH TIME ZONE,
    "authentication_method" TEXT NOT NULL,
    "auth_code_issued_at" TIMESTAMP WITH TIME ZONE,
    "invite_token" TEXT,
    "referrer" TEXT,
    "oauth_client_state_id" UUID,
    "linking_target_id" UUID,
    "email_optional" BOOLEAN NOT NULL,
    CONSTRAINT "pk_flow_state" PRIMARY KEY ("id")
);

CREATE TABLE "auth"."instances" (
    "id" UUID NOT NULL,
    "uuid" UUID,
    "raw_base_config" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE,
    "updated_at" TIMESTAMP WITH TIME ZONE,
    CONSTRAINT "pk_instances" PRIMARY KEY ("id")
);

CREATE TABLE "auth"."oauth_client_states" (
    "id" UUID NOT NULL,
    "provider_type" TEXT NOT NULL,
    "code_verifier" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT "pk_oauth_client_states" PRIMARY KEY ("id")
);

CREATE TABLE "auth"."oauth_clients" (
    "id" UUID NOT NULL,
    "client_secret_hash" TEXT,
    "registration_type" "auth"."auth_oauth_registration_type" NOT NULL,
    "redirect_uris" TEXT NOT NULL,
    "grant_types" TEXT NOT NULL,
    "client_name" TEXT,
    "client_uri" TEXT,
    "logo_uri" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "deleted_at" TIMESTAMP WITH TIME ZONE,
    "client_type" "auth"."auth_oauth_client_type" NOT NULL,
    "token_endpoint_auth_method" TEXT NOT NULL,
    CONSTRAINT "pk_oauth_clients" PRIMARY KEY ("id")
);

CREATE TABLE "auth"."schema_migrations" (
    "version" VARCHAR(255) NOT NULL,
    CONSTRAINT "pk_schema_migrations" PRIMARY KEY ("version")
);

CREATE TABLE "auth"."sso_providers" (
    "id" UUID NOT NULL,
    "resource_id" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE,
    "updated_at" TIMESTAMP WITH TIME ZONE,
    "disabled" BOOLEAN,
    CONSTRAINT "pk_sso_providers" PRIMARY KEY ("id")
);

CREATE TABLE "auth"."users" (
    "instance_id" UUID,
    "id" UUID NOT NULL,
    "aud" VARCHAR(255),
    "role" VARCHAR(255),
    "email" VARCHAR(255),
    "encrypted_password" VARCHAR(255),
    "email_confirmed_at" TIMESTAMP WITH TIME ZONE,
    "invited_at" TIMESTAMP WITH TIME ZONE,
    "confirmation_token" VARCHAR(255),
    "confirmation_sent_at" TIMESTAMP WITH TIME ZONE,
    "recovery_token" VARCHAR(255),
    "recovery_sent_at" TIMESTAMP WITH TIME ZONE,
    "email_change_token_new" VARCHAR(255),
    "email_change" VARCHAR(255),
    "email_change_sent_at" TIMESTAMP WITH TIME ZONE,
    "last_sign_in_at" TIMESTAMP WITH TIME ZONE,
    "raw_app_meta_data" JSONB,
    "raw_user_meta_data" JSONB,
    "is_super_admin" BOOLEAN,
    "created_at" TIMESTAMP WITH TIME ZONE,
    "updated_at" TIMESTAMP WITH TIME ZONE,
    "phone" TEXT,
    "phone_confirmed_at" TIMESTAMP WITH TIME ZONE,
    "phone_change" TEXT,
    "phone_change_token" VARCHAR(255),
    "phone_change_sent_at" TIMESTAMP WITH TIME ZONE,
    "confirmed_at" TIMESTAMP WITH TIME ZONE,
    "email_change_token_current" VARCHAR(255),
    "email_change_confirm_status" SMALLINT,
    "banned_until" TIMESTAMP WITH TIME ZONE,
    "reauthentication_token" VARCHAR(255),
    "reauthentication_sent_at" TIMESTAMP WITH TIME ZONE,
    "is_sso_user" BOOLEAN NOT NULL,
    "deleted_at" TIMESTAMP WITH TIME ZONE,
    "is_anonymous" BOOLEAN NOT NULL,
    CONSTRAINT "pk_users" PRIMARY KEY ("id"),
    CONSTRAINT "uq_01" UNIQUE ("phone")
);

CREATE TABLE "public"."contact_messages" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT "pk_contact_messages" PRIMARY KEY ("id")
);

CREATE TABLE "public"."volunteer_requests" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "full_name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "interest_area" TEXT NOT NULL,
    "availability" TEXT NOT NULL,
    "motivation" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "age" INTEGER,
    "avatar_url" TEXT,
    "bio" TEXT,
    "location" TEXT,
    "skills" TEXT[] NOT NULL,
    "languages" TEXT[] NOT NULL,
    "experience" TEXT,
    "accessibility" TEXT,
    "rating" NUMERIC(2,1),
    CONSTRAINT "pk_volunteer_requests" PRIMARY KEY ("id")
);

CREATE TABLE "storage"."buckets" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "owner" UUID,
    "created_at" TIMESTAMP WITH TIME ZONE,
    "updated_at" TIMESTAMP WITH TIME ZONE,
    "public" BOOLEAN,
    "avif_autodetection" BOOLEAN,
    "file_size_limit" BIGINT,
    "allowed_mime_types" TEXT[],
    "owner_id" TEXT,
    "type" "storage"."storage_buckettype" NOT NULL,
    "versioning_status" TEXT NOT NULL,
    "lifecycle_configuration" JSONB,
    "lifecycle_configuration_generation" UUID,
    CONSTRAINT "pk_buckets" PRIMARY KEY ("id"),
    CONSTRAINT "uq_01" UNIQUE ("name")
);

CREATE TABLE "storage"."buckets_analytics" (
    "name" TEXT NOT NULL,
    "type" "storage"."storage_buckettype" NOT NULL,
    "format" TEXT NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "id" UUID NOT NULL,
    "deleted_at" TIMESTAMP WITH TIME ZONE,
    CONSTRAINT "pk_buckets_analytics" PRIMARY KEY ("id")
);

CREATE TABLE "storage"."buckets_vectors" (
    "id" TEXT NOT NULL,
    "type" "storage"."storage_buckettype" NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT "pk_buckets_vectors" PRIMARY KEY ("id")
);

CREATE TABLE "storage"."migrations" (
    "id" INTEGER NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "hash" VARCHAR(40) NOT NULL,
    "executed_at" TIMESTAMP WITHOUT TIME ZONE,
    CONSTRAINT "pk_migrations" PRIMARY KEY ("id"),
    CONSTRAINT "uq_01" UNIQUE ("name")
);

CREATE TABLE "supabase_migrations"."schema_migrations" (
    "version" TEXT NOT NULL,
    "statements" TEXT[],
    "name" TEXT,
    "created_by" TEXT,
    "idempotency_key" TEXT,
    "rollback" TEXT[],
    CONSTRAINT "pk_schema_migrations" PRIMARY KEY ("version"),
    CONSTRAINT "uq_01" UNIQUE ("idempotency_key")
);

CREATE TABLE "vault"."secrets" (
    "id" UUID NOT NULL,
    "name" TEXT,
    "description" TEXT NOT NULL,
    "secret" TEXT NOT NULL,
    "key_id" UUID,
    "nonce" BYTEA,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT "pk_secrets" PRIMARY KEY ("id")
);

CREATE TABLE "auth"."identities" (
    "provider_id" TEXT NOT NULL,
    "user_id" UUID NOT NULL,
    "identity_data" JSONB NOT NULL,
    "provider" TEXT NOT NULL,
    "last_sign_in_at" TIMESTAMP WITH TIME ZONE,
    "created_at" TIMESTAMP WITH TIME ZONE,
    "updated_at" TIMESTAMP WITH TIME ZONE,
    "email" TEXT,
    "id" UUID NOT NULL,
    CONSTRAINT "pk_identities" PRIMARY KEY ("id"),
    CONSTRAINT "uq_01" UNIQUE ("provider_id", "provider"),
    CONSTRAINT "fk_01" FOREIGN KEY ("user_id") REFERENCES "auth"."users" ("id")
);

CREATE TABLE "auth"."mfa_factors" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "friendly_name" TEXT,
    "factor_type" "auth"."auth_factor_type" NOT NULL,
    "status" "auth"."auth_factor_status" NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "secret" TEXT,
    "phone" TEXT,
    "last_challenged_at" TIMESTAMP WITH TIME ZONE,
    "web_authn_credential" JSONB,
    "web_authn_aaguid" UUID,
    "last_webauthn_challenge_data" JSONB,
    CONSTRAINT "pk_mfa_factors" PRIMARY KEY ("id"),
    CONSTRAINT "uq_01" UNIQUE ("last_challenged_at"),
    CONSTRAINT "fk_01" FOREIGN KEY ("user_id") REFERENCES "auth"."users" ("id")
);

CREATE TABLE "auth"."oauth_authorizations" (
    "id" UUID NOT NULL,
    "authorization_id" TEXT NOT NULL,
    "client_id" UUID NOT NULL,
    "user_id" UUID,
    "redirect_uri" TEXT NOT NULL,
    "scope" TEXT NOT NULL,
    "state" TEXT,
    "resource" TEXT,
    "code_challenge" TEXT,
    "code_challenge_method" "auth"."auth_code_challenge_method",
    "response_type" "auth"."auth_oauth_response_type" NOT NULL,
    "status" "auth"."auth_oauth_authorization_status" NOT NULL,
    "authorization_code" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "expires_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "approved_at" TIMESTAMP WITH TIME ZONE,
    "nonce" TEXT,
    CONSTRAINT "pk_oauth_authorizations" PRIMARY KEY ("id"),
    CONSTRAINT "uq_01" UNIQUE ("authorization_id"),
    CONSTRAINT "uq_02" UNIQUE ("authorization_code"),
    CONSTRAINT "fk_01" FOREIGN KEY ("client_id") REFERENCES "auth"."oauth_clients" ("id"),
    CONSTRAINT "fk_02" FOREIGN KEY ("user_id") REFERENCES "auth"."users" ("id")
);

CREATE TABLE "auth"."oauth_consents" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "client_id" UUID NOT NULL,
    "scopes" TEXT NOT NULL,
    "granted_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "revoked_at" TIMESTAMP WITH TIME ZONE,
    CONSTRAINT "pk_oauth_consents" PRIMARY KEY ("id"),
    CONSTRAINT "uq_01" UNIQUE ("user_id", "client_id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("client_id") REFERENCES "auth"."oauth_clients" ("id"),
    CONSTRAINT "fk_02" FOREIGN KEY ("user_id") REFERENCES "auth"."users" ("id")
);

CREATE TABLE "auth"."one_time_tokens" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "token_type" "auth"."auth_one_time_token_type" NOT NULL,
    "token_hash" TEXT NOT NULL,
    "relates_to" TEXT NOT NULL,
    "created_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    "expires_at" TIMESTAMP WITH TIME ZONE,
    CONSTRAINT "pk_one_time_tokens" PRIMARY KEY ("id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("user_id") REFERENCES "auth"."users" ("id")
);

CREATE TABLE "auth"."saml_providers" (
    "id" UUID NOT NULL,
    "sso_provider_id" UUID NOT NULL,
    "entity_id" TEXT NOT NULL,
    "metadata_xml" TEXT NOT NULL,
    "metadata_url" TEXT,
    "attribute_mapping" JSONB,
    "created_at" TIMESTAMP WITH TIME ZONE,
    "updated_at" TIMESTAMP WITH TIME ZONE,
    "name_id_format" TEXT,
    CONSTRAINT "pk_saml_providers" PRIMARY KEY ("id"),
    CONSTRAINT "uq_01" UNIQUE ("entity_id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers" ("id")
);

CREATE TABLE "auth"."saml_relay_states" (
    "id" UUID NOT NULL,
    "sso_provider_id" UUID NOT NULL,
    "request_id" TEXT NOT NULL,
    "for_email" TEXT,
    "redirect_to" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE,
    "updated_at" TIMESTAMP WITH TIME ZONE,
    "flow_state_id" UUID,
    CONSTRAINT "pk_saml_relay_states" PRIMARY KEY ("id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("flow_state_id") REFERENCES "auth"."flow_state" ("id"),
    CONSTRAINT "fk_02" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers" ("id")
);

CREATE TABLE "auth"."scim_tokens" (
    "id" UUID NOT NULL,
    "sso_provider_id" UUID NOT NULL,
    "token_hash" TEXT NOT NULL,
    "prefix" TEXT NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "expires_at" TIMESTAMP WITH TIME ZONE,
    "revoked_at" TIMESTAMP WITH TIME ZONE,
    "last_used_at" TIMESTAMP WITH TIME ZONE,
    CONSTRAINT "pk_scim_tokens" PRIMARY KEY ("id"),
    CONSTRAINT "uq_01" UNIQUE ("token_hash"),
    CONSTRAINT "fk_01" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers" ("id")
);

CREATE TABLE "auth"."scim_users" (
    "id" UUID NOT NULL,
    "sso_provider_id" UUID NOT NULL,
    "user_id" UUID,
    "resource" JSONB NOT NULL,
    "user_name" TEXT NOT NULL,
    "external_id" TEXT,
    "active" BOOLEAN NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "deleted_at" TIMESTAMP WITH TIME ZONE,
    CONSTRAINT "pk_scim_users" PRIMARY KEY ("id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers" ("id"),
    CONSTRAINT "fk_02" FOREIGN KEY ("user_id") REFERENCES "auth"."users" ("id")
);

CREATE TABLE "auth"."sessions" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE,
    "updated_at" TIMESTAMP WITH TIME ZONE,
    "factor_id" UUID,
    "aal" "auth"."auth_aal_level",
    "not_after" TIMESTAMP WITH TIME ZONE,
    "refreshed_at" TIMESTAMP WITHOUT TIME ZONE,
    "user_agent" TEXT,
    "ip" INET,
    "tag" TEXT,
    "oauth_client_id" UUID,
    "refresh_token_hmac_key" TEXT,
    "refresh_token_counter" BIGINT,
    "scopes" TEXT,
    CONSTRAINT "pk_sessions" PRIMARY KEY ("id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("oauth_client_id") REFERENCES "auth"."oauth_clients" ("id"),
    CONSTRAINT "fk_02" FOREIGN KEY ("user_id") REFERENCES "auth"."users" ("id")
);

CREATE TABLE "auth"."sso_domains" (
    "id" UUID NOT NULL,
    "sso_provider_id" UUID NOT NULL,
    "domain" TEXT NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE,
    "updated_at" TIMESTAMP WITH TIME ZONE,
    CONSTRAINT "pk_sso_domains" PRIMARY KEY ("id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers" ("id")
);

CREATE TABLE "auth"."webauthn_challenges" (
    "id" UUID NOT NULL,
    "user_id" UUID,
    "challenge_type" TEXT NOT NULL,
    "session_data" JSONB NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "expires_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT "pk_webauthn_challenges" PRIMARY KEY ("id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("user_id") REFERENCES "auth"."users" ("id")
);

CREATE TABLE "auth"."webauthn_credentials" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "credential_id" BYTEA NOT NULL,
    "public_key" BYTEA NOT NULL,
    "attestation_type" TEXT NOT NULL,
    "aaguid" UUID,
    "sign_count" BIGINT NOT NULL,
    "transports" JSONB NOT NULL,
    "backup_eligible" BOOLEAN NOT NULL,
    "backed_up" BOOLEAN NOT NULL,
    "friendly_name" TEXT NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "last_used_at" TIMESTAMP WITH TIME ZONE,
    CONSTRAINT "pk_webauthn_credentials" PRIMARY KEY ("id"),
    CONSTRAINT "uq_01" UNIQUE ("credential_id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("user_id") REFERENCES "auth"."users" ("id")
);

CREATE TABLE "public"."competitions" (
    "id" UUID NOT NULL,
    "host_id" UUID,
    "title" TEXT NOT NULL,
    "title_en" TEXT,
    "description" TEXT,
    "description_en" TEXT,
    "category" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    "starts_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "ends_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "prize_amount" INTEGER NOT NULL,
    "entry_fee" INTEGER NOT NULL,
    "capacity" INTEGER NOT NULL,
    "participants_count" INTEGER NOT NULL,
    "image_url" TEXT,
    "status" "public"."competition_status" NOT NULL,
    "featured" BOOLEAN NOT NULL,
    "coming_soon" BOOLEAN NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT "pk_competitions" PRIMARY KEY ("id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("host_id") REFERENCES "auth"."users" ("id")
);

CREATE TABLE "public"."favorites" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "item_type" "public"."item_type" NOT NULL,
    "item_id" UUID NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT "pk_favorites" PRIMARY KEY ("id"),
    CONSTRAINT "uq_01" UNIQUE ("user_id", "item_type", "item_id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("user_id") REFERENCES "auth"."users" ("id")
);

CREATE TABLE "public"."host_verifications" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "national_id" TEXT NOT NULL,
    "id_front_path" TEXT,
    "id_back_path" TEXT,
    "status" TEXT NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT "pk_host_verifications" PRIMARY KEY ("id"),
    CONSTRAINT "uq_01" UNIQUE ("user_id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("user_id") REFERENCES "auth"."users" ("id")
);

CREATE TABLE "public"."listings" (
    "id" UUID NOT NULL,
    "host_id" UUID NOT NULL,
    "type" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "title_en" TEXT,
    "description" TEXT,
    "description_en" TEXT,
    "category" TEXT,
    "price" INTEGER NOT NULL,
    "discount" INTEGER NOT NULL,
    "capacity" INTEGER,
    "location" TEXT,
    "images" TEXT[] NOT NULL,
    "starts_at" TIMESTAMP WITH TIME ZONE,
    "ends_at" TIMESTAMP WITH TIME ZONE,
    "is_featured" BOOLEAN NOT NULL,
    "status" TEXT NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT "pk_listings" PRIMARY KEY ("id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("host_id") REFERENCES "auth"."users" ("id")
);

CREATE TABLE "public"."notifications" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "type" "public"."notification_type" NOT NULL,
    "title" TEXT NOT NULL,
    "body" TEXT,
    "link" TEXT,
    "read" BOOLEAN NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT "pk_notifications" PRIMARY KEY ("id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("user_id") REFERENCES "auth"."users" ("id")
);

CREATE TABLE "public"."profiles" (
    "id" UUID NOT NULL,
    "display_name" TEXT,
    "avatar_url" TEXT,
    "bio" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "account_type" TEXT NOT NULL,
    "is_blocked" BOOLEAN NOT NULL,
    "role_selected" BOOLEAN NOT NULL,
    "age" INTEGER,
    "location" TEXT,
    "phone" TEXT,
    "email" TEXT,
    CONSTRAINT "pk_profiles" PRIMARY KEY ("id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("id") REFERENCES "auth"."users" ("id")
);

CREATE TABLE "public"."user_contacts" (
    "user_id" UUID NOT NULL,
    "phone" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT "pk_user_contacts" PRIMARY KEY ("user_id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("user_id") REFERENCES "auth"."users" ("id")
);

CREATE TABLE "public"."user_roles" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "role" "public"."app_role" NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT "pk_user_roles" PRIMARY KEY ("id"),
    CONSTRAINT "uq_01" UNIQUE ("user_id", "role"),
    CONSTRAINT "fk_01" FOREIGN KEY ("user_id") REFERENCES "auth"."users" ("id")
);

CREATE TABLE "public"."volunteer_service_requests" (
    "id" UUID NOT NULL,
    "requester_id" UUID NOT NULL,
    "volunteer_id" UUID NOT NULL,
    "volunteer_user_id" UUID NOT NULL,
    "requested_date" DATE NOT NULL,
    "requested_time" TEXT,
    "location" TEXT NOT NULL,
    "reason" TEXT NOT NULL,
    "people_count" INTEGER NOT NULL,
    "notes" TEXT,
    "status" TEXT NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT "pk_volunteer_service_requests" PRIMARY KEY ("id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("requester_id") REFERENCES "auth"."users" ("id"),
    CONSTRAINT "fk_02" FOREIGN KEY ("volunteer_id") REFERENCES "public"."volunteer_requests" ("id"),
    CONSTRAINT "fk_03" FOREIGN KEY ("volunteer_user_id") REFERENCES "auth"."users" ("id")
);

CREATE TABLE "storage"."objects" (
    "id" UUID NOT NULL,
    "bucket_id" TEXT,
    "name" TEXT,
    "owner" UUID,
    "created_at" TIMESTAMP WITH TIME ZONE,
    "updated_at" TIMESTAMP WITH TIME ZONE,
    "last_accessed_at" TIMESTAMP WITH TIME ZONE,
    "metadata" JSONB,
    "path_tokens" TEXT[],
    "version" TEXT,
    "owner_id" TEXT,
    "user_metadata" JSONB,
    "archived_at" TIMESTAMP WITH TIME ZONE,
    "is_delete_marker" BOOLEAN NOT NULL,
    "is_versioned" BOOLEAN NOT NULL,
    CONSTRAINT "pk_objects" PRIMARY KEY ("id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets" ("id")
);

CREATE TABLE "storage"."s3_multipart_uploads" (
    "id" TEXT NOT NULL,
    "in_progress_size" BIGINT NOT NULL,
    "upload_signature" TEXT NOT NULL,
    "bucket_id" TEXT NOT NULL,
    "key" TEXT NOT NULL,
    "version" TEXT NOT NULL,
    "owner_id" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "user_metadata" JSONB,
    "metadata" JSONB,
    CONSTRAINT "pk_s3_multipart_uploads" PRIMARY KEY ("id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets" ("id")
);

CREATE TABLE "storage"."vector_indexes" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "bucket_id" TEXT NOT NULL,
    "data_type" TEXT NOT NULL,
    "dimension" INTEGER NOT NULL,
    "distance_metric" TEXT NOT NULL,
    "metadata_configuration" JSONB,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT "pk_vector_indexes" PRIMARY KEY ("id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets_vectors" ("id")
);

CREATE TABLE "auth"."mfa_amr_claims" (
    "session_id" UUID NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "authentication_method" TEXT NOT NULL,
    "id" UUID NOT NULL,
    CONSTRAINT "pk_mfa_amr_claims" PRIMARY KEY ("id"),
    CONSTRAINT "uq_01" UNIQUE ("session_id", "authentication_method"),
    CONSTRAINT "fk_01" FOREIGN KEY ("session_id") REFERENCES "auth"."sessions" ("id")
);

CREATE TABLE "auth"."mfa_challenges" (
    "id" UUID NOT NULL,
    "factor_id" UUID NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "verified_at" TIMESTAMP WITH TIME ZONE,
    "ip_address" INET NOT NULL,
    "otp_code" TEXT,
    "web_authn_session_data" JSONB,
    CONSTRAINT "pk_mfa_challenges" PRIMARY KEY ("id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("factor_id") REFERENCES "auth"."mfa_factors" ("id")
);

CREATE TABLE "auth"."mfa_recovery_code_sets" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "mfa_factor_id" UUID NOT NULL,
    "failed_verification_count" INTEGER NOT NULL,
    "verification_locked_until" TIMESTAMP WITH TIME ZONE,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT "pk_mfa_recovery_code_sets" PRIMARY KEY ("id"),
    CONSTRAINT "uq_01" UNIQUE ("user_id", "mfa_factor_id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("mfa_factor_id") REFERENCES "auth"."mfa_factors" ("id"),
    CONSTRAINT "fk_02" FOREIGN KEY ("user_id") REFERENCES "auth"."users" ("id")
);

CREATE TABLE "auth"."refresh_tokens" (
    "instance_id" UUID,
    "id" BIGINT NOT NULL,
    "token" VARCHAR(255),
    "user_id" VARCHAR(255),
    "revoked" BOOLEAN,
    "created_at" TIMESTAMP WITH TIME ZONE,
    "updated_at" TIMESTAMP WITH TIME ZONE,
    "parent" VARCHAR(255),
    "session_id" UUID,
    CONSTRAINT "pk_refresh_tokens" PRIMARY KEY ("id"),
    CONSTRAINT "uq_01" UNIQUE ("token"),
    CONSTRAINT "fk_01" FOREIGN KEY ("session_id") REFERENCES "auth"."sessions" ("id")
);

CREATE TABLE "public"."bookings" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "item_type" "public"."item_type" NOT NULL,
    "item_id" UUID NOT NULL,
    "host_id" UUID,
    "status" "public"."booking_status" NOT NULL,
    "amount" INTEGER NOT NULL,
    "notes" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "listing_id" UUID,
    "booking_date" DATE,
    "guests" INTEGER NOT NULL,
    CONSTRAINT "pk_bookings" PRIMARY KEY ("id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("host_id") REFERENCES "auth"."users" ("id"),
    CONSTRAINT "fk_02" FOREIGN KEY ("listing_id") REFERENCES "public"."listings" ("id"),
    CONSTRAINT "fk_03" FOREIGN KEY ("user_id") REFERENCES "auth"."users" ("id")
);

CREATE TABLE "public"."community_posts" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "listing_id" UUID,
    "title" TEXT,
    "body" TEXT NOT NULL,
    "image_url" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT "pk_community_posts" PRIMARY KEY ("id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("listing_id") REFERENCES "public"."listings" ("id"),
    CONSTRAINT "fk_02" FOREIGN KEY ("user_id") REFERENCES "auth"."users" ("id")
);

CREATE TABLE "public"."feature_requests" (
    "id" UUID NOT NULL,
    "listing_id" UUID NOT NULL,
    "host_id" UUID NOT NULL,
    "amount" INTEGER NOT NULL,
    "payment_method" TEXT NOT NULL,
    "payment_status" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "admin_note" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT "pk_feature_requests" PRIMARY KEY ("id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("host_id") REFERENCES "auth"."users" ("id"),
    CONSTRAINT "fk_02" FOREIGN KEY ("listing_id") REFERENCES "public"."listings" ("id")
);

CREATE TABLE "public"."reviews" (
    "id" UUID NOT NULL,
    "listing_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "image_url" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT "pk_reviews" PRIMARY KEY ("id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("listing_id") REFERENCES "public"."listings" ("id"),
    CONSTRAINT "fk_02" FOREIGN KEY ("user_id") REFERENCES "auth"."users" ("id")
);

CREATE TABLE "storage"."s3_multipart_uploads_parts" (
    "id" UUID NOT NULL,
    "upload_id" TEXT NOT NULL,
    "size" BIGINT NOT NULL,
    "part_number" INTEGER NOT NULL,
    "bucket_id" TEXT NOT NULL,
    "key" TEXT NOT NULL,
    "etag" TEXT NOT NULL,
    "owner_id" TEXT,
    "version" TEXT NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT "pk_s3_multipart_uploads_parts" PRIMARY KEY ("id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets" ("id"),
    CONSTRAINT "fk_02" FOREIGN KEY ("upload_id") REFERENCES "storage"."s3_multipart_uploads" ("id")
);

CREATE TABLE "auth"."mfa_recovery_codes" (
    "id" UUID NOT NULL,
    "mfa_recovery_code_set_id" UUID NOT NULL,
    "code_hash" TEXT NOT NULL,
    "consumed_at" TIMESTAMP WITH TIME ZONE,
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT "pk_mfa_recovery_codes" PRIMARY KEY ("id"),
    CONSTRAINT "fk_01" FOREIGN KEY ("mfa_recovery_code_set_id") REFERENCES "auth"."mfa_recovery_code_sets" ("id")
);

-- End of schema. The ERD contains 52 tables; no seed data is included.
