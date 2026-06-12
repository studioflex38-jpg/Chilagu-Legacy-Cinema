import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String ADMIN_PASSWORD = "ChilaguCinemaPro";
const String BIASHARA_NUMBER = "0686436004";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("FIREBASE IMEGOMA: $e");
  }
  runApp(const ChilaguCinemaApp());
}

class ChilaguCinemaApp extends StatelessWidget {
  const ChilaguCinemaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chilagu Legacy Cinema',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _inaLoad = false;
  bool _niUsajili = false;

  void _login() async {
    setState(() => _inaLoad = true);
    if (_emailController.text.trim() == ADMIN_PASSWORD || _passwordController.text.trim() == ADMIN_PASSWORD) {
      _ingiaAdmin();
      return;
    }
    try {
      final users = await FirebaseFirestore.instance
       .collection("wateja")
       .where("email", isEqualTo: _emailController.text.trim())
       .where("password", isEqualTo: _passwordController.text.trim())
       .get();
      if (users.docs.isNotEmpty) {
        _ingiaMteja(users.docs.first.id);
      } else {
        _showError("Email au Password sio sahihi");
      }
    } catch (e) {
      _showError("Imeshindwa kuingia: $e");
    }
    setState(() => _inaLoad = false);
  }

  void _jisajili() async {
    if (_emailController.text.isEmpty || _passwordController.text.length < 6) {
      _showError("Jaza email sahihi na password ya herufi 6+");
      return;
    }
    setState(() => _inaLoad = true);
    try {
      final existing = await FirebaseFirestore.instance
       .collection("wateja")
       .where("email", isEqualTo: _emailController.text.trim())
       .get();
      if (existing.docs.isNotEmpty) {
        _showError("Email hii imesajiliwa tayari");
      } else {
        await FirebaseFirestore.instance.collection("wateja").add({
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
          "tarehe": Timestamp.now(),
          "salio_siku": 0,
        });
        _showSuccess("Umesajiliwa! Ingia sasa");
        setState(() => _niUsajili = false);
      }
    } catch (e) {
      _showError("Imeshindwa kujisajili: $e");
    }
    setState(() => _inaLoad = false);
  }

