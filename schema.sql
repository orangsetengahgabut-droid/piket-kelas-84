-- ============================================================
-- Piket Kelas - schema.sql (Supabase / PostgreSQL)
-- Jalankan seluruh file ini di Supabase > SQL Editor > Run
-- ============================================================

create extension if not exists pgcrypto with schema extensions;

-- ---------- Tabel ----------
create table if not exists public.students (
  id         bigint generated always as identity primary key,
  name       text not null unique check (char_length(trim(name)) between 1 and 60),
  created_at timestamptz not null default now()
);

create table if not exists public.duties (
  id        bigint generated always as identity primary key,
  duty_date date   not null,
  student_id bigint not null references public.students(id) on delete cascade,
  status    text   not null default 'piket' check (status in ('piket', 'tidak', 'kabur')),
  unique (duty_date, student_id)
);

create index if not exists duties_date_idx on public.duties (duty_date);

-- Tempat menyimpan hash password admin (tidak bisa dibaca publik)
create table if not exists public.settings (
  key   text primary key,
  value text not null
);

-- Password admin: naz  (disimpan sebagai hash bcrypt, bukan teks asli)
insert into public.settings (key, value)
values ('admin_password_hash', extensions.crypt('naz', extensions.gen_salt('bf')))
on conflict (key) do nothing;

-- ---------- Keamanan (RLS) ----------
-- Pengunjung hanya boleh MEMBACA students & duties.
-- Tidak ada policy insert/update/delete, jadi semua perubahan hanya lewat fungsi admin_* di bawah.
alter table public.students enable row level security;
alter table public.duties   enable row level security;
alter table public.settings enable row level security;

drop policy if exists "baca students" on public.students;
drop policy if exists "baca duties"   on public.duties;
create policy "baca students" on public.students for select to anon, authenticated using (true);
create policy "baca duties"   on public.duties   for select to anon, authenticated using (true);

revoke all on public.students, public.duties, public.settings from anon, authenticated;
grant select on public.students, public.duties to anon, authenticated;

-- ---------- Fungsi admin (cek password di server) ----------
create or replace function public.admin_check(p_password text)
returns boolean
language sql security definer set search_path = public, extensions
as $$
  select exists (
    select 1 from public.settings
    where key = 'admin_password_hash' and value = crypt(p_password, value)
  );
$$;

create or replace function public.admin_add_student(p_password text, p_name text)
returns void
language plpgsql security definer set search_path = public, extensions
as $$
begin
  if not public.admin_check(p_password) then raise exception 'Password salah'; end if;
  insert into public.students (name) values (trim(p_name)) on conflict (name) do nothing;
end;
$$;

create or replace function public.admin_delete_student(p_password text, p_id bigint)
returns void
language plpgsql security definer set search_path = public, extensions
as $$
begin
  if not public.admin_check(p_password) then raise exception 'Password salah'; end if;
  delete from public.students where id = p_id;
end;
$$;

-- p_items contoh: [{"student_id": 1, "status": "piket"}, {"student_id": 2, "status": "kabur"}]
create or replace function public.admin_save_date(p_password text, p_date date, p_items jsonb)
returns void
language plpgsql security definer set search_path = public, extensions
as $$
begin
  if not public.admin_check(p_password) then raise exception 'Password salah'; end if;
  if p_date < date '2026-10-05' or p_date > date '2026-10-31' then
    raise exception 'Tanggal di luar jadwal Oktober 2026';
  end if;
  delete from public.duties where duty_date = p_date;
  insert into public.duties (duty_date, student_id, status)
  select p_date, (i->>'student_id')::bigint, i->>'status'
  from jsonb_array_elements(p_items) i
  on conflict (duty_date, student_id) do update set status = excluded.status;
end;
$$;

create or replace function public.admin_delete_date(p_password text, p_date date)
returns void
language plpgsql security definer set search_path = public, extensions
as $$
begin
  if not public.admin_check(p_password) then raise exception 'Password salah'; end if;
  delete from public.duties where duty_date = p_date;
end;
$$;

revoke all on function public.admin_check(text), public.admin_add_student(text, text),
  public.admin_delete_student(text, bigint), public.admin_save_date(text, date, jsonb),
  public.admin_delete_date(text, date) from public;
grant execute on function public.admin_check(text), public.admin_add_student(text, text),
  public.admin_delete_student(text, bigint), public.admin_save_date(text, date, jsonb),
  public.admin_delete_date(text, date) to anon, authenticated;

-- ---------- (Opsional) contoh data ----------
-- insert into public.students (name) values ('Helmi') on conflict do nothing;
