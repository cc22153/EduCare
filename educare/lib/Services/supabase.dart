import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://cooykjcewfdvmxkvlczq.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNvb3lramNld2Zkdm14a3ZsY3pxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI4ODkxNTIsImV4cCI6MjA2ODQ2NTE1Mn0.kOb-dTqDB15A2Z72nZA_0wgIXPITHivqWXXLLTidOgI'
  );

}