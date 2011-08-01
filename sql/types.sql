CREATE TYPE block_types as enum ('none','raw_html','inline_css','parse','html_head','dyn_head','full_doc','full_html','paginate');

CREATE TYPE statuses as enum ('inactive','active');

CREATE TYPE texts as enum ('master_select','block_content','block_options');