  void _ingiaAdmin() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
  }

  void _ingiaMteja(String userId) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserHomePage(userId: userId)));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.movie_filter, size: 100, color: Colors.deepPurple),
              const SizedBox(height: 16),
              const Text("CHILAGU LEGACY CINEMA", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              Text(_niUsajili? "JISAJILI" : "INGIA", style: const TextStyle(color: Colors.deepPurple, fontSize: 18)),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 30),
              _inaLoad
             ? const CircularProgressIndicator(color: Colors.deepPurple)
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _niUsajili? _jisajili : _login,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                      child: Text(_niUsajili? "JISAJILI" : "INGIA", style: const TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => setState(() => _niUsajili =!_niUsajili),
                child: Text(_niUsajili? "Una akaunti? Ingia" : "Huna akaunti? Jisajili", style: const TextStyle(color: Colors.deepPurple)),
              ),
              const SizedBox(height: 20),
              Text("Namba ya Malipo: $BIASHARA_NUMBER", style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class UserHomePage extends StatefulWidget {
  final String userId;
  const UserHomePage({super.key, required this.userId});
  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chilagu Cinema"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("movies").orderBy("tarehe", descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text("Hakuna movie bado. Subiri Admin apakie", style: TextStyle(color: Colors.white)));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var movie = snapshot.data!.docs[index];
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: const Icon(Icons.movie, size: 40, color: Colors.deepPurple),
                  title: Text(movie["jina"], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text("Tsh ${movie["bei"]}", style: const TextStyle(color: Colors.deepPurple)),
                  trailing: ElevatedButton(
                    onPressed: () => _showLipiaDialog(movie),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                    child: const Text("LIPIA", style: TextStyle(color: Colors.white)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showLipiaDialog(QueryDocumentSnapshot movie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(movie["jina"], style: const TextStyle(color: Colors.white)),
        content: Text("Lipia Tsh ${movie["bei"]} kwenda $BIASHARA_NUMBER kisha tuma screenshot kwa admin", style: const TextStyle(color: Colors.grey)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Sawa"))],
      ),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String nambaYaMalipo = BIASHARA_NUMBER;
  String beiSiku = "1000";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nambaYaMalipo = prefs.getString("namba")?? BIASHARA_NUMBER;
      beiSiku = prefs.getString("beiSiku")?? "1000";
    });
  }

  Future<void> _hifadhiSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("namba", nambaYaMalipo);
    await prefs.setString("beiSiku", beiSiku);
    try {
      await FirebaseFirestore.instance.collection("settings").doc("malipo").set({"namba": nambaYaMalipo, "bei_siku": beiSiku});
    } catch (e) {}
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Zimehifadhiwa"), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.movie_filter, size: 60, color: Colors.deepPurple),
          const SizedBox(height: 10),
          const Text("Karibu Admin wa Chilagu Cinema Pro", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          Card(
            color: Colors.grey[900],
            child: ListTile(
              leading: const Icon(Icons.cloud_upload, size: 40, color: Colors.deepPurple),
              title: const Text("Upload Movie Mpya", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: const Text("Weka jina na bei ya movie", style: TextStyle(color: Colors.grey)),
              onTap: () => _showUploadDialog(),
            ),
          ),
          Card(
            color: Colors.grey[900],
            child: ListTile(
              leading: const Icon(Icons.payment, size: 40, color: Colors.deepPurple),
              title: const Text("Panga Malipo", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text("Namba: $nambaYaMalipo | Siku: Tsh $beiSiku", style: const TextStyle(color: Colors.grey)),
              onTap: () => _showSettingsDialog(),
            ),
          ),
          Card(
            color: Colors.grey[900],
            child: ListTile(
              leading: const Icon(Icons.people, size: 40, color: Colors.deepPurple),
              title: const Text("Watumiaji", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: const Text("Ona wateja waliojisajili", style: TextStyle(color: Colors.grey)),
              onTap: () => _showWateja(),
            ),
          ),
          Card(
            color: Colors.grey[900],
            child: ListTile(
              leading: const Icon(Icons.list, size: 40, color: Colors.deepPurple),
              title: const Text("Movie Zote", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: const Text("Futa au badilisha movie", style: TextStyle(color: Colors.grey)),
              onTap: () => _showMoviesList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showWateja() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const WatejaPage()));
  }

  void _showMoviesList() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const MoviesListPage()));
  }

  void _showUploadDialog() {
    final jinaController = TextEditingController();
    final beiController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Pakia Movie Mpya", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: jinaController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Jina la Movie"),
            ),
            TextField(
              controller: beiController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Bei Tsh"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            const Text("KUMBUKA: Video halisi utaipakia kwenye APK. Hapa ni jina na bei tu", style: TextStyle(color: Colors.orange, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Ghairi")),
          ElevatedButton(
            onPressed: () async {
              if (jinaController.text.isNotEmpty && beiController.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection("movies").add({
                  "jina": jinaController.text.trim(),
                  "bei": beiController.text.trim(),
                  "tarehe": Timestamp.now(),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Movie imeongezwa"), backgroundColor: Colors.green));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text("HIFADHI", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Badilisha Settings", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (val) => nambaYaMalipo = val,
              controller: TextEditingController(text: nambaYaMalipo),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Namba ya Malipo"),
            ),
            TextField(
              onChanged: (val) => beiSiku = val,
              controller: TextEditingController(text: beiSiku),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Bei Siku 1"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Funga")),
          ElevatedButton(
            onPressed: () {
              _hifadhiSettings();
              Navigator.pop(context);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text("HIFADHI", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class WatejaPage extends StatelessWidget {
  const WatejaPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wateja Waliosajiliwa"), backgroundColor: Colors.deepPurple),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("wateja").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var mteja = snapshot.data!.docs[index];
              return ListTile(
                leading: const Icon(Icons.person, color: Colors.deepPurple),
                title: Text(mteja["email"], style: const TextStyle(color: Colors.white)),
                subtitle: Text("Salio: ${mteja["salio_siku"]} siku", style: const TextStyle(color: Colors.grey)),
              );
            },
          );
        },
      ),
    );
  }
}

class MoviesListPage extends StatelessWidget {
  const MoviesListPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Movie Zote"), backgroundColor: Colors.deepPurple),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("movies").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var movie = snapshot.data!.docs[index];
              return ListTile(
                leading: const Icon(Icons.movie, color: Colors.deepPurple),
                title: Text(movie["jina"], style: const TextStyle(color: Colors.white)),
                subtitle: Text("Tsh ${movie["bei"]}", style: const TextStyle(color: Colors.grey)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => FirebaseFirestore.instance.collection("movies").doc(movie.id).delete(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}