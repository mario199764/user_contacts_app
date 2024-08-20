import 'package:flutter/material.dart';
import '../models/contact_model.dart';
import '../services/database_service.dart';

class ContactProvider with ChangeNotifier {
  List<Contact> _contacts = [];
  final DatabaseService _dbService = DatabaseService();

  List<Contact> get contacts => _contacts;

  Future<void> addContact(Contact contact) async {
    await _dbService.addContact(contact.toMap());
  }

  Future<void> updateContact(Contact contact) async {
    if (contact.id != null) {
      await _dbService.updateContact(contact.id!, contact.toMap());
    }
  }

  Future<void> deleteContact(int id) async {
    await _dbService.deleteContact(id);
  }
}
