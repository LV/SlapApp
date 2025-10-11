-- Add constraints for username validation
-- This ensures usernames follow the rules even if bypassing the app

-- Add check constraint for username format
-- Only allows alphanumeric characters, dashes, and underscores
alter table profiles
add constraint username_format_check
check (username ~ '^[a-zA-Z0-9_-]*$');

-- Add check constraint for username length
-- Maximum 32 characters
alter table profiles
add constraint username_length_check
check (length(username) <= 32);

-- Add check constraint to prevent empty usernames if set
-- Username can be null, but if set, it must not be empty
alter table profiles
add constraint username_not_empty_check
check (username is null or length(trim(username)) > 0);
