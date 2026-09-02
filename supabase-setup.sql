-- ============================================================
-- SUPABASE SCHEMA FOR COMMUNITY ACTIVITY CRM
-- Run this entire script in your Supabase SQL Editor (1-click)
-- ============================================================

-- 1. Create the members table
create table if not exists public.members (
  id bigint primary key,
  name text not null,
  initials text,
  role text,
  space text,
  state text,
  last text,
  activities int default 0,
  owner text,
  "nextAction" text,
  color text,
  history jsonb default '[]'::jsonb,
  created_at timestamptz default now()
);

-- 2. Enable Row Level Security (RLS) and allow public CRUD operations
alter table public.members enable row level security;

drop policy if exists "Allow public read access" on public.members;
create policy "Allow public read access"
  on public.members for select
  using (true);

drop policy if exists "Allow public insert access" on public.members;
create policy "Allow public insert access"
  on public.members for insert
  with check (true);

drop policy if exists "Allow public update access" on public.members;
create policy "Allow public update access"
  on public.members for update
  using (true);

drop policy if exists "Allow public delete access" on public.members;
create policy "Allow public delete access"
  on public.members for delete
  using (true);

-- 3. Enable Realtime updates
alter publication supabase_realtime add table public.members;

-- 4. Seed initial 15 community members
insert into public.members (id, name, initials, role, space, state, last, activities, owner, "nextAction", color, history)
values
  (1, 'Aisha Mensah', 'AM', 'Product builder', 'Peer Circles', 'Highly active', 'Today', 18, 'Maya', 'Invite to host a circle', '#e36b46', '["Shared a funding resource in Peer Circles", "Joined Founder Friday", "Welcomed two new members"]'::jsonb),
  (2, 'Theo Martins', 'TM', 'Freelance designer', 'Skill Swaps', 'Active', 'Yesterday', 9, 'Maya', 'Check in after workshop', '#487b8c', '["Offered brand feedback in Skill Swaps", "Attended Creative Ops workshop"]'::jsonb),
  (3, 'Priya Shah', 'PS', 'Community researcher', 'Open Forum', 'Newly joined', '2 days ago', 2, 'Jordan', 'Make a peer introduction', '#b17a45', '["Introduced herself in Open Forum", "Saved a discussion on inclusive research"]'::jsonb),
  (4, 'Jon Bell', 'JB', 'Operations lead', 'Office Hours', 'At risk', '12 days ago', 6, 'Maya', 'Send a human check-in', '#8166a8', '["Booked an Office Hours slot", "Asked about member benefits"]'::jsonb),
  (5, 'Nia Okafor', 'NO', 'Social entrepreneur', 'Founder Friday', 'Highly active', 'Today', 22, 'Jordan', 'Nominate for member spotlight', '#c45a70', '["Posted a grant opportunity", "Attended Founder Friday", "Introduced Ravi to the finance circle"]'::jsonb),
  (6, 'Marcus Lee', 'ML', 'Impact investor', 'Open Forum', 'Active', '3 days ago', 11, 'Maya', 'Invite to the capital Q&A', '#5b8f78', '["Answered a question about impact metrics", "Commented on a community thread"]'::jsonb),
  (7, 'Ravi Kumar', 'RK', 'Early-stage founder', 'Peer Circles', 'Active', '4 days ago', 8, 'Jordan', 'Share peer circle options', '#3f75a3', '["Joined a peer circle", "Reacted to a founder introduction"]'::jsonb),
  (8, 'Sofia Chen', 'SC', 'Finance educator', 'Skill Swaps', 'Highly active', 'Yesterday', 16, 'Maya', 'Ask about leading a session', '#d4934d', '["Hosted a budgeting skill swap", "Commented on three discussions"]'::jsonb),
  (9, 'Daniel Reed', 'DR', 'Marketing strategist', 'Open Forum', 'Dormant', '31 days ago', 3, 'Jordan', 'Offer a low-friction re-entry', '#707786', '["Joined the community", "Read the welcome thread"]'::jsonb),
  (10, 'Leila Haddad', 'LH', 'Program manager', 'Office Hours', 'Active', '5 days ago', 10, 'Maya', 'Follow up on office hours', '#9e6b82', '["Booked office hours", "Shared an event recap"]'::jsonb),
  (11, 'Owen Wright', 'OW', 'Data analyst', 'Peer Circles', 'At risk', '16 days ago', 5, 'Jordan', 'Ask what would be useful now', '#4d847e', '["Joined a peer circle", "Reacted to a resource"]'::jsonb),
  (12, 'Amara Joseph', 'AJ', 'Nonprofit founder', 'Founder Friday', 'Highly active', 'Today', 20, 'Maya', 'Connect with impact peers', '#c7713f', '["Attended Founder Friday", "Shared a hiring resource", "Welcomed a new member"]'::jsonb),
  (13, 'Eli Novak', 'EN', 'Product manager', 'Skill Swaps', 'Newly joined', '1 day ago', 1, 'Jordan', 'Invite to a first event', '#5c729b', '["Completed onboarding profile"]'::jsonb),
  (14, 'Grace Kim', 'GK', 'Creative director', 'Open Forum', 'Dormant', '45 days ago', 4, 'Maya', 'Review before outreach', '#8a7a5e', '["Posted an introduction", "Saved a discussion"]'::jsonb),
  (15, 'Samira Cole', 'SC', 'Policy fellow', 'Office Hours', 'Active', '6 days ago', 7, 'Jordan', 'Share policy circle details', '#bf6370', '["Attended an office hour", "Asked a thoughtful question"]'::jsonb)
on conflict (id) do nothing;
