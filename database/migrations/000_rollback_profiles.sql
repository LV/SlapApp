-- Rollback script to drop profiles table and related objects
-- Run this if you need to start fresh or undo the profiles setup

drop trigger if exists on_auth_user_created on auth.users;

drop function if exists public.handle_new_user();

drop table if exists public.profiles cascade;
