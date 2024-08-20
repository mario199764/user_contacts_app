// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ContactsScreen extends StatefulWidget {
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Map<String, dynamic>> contacts = [];
  List<Map<String, dynamic>> filteredContacts = [];
  TextEditingController searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  final ValueNotifier<bool> _isButtonEnabled = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    if (userId != null) {
      _loadContacts(userId);
      searchController.addListener(_filterContacts);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _isButtonEnabled.dispose();
    super.dispose();
  }

  void _loadContacts(int userId) async {
    contacts = await _databaseService.fetchContacts(userId: userId);
    setState(() {
      filteredContacts = contacts;
    });
  }

  void _filterContacts() {
    final query = searchController.text;
    if (query.length >= 3) {
      setState(() {
        filteredContacts = contacts.where((contact) {
          return contact['name'].toLowerCase().contains(query.toLowerCase()) ||
              contact['identification'].contains(query);
        }).toList();
      });
    } else {
      setState(() {
        filteredContacts = contacts;
      });
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es obligatorio';
    }
    if (value.length < 2 || value.length > 50) {
      return 'El nombre debe tener entre 2 y 50 caracteres';
    }
    final nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegExp.hasMatch(value)) {
      return 'Solo se permiten letras';
    }
    return null;
  }

  String? _validateID(String? value) {
    if (value == null || value.isEmpty) {
      return 'La identificación es obligatoria';
    }
    if (value.length < 6 || value.length > 10) {
      return 'La identificación debe tener entre 6 y 10 dígitos';
    }
    final idRegExp = RegExp(r'^\d+$');
    if (!idRegExp.hasMatch(value)) {
      return 'Solo se permiten números';
    }
    return null;
  }

  void _showAddContactDialog(BuildContext context, int userId) {
    final nameController = TextEditingController();
    final idController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Contacto'),
          content: Form(
            key: _formKey,
            onChanged: () {
              _isButtonEnabled.value = _formKey.currentState!.validate();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: 'Nombre del contacto'),
                  validator: _validateName,
                ),
                TextFormField(
                  controller: idController,
                  decoration:
                      const InputDecoration(labelText: 'Identificación'),
                  keyboardType: TextInputType.number,
                  validator: _validateID,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _isButtonEnabled,
              builder: (context, isEnabled, child) {
                return TextButton(
                  onPressed: isEnabled
                      ? () async {
                          if (_formKey.currentState!.validate()) {
                            await _databaseService.addContact({
                              'name': nameController.text,
                              'identification': idController.text,
                              'user_id': userId,
                            });
                            _loadContacts(userId);
                            Navigator.of(context).pop();
                          }
                        }
                      : null,
                  child: const Text('Guardar'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthProvider>(context).userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis contactos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar contactos...',
                prefixIcon: Icon(Icons.search,
                    color: Theme.of(context).iconTheme.color),
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: Colors.white,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor ??
                    Theme.of(context).cardColor,
              ),
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
        ),
      ),
      body: filteredContacts.isEmpty
          ? const Center(child: Text('Aun no tiene contactos agregados'))
          : ListView.separated(
              itemCount: filteredContacts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredContacts[index]['name']),
                  subtitle: Text(
                      'Documento: ${filteredContacts[index]['identification']}'),
                );
              },
              separatorBuilder: (context, index) => const Divider(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: userId != null
            ? () {
                _showAddContactDialog(context, userId);
              }
            : null,
        child: const Icon(Icons.add),
      ),
    );
  }
}
