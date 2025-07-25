import 'package:flutter/material.dart';
import 'package:kundali_crypt/views/add_vault_item.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../controllers/vault_controller.dart';
import '../models/vault_item.dart';

class VaultView extends StatefulWidget {
  @override
  _VaultViewState createState() => _VaultViewState();
}

class _VaultViewState extends State<VaultView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<VaultController>(
      builder: (context, vaultController, child) {
        return Scaffold(
          backgroundColor: Color(0xFF0A0A0A),
          appBar: AppBar(
            backgroundColor: Color(0xFF1A1A1A),
            title: Row(
              children: [
                Icon(
                  vaultController.isHoneypot ? Icons.warning : Icons.lock,
                  color:
                      vaultController.isHoneypot ? Colors.orange : Colors.green,
                ),
                SizedBox(width: 8),
                Text(
                  vaultController.isHoneypot ? 'Decoy Vault' : 'Secure Vault',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add, color: Colors.white),
                onPressed:
                    vaultController.isHoneypot
                        ? null
                        : () => _showAddItemDialog(context),
              ),
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  vaultController.lockVault();
                  Provider.of<AppController>(
                    context,
                    listen: false,
                  ).resetToPublic();
                },
              ),
            ],
          ),
          body: SafeArea(
            child:
                vaultController.vaultItems.isEmpty
                    ? _buildEmptyState()
                    : _buildVaultItems(vaultController.vaultItems),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.white30),
          SizedBox(height: 16),
          Text(
            'Your vault is empty',
            style: TextStyle(fontSize: 20, color: Colors.white70),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first secure item',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildVaultItems(List<VaultItem> items) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildVaultItemCard(item);
      },
    );
  }

  Widget _buildVaultItemCard(VaultItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getItemTypeColor(item.type),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getItemTypeIcon(item.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          item.content.length > 50
              ? '${item.content.substring(0, 50)}...'
              : item.content,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.white30),
        onTap: () => _showItemDetails(context, item),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => AddVaultItemView()));
  }

  void _showItemDetails(BuildContext context, VaultItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getItemTypeColor(item.type),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getItemTypeIcon(item.type),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.content,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Created: ${item.createdAt.toString().split('.')[0]}',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getItemTypeColor(VaultItemType type) {
    switch (type) {
      case VaultItemType.note:
        return Colors.blueAccent;
      case VaultItemType.password:
        return Colors.redAccent;
      case VaultItemType.file:
        return Colors.teal;
      case VaultItemType.image:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getItemTypeIcon(VaultItemType type) {
    switch (type) {
      case VaultItemType.note:
        return Icons.notes;
      case VaultItemType.password:
        return Icons.vpn_key;
      case VaultItemType.file:
        return Icons.insert_drive_file;
      case VaultItemType.image:
        return Icons.image;
      default:
        return Icons.lock;
    }
  }
}
