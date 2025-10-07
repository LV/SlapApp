-- Automatically create a profile entry when a new user signs up
-- This trigger ensures every auth.users entry has a corresponding profiles entry

-- Function to handle new user creation
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id)
  values (new.id);
  return new;
end;
$$ language plpgsql security definer;

-- Trigger that fires after a new user is inserted into auth.users
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
