import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String grad = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Card(
          child: TextField(
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search), hintText: 'Pretraga...'),
              onChanged: (val) {
                setState(() {
                  grad = val;
                });
              }),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: (grad != "" && grad != null)
            ? FirebaseFirestore.instance
                .collection('vreme')
                .where("searchKey", arrayContains: grad)
                .snapshots()
            : FirebaseFirestore.instance.collection('vreme').snapshots(),
        builder: (context, snapshot) {
          return (snapshot.connectionState == ConnectionState.waiting)
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot data = snapshot.data!.docs[index];
                    return Container(
                      padding: EdgeInsets.only(top: 16),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              data['grad'],
                            ),
                            subtitle: Text(
                              data['vremee'] + ' ' + data['temperatura'],
                            ),
                          ),
                          Divider(
                            thickness: 2,
                          )
                        ],
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
