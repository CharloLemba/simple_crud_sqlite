import 'package:flutter/material.dart';
import 'package:simple_crud_sqlite/database/database_helper.dart';

class SimpleCrud extends StatefulWidget {
  const SimpleCrud({super.key});

  @override
  State<SimpleCrud> createState() => _SimpleCrudState();
}

class _SimpleCrudState extends State<SimpleCrud> {
  final TextEditingController _controller = TextEditingController();

  // Fungsi Simpan Data (Create)
  void _saveData() async {
    String teksInput = _controller.text.trim();
    if (teksInput.isEmpty) return;

    await DatabaseHelper.instance.insertData(Data(id: null, teks: teksInput));
    _controller.clear();
    FocusScope.of(context).unfocus();

    // setState atau fungsi reload data dipanggil di sini nanti
    setState(() {});
  }

  // Fungsi Hapus Data (Delete) Berdasarkan ID
  void _deleteData(int id) async {
    await DatabaseHelper.instance.deleteData(id);

    // Refresh tampilan setelah dihapus
    setState(() {});

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Data berhasil dihapus!")));
  }

  // Fungsi Edit / Update Data (Memunculkan Dialog Input Edit)
  void _showEditDialog(Data itemData) {
    // Controller khusus untuk dialog edit, diisi teks yang lama
    TextEditingController editController = TextEditingController(
      text: itemData.teks,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Data"),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(
              labelText: "Ubah Teks",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Batal
              child: Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                String updatedText = editController.text.trim();
                if (updatedText.isNotEmpty) {
                  // Jalankan fungsi update ke SQLite
                  await DatabaseHelper.instance.updateData(
                    Data(id: itemData.id, teks: updatedText),
                  );

                  // Tutup dialog
                  Navigator.pop(context);

                  // Refresh tampilan
                  setState(() {});

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Data berhasil diubah!")),
                  );
                }
              },
              child: Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black,
        title: Text(
          "Simple CRUD - SQLite",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Card(
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'Masukkan Teks',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 5,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Submit!",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // BAGIAN LIST VIEW & READ DATA DARI SQLITE
            Expanded(
              child: FutureBuilder<List<Data>>(
                future: DatabaseHelper.instance
                    .getData(), // Mengambil data dari SQLite
                builder: (context, snapshot) {
                  // Kalau data masih loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  // Kalau data kosong atau belum ada
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("Belum ada data tersimpan."));
                  }

                  final dataList = snapshot.data!;

                  return ListView.builder(
                    itemCount: dataList.length,
                    itemBuilder: (context, index) {
                      final item = dataList[index];
                      return ListTile(
                        title: Text(item.teks),
                        subtitle: Text("ID: ${item.id}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tombol Edit
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.black),
                              onPressed: () {
                                // Panggil dialog edit dengan membawa data item saat ini
                                _showEditDialog(item);
                              },
                            ),
                            SizedBox(width: 5),
                            // Tombol Delete
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Panggil fungsi hapus berdasarkan ID item
                                if (item.id != null) {
                                  _deleteData(item.id!);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
