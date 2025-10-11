-- Add function to validate display name in auth metadata
-- This function will be used in a trigger to validate full_name

create or replace function validate_auth_metadata()
returns trigger as $$
begin
  -- Check if full_name exists in metadata
  if NEW.raw_user_meta_data ? 'full_name' then
    declare
      full_name text := NEW.raw_user_meta_data->>'full_name';
    begin
      -- Check length (max 64 characters)
      if length(full_name) > 64 then
        raise exception 'Display name must be 64 characters or less';
      end if;

      -- Check for control characters and harmful characters
      -- Block ASCII control chars (0x00-0x1F, 0x7F) and angle brackets
      if full_name ~ '[\x00-\x1F\x7F<>]' then
        raise exception 'Display name contains invalid characters';
      end if;
    end;
  end if;

  return NEW;
end;
$$ language plpgsql;

-- Create trigger to validate metadata on insert and update
create trigger validate_auth_metadata_trigger
  before insert or update on auth.users
  for each row
  execute function validate_auth_metadata();
