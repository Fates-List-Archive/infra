--
-- PostgreSQL database dump
--

-- Dumped from database version 14.0 (Debian 14.0-1.pgdg110+1)
-- Dumped by pg_dump version 14.2

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

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bot_commands; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.bot_commands (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    bot_id bigint NOT NULL,
    cmd_type integer NOT NULL,
    groups text[] DEFAULT '{Default}'::text[] NOT NULL,
    name text NOT NULL,
    vote_locked boolean DEFAULT false NOT NULL,
    description text NOT NULL,
    args text[] DEFAULT '{}'::text[] NOT NULL,
    examples text[] DEFAULT '{}'::text[] NOT NULL,
    premium_only boolean DEFAULT false NOT NULL,
    notes text[] DEFAULT '{}'::text[] NOT NULL,
    doc_link text,
    nsfw boolean DEFAULT false
);


ALTER TABLE public.bot_commands OWNER TO fateslist;

--
-- Name: bot_list_feature; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.bot_list_feature (
    feature_id integer NOT NULL,
    name text NOT NULL,
    iname text NOT NULL,
    description text,
    positive integer
);


ALTER TABLE public.bot_list_feature OWNER TO fateslist;

--
-- Name: bot_list_tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bot_list_tags (
    id text NOT NULL,
    icon text NOT NULL
);


ALTER TABLE public.bot_list_tags OWNER TO postgres;

--
-- Name: bot_maint; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bot_maint (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    bot_id bigint,
    reason text,
    type integer,
    epoch bigint
);


ALTER TABLE public.bot_maint OWNER TO postgres;

--
-- Name: bot_owner; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bot_owner (
    bot_id bigint NOT NULL,
    owner bigint NOT NULL,
    main boolean DEFAULT false,
    id integer NOT NULL
);


ALTER TABLE public.bot_owner OWNER TO postgres;

--
-- Name: bot_owner__id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bot_owner__id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bot_owner__id_seq OWNER TO postgres;

--
-- Name: bot_owner__id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bot_owner__id_seq OWNED BY public.bot_owner.id;


--
-- Name: bot_packs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bot_packs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    icon text,
    banner text,
    owner bigint,
    bots bigint[],
    description text,
    name text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.bot_packs OWNER TO postgres;

--
-- Name: bot_promotions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bot_promotions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    bot_id bigint,
    title text,
    info text,
    css text,
    type integer DEFAULT 3
);


ALTER TABLE public.bot_promotions OWNER TO postgres;

--
-- Name: bot_stats_votes_pm; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bot_stats_votes_pm (
    bot_id bigint,
    votes bigint,
    epoch bigint
);


ALTER TABLE public.bot_stats_votes_pm OWNER TO postgres;

--
-- Name: bot_tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bot_tags (
    bot_id bigint NOT NULL,
    tag text NOT NULL,
    id integer NOT NULL
);


ALTER TABLE public.bot_tags OWNER TO postgres;

--
-- Name: bot_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bot_tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bot_tags_id_seq OWNER TO postgres;

--
-- Name: bot_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bot_tags_id_seq OWNED BY public.bot_tags.id;


--
-- Name: bot_voters; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.bot_voters (
    bot_id bigint NOT NULL,
    user_id bigint NOT NULL,
    timestamps timestamp with time zone[] DEFAULT '{"2022-03-20 16:36:11.388973+00"}'::timestamp with time zone[] NOT NULL
);


ALTER TABLE public.bot_voters OWNER TO fateslist;

