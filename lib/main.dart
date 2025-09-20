import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // Quita la etiqueta "debug"
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _guardarCitaDemo(BuildContext context) async {
    await FirebaseFirestore.instance.collection('DocApp').add({
      'paciente': 'Juan Perez',
      'motivo': 'Dolor de cabeza',
      'fecha': DateTime.now(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita guardada exitosamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo Firebase')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => _guardarCitaDemo(context),
            child: const Text('Guardar Cita Demo'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('DocApp').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay citas registradas'));
                }

                final citas = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: citas.length,
                  itemBuilder: (context, index) {
                    final cita = citas[index];
                    return ListTile(
                      title: Text("Paciente: ${cita['paciente']}"),
                      subtitle: Text(
                        "Motivo: ${cita['motivo']} \nFecha: ${cita['fecha'].toDate()}",
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
