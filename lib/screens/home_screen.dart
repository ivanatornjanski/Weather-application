import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vremenska_prognoza/model/user_model.dart';
import 'package:vremenska_prognoza/screens/registration_screen.dart';
import 'package:vremenska_prognoza/screens/search_page.dart';

import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _gradController = TextEditingController();
  final TextEditingController _vremeeController = TextEditingController();
  final TextEditingController _temperaturaController = TextEditingController();

  final CollectionReference _vreme =
      FirebaseFirestore.instance.collection('vreme');

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _gradController.text = documentSnapshot['grad'];
      _vremeeController.text = documentSnapshot['vremee'];
      _temperaturaController.text = documentSnapshot['temperatura'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _gradController,
                  decoration: const InputDecoration(
                      labelText: 'Grad', prefixIcon: Icon(Icons.add_location)),
                ),
                TextField(
                    controller: _vremeeController,
                    decoration: const InputDecoration(
                        labelText: 'Oblačno/vedro/sunčano',
                        prefixIcon: Icon(Icons.sunny_snowing))),
                TextField(
                  controller: _temperaturaController,
                  decoration: const InputDecoration(
                      labelText: 'Temp (npr. 13°C)',
                      prefixIcon: Icon(Icons.device_thermostat)),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Kreiraj' : 'Izmeni'),
                  onPressed: () async {
                    final String? grad = _gradController.text;
                    final String? vremee = _vremeeController.text;
                    final String? temperatura =
                        _temperaturaController.text + '°C';

                    if (grad != null && vremee != null && temperatura != null) {
                      if (action == 'create') {
                        // Dodavanje proizvoda
                        await _vreme.add({
                          "grad": grad,
                          "vremee": vremee,
                          "temperatura": temperatura
                        });
                      }

                      if (action == 'update') {
                        // Update proizvoda
                        await _vreme.doc(documentSnapshot!.id).update({
                          "grad": grad,
                          "vreme": vremee,
                          "temperatura": temperatura
                        });
                      }
                      _gradController.text = '';
                      _vremeeController.text = '';
                      _temperaturaController.text = '';

                      // sakrivanje prozora
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  // Brisanje proizvoda po id
  Future<void> _delete(String vremeId) async {
    await _vreme.doc(vremeId).delete();

    // poruka nakon uspešno obrisanih zadataka
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uspešno ste obrisali podatke')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vremenska prognoza"),
        centerTitle: false,
        actions: [
          // preusmeravanje na pretraga stranicu
          IconButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => SearchPage())),
              icon: Icon(Icons.search))
        ],
      ),
      body: StreamBuilder(
        stream: _vreme.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['grad']),
                    subtitle: Text(documentSnapshot['vremee'] +
                        ' ' +
                        documentSnapshot['temperatura']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          // dugme za edit
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _createOrUpdate(documentSnapshot)),
                          // dugme za brisanje
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _delete(documentSnapshot.id)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      // odjava i dodavanje dugmici

      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton(
              onPressed: () {
                logout(context);
              },
              child: Icon(Icons.logout),
            ),
            FloatingActionButton(
              onPressed: () => _createOrUpdate(),
              child: Icon(Icons.add),
            )
          ],
        ),
      ),
    );
  }

  // funkcija za odjavu
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}