--
-- Name: bots; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bots (
    bot_id bigint NOT NULL,
    votes bigint DEFAULT 0,
    guild_count bigint DEFAULT 0,
    shard_count bigint DEFAULT 0,
    bot_library text,
    webhook text,
    description text NOT NULL,
    long_description text NOT NULL,
    prefix text,
    api_token text,
    banner_card text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    invite text DEFAULT ''::text NOT NULL,
    features text[],
    invite_amount integer DEFAULT 0,
    user_count bigint DEFAULT 0,
    css text DEFAULT ''::text,
    shards integer[] DEFAULT '{}'::integer[],
    username_cached text DEFAULT ''::text NOT NULL,
    state integer DEFAULT 1 NOT NULL,
    long_description_type integer NOT NULL,
    verifier bigint,
    last_stats_post timestamp with time zone DEFAULT now() NOT NULL,
    webhook_secret text,
    webhook_type integer,
    di_text text,
    id bigint NOT NULL,
    banner_page text,
    total_votes bigint DEFAULT 0,
    client_id bigint,
    flags integer[] DEFAULT '{}'::integer[] NOT NULL,
    uptime_checks_total integer DEFAULT 0,
    uptime_checks_failed integer DEFAULT 0,
    page_style integer DEFAULT 0 NOT NULL,
    webhook_hmac_only boolean DEFAULT false,
    last_updated_at timestamp with time zone DEFAULT now() NOT NULL,
    avatar_cached text DEFAULT ''::text NOT NULL,
    disc_cached text DEFAULT ''::text NOT NULL,
    extra_links jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE public.bots OWNER TO postgres;

--
-- Name: events; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.events (
    id bigint NOT NULL,
    type text NOT NULL,
    ts timestamp with time zone DEFAULT now() NOT NULL,
    event jsonb NOT NULL
);


ALTER TABLE public.events OWNER TO fateslist;

--
-- Name: features; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.features (
    id text NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    viewed_as text NOT NULL
);


ALTER TABLE public.features OWNER TO fateslist;

--
-- Name: frostpaw_clients; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.frostpaw_clients (
    id text NOT NULL,
    name text NOT NULL,
    domain text NOT NULL,
    privacy_policy text NOT NULL,
    secret text NOT NULL,
    owner_id bigint NOT NULL
);


ALTER TABLE public.frostpaw_clients OWNER TO fateslist;

--
-- Name: leave_of_absence; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.leave_of_absence (
    reason text,
    estimated_time interval,
    start_date timestamp with time zone DEFAULT now(),
    user_id bigint,
    id integer NOT NULL
);


ALTER TABLE public.leave_of_absence OWNER TO fateslist;

--
-- Name: leave_of_absence_id_seq; Type: SEQUENCE; Schema: public; Owner: fateslist
--

CREATE SEQUENCE public.leave_of_absence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.leave_of_absence_id_seq OWNER TO fateslist;

--
-- Name: leave_of_absence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fateslist
--

ALTER SEQUENCE public.leave_of_absence_id_seq OWNED BY public.leave_of_absence.id;


--
-- Name: lynx_apps; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.lynx_apps (
    user_id bigint,
    app_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    questions jsonb,
    answers jsonb,
    app_version integer,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.lynx_apps OWNER TO fateslist;

--
-- Name: lynx_data; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.lynx_data (
    default_user_experiments integer[],
    id integer NOT NULL
);


ALTER TABLE public.lynx_data OWNER TO fateslist;

--
-- Name: lynx_data_id_seq; Type: SEQUENCE; Schema: public; Owner: fateslist
--

CREATE SEQUENCE public.lynx_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lynx_data_id_seq OWNER TO fateslist;

--
-- Name: lynx_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fateslist
--

ALTER SEQUENCE public.lynx_data_id_seq OWNED BY public.lynx_data.id;


--
-- Name: lynx_logs; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.lynx_logs (
    user_id bigint NOT NULL,
    method text NOT NULL,
    url text NOT NULL,
    status_code integer NOT NULL,
    request_time timestamp with time zone DEFAULT now()
);


ALTER TABLE public.lynx_logs OWNER TO fateslist;

--
-- Name: lynx_notifications; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.lynx_notifications (
    acked_users bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    message text NOT NULL,
    type text NOT NULL,
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    staff_only boolean DEFAULT false
);


ALTER TABLE public.lynx_notifications OWNER TO fateslist;

--
-- Name: lynx_ratings; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.lynx_ratings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    feedback text NOT NULL,
    username_cached text NOT NULL,
    user_id bigint,
    page text NOT NULL
);


ALTER TABLE public.lynx_ratings OWNER TO fateslist;

--
-- Name: lynx_survey_responses; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.lynx_survey_responses (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    questions jsonb NOT NULL,
    answers jsonb NOT NULL,
    username_cached text NOT NULL,
    user_id bigint,
    survey_id uuid NOT NULL
);


ALTER TABLE public.lynx_survey_responses OWNER TO fateslist;

--
-- Name: lynx_surveys; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.lynx_surveys (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    title text NOT NULL,
    questions jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.lynx_surveys OWNER TO fateslist;

--
-- Name: migration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration (
    id integer NOT NULL,
    name character varying(200) DEFAULT ''::character varying NOT NULL,
    app_name character varying(200) DEFAULT ''::character varying NOT NULL,
    ran_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.migration OWNER TO postgres;

--
-- Name: migration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.migration_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.migration_id_seq OWNER TO postgres;

--
-- Name: migration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.migration_id_seq OWNED BY public.migration.id;


--
-- Name: piccolo_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.piccolo_user (
    id integer NOT NULL,
    username character varying(100) DEFAULT ''::character varying NOT NULL,
    password character varying(255) DEFAULT ''::character varying NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    active boolean DEFAULT false NOT NULL,
    admin boolean DEFAULT false NOT NULL,
    first_name character varying(255) DEFAULT ''::character varying,
    last_name character varying(255) DEFAULT ''::character varying,
    superuser boolean DEFAULT false NOT NULL,
    last_login timestamp without time zone
);


ALTER TABLE public.piccolo_user OWNER TO postgres;

--
-- Name: piccolo_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.piccolo_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.piccolo_user_id_seq OWNER TO postgres;

--
-- Name: piccolo_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.piccolo_user_id_seq OWNED BY public.piccolo_user.id;


--
-- Name: platform_map; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.platform_map (
    fates_id numeric NOT NULL,
    platform_id text NOT NULL
);


ALTER TABLE public.platform_map OWNER TO fateslist;

--
-- Name: push_notifications; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.push_notifications (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id bigint NOT NULL,
    endpoint text NOT NULL,
    p256dh text NOT NULL,
    auth text NOT NULL
);


ALTER TABLE public.push_notifications OWNER TO fateslist;

--
-- Name: resources; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.resources (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    target_id bigint NOT NULL,
    resource_title text NOT NULL,
    resource_link text NOT NULL,
    resource_description text NOT NULL,
    target_type integer DEFAULT 0
);


ALTER TABLE public.resources OWNER TO fateslist;

--
-- Name: review_votes; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.review_votes (
    id uuid NOT NULL,
    user_id bigint NOT NULL,
    upvote boolean NOT NULL
);


ALTER TABLE public.review_votes OWNER TO fateslist;

--
-- Name: reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reviews (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    target_id bigint NOT NULL,
    user_id bigint NOT NULL,
    star_rating numeric(4,2) DEFAULT 0.0 NOT NULL,
    review_text text NOT NULL,
    flagged boolean DEFAULT false NOT NULL,
    epoch bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    target_type integer DEFAULT 0,
    parent_id uuid
);


ALTER TABLE public.reviews OWNER TO postgres;

--
-- Name: server_audit_logs; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.server_audit_logs (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    username text NOT NULL,
    user_guild_perms text NOT NULL,
    field text NOT NULL,
    value text NOT NULL,
    action_time timestamp with time zone DEFAULT now() NOT NULL,
    action_id uuid DEFAULT public.uuid_generate_v4() NOT NULL
);


ALTER TABLE public.server_audit_logs OWNER TO fateslist;

--
-- Name: server_tags; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.server_tags (
    id text NOT NULL,
    name text NOT NULL,
    owner_guild bigint NOT NULL,
    iconify_data text NOT NULL
);


ALTER TABLE public.server_tags OWNER TO fateslist;

--
-- Name: server_voters; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.server_voters (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    timestamps timestamp with time zone[] DEFAULT '{"2022-03-20 16:36:33.784499+00"}'::timestamp with time zone[] NOT NULL
);


ALTER TABLE public.server_voters OWNER TO fateslist;

--
-- Name: servers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.servers (
    guild_id bigint NOT NULL,
    votes bigint DEFAULT 0,
    webhook text,
    description text DEFAULT 'No description set'::text NOT NULL,
    long_description text DEFAULT 'No long description set! Set one with /settings longdesc Long description'::text NOT NULL,
    css text DEFAULT ''::text,
    api_token text NOT NULL,
    invite_amount integer DEFAULT 0,
    invite_url text,
    name_cached text NOT NULL,
    long_description_type integer DEFAULT 0,
    state integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    avatar_cached text DEFAULT 'Unlisted'::text,
    invite_channel bigint,
    guild_count bigint DEFAULT 0,
    banner_card text,
    banner_page text,
    webhook_secret text,
    webhook_type integer DEFAULT 1,
    total_votes bigint DEFAULT 0,
    tags text[] DEFAULT '{}'::text[],
    owner_id bigint NOT NULL,
    flags integer[] DEFAULT '{}'::integer[] NOT NULL,
    autorole_votes bigint[] DEFAULT '{}'::bigint[],
    whitelist_form text,
    webhook_hmac_only boolean DEFAULT false,
    old_state integer DEFAULT 0 NOT NULL,
    user_whitelist bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    user_blacklist bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    extra_links jsonb DEFAULT '{}'::jsonb NOT NULL
)
WITH (fillfactor='70');


ALTER TABLE public.servers OWNER TO postgres;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sessions (
    id integer NOT NULL,
    token character varying(100) DEFAULT ''::character varying NOT NULL,
    user_id integer DEFAULT 0 NOT NULL,
    expiry_date timestamp without time zone DEFAULT (CURRENT_TIMESTAMP + '01:00:00'::interval) NOT NULL,
    max_expiry_date timestamp without time zone DEFAULT (CURRENT_TIMESTAMP + '7 days'::interval) NOT NULL
);


ALTER TABLE public.sessions OWNER TO postgres;

--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sessions_id_seq OWNER TO postgres;

--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: user_bot_logs; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.user_bot_logs (
    user_id bigint NOT NULL,
    bot_id bigint NOT NULL,
    action_time timestamp with time zone DEFAULT now() NOT NULL,
    action integer NOT NULL,
    context text
);


ALTER TABLE public.user_bot_logs OWNER TO fateslist;

--
-- Name: user_connections; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.user_connections (
    user_id bigint NOT NULL,
    client_id text NOT NULL,
    refresh_token text NOT NULL,
    expires_on timestamp with time zone DEFAULT (now() + '7 days'::interval) NOT NULL
);


ALTER TABLE public.user_connections OWNER TO fateslist;

--
-- Name: user_server_vote_table; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.user_server_vote_table (
    user_id bigint NOT NULL,
    guild_id bigint NOT NULL,
    expires_on timestamp with time zone DEFAULT (now() + '08:00:00'::interval)
);


ALTER TABLE public.user_server_vote_table OWNER TO fateslist;

--
-- Name: user_vote_table; Type: TABLE; Schema: public; Owner: fateslist
--

CREATE TABLE public.user_vote_table (
    user_id bigint NOT NULL,
    bot_id bigint NOT NULL,
    expires_on timestamp with time zone DEFAULT (now() + '08:00:00'::interval)
);


ALTER TABLE public.user_vote_table OWNER TO fateslist;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id bigint NOT NULL,
    api_token text NOT NULL,
    description text DEFAULT 'This user prefers to be an enigma'::text,
    badges text[],
    username text,
    user_css text DEFAULT ''::text,
    state integer DEFAULT 0 NOT NULL,
    coins integer DEFAULT 0,
    id bigint NOT NULL,
    site_lang text DEFAULT 'default'::text,
    profile_css text DEFAULT ''::text NOT NULL,
    vote_reminders bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    vote_reminder_channel bigint,
    staff_verify_code text,
    vote_reminders_last_acked timestamp with time zone DEFAULT now() NOT NULL,
    vote_reminders_servers bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    vote_reminders_servers_last_acked timestamp with time zone DEFAULT now() NOT NULL,
    vote_reminder_servers_channel bigint,
    experiments integer[] DEFAULT '{}'::integer[] NOT NULL,
    flags integer[] DEFAULT '{}'::integer[] NOT NULL,
    extra_links jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: vanity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vanity (
    type integer,
    vanity_url text,
    redirect bigint,
    id integer NOT NULL
);


ALTER TABLE public.vanity OWNER TO postgres;

--
-- Name: vanity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vanity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vanity_id_seq OWNER TO postgres;

--
-- Name: vanity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vanity_id_seq OWNED BY public.vanity.id;


--
-- Name: bot_owner id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bot_owner ALTER COLUMN id SET DEFAULT nextval('public.bot_owner__id_seq'::regclass);


--
-- Name: bot_tags id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bot_tags ALTER COLUMN id SET DEFAULT nextval('public.bot_tags_id_seq'::regclass);


--
-- Name: leave_of_absence id; Type: DEFAULT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.leave_of_absence ALTER COLUMN id SET DEFAULT nextval('public.leave_of_absence_id_seq'::regclass);


--
-- Name: lynx_data id; Type: DEFAULT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.lynx_data ALTER COLUMN id SET DEFAULT nextval('public.lynx_data_id_seq'::regclass);


--
-- Name: migration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration ALTER COLUMN id SET DEFAULT nextval('public.migration_id_seq'::regclass);


--
-- Name: piccolo_user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.piccolo_user ALTER COLUMN id SET DEFAULT nextval('public.piccolo_user_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: vanity id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vanity ALTER COLUMN id SET DEFAULT nextval('public.vanity_id_seq'::regclass);


--
-- Name: bots bot_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bots
    ADD CONSTRAINT bot_id_unique UNIQUE (bot_id);


--
-- Name: bot_list_feature bot_list_feature_iname_key; Type: CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.bot_list_feature
    ADD CONSTRAINT bot_list_feature_iname_key UNIQUE (iname);


--
-- Name: bot_list_feature bot_list_feature_name_key; Type: CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.bot_list_feature
    ADD CONSTRAINT bot_list_feature_name_key UNIQUE (name);


--
-- Name: bot_list_feature bot_list_feature_pkey; Type: CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.bot_list_feature
    ADD CONSTRAINT bot_list_feature_pkey PRIMARY KEY (feature_id);


--
-- Name: bot_list_tags bot_list_tags_icon_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bot_list_tags
    ADD CONSTRAINT bot_list_tags_icon_key UNIQUE (icon);


--
-- Name: bot_list_tags bot_list_tags_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bot_list_tags
    ADD CONSTRAINT bot_list_tags_id_key UNIQUE (id);


--
-- Name: bot_maint bot_maint_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bot_maint
    ADD CONSTRAINT bot_maint_pkey PRIMARY KEY (id);


--
-- Name: bot_packs bot_packs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bot_packs
    ADD CONSTRAINT bot_packs_pkey PRIMARY KEY (id);


--
-- Name: resources bot_resources_pkey; Type: CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.resources
    ADD CONSTRAINT bot_resources_pkey PRIMARY KEY (id);


--
-- Name: reviews bot_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT bot_reviews_pkey PRIMARY KEY (id);


--
-- Name: bots bots_api_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bots
    ADD CONSTRAINT bots_api_token_key UNIQUE (api_token);


--
-- Name: vanity constraintname; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vanity
    ADD CONSTRAINT constraintname UNIQUE (vanity_url);


--
-- Name: lynx_apps lynx_apps_pkey; Type: CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.lynx_apps
    ADD CONSTRAINT lynx_apps_pkey PRIMARY KEY (app_id);


--
-- Name: lynx_data lynx_data_pkey; Type: CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.lynx_data
    ADD CONSTRAINT lynx_data_pkey PRIMARY KEY (id);


--
-- Name: migration migration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration
    ADD CONSTRAINT migration_pkey PRIMARY KEY (id);


--
-- Name: piccolo_user piccolo_user_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.piccolo_user
    ADD CONSTRAINT piccolo_user_email_key UNIQUE (email);


--
-- Name: piccolo_user piccolo_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.piccolo_user
    ADD CONSTRAINT piccolo_user_pkey PRIMARY KEY (id);


--
-- Name: piccolo_user piccolo_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.piccolo_user
    ADD CONSTRAINT piccolo_user_username_key UNIQUE (username);


--
-- Name: bot_promotions promotions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bot_promotions
    ADD CONSTRAINT promotions_pkey PRIMARY KEY (id);


--
-- Name: push_notifications push_notifications_endpoint_key; Type: CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.push_notifications
    ADD CONSTRAINT push_notifications_endpoint_key UNIQUE (endpoint);


--
-- Name: push_notifications push_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.push_notifications
    ADD CONSTRAINT push_notifications_pkey PRIMARY KEY (id);


--
-- Name: review_votes review_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.review_votes
    ADD CONSTRAINT review_votes_pkey PRIMARY KEY (id, user_id);


--
-- Name: server_audit_logs server_audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.server_audit_logs
    ADD CONSTRAINT server_audit_logs_pkey PRIMARY KEY (action_id);


--
-- Name: server_tags server_tags_id_key; Type: CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.server_tags
    ADD CONSTRAINT server_tags_id_key UNIQUE (id);


--
-- Name: server_tags server_tags_name_key; Type: CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.server_tags
    ADD CONSTRAINT server_tags_name_key UNIQUE (name);


--
-- Name: servers servers_api_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servers
    ADD CONSTRAINT servers_api_token_key UNIQUE (api_token);


--
-- Name: servers servers_guild_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servers
    ADD CONSTRAINT servers_guild_id_key UNIQUE (guild_id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: lynx_surveys survey_pkey; Type: CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.lynx_surveys
    ADD CONSTRAINT survey_pkey PRIMARY KEY (id);


--
-- Name: user_server_vote_table user_server_vote_table_pkey; Type: CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.user_server_vote_table
    ADD CONSTRAINT user_server_vote_table_pkey PRIMARY KEY (user_id);


--
-- Name: users user_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT user_unique UNIQUE (user_id);


--
-- Name: user_vote_table user_vote_table_pkey; Type: CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.user_vote_table
    ADD CONSTRAINT user_vote_table_pkey PRIMARY KEY (user_id);


--
-- Name: vanity vanity_redirect_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vanity
    ADD CONSTRAINT vanity_redirect_key UNIQUE (redirect);


--
-- Name: bots_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX bots_index ON public.bots USING btree (bot_id);


--
-- Name: bot_owner bots_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bot_owner
    ADD CONSTRAINT bots_fk FOREIGN KEY (bot_id) REFERENCES public.bots(bot_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bot_maint bots_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bot_maint
    ADD CONSTRAINT bots_fk FOREIGN KEY (bot_id) REFERENCES public.bots(bot_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bot_promotions bots_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bot_promotions
    ADD CONSTRAINT bots_fk FOREIGN KEY (bot_id) REFERENCES public.bots(bot_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bot_tags bots_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bot_tags
    ADD CONSTRAINT bots_fk FOREIGN KEY (bot_id) REFERENCES public.bots(bot_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bot_commands bots_fk; Type: FK CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.bot_commands
    ADD CONSTRAINT bots_fk FOREIGN KEY (bot_id) REFERENCES public.bots(bot_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: reviews review_parent_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT review_parent_id FOREIGN KEY (parent_id) REFERENCES public.reviews(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: review_votes review_votes_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.review_votes
    ADD CONSTRAINT review_votes_id_fkey FOREIGN KEY (id) REFERENCES public.reviews(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: server_audit_logs servers_fk; Type: FK CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.server_audit_logs
    ADD CONSTRAINT servers_fk FOREIGN KEY (guild_id) REFERENCES public.servers(guild_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lynx_survey_responses survey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.lynx_survey_responses
    ADD CONSTRAINT survey_fkey FOREIGN KEY (survey_id) REFERENCES public.lynx_surveys(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bot_tags tags_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bot_tags
    ADD CONSTRAINT tags_fk FOREIGN KEY (tag) REFERENCES public.bot_list_tags(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lynx_apps user_fk; Type: FK CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.lynx_apps
    ADD CONSTRAINT user_fk FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: servers user_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servers
    ADD CONSTRAINT user_fk FOREIGN KEY (owner_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: server_audit_logs user_fk; Type: FK CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.server_audit_logs
    ADD CONSTRAINT user_fk FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lynx_logs user_fk; Type: FK CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.lynx_logs
    ADD CONSTRAINT user_fk FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_connections user_fk; Type: FK CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.user_connections
    ADD CONSTRAINT user_fk FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: frostpaw_clients user_fk; Type: FK CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.frostpaw_clients
    ADD CONSTRAINT user_fk FOREIGN KEY (owner_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: leave_of_absence user_fk; Type: FK CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.leave_of_absence
    ADD CONSTRAINT user_fk FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: push_notifications user_fk; Type: FK CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.push_notifications
    ADD CONSTRAINT user_fk FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: reviews users_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT users_fk FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_bot_logs users_fk; Type: FK CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.user_bot_logs
    ADD CONSTRAINT users_fk FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lynx_survey_responses users_fk; Type: FK CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.lynx_survey_responses
    ADD CONSTRAINT users_fk FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lynx_ratings users_fk; Type: FK CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.lynx_ratings
    ADD CONSTRAINT users_fk FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bot_voters users_fk; Type: FK CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.bot_voters
    ADD CONSTRAINT users_fk FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: server_voters users_fk; Type: FK CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.server_voters
    ADD CONSTRAINT users_fk FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_vote_table users_fk; Type: FK CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.user_vote_table
    ADD CONSTRAINT users_fk FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_server_vote_table users_fk; Type: FK CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.user_server_vote_table
    ADD CONSTRAINT users_fk FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: review_votes users_fk; Type: FK CONSTRAINT; Schema: public; Owner: fateslist
--

ALTER TABLE ONLY public.review_votes
    ADD CONSTRAINT users_fk FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

