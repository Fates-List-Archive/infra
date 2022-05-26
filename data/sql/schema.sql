CREATE DATABASE fateslist;
\c fateslist
CREATE EXTENSION "uuid-ossp";

-- Maps a fates snowflake to a platform specific id
CREATE TABLE platform_map (
    fates_id DECIMAL NOT NULL,
    platform_id TEXT NOT NULL
);

CREATE TABLE features (
    id text not null,
    name text not null,
    description text not null,
    viewed_as text not null
);

INSERT INTO features VALUES (
    'custom_prefix',
    'Customizable Prefix',
    'positive',
    'This bot supports changing of its prefix and/or has recently migrated to slash commands'
);
INSERT INTO features VALUES (
    'open_source',
    'Open Source',
    'positive',
    'These bots are open source meaning they can easily be audited and/or potentially self hosted'
);
INSERT INTO features VALUES (
    'slash_commands',
    'Slash Commands',
    'critical',
    'These bots support slash commands'
);
INSERT INTO features VALUES (
    'cryptocurrency',
    'Cryptocurrency (NFTs)',
    'negative',
    'These bots offer services related to cryptocurrency which is considered negative by users'
);

CREATE TABLE users (
    id bigint not null, -- Used by piccolo, must be equal to user_id
    user_id bigint not null unique,
    api_token text not null,
    description text DEFAULT 'This user prefers to be an enigma',
    badges text[],
    username text,
    extra_links jsonb not null default '{}',
    user_css text not null default '',
    profile_css text not null default '',
    state integer not null default 0, -- 0 = No Ban, 1 = Global Ban
    coins INTEGER DEFAULT 0,
    js_allowed BOOLEAN DEFAULT false,
    vote_reminders bigint[] not null default '{}',
    vote_reminders_servers bigint[] not null default '{}',
    vote_reminder_channel bigint,
    vote_reminder_servers_channel bigint,
    vote_reminders_last_acked timestamptz not null default now(),
    vote_reminders_servers_last_acked timestamptz not null default now(),
    staff_verify_code text,
    experiments integer[] not null default '{}',
    flags integer[] not null default '{}'
);

CREATE TABLE bots (
    id BIGINT NOT NULL, -- Used by piccolo, must be equal to bot_id
    flags integer[] not null default '{}',
    username_cached text not null DEFAULT '',
    avatar_cached text not null DEFAULT '',
    disc_cached text not null DEFAULT '',
    bot_id bigint not null unique,
    client_id bigint,
    votes bigint default 0,
    total_votes bigint default 0,
    guild_count bigint DEFAULT 0,
    last_stats_post timestamptz not null DEFAULT NOW(),
    user_count bigint DEFAULT 0,
    shard_count bigint DEFAULT 0,
    shards integer[] DEFAULT '{}',
    bot_library text,
    webhook_type integer DEFAULT 1,
    webhook text,
    webhook_secret text,
    webhook_hmac_only boolean default false,
    description text not null,
    long_description text not null,
    long_description_type integer not null default 0,
    page_style integer not null default 0,
    css text default '',
    prefix text,
    features TEXT[] DEFAULT '{}',
    api_token text unique not null,
    extra_links jsonb not null default '{}',
    state integer not null DEFAULT 1,
    banner_card text,
    banner_page text,
    keep_banner_decor boolean default true,
    created_at timestamptz not null DEFAULT NOW(),
    last_updated_at timestamptz not null DEFAULT NOW(),
    invite text not null default '',
    invite_amount integer DEFAULT 0,
    verifier bigint,
    uptime_checks_total integer default 0,
    uptime_checks_failed integer default 0,
    di_text text
);

CREATE INDEX bots_ext_index ON bots (username_cached, created_at, prefix, page_style); 

CREATE TABLE resources (
    id uuid primary key DEFAULT uuid_generate_v4(),
    target_id BIGINT NOT NULL,
    target_type integer default 0,
    resource_title TEXT NOT NULL,
    resource_link TEXT NOT NULL,
    resource_description TEXT NOT NULL
);

CREATE TABLE bot_list_tags (
    id TEXT NOT NULL UNIQUE,
    icon TEXT NOT NULL UNIQUE
);

INSERT INTO bot_list_tags VALUES ('music', 'fa-solid:music');
INSERT INTO bot_list_tags VALUES ('moderation', 'fa-solid:hammer');
INSERT INTO bot_list_tags VALUES ('economy', 'fa-solid:coins');
INSERT INTO bot_list_tags VALUES ('fun', 'fa-solid:heart');
INSERT INTO bot_list_tags VALUES ('anime', 'fa-solid:camera');
INSERT INTO bot_list_tags VALUES ('games', 'fa-solid:smile');
INSERT INTO bot_list_tags VALUES ('web_dashboard', 'fa-solid:chart-bar');
INSERT INTO bot_list_tags VALUES ('logging', 'fa-solid:chart-line');
INSERT INTO bot_list_tags VALUES ('game_stats', 'fa-solid:chart-pie');
INSERT INTO bot_list_tags VALUES ('leveling', 'fa-solid:arrow-up');
INSERT INTO bot_list_tags VALUES ('roleplay', 'fa-solid:cat');
INSERT INTO bot_list_tags VALUES ('utility', 'fa-solid:desktop');
INSERT INTO bot_list_tags VALUES ('social', 'fa-solid:users');
INSERT INTO bot_list_tags VALUES ('meme', 'cib:happycow');
INSERT INTO bot_list_tags VALUES ('reddit', 'akar-icons:reddit-fill');
INSERT INTO bot_list_tags VALUES ('pokemon', 'mdi-pokemon-go');

