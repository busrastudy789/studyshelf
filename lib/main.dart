import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Android emulator -> XAMPP on host. For a real phone use your PC's LAN IP.
const base = 'http://172.16.114.96/studyshelf/api.php';

Future<dynamic> api(String action, [Map? body]) async {
  final p = await SharedPreferences.getInstance();
  try {
    final r = await http.post(Uri.parse('$base?action=$action'),
        headers: {'Content-Type': 'application/json', 'X-Token': p.getString('token') ?? ''},
        body: jsonEncode(body ?? {}));
    return jsonDecode(r.body);
  } catch (_) {
    return {'error': 'Cannot reach server'};
  }
}

void main() => runApp(const StudyShelf());

class StudyShelf extends StatelessWidget {
  const StudyShelf({super.key});
  @override
  Widget build(BuildContext c) => MaterialApp(
        title: 'StudyShelf',
        theme: ThemeData(colorSchemeSeed: const Color(0xFF004AAD), useMaterial3: true),
        home: const Gate(),
      );
}

class Gate extends StatefulWidget {
  const Gate({super.key});
  @override
  State<Gate> createState() => _GateState();
}

class _GateState extends State<Gate> {
  bool? loggedIn;
  @override
  void initState() {
    super.initState();
    check();
  }

  Future<void> check() async {
    final r = await api('me');
    setState(() => loggedIn = r is Map && r['error'] == null);
  }

  @override
  Widget build(BuildContext c) {
    if (loggedIn == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return loggedIn! ? Home(onLogout: () => setState(() => loggedIn = false)) : AuthPage(onDone: () => setState(() => loggedIn = true));
  }
}

class AuthPage extends StatefulWidget {
  final VoidCallback onDone;
  const AuthPage({super.key, required this.onDone});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final u = TextEditingController(), p = TextEditingController();
  bool reg = false;
  String? err;
  Future<void> submit() async {
    final r = await api(reg ? 'register' : 'login', {'username': u.text, 'password': p.text});
    if (r['token'] != null) {
      (await SharedPreferences.getInstance()).setString('token', r['token']);
      widget.onDone();
    } else {
      setState(() => err = r['error']);
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('📚 StudyShelf', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Color(0xFF004AAD))),
            const SizedBox(height: 24),
            TextField(controller: u, decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: p, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
            if (err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(err!, style: const TextStyle(color: Colors.red))),
            const SizedBox(height: 16),
            FilledButton(onPressed: submit, child: Text(reg ? 'Create account' : 'Log in')),
            TextButton(onPressed: () => setState(() => reg = !reg), child: Text(reg ? 'Have an account? Log in' : 'New here? Register')),
          ]),
        ),
      );
}

class Home extends StatefulWidget {
  final VoidCallback onLogout;
  const Home({super.key, required this.onLogout});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0;
  Map user = {'coins': 0, 'streak': 0, 'username': ''};
  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    final r = await api('me');
    if (r['error'] == null) setState(() => user = r);
  }

  void setUser(Map u) => setState(() => user = u);

  @override
  Widget build(BuildContext c) {
    final pages = [
      TimerPage(onUser: setUser),
      ShopPage(onUser: setUser),
      const ShelfPage(),
      const HistoryPage(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('🪙 ${user['coins']}   🔥 ${user['streak']}'),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                (await SharedPreferences.getInstance()).remove('token');
                widget.onLogout();
              })
        ],
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.timer), label: 'Focus'),
          NavigationDestination(icon: Icon(Icons.storefront), label: 'Store'),
          NavigationDestination(icon: Icon(Icons.shelves), label: 'Shelf'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}

class TimerPage extends StatefulWidget {
  final void Function(Map) onUser;
  const TimerPage({super.key, required this.onUser});
  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  int minutes = 25, left = 0;
  final subject = TextEditingController(text: 'General');
  Timer? t;
  bool get running => t != null;

  void start() {
    left = minutes * 60;
    t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (--left <= 0) {
        finish(true);
      } else {
        setState(() {});
      }
    });
    setState(() {});
  }

  Future<void> finish(bool done) async {
    t?.cancel();
    t = null;
    final r = await api('save_session', {'subject': subject.text, 'minutes': minutes, 'completed': done});
    if (r['user'] != null) widget.onUser(r['user']);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done ? 'Session complete! +${r['earned']} coins 🪙' : 'Session abandoned. No coins earned.')));
    }
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  String fmt(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext c) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(fmt(running ? left : minutes * 60), style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          if (!running) ...[
            TextField(controller: subject, decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            Wrap(spacing: 8, children: [
              for (final m in [1, 15, 25, 30, 45, 60]) ChoiceChip(label: Text('$m min'), selected: minutes == m, onSelected: (_) => setState(() => minutes = m))
            ]),
            const SizedBox(height: 24),
            FilledButton.icon(onPressed: start, icon: const Icon(Icons.play_arrow), label: const Text('Start focus')),
            const SizedBox(height: 8),
            const Text('1 minute studied = 1 Study Coin', style: TextStyle(color: Colors.grey)),
          ] else
            OutlinedButton(onPressed: () => finish(false), child: const Text('Give up')),
        ]),
      );
}

const rarityColor = {'Common': Colors.grey, 'Rare': Colors.blue, 'Epic': Colors.purple, 'Legendary': Colors.orange};

class ShopPage extends StatefulWidget {
  final void Function(Map) onUser;
  const ShopPage({super.key, required this.onUser});
  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  List items = [];
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final r = await api('shop');
    if (r is List) setState(() => items = r);
  }

  Future<void> buy(Map i) async {
    final r = await api('unlock', {'collectible_id': int.parse('${i['id']}')});
    if (r['user'] != null) widget.onUser(r['user']);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r['error'] ?? 'Unlocked ${i['name']}!')));
    load();
  }

  @override
  Widget build(BuildContext c) => ListView(children: [
        for (final i in items)
          ListTile(
            leading: Text(i['emoji'], style: const TextStyle(fontSize: 32)),
            title: Text(i['name']),
            subtitle: Text(i['rarity'], style: TextStyle(color: rarityColor[i['rarity']], fontWeight: FontWeight.w600)),
            trailing: '${i['owned']}' == '1' ? const Icon(Icons.check_circle, color: Colors.green) : FilledButton(onPressed: () => buy(i), child: Text('🪙 ${i['cost']}')),
          )
      ]);
}

class ShelfPage extends StatefulWidget {
  const ShelfPage({super.key});
  @override
  State<ShelfPage> createState() => _ShelfPageState();
}

class _ShelfPageState extends State<ShelfPage> {
  List owned = [];
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final r = await api('shelf');
    if (r is List) setState(() => owned = r);
  }

  Map? at(int pos) {
    for (final o in owned) {
      if (o['shelf_pos'] != null && int.parse('${o['shelf_pos']}') == pos) return o;
    }
    return null;
  }

  Future<void> tapSlot(int pos) async {
    final cur = at(pos);
    final free = owned.where((o) => o['shelf_pos'] == null).toList();
    final choice = await showModalBottomSheet<Object>(
        context: context,
        builder: (_) => ListView(children: [
              if (cur != null) ListTile(leading: const Icon(Icons.remove_circle_outline), title: Text('Remove ${cur['name']}'), onTap: () => Navigator.pop(context, 'remove')),
              for (final o in free) ListTile(leading: Text(o['emoji'], style: const TextStyle(fontSize: 28)), title: Text(o['name']), subtitle: Text(o['rarity']), onTap: () => Navigator.pop(context, o)),
              if (free.isEmpty && cur == null) const ListTile(title: Text('Nothing to place. Unlock figurines in the Store!')),
            ]));
    if (choice == 'remove') {
      await api('place', {'collectible_id': int.parse('${cur!['id']}'), 'pos': null});
    } else if (choice is Map) {
      if (cur != null) await api('place', {'collectible_id': int.parse('${cur['id']}'), 'pos': null});
      await api('place', {'collectible_id': int.parse('${choice['id']}'), 'pos': pos});
    }
    load();
  }

  @override
  Widget build(BuildContext c) => Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, children: [
          for (var i = 0; i < 9; i++)
            InkWell(
              onTap: () => tapSlot(i),
              child: Container(
                decoration: BoxDecoration(color: Colors.brown.shade100, borderRadius: BorderRadius.circular(12), border: Border(bottom: BorderSide(color: Colors.brown.shade400, width: 6))),
                child: Center(child: at(i) == null ? const Icon(Icons.add, color: Colors.black26) : Text(at(i)!['emoji'], style: const TextStyle(fontSize: 48))),
              ),
            )
        ]),
      );
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});
  @override
  Widget build(BuildContext c) => FutureBuilder(
        future: api('history'),
        builder: (_, s) {
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          final l = s.data is List ? s.data as List : [];
          if (l.isEmpty) return const Center(child: Text('No sessions yet'));
          return ListView(children: [
            for (final h in l)
              ListTile(
                leading: Icon('${h['completed']}' == '1' ? Icons.check_circle : Icons.cancel, color: '${h['completed']}' == '1' ? Colors.green : Colors.red),
                title: Text('${h['subject']} · ${h['duration_min']} min'),
                subtitle: Text('${h['created_at']}'),
              )
          ]);
        },
      );
}