CREATE INDEX bot_list_tags_index ON bot_list_tags (id, icon);

CREATE TABLE bot_tags (
    id SERIAL,
    bot_id BIGINT NOT NULL,
    tag TEXT NOT NULL,
    CONSTRAINT bots_fk FOREIGN KEY (bot_id) REFERENCES bots(bot_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT tags_fk FOREIGN KEY (tag) REFERENCES bot_list_tags(id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE bot_owner (
    id SERIAL,
    bot_id BIGINT not null,
    owner BIGINT not null,
    main BOOLEAN DEFAULT false,
    CONSTRAINT bots_fk FOREIGN KEY (bot_id) REFERENCES bots(bot_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE bot_packs (
   id uuid primary key DEFAULT uuid_generate_v4(),
   icon text,
   banner text,
   created_at timestamptz DEFAULT NOW(),
   owner bigint not null,
   bots bigint[] not null default '{}',
   description text not null,
   name text not null
);

CREATE TABLE bot_commands (
   id uuid not null DEFAULT uuid_generate_v4(),
   bot_id bigint not null,
   cmd_type integer not null, -- 0 = no, 1 = guild, 2 = global
   groups text[] not null default '{Default}',
   name text not null, -- command name
   vote_locked boolean not null default false, -- friendly name
   description text not null, -- command description
   args text[] not null default '{}', -- list of arguments
   examples text[] not null default '{}', -- examples
   premium_only boolean not null default false, -- premium status
   notes text[] not null default '{}', -- notes on said command
   doc_link text, -- link to documentation of command
   nsfw boolean default false,
   CONSTRAINT bots_fk FOREIGN KEY (bot_id) REFERENCES bots(bot_id) ON DELETE CASCADE ON UPDATE CASCADE,
   PRIMARY KEY (name)
);

CREATE TABLE bot_stats_votes_pm (
   bot_id bigint,
   month integer,
   votes bigint
);

CREATE TABLE bot_voters (
    bot_id bigint not null,
    user_id bigint not null,
    timestamps timestamptz[] not null DEFAULT '{NOW()}',
    CONSTRAINT users_fk FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE server_voters (
    guild_id bigint not null,
    user_id bigint not null,
    timestamps timestamptz[] not null DEFAULT '{NOW()}',
    CONSTRAINT users_fk FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE user_vote_table (
	user_id bigint PRIMARY KEY,
	bot_id bigint NOT NULL,
	expires_on timestamptz DEFAULT NOW() + '8 hours',
    CONSTRAINT users_fk FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE user_server_vote_table (
	user_id bigint PRIMARY KEY,
	guild_id bigint NOT NULL,
	expires_on timestamptz DEFAULT NOW() + '8 hours',
    CONSTRAINT users_fk FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE reviews (
   id uuid primary key DEFAULT uuid_generate_v4(),
   target_id bigint not null,
   target_type integer default 0,
   user_id bigint not null,
   star_rating numeric(4,2) not null default 0.0,
   review_text text not null,
   review_upvotes bigint[] not null default '{}',
   review_downvotes bigint[] not null default '{}',
   flagged boolean not null default false,
   epoch bigint[] not null default '{}',
   parent_id uuid REFERENCES reviews (id),
   CONSTRAINT users_fk FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

create index review_index on reviews (id, target_id, user_id, review_text, review_upvotes, review_downvotes, epoch, parent_id, target_type, star_rating, flagged, parent_id);

CREATE TABLE review_votes (
    id uuid not null REFERENCES reviews (id) ON DELETE CASCADE ON UPDATE CASCADE,
    user_id bigint not null,
    upvote BOOLEAN NOT NULL,
    CONSTRAINT users_fk FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY(id, user_id)
);


CREATE TABLE user_bot_logs (
    user_id BIGINT NOT NULL,
    bot_id BIGINT NOT NULL,
    action_time timestamptz NOT NULL DEFAULT NOW(),
    action integer not null, -- 0 = approve
    context text, -- Optional context field
    CONSTRAINT users_fk FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE bot_events (
    id uuid not null default uuid_generate_v4(),
    bot_id BIGINT NOT NULL,
    type integer not null,
    ts timestamptz not null default NOW(),
    reason text not null,
    css text not null default '',
    CONSTRAINT bots_fk FOREIGN KEY (bot_id) REFERENCES bots(bot_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE ws_events (
    id BIGINT not null, 
    type TEXT NOT NULL,
    ts timestamptz not null default now(),
    event jsonb not null
);

CREATE TABLE vanity (
    id SERIAL,
    type integer, -- 1 = bot, 2 = profile, 3 = server
    vanity_url text unique, -- This is the text I wish to match
    redirect bigint unique, -- What does this vanity resolve to
    redirect_text text unique-- For the future
);

CREATE TABLE servers (
    guild_id bigint not null unique,
    owner_id bigint not null,
    name_cached text not null default 'Unlisted',
    avatar_cached text default 'Unlisted',
    votes bigint default 0,   
    total_votes bigint default 0,
    webhook_type integer DEFAULT 1,
    webhook text,
    webhook_secret text,
    webhook_hmac_only boolean default false,
    description text not null default 'No description set',
    user_blacklist bigint[] not null default '{}',
    user_whitelist bigint[] not null default '{}',
    whitelist_form text,
    long_description text not null default 'No long description set! Set one with /settings longdesc Long description',
    long_description_type integer default 0,
    css text default '',
    api_token text not null unique,
    extra_links jsonb not null default '{}',
    created_at timestamptz not null default now(),
    invite_amount integer DEFAULT 0,
    invite_url text,
    invite_channel bigint,
    state int not null default 0,
    banner_card text,
    banner_page text,
    guild_count bigint default 0,
    tags text[] default '{}',
    old_state int not null default 0,
    flags integer[] not null default '{}',
    autorole_votes bigint[] default '{}',
    CONSTRAINT user_fk FOREIGN KEY (owner_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE user_connections (
   user_id bigint not null,
   client_id text not null,
   refresh_token text not null,
   expires_on timestamptz DEFAULT NOW() + interval '1 week',
   CONSTRAINT user_fk FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE server_audit_logs (
    guild_id bigint not null,
    user_id bigint not null,
    username text not null,
    user_guild_perms text not null, -- use text, u64 may overflow
    field text not null,
    value text not null,
    action_time timestamptz not null default now(),
    action_id uuid primary key default uuid_generate_v4(),
    CONSTRAINT servers_fk FOREIGN KEY (guild_id) REFERENCES servers(guild_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT user_fk FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- In server tags, owner_guild is the first guild a tag was given to
create table server_tags (id TEXT NOT NULL UNIQUE, name TEXT NOT NULL UNIQUE, iconify_data TEXT NOT NULL, owner_guild BIGINT NOT NULL);

create table frostpaw_clients (
	id text not null,
	name text not null,
	domain text not null,
	privacy_policy text not null,
	owner_id bigint not null,
	secret text not null,
	CONSTRAINT user_fk FOREIGN KEY (owner_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE push_notifications (
    id uuid primary key default uuid_generate_v4(),
    user_id bigint not null,
    endpoint text not null unique,
    bots bigint[] not null default '{}',
    servers bigint[] not null default '{}',
    p256dh text not null,
    auth text not null,
    CONSTRAINT user_fk FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE leave_of_absence (
    id serial primary key,
    user_id bigint not null,
    reason text not null,
    estimated_time interval not null,
    start_date timestamptz not null default now(),
    CONSTRAINT user_fk FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE lynx_exp_features (
    user_id bigint,
    features text[],
    CONSTRAINT users_fk FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE lynx_apps (
    user_id bigint,
    app_id uuid primary key DEFAULT uuid_generate_v4(),
    questions jsonb,
    answers jsonb,
    app_version integer,
    created_at timestamptz default NOW(),
    CONSTRAINT user_fk FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE lynx_logs (
    user_id bigint not null,
    method text not null,
    url text not null,
    status_code integer not null,
    request_time timestamptz default NOW(),
    CONSTRAINT user_fk FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE lynx_notifications (
    id uuid not null default uuid_generate_v4(),
    acked_users bigint[] not null default '{}', -- The users to send this to
    message text not null,
    staff_only boolean default false,
    type text not null -- alert etc
);

CREATE TABLE lynx_ratings (
    id uuid not null default uuid_generate_v4(),
    feedback text not null,
    page text not null,
    username_cached text not null,
    user_id bigint,
    CONSTRAINT users_fk FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE lynx_surveys (
    id uuid primary key default uuid_generate_v4(),
    title text not null,
    questions jsonb not null,
    created_at timestamptz default NOW()
);

CREATE TABLE lynx_survey_responses (
    id uuid not null default uuid_generate_v4(),
    survey_id uuid not null,
    questions jsonb not null,
    answers jsonb not null,
    username_cached text not null,
    user_id bigint,
    CONSTRAINT users_fk FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

create table lynx_data (id SERIAL PRIMARY KEY, default_user_experiments integer[]);

-- Be careful to not insert multiple
insert into lynx_data (default_user_experiments) VALUES ('{5,2,3}');
